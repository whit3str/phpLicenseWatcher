FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    apache2 \
    php8.1 \
    php8.1-mysql \
    php8.1-gd \
    php8.1-curl \
    php8.1-xml \
    php8.1-mbstring \
    php8.1-zip \
    php8.1-cli \
    mariadb-client \
    composer \
    cron \
    lsb-core \
    wget \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite && a2enmod ssl

COPY . /var/www/html/
RUN rm -f /var/www/html/index.html
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R 755 /var/www/html/

RUN mkdir -p /opt/lmtools/ /var/cache/phplw/ /usr/local/bin/
RUN chown www-data:www-data /var/cache/phplw/
RUN chmod 755 /opt/lmtools/ /var/cache/phplw/

WORKDIR /var/www/html
RUN if [ -f composer.json ]; then composer install --no-dev --optimize-autoloader; fi

RUN echo '<VirtualHost *:80>\n\
    ServerName localhost\n\
    DocumentRoot /var/www/html\n\
    DirectoryIndex index.php index.html\n\
    <Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
        Options Indexes FollowSymLinks\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

RUN echo '*/15 * * * * www-data php /var/www/html/license_util.php >> /dev/null 2>&1' >> /etc/crontab \
    && echo '15 0 * * 1 www-data php /var/www/html/license_cache.php >> /dev/null 2>&1' >> /etc/crontab \
    && echo '0 6 * * 1 www-data php /var/www/html/license_alert.php >> /dev/null 2>&1' >> /etc/crontab

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
