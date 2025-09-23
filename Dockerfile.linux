# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# Ajout des arguments automatiques de buildx
ARG TARGETPLATFORM
ARG TARGETOS  
ARG TARGETARCH
ARG BUILDPLATFORM

ENV DEBIAN_FRONTEND=noninteractive

# Affichage des informations de build pour debug
RUN echo "Building for platform: $TARGETPLATFORM on $BUILDPLATFORM"

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

# Créer les répertoires nécessaires avec logique conditionnelle selon l'architecture
RUN mkdir -p /opt/lmtools/ \
    && mkdir -p /var/cache/phplw/ \
    && mkdir -p /usr/local/bin/ \
    && chown www-data:www-data /var/cache/phplw/ \
    && chmod 755 /opt/lmtools/ \
    && chmod 755 /var/cache/phplw/ \
    && case ${TARGETPLATFORM} in \
         "linux/amd64") echo "Optimisation pour x86_64" ;; \
         "linux/arm64") echo "Optimisation pour ARM64" ;; \
         "linux/arm/v7") echo "Optimisation pour ARMv7" ;; \
         "linux/ppc64le") echo "Optimisation pour PowerPC" ;; \
         "linux/s390x") echo "Optimisation pour IBM Z" ;; \
         *) echo "Architecture standard: ${TARGETPLATFORM}" ;; \
    esac

WORKDIR /var/www/html

# Installation Composer avec gestion multi-arch
RUN if [ -f composer.json ]; then \
        # Optimisations spécifiques par architecture si nécessaire
        case ${TARGETARCH} in \
            "amd64") composer install --no-dev --optimize-autoloader ;; \
            "arm64") composer install --no-dev --optimize-autoloader --no-scripts ;; \
            "arm") composer install --no-dev --optimize-autoloader --no-scripts ;; \
            *) composer install --no-dev --optimize-autoloader ;; \
        esac; \
    fi

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

# Configuration du cron avec gestion des différences d'architecture
RUN echo '*/15 * * * * www-data php /var/www/html/license_util.php >> /dev/null 2>&1' >> /etc/crontab \
    && echo '15 0 * * 1 www-data php /var/www/html/license_cache.php >> /dev/null 2>&1' >> /etc/crontab \
    && echo '0 6 * * 1 www-data php /var/www/html/license_alert.php >> /dev/null 2>&1' >> /etc/crontab \
    && case ${TARGETARCH} in \
         "arm"|"arm64") echo "# ARM architecture detected - using lighter cron config" >> /etc/crontab ;; \
         *) echo "# Standard architecture cron config" >> /etc/crontab ;; \
    esac

# Utiliser votre script existant
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Ajout de métadonnées pour identifier l'architecture du conteneur
LABEL org.opencontainers.image.architecture="${TARGETARCH}"
LABEL org.opencontainers.image.platform="${TARGETPLATFORM}"

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
