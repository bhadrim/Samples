#!/bin/bash
LOGFILE="/var/log/install_mariadb.log"
USER=$1
PASSWORD=$2
HOST=$3
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
echo "---start installing mariaDB---" | tee -a $LOGFILE 2>&1
retryInstall "yum install -y mariadb mariadb-server"        >> $LOGFILE 2>&1 || { echo "---Failed to install MariaDB---" | tee -a $LOGFILE; exit 1; }
systemctl start mariadb                                     >> $LOGFILE 2>&1 || { echo "---Failed to start MariaDB---" | tee -a $LOGFILE; exit 1; }
systemctl enable mariadb                                    >> $LOGFILE 2>&1 || { echo "---Failed to enable MariaDB---" | tee -a $LOGFILE; exit 1; }
mysql -e "CREATE USER '$USER'@'$HOST' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON * . * TO '$USER'@'$HOST'; FLUSH PRIVILEGES;"  >> $LOGFILE 2>&1 || { echo "---Failed to add user---" | tee -a $LOGFILE; exit 1; }
firewall-cmd --state >> $LOGFILE 2>&1
if [ $? -eq 0 ] ; then
  firewall-cmd --zone=public --add-port=3306/tcp --permanent  >> $LOGFILE 2>&1 || { echo "---Failed to open port 3306---" | tee -a $LOGFILE; exit 1; }
  firewall-cmd --reload                                       >> $LOGFILE 2>&1 || { echo "---Failed to reload firewall---" | tee -a $LOGFILE; exit 1; }
fi
echo "---finish installing mariaDB---" | tee -a $LOGFILE 2>&1
echo '{"status":"success"}'
