
FROM saqing/php5-nginx
## install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
      && php composer-setup.php \
      && php -r "unlink('composer-setup.php');" \
      && mv composer.phar /usr/local/bin/composer

## install pdo_mysql ext
RUN docker-php-ext-install pdo_mysql

## install pcntl ext
RUN docker-php-ext-install pcntl

## install gd ext
RUN apk add --no-cache libpng libpng-dev && docker-php-ext-install gd && apk del libpng-dev

## install zip ext
RUN apk add --no-cache zlib-dev && docker-php-ext-install zip && apk del zlib-dev

## install ldap ext
RUN apk add --no-cache --virtual .persistent-deps \
        ca-certificates \
        openldap-dev \
        curl \
        tar \
        xz \
    && docker-php-ext-configure ldap --with-libdir=lib/ \
    && docker-php-ext-install ldap

## install redis ext
ENV PHPREDIS_VERSION 3.1.6
RUN docker-php-source extract \
    && curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis \
    && docker-php-source delete

## install mongodb ext
ENV MONGODB_VERSION 1.4.3
RUN docker-php-source extract \
    && curl -L -o /tmp/mongo.tgz  https://pecl.php.net/get/mongodb-$MONGODB_VERSION.tgz \
    && tar zxvf /tmp/mongo.tgz \
    && rm -r /tmp/mongo.tgz \
    && mv mongodb-$MONGODB_VERSION /usr/src/php/ext/mongodb \
    && docker-php-ext-install mongodb \
    && docker-php-source delete
