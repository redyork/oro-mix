#!/bin/bash

set -e

if [ -d $APP_PATH ]; then

    echo '-----------------------------------------------------------------------'
    echo '-----------------------------------------------------------------------'
    echo '------------------------- VERSION 3.0 ---------------------------------'
    echo '-----------------------------------------------------------------------'
    echo '-----------------------------------------------------------------------'

    cd $APP_PATH
    rm -rf app/cache/prod
    rm -rf var/cache/ &2>1
    rm -rf $APP_ROOT/new &2>1
    git checkout 3.0 &2>1
    echo '-----------------------------------------------------------------------'
    cd $APP_ROOT
    git clone -b 3.0 https://github.com/oroinc/orocommerce-application.git new &2>1 
    echo '-----------------------------------------------------------------------'
    rsync -av ./new/ $APP_PATH
    echo '-----------------------------------------------------------------------'
    cp $APP_PATH/app/config/parameters.yml $APP_PATH/config/parameters.yml
    cd $APP_PATH
    #composer update
    composer install --prefer-dist --no-dev
    echo '-----------------------------------------------------------------------'
    #chown www-data:www-data -R ./*
    echo '-----------------------------------------------------------------------'
    rm -rf app/cache/prod
    php bin/console oro:platform:update --env=prod --force --timeout=0 -vv

    echo '-----------------------------------------------------------------------'
    echo '-----------------------------------------------------------------------'
    echo '------------------------- VERSION 3.1 ---------------------------------'
    echo '-----------------------------------------------------------------------'
    echo '-----------------------------------------------------------------------'

    rm -rf app/cache/prod
    rm -rf var/cache/ &2>1
    rm -rf $APP_ROOT/new &2>1
    git checkout 3.1 &2>1 && \
    echo '-----------------------------------------------------------------------'
    cd $APP_ROOT
    git clone -b 3.1 https://github.com/oroinc/orocommerce-application.git new &2>1 && \
    echo '-----------------------------------------------------------------------'
    rsync -av ./new/ $APP_PATH
    echo '-----------------------------------------------------------------------'
    cp $APP_PATH/app/config/parameters.yml $APP_PATH/config/parameters.yml
    cd $APP_PATH
    composer install --prefer-dist --no-dev
    echo '-----------------------------------------------------------------------'
    #chown www-data:www-data -R ./*
    echo '-----------------------------------------------------------------------'
    rm -rf app/cache/prod
    php bin/console oro:platform:update --env=prod --force --timeout=0 -vv



    #nohup php ./app/console oro:message-queue:consume --env=$APP_ENV &

fi

