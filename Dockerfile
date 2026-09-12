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
        xml

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

COPY . .



FROM php:8.2-fpm AS production

WORKDIR /var/www/html

# Copy PHP extensions/configuration
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Copy required shared libraries from Debian builder
COPY --from=builder /usr/lib/x86_64-linux-gnu/libzip.so* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libpng16.so* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libjpeg.so* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libfreetype.so* /usr/lib/x86_64-linux-gnu/

# Composer dependencies
COPY --from=builder /var/www/html/vendor ./vendor

# Application
COPY . .

CMD ["php-fpm"]
