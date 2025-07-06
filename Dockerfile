FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    icu-dev \
    unzip \
    git \
    bash \
    && docker-php-ext-configure gd \
        --with-freetype=/usr/include/ \
        --with-jpeg=/usr/include/ \
    && docker-php-ext-install \
        gd \
        zip \
        exif \
        intl \
        mysqli \
        pdo \
        pdo_mysql \
        bcmath \
        mbstring \
        xml

# Install Composer globally from Composer image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory and install PHP dependencies
WORKDIR /var/www/html
COPY composer.json composer.lock* ./
RUN composer install --no-dev --no-interaction --prefer-dist

CMD ["php-fpm"]
