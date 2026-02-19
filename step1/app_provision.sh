#!/bin/bash

PRIVATE_IP="10.0.2.15"
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}
APP_USER=${APP_USER:-appuser}
PROJECT_DIR=${PROJECT_DIR:-/home/$APP_USER/project}
APP_DIR=${APP_DIR:-/home/$APP_USER/app}
if ! id -u $APP_USER >/dev/null 2>&1; then

    adduser --disabled-password --gecos "" $APP_USER
fi

apt-get update -y
apt-get install -y openjdk-17-jdk git unzip
if [ ! -d "$PROJECT_DIR" ]; then
    sudo -u $APP_USER git clone https://github.com/spring-projects/spring-petclinic.git $PROJECT_DIR
else
    cd $PROJECT_DIR
    sudo -u $APP_USER git pull
fi
cd $PROJECT_DIR
sudo -u $APP_USER ./mvnw clean package
mkdir -p $APP_DIR
JAR_FILE=$(ls target/*.jar | head -n 1)
if [ -f "$JAR_FILE" ]; then
    cp $JAR_FILE $APP_DIR/
    chown -R $APP_USER:$APP_USER $APP_DIR
else
    echo "ERROR: JAR file not found!"
    exit 1
fi
ENV_FILE="/home/$APP_USER/.bash_profile"
echo "Exporting environment variables..."
{
    echo "export DB_HOST=$DB_HOST"
    echo "export DB_PORT=$DB_PORT"
    echo "export DB_NAME=$DB_NAME"
    echo "export DB_USER=$DB_USER"
    echo "export DB_PASS=$DB_PASS"
} >> $ENV_FILE
chown $APP_USER:$APP_USER $ENV_FILE

sudo -u $APP_USER bash -c "cd $APP_DIR && java -jar $(basename $JAR_FILE) &"
