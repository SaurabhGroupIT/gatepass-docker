FROM php:8.2-fpm-alpine AS builder

RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        libzip-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        oniguruma-dev \
        libxml2-dev \
        curl-dev \
        unzip \
        git

RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg

RUN docker-php-ext-install -j"$(nproc)" \
        gd \
        zip \
        mbstring \
        mysqli \
        curl \
        xml

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock* ./

RUN composer install \
        --no-dev \
        --no-interaction \
        --prefer-dist \
        --no-progress \
        --optimize-autoloader

COPY . .

FROM php:8.2-fpm-alpine AS production

RUN apk add --no-cache \
        libzip \
        libpng \
        libjpeg-turbo \
        freetype \
        oniguruma \
        libxml2 \
        libcurl

WORKDIR /var/www/html

COPY --from=builder \
    /usr/local/lib/php/extensions/ \
    /usr/local/lib/php/extensions/

COPY --from=builder \
    /usr/local/etc/php/conf.d/ \
    /usr/local/etc/php/conf.d/

COPY --from=builder \
    /var/www/html/vendor \
    ./vendor

CMD ["php-fpm"]
