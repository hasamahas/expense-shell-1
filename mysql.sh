#!/bin/bash

source ./common.sh

check_root

echo "Please enter db password:"
read -s mysql_root_password

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySQL server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "start  MySQL server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySQL server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting up root password"
 mysql -h db.hasamahas.site -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE

 if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "Mysql root password setup"
else
    echo -e "Mysql root password is already setup... $Y SKIPPING $N "

fi







