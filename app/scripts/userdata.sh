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
echo "Custom Apache config and unset upgrade to HTTP/2"
sudo systemctl restart httpd

wp config create --dbhost=${db_host} --dbname=${db_name} --dbuser=${db_user} --dbpass=${db_pass} --allow-root --extra-php <<PHP
define( 'TNA_CLOUD', false );
define( 'WP_MEMORY_LIMIT', '256M' );
define( 'WP_MAX_MEMORY_LIMIT', '2048M' );
define( 'AS3CF_AWS_USE_EC2_IAM_ROLE', true );
define( 'AS3CF_SETTINGS', serialize( array(
    'bucket' => ${cdn_bucket_name},
    'provider' => 'aws',
    'use-server-roles' => true,
    'copy-to-s3' => true,
    'serve-from-s3' => true,
    'domain' => 'cloudfront',
    'cloudfront' => ${cdn_cloudfront_url},
    'enable-object-prefix' => true,
    'object-prefix' => '${cdn_dir}/wp-content/uploads/',
    'force-https' => true,
    'remove-local-file' => true
) ) );
define( 'WPMS_ON', true );
define( 'WPMS_SMTP_PASS', ${wpms_smtp_password} );
@ini_set( 'upload_max_size' , '64M' );
@ini_set( 'post_max_size', '128M');
@ini_set( 'memory_limit', '256M' );
PHP

# Reset .htaccess
wp rewrite flush --allow-root
