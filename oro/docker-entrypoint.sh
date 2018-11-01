#!/bin/bash
set -e

nohup service php7.1-fpm restart &

if ! [ -d /var/www ]; then
 mkdir -p /var/www
fi

if ! [ -d /root/.composer ]; then
 mkdir -p /root/.composer
fi

chown -R www-data:www-data /var/www
chown -R www-data:www-data /root/.composer

if ! [ -d $APP_PATH ]; then

    cd $APP_ROOT \
    && git clone -b 1.6 https://github.com/oroinc/orocommerce-application.git $APP_PATH \
    && cd $APP_PATH
    chown -R www-data:www-data $APP_PATH
    composer install --prefer-dist

    cp /parameters.yml $APP_ROOT/parameters_$PRFX.yml &2>1
    mkdir -p $APP_PATH/app/config &2>1
    if [ -f  "$APP_ROOT/parameters_$PRFX.yml" ]; then
    cp $APP_ROOT/parameters_$PRFX.yml $APP_PATH/app/config/parameters.yml
    sed -i -e 's/MYSQL_HOST/'$MYSQL_HOST'/g' $APP_PATH/app/config/parameters.yml
    sed -i -e 's/MYSQL_PORT/'$MYSQL_PORT'/g' $APP_PATH/app/config/parameters.yml
    sed -i -e 's/MYSQL_DATABASE/'$MYSQL_DATABASE'/g' $APP_PATH/app/config/parameters.yml
    sed -i -e 's/MYSQL_USER/'$MYSQL_USER'/g' $APP_PATH/app/config/parameters.yml
    sed -i -e 's/MYSQL_PASSWORD/'$MYSQL_PASSWORD'/g' $APP_PATH/app/config/parameters.yml
    sed -i -e 's/APP_MAILER_TRANSPORT/'$APP_MAILER_TRANSPORT'/g' $APP_PATH/app/config/parameters.yml
    sed -i -e 's/APP_MAILER_HOST/'$APP_MAILER_HOST'/g' $APP_PATH/app/config/parameters.yml
    sed -i -e 's/APP_MAILER_PORT/'$APP_MAILER_PORT'/g' $APP_PATH/app/config/parameters.yml
    sed -i -e 's/APP_MAILER_ENCRYPTION/'$APP_MAILER_ENCRYPTION'/g' $APP_PATH/app/config/parameters.yml
    sed -i -e 's/APP_MAILER_USER/'$APP_MAILER_USER'/g' $APP_PATH/app/config/parameters.yml
    sed -i -e 's/APP_MAILER_PASSWORD/'$APP_MAILER_PASSWORD'/g' $APP_PATH/app/config/parameters.yml
    fi
    echo '---------------------------------------------------'
    env
    echo '---------------------------------------------------'
    chmod -w $APP_PATH/app/config/parameters.yml
    chown www-data:www-data $APP_PATH/app/config/parameters.yml
    chown -R www-data:www-data $APP_PATH
    cd $APP_PATH
    #rm -rf app/cache/* 
    #php ./app/console cache:clear –-env $APP_ENV
    cp $APP_PATH/app/config/parameters.yml.dist $APP_PATH/app/config/parameters.yml.dist.back
    cp $APP_PATH/app/config/parameters.yml $APP_PATH/app/config/parameters.yml.dist
    php ./app/console oro:install --env=$APP_ENV --timeout=$INSTTIME --no-debug --application-url="$APP_URL" \
    --organization-name "$APP_ORG" --user-name="$APP_LOGIN" --user-email="$APP_MAIL" --user-firstname="$APP_UFN" --user-lastname="$APP_ULN" --user-password="$APP_PASS" --sample-data=$APP_DEMO
    chmod +w $APP_PATH/app/config/parameters.yml
    chown -R www-data:www-data $APP_PATH
    cd $APP_PATH && su -m -p -s /bin/bash -c 'php app/console cache:warmup --env=prod' www-data
 fi

    cd $APP_PATH
    chown -R www-data:www-data $APP_PATH
    chown -R www-data:www-data /root/.composer


    cd $APP_PATH
    echo '---------------------------------------------------'
    nohup su -m -p -s /bin/bash -c 'php ./app/console oro:message-queue:consume --env=$APP_ENV' www-data &
    nohup su -m -p -s /bin/bash -c 'php ./app/console clank:server --env=$APP_ENV' www-data &
    nohup su -m -p -s /bin/bash -c 'php ./bin/console oro:message-queue:consume --env=$APP_ENV' www-data &
    nohup su -m -p -s /bin/bash -c 'php ./bin/console gos:websocket:server --env=$APP_ENV' www-data &

/usr/bin/tail -f /dev/null

exec "$@"