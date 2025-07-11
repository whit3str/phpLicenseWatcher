FROM ubuntu:22.04

# Éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive

# Installation des dépendances système (MariaDB client au lieu de MySQL)
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

# Configuration d'Apache
RUN a2enmod rewrite
RUN a2enmod ssl

# Copier les fichiers de l'application
COPY . /var/www/html/

# Définir les permissions appropriées
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R 755 /var/www/html/

# Créer les répertoires nécessaires
RUN mkdir -p /opt/lmtools/
RUN mkdir -p /var/cache/phplw/
RUN mkdir -p /usr/local/bin/
RUN chown www-data:www-data /var/cache/phplw/
RUN chmod 755 /opt/lmtools/
RUN chmod 755 /var/cache/phplw/

# Installation des dépendances PHP avec Composer (si composer.json existe)
WORKDIR /var/www/html
RUN if [ -f composer.json ]; then composer install --no-dev --optimize-autoloader; fi

# Configuration d'Apache pour phpLicenseWatcher avec ServerName
RUN echo '<VirtualHost *:80>\n\
    ServerName localhost\n\
    DocumentRoot /var/www/html\n\
    DirectoryIndex index.php\n\
    <Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Configuration du cron pour les tâches planifiées (adapté à l'intervalle de 15 minutes)
RUN echo '*/15 * * * * www-data php /var/www/html/license_util.php >> /dev/null 2>&1' >> /etc/crontab
RUN echo '15 0 * * 1 www-data php /var/www/html/license_cache.php >> /dev/null 2>&1' >> /etc/crontab
RUN echo '0 6 * * 1 www-data php /var/www/html/license_alert.php >> /dev/null 2>&1' >> /etc/crontab

# Script de démarrage amélioré
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Exposition du port
EXPOSE 80

# Point d'entrée
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
