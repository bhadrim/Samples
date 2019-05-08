#!/bin/bash
LOGFILE="/var/log/install_mariadb.log"
echo "---Install JQ---" >> $LOGFILE
rpm --quiet -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm >> $LOGFILE
yum install -qy jq >> $LOGFILE
echo "---Process input and set to environment variables---" >> $LOGFILE
read query
#echo $query  >> $LOGFILE
for s in $(echo $query | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" ); do
    export $s
done
#USER=$1
#PASSWORD=$2
#HOST=$3
#echo $USER  >> $LOGFILE
#echo $PASSWORD  >> $LOGFILE
#echo $HOST  >> $LOGFILE
retryInstall () {
  n=0
  max=5
  command=$1
  while [ $n -lt $max ]; do
    $command && break
    let n=n+1
    if [ $n -eq $max ]; then
      echo "---Exceed maximal number of retries---" >> $LOGFILE
      exit 1
    fi
    sleep 15
   done
}
echo "---start installing mariaDB---" >> $LOGFILE
retryInstall "yum install -y mariadb mariadb-server"        >> $LOGFILE || { echo "---Failed to install MariaDB---" | tee -a $LOGFILE; exit 1; }
systemctl start mariadb                                     >> $LOGFILE || { echo "---Failed to start MariaDB---" | tee -a $LOGFILE; exit 1; }
systemctl enable mariadb                                    >> $LOGFILE || { echo "---Failed to enable MariaDB---" | tee -a $LOGFILE; exit 1; }
mysql -e "CREATE USER '$USER'@'$HOST' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON * . * TO '$USER'@'$HOST'; FLUSH PRIVILEGES;"  >> $LOGFILE 2>&1 || { echo "---Failed to add user---" | tee -a $LOGFILE; exit 1; }
firewall-cmd --state >> $LOGFILE
if [ $? -eq 0 ] ; then
  firewall-cmd --zone=public --add-port=3306/tcp --permanent  >> $LOGFILE || { echo "---Failed to open port 3306---" | tee -a $LOGFILE; exit 1; }
  firewall-cmd --reload                                       >> $LOGFILE || { echo "---Failed to reload firewall---" | tee -a $LOGFILE; exit 1; }
fi
echo "---finish installing mariaDB---" >> $LOGFILE
echo '{"loglocation":"/var/log/install_mariadb.log","status":"warning"}'
