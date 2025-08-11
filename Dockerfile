FROM php:8.1-fpm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    libzip-dev \
    autoconf \
    pkg-config \
    libssl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP source for extensions
RUN docker-php-source extract

# Configure GD before extension install
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    mbstring \
    tokenizer \
    xml \
    ctype \
    json \
    bcmath \
    gd \
    zip

# Cleanup PHP source after build
RUN docker-php-source delete

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction --no-scripts

COPY . .

RUN php artisan config:cache && php artisan route:cache && php artisan view:cache

RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]
