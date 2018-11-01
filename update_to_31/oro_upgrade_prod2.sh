#!/bin/bash

set -e

#ps aux |grep 'su -m -p'|awk '{print $2}'|xargs -I% kill % &2>1

if [ -d $APP_PATH ]; then
    echo '-----------------------------------------------------------------------'
    echo '-----------------------------------------------------------------------'
    echo '------------------------- VERSION 3.1 ---------------------------------'
    echo '-----------------------------------------------------------------------'
    echo '-----------------------------------------------------------------------'
    rm -rf $APP_ROOT/new &2>1
    rmdir $APP_ROOT/new &2>1
    rm -rf app/cache/prod &2>1
    rm -rf var/cache/ &2>1
    cd $APP_PATH
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
 # -------------- UPDATE ERROR FIX -------------------------------------------------------------------
 cp -ar $APP_ROOT/_fix/fullcalendar/dist $APP_PATH/public/bundles/bowerassets/fullcalendar/
 cp -ar $APP_ROOT/_fix/jquery-validate/dist $APP_PATH/public/bundles/bowerassets/jquery-validate/
 # ---------------------------------------------------------------------------------------------------
    cd $APP_PATH
    php bin/console oro:platform:update --env=prod --force --timeout=0 -vv
 # -------------- UPDATE ERROR FIX -------------------------------------------------------------------
 cd $APP_PATH
 grep -ri ' @setBlockTheme' ./ | grep -v 'var/cache' | grep '.yml' | awk -F':' '{print $1}' | xargs -I% sed -i -e "s/\ @setBlockTheme/\ \'@setBlockTheme\'/g" %
 # ---------------------------------------------------------------------------------------------------

fi

