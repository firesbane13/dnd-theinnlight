FROM php:8.5-apache

# Laravel's public/.htaccess sends every request through index.php.
RUN a2enmod rewrite \
    && echo 'ServerName localhost' >> /etc/apache2/apache2.conf

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libzip-dev \
        libicu-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && for ext in bcmath exif gd intl pdo_mysql zip; do \
        docker-php-ext-install "$ext"; \
    done \
    && rm -rf /var/lib/apt/lists/*

# Composer writes vendor/ onto the host mount. Nothing is installed at build time.
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY docker/php/dev.ini /usr/local/etc/php/conf.d/zz-dev.ini
COPY docker/entrypoint.sh /usr/local/bin/innlight-entrypoint
RUN chmod +x /usr/local/bin/innlight-entrypoint

WORKDIR /var/www/html

ENTRYPOINT ["innlight-entrypoint"]
CMD ["apache2-foreground"]
