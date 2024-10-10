# Base image
FROM php:8.1-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    vim \
    curl \
    default-mysql-client \
    libzip-dev \
    libonig-dev \
    libpng-dev \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install Composer (PHP package manager)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Copy your PHP application files to the container
COPY . /var/www/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Grant execute permissions for directories and read permissions for files
RUN chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
