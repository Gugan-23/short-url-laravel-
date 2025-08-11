# ----------------------------------------
# Stage 1: Base PHP with Composer & Node
# ----------------------------------------
FROM php:8.1-fpm-bullseye AS base

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    libssl-dev \
    pkg-config \
    autoconf \
    nano \
    # Node.js (for Vite or Laravel Mix)
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
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

# Cleanup PHP source
RUN docker-php-source delete

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ----------------------------------------
# Stage 2: Laravel Application Setup
# ----------------------------------------
FROM base AS app

WORKDIR /var/www/html

# Copy Laravel composer files first for caching
COPY composer.json composer.lock ./

# Install PHP dependencies (production only)
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

# Copy Node package files
COPY package.json package-lock.json ./

# Install Node dependencies and build assets
RUN npm install && npm run build

# Copy full Laravel application
COPY . .

# Cache Laravel config, routes, views
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Set permissions for storage and cache
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
