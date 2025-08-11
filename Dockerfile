# Use official PHP 8.1 FPM image
FROM php:8.1-fpm

# Prevent interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and PHP extensions needed for Laravel
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring tokenizer xml ctype json bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer (latest) globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory in container
WORKDIR /var/www/html

# Copy composer files first to leverage Docker cache
COPY composer.json composer.lock ./

# Install PHP dependencies with Composer, optimize for production
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction --no-scripts

# Copy the rest of the application files
COPY . .

# Run post-install scripts and cache clearing (if needed)
RUN composer dump-autoload -o \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Set permissions on storage and bootstrap/cache
RUN chown -R www-data:www-data storage bootstrap/cache

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM server
CMD ["php-fpm"]
