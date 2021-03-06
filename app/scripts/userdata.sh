#!/bin/bash

# Update yum
sudo yum update -y

# Mount EFS storage
sudo mkdir -p ${mount_dir}
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${mount_target}:/ ${mount_dir}
sudo chmod 777 ${mount_dir}
cd ${mount_dir}
sudo chmod go+rw .
sudo ln -s /var/www/html ${mount_dir}
cd /

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

cd /var/www/html

# Create .htaccess
sudo echo "# BEGIN WordPress
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %%{REQUEST_FILENAME} !-f
RewriteCond %%{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
# END WordPress" >> .htaccess

# Create WP config file
/usr/local/bin/wp config create --dbhost=${db_host} --dbname=${db_name} --dbuser=${db_user} --dbpass=${db_pass} --allow-root --extra-php <<PHP
/** Detect if SSL is used. This is required since we are terminating SSL either on CloudFront or on ELB */
if ((\$_SERVER['HTTP_CLOUDFRONT_FORWARDED_PROTO'] == 'https') OR (\$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https'))
    {\$_SERVER['HTTPS']='on';}
define('WP_SITEURL', 'https://${domain}');
define('WP_HOME', 'https://${domain}');
define( 'TNA_CLOUD', false );
define( 'WP_MEMORY_LIMIT', '256M' );
define( 'WP_MAX_MEMORY_LIMIT', '2048M' );
define( 'AS3CF_AWS_USE_EC2_IAM_ROLE', true );
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
@ini_set( 'upload_max_size' , '64M' );
@ini_set( 'post_max_size', '128M');
@ini_set( 'memory_limit', '256M' );
PHP

# Reset .htaccess
/usr/local/bin/wp rewrite flush --allow-root 2>/var/www/html/wp-cli.log

# Install themes and plugins
/usr/local/bin/wp theme install https://github.com/nationalarchives/tna-base/archive/refs/heads/master.zip --force --allow-root 2>/var/www/html/wp-cli.log
/usr/local/bin/wp theme install https://github.com/nationalarchives/tna-child-blog/archive/refs/heads/master.zip --force --allow-root 2>/var/www/html/wp-cli.log
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
sudo chown apache:apache /var/www/html -R
find /var/www/html -type d -exec chmod 775 {} \;
find /var/www/html -type f -exec chmod 664 {} \;
sudo systemctl restart httpd
