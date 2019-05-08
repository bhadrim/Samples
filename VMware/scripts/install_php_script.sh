#!/bin/bash
LOGFILE="/var/log/install_php.log"
PHP_HOST=$1
MYSQL_HOST=$2
MYSQL_USER=$3
MYSQL_PWD=$4
retryInstall () {
  n=0
  max=5
  command=$1
  while [ $n -lt $max ]; do
    $command && break
    let n=n+1
    if [ $n -eq $max ]; then
      echo "---Exceed maximal number of retries---"
      exit 1
    fi
    sleep 15
   done
}
echo "---start installing apache---" >> tee -a $LOGFILE
retryInstall "yum install -y httpd"                       >> $LOGFILE || { echo "---Failed to install apache---" | tee -a $LOGFILE; exit 1; }
systemctl start httpd                                     >> $LOGFILE || { echo "---Failed to start apache---" | tee -a $LOGFILE; exit 1; }
systemctl enable httpd                                    >> $LOGFILE || { echo "---Failed to enable apache---" | tee -a $LOGFILE; exit 1; }
firewall-cmd --state >> $LOGFILE 
if [ $? -eq 0 ] ; then
  firewall-cmd --zone=public --add-port=80/tcp --permanent  >> $LOGFILE || { echo "---Failed to open port 80---" | tee -a $LOGFILE; exit 1; }
  firewall-cmd --reload                                     >> $LOGFILE || { echo "---Failed to reload firewall---" | tee -a $LOGFILE; exit 1; }
fi
mkdir -p /var/www/html/$PHP_HOST/public_html              >> $LOGFILE || { echo "---Failed to create directory for web pages---" | tee -a $LOGFILE; exit 1; }
mkdir -p /var/log/httpd/$PHP_HOST/logs                    >> $LOGFILE || { echo "---Failed to create directory for apache logs---" | tee -a $LOGFILE; exit 1; }
cat << EOT > /etc/httpd/conf.d/virtualHost.conf
<Directory /var/www/html/$PHP_HOST/public_html>
    Require all granted
</Directory>
<VirtualHost *:80>
        ServerName $PHP_HOST
        ServerAdmin camadmin@localhost
        DocumentRoot /var/www/html/$PHP_HOST/public_html
        ErrorLog /var/log/httpd/$PHP_HOST/logs/error.log
        CustomLog /var/log/httpd/$PHP_HOST/logs/access.log combined
</VirtualHost>
EOT
systemctl restart httpd                                   >> $LOGFILE || { echo "---Failed to restart apache---" | tee -a $LOGFILE; exit 1; }
echo "---finish installing apache---" >> tee -a $LOGFILE  
echo "---start installing php---" >> tee -a $LOGFILE  
retryInstall "yum install -y php php-mysql php-gd php-pear"  >> $LOGFILE || { echo "---Failed to install php---" | tee -a $LOGFILE; exit 1; }
cat << EOT > /var/www/html/$PHP_HOST/public_html/test.php
<html>
<head>
    <title>PHP Test</title>
</head>
    <body>
    <?php echo '<p>Thanks for trying the CAM Lamp stack starter pack</p>';
    // In the variables section below, replace user and password with your own MariaDB credentials as created on your server
    \$servername = "$MYSQL_HOST";
    \$username = "$MYSQL_USER";
    \$password = "$MYSQL_PWD";
    // Create MySQL connection
    \$conn = mysqli_connect(\$servername, \$username, \$password);
    // Check connection - if it fails, output will include the error message
    if (!\$conn) {
        die('<p>Connection failed: <p>' . mysqli_connect_error());
    }
    echo '<p>Connected successfully to MariaDB</p>';
    echo '<p>If you would like more information on IBM\'s cloud management products, checkout this <a href="https://www.ibm.com/cloud-computing/products/cloud-management/">link</a></p>';
    ?>
</body>
</html>
EOT
sestatus | grep 'enabled' >> $LOGFILE 
if [ $? == 0 ]; then
   setsebool -P httpd_can_network_connect=1                  >> $LOGFILE || { echo "---Failed to change SELinux permission---" | tee -a $LOGFILE; exit 1; }
fi
systemctl restart httpd                                   >> $LOGFILE || { echo "---Failed to restart apache---" | tee -a $LOGFILE; exit 1; }
echo "---finish installing php---" >> tee -a $LOGFILE 
logvalue=$(</var/log/install_php.log)
echo $logvalue
