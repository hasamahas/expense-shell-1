#!/bin/bash

USERID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
echo "Enter MySQL db password:"
read -s mysql_root_password
VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Insstalling nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then 
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating user expense"
else
    echo -e "expense user already created... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating the app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracting backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installiing nodejs dependencies "

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied Backend Service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Validaged daemon-realod "
systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend "
systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend "

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql client"

mysql -h db.hasamahas.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend"










