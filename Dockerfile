FROM php:8.2-fpm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
        libzip-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        unzip \
        git \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        gd \
        zip \
        mbstring \
        mysqli \
        xml \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock* ./

RUN composer install \
        --no-dev \
        --no-interaction \
        --prefer-dist \
        --no-progress \
        --optimize-autoloader \
        --no-scripts


FROM php:8.2-fpm AS production

RUN apt-get update && apt-get install -y --no-install-recommends \
        libzip4 \
        libpng16-16 \
        libjpeg62-turbo \
        libfreetype6 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

WORKDIR /var/www/html

COPY --from=builder /var/www/html/vendor ./vendor

# Your application
COPY . .

CMD ["php-fpm"]
