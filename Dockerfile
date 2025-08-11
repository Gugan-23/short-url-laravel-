# Use official PHP 8.1 FPM Bullseye-based image
FROM php:8.1-fpm-bullseye

# Avoid interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Extract PHP source for building extensions
RUN docker-php-source extract

# Configure GD extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions
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

# Enable tokenizer (usually built-in, but safe to include)
RUN docker-php-ext-enable tokenizer

# Remove PHP source to reduce image size
RUN docker-php-source delete

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files first to leverage Docker cache
COPY composer.json composer.lock ./

# Install PHP dependencies (production only)
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

# Copy application files
COPY . .

# Cache Laravel config, routes, and views
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Set proper permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
