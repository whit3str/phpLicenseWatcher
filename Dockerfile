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

RUN a2enmod rewrite
RUN a2enmod ssl

# Copier les fichiers de l'application
COPY . /var/www/html/

# SUPPRIMER LE FICHIER INDEX.HTML QUI INTERFÈRE
RUN rm -f /var/www/html/index.html

# Définir les permissions appropriées
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R 755 /var/www/html/

# Créer les répertoires nécessaires
RUN mkdir -p /opt/lmtools/ \
    && mkdir -p /var/cache/phplw/ \
    && mkdir -p /usr/local/bin/ \
    && chown www-data:www-data /var/cache/phplw/ \
    && chmod 755 /opt/lmtools/ \
    && chmod 755 /var/cache/phplw/

WORKDIR /var/www/html
RUN if [ -f composer.json ]; then composer install --no-dev --optimize-autoloader; fi

# Configuration d'Apache pour prioriser index.php
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

# Configuration du cron
RUN echo '*/15 * * * * www-data php /var/www/html/license_util.php >> /dev/null 2>&1' >> /etc/crontab \
    && echo '15 0 * * 1 www-data php /var/www/html/license_cache.php >> /dev/null 2>&1' >> /etc/crontab \
    && echo '0 6 * * 1 www-data php /var/www/html/license_alert.php >> /dev/null 2>&1' >> /etc/crontab

# Utiliser votre script existant
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
