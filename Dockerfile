# Use official PHP 8.1 FPM image
FROM php:8.1-fpm

# Prevent interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and PHP extensions needed for Laravel
RUN apt-get update && apt-get install -y \
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
    && docker-php-ext-install pdo pdo_mysql mbstring tokenizer xml ctype json bcmath gd zip

# Install Composer (latest)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory in container
WORKDIR /var/www/html

# Copy existing application files
COPY . .

# Install PHP dependencies with Composer, optimize for production
RUN composer install --no-dev --optimize-autoloader

# Set permissions (optional, adjust to your needs)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM server
CMD ["php-fpm"]

