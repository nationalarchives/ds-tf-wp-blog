#!/bin/bash

# Update yum
sudo yum update -y

# Create mount directory and set file permissions
sudo mkdir -p ${mount_dir}
sudo chown -R apache:apache ${mount_dir}
sudo chmod 2775 ${mount_dir} && find ${mount_dir} -type d -exec sudo chmod 2775 {} \;
sudo find ${mount_dir} -type f -exec sudo chmod 0664 {} \;

# Mount EFS storage
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${mount_target}:/ ${mount_dir}

# Auto mount EFS storage on reboot
sudo echo "${mount_target}:/ ${mount_dir} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,fsc,_netdev 0 0" >> /etc/fstab

# Link uploads directory to EFS mount
sudo mkdir -p /mnt/efs/uploads
# sudo rm -rf /var/www/html/wp-content/uploads
sudo ln -snf /mnt/efs/uploads /var/www/html/wp-content/uploads

sudo systemctl restart httpd
