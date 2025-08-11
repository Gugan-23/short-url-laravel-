FROM php:8.1-fpm-bullseye

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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Extract PHP source for building extensions
RUN docker-php-source extract

# Configure and install extensions one-by-one to isolate errors
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install xml
RUN docker-php-ext-install ctype
RUN docker-php-ext-install json
RUN docker-php-ext-install bcmath

# Configure and install GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

# Configure and install ZIP
RUN docker-php-ext-configure zip \
    && docker-php-ext-install zip

# Cleanup PHP source
RUN docker-php-source delete

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy Laravel files
COPY . .

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
