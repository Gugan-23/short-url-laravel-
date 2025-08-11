# Use official PHP 8.1 FPM Bullseye-based image with more complete source
FROM php:8.1-fpm-bullseye

# Prevent interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Update and upgrade OS packages
RUN apt-get update && apt-get upgrade -y

# Install system dependencies
RUN apt-get install -y --no-install-recommends \
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

# Extract PHP source (needed for building some extensions)
RUN docker-php-source extract

# Configure GD with JPEG and Freetype support
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions (without tokenizer)
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    mbstring \
    xml \
    ctype \
    json \
    bcmath \
    gd \
    zip

# Enable tokenizer explicitly (usually built-in, but just in case)
RUN docker-php-ext-enable tokenizer

# Cleanup PHP source to reduce image size
RUN docker-php-source delete

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files separately to leverage Docker cache
COPY composer.json composer.lock ./

# Install PHP dependencies without dev packages and optimize autoloader
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction --no-scripts

# Copy all application files
COPY . .

# Cache config, routes, views to optimize performance
RUN php artisan config:cache && php artisan route:cache && php artisan view:cache

# Set permissions for Laravel storage and cache directories
RUN chown -R www-data:www-data storage bootstrap/cache

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM process
CMD ["php-fpm"]
