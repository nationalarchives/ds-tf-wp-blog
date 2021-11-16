#!/bin/bash

# Update yum
sudo yum update -y

# Install apache
sudo yum install -y httpd httpd-tools mod_ssl
sudo systemctl enable httpd
sudo systemctl start httpd

# Install php 7.4
sudo amazon-linux-extras enable php7.4
sudo yum clean metadata
sudo yum install php php-common php-pear -y
sudo yum install php-{cli,cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip,simplexml,gd} -y

# Install mysql5.7
sudo rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
sudo yum install mysql-community-server -y
sudo systemctl enable mysqld
sudo systemctl start mysqld

# Install ImageMagick
sudo yum -y install php-devel gcc ImageMagick ImageMagick-devel
sudo bash -c "yes '' | pecl install -f imagick"
sudo bash -c "echo 'extension=imagick.so' > /etc/php.d/imagick.ini"

sudo systemctl restart php-fpm.service
sudo systemctl restart httpd.service

# Install NFS packages
sudo yum install -y amazon-efs-utils
sudo yum install -y nfs-utils
sudo service nfs start
sudo service nfs status

# Install Cloudwatch agent
sudo yum install amazon-cloudwatch-agent -y
sudo amazon-linux-extras install -y collectd
sudo aws s3 cp s3://${deployment_s3_bucket}/${service}/cloudwatch/cloudwatch-agent-config.json /opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1s

# Install WP CLI
mkdir /build
cd /build
sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
wp cli info
cd /

cd /var/www/html
echo "<html><head><title>Health Check</title></head><body><h1>Hello world!</h1></body></html>" >> healthcheck.html
echo "apache_modules:
  - mod_rewrite" >> wp-cli.yml
if [[ "${environment}" == "live" ]]; then
    echo $"User-agent: *
Disallow: /wp-admin/
Allow: /wp-admin/admin-ajax.php" >> robots.txt
else
    echo $"User-agent: *
Disallow: /" >> robots.txt
    echo "<?php phpinfo() ?>" >> phpinfo.php
fi

# Apache config and unset upgrade to HTTP/2
sudo echo "# file: /etc/httpd/conf.d/wordpress.conf
<VirtualHost *:80>
  Header unset Upgrade
  ServerName ${domain}
  ServerAlias ${domain}
  ServerAdmin webmaster@nationalarchives.gov.uk
  DocumentRoot /var/www/html
  <Directory "/var/www/html">
    Options +FollowSymlinks
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>" >> /etc/httpd/conf.d/wordpress.conf
sudo systemctl restart httpd

# Create .htaccess
sudo echo "# BEGIN WordPress
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %%{REQUEST_FILENAME} !-f
RewriteCond %%{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
# END WordPress
Options All -Indexes" >> /var/www/html/.htaccess

wp core download --allow-root

# Create WP config file
/usr/local/bin/wp config create --dbhost=${db_host} --dbname=${db_name} --dbuser=${db_user} --dbpass="${db_pass}" --allow-root --extra-php <<PHP
/* Turn HTTPS 'on' if HTTP_X_FORWARDED_PROTO matches 'https' */
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) &&  strpos(\$_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false) {
    \$_SERVER['HTTPS'] = 'on';
}
define( 'WP_ENV', '${environment}' );
define( 'PUBLIC_SITEURL', '${domain}' );
define( 'FORCE_SSL_ADMIN', false );
define( 'ADMIN_COOKIE_PATH', '/' );
define( 'COOKIEPATH', '/' );
define( 'SITECOOKIEPATH', '/' );
define( 'COOKIE_DOMAIN', 'nationalarchives.gov.uk' );
define('WP_SITEURL', 'https://${domain}');
define('WP_HOME', 'https://${domain}');
define( 'TNA_CLOUD', false );
define( 'WP_MEMORY_LIMIT', '256M' );
define( 'WP_MAX_MEMORY_LIMIT', '2048M' );
define( 'AS3CF_SETTINGS', serialize( array(
    'bucket' => '${cdn_bucket_name}',
    'provider' => 'aws',
    'region' => '${cdn_aws_region}',
    'use-server-roles' => true,
    'copy-to-s3' => true,
    'serve-from-s3' => true,
    'domain' => 'cloudfront',
    'cloudfront' => '${cdn_cloudfront_url}',
    'enable-object-prefix' => true,
    'object-prefix' => '${cdn_dir}/wp-content/uploads/',
    'force-https' => true,
    'remove-local-file' => true
) ) );
define( 'SMTP_SES', true);
define( 'SMTP_SES_USER', '${ses_user}' );
define( 'SMTP_SES_PASS', '${ses_pass}' );
define( 'SMTP_SES_HOST', '${ses_host}' );
define( 'SMTP_SES_PORT', ${ses_port} );
define( 'SMTP_SES_SECURE', '${ses_secure}' );
define( 'SMTP_SES_FROM_EMAIL', '${ses_from_email}' );
define( 'SMTP_SES_FROM_NAME', '${ses_from_name}' );
if (WP_ENV == 'dev') {
    define( 'WP_DEBUG', true );
    define( 'WP_DEBUG_LOG', true );
    define( 'WP_DEBUG_DISPLAY', false );
}
@ini_set( 'upload_max_size' , '64M' );
@ini_set( 'post_max_size', '128M');
@ini_set( 'memory_limit', '256M' );
PHP

# Reset .htaccess
/usr/local/bin/wp rewrite flush --allow-root 2>>/var/www/html/wp-cli.log

# Install themes
/usr/local/bin/wp theme install https://github.com/nationalarchives/tna-base/archive/refs/heads/master.zip --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp theme install https://github.com/nationalarchives/tna-child-blog/archive/refs/heads/master.zip --force --allow-root 2>/var/www/html/wp-cli.log

# Install plugins
/usr/local/bin/wp plugin install amazon-s3-and-cloudfront --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp plugin install co-authors-plus --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp plugin install wordpress-seo --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp plugin install jquery-colorbox --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp plugin install simple-footnotes --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp plugin install https://github.com/wp-sync-db/wp-sync-db/archive/master.zip --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp plugin install https://github.com/nationalarchives/tna-editorial-review/archive/master.zip --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp plugin install https://github.com/nationalarchives/tna-wp-aws/archive/master.zip --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp plugin install https://github.com/nationalarchives/tna-password-message/archive/master.zip --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp plugin install https://github.com/nationalarchives/ds-tna-wp-ses/archive/refs/heads/main.zip --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp plugin install https://github.com/nationalarchives/ds-cookie-consent/archive/refs/heads/master.zip --force --allow-root 2>/var/www/html/wp-cli.log

# Set file permissions for apache
sudo usermod -a -G apache ec2-user
sudo usermod -a -G apache ssm-user
sudo chown apache:apache /var/www -R
sudo find /var/www -type d -exec chmod 775 {} \;
sudo find /var/www -type f -exec chmod 664 {} \;
sudo systemctl restart httpd
