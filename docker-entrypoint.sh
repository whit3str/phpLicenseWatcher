#!/bin/bash
set -e

# Corriger les permissions du fichier config.php
if [ -f /var/www/html/config.php ]; then
    chown www-data:www-data /var/www/html/config.php
    chmod 644 /var/www/html/config.php
    echo "config.php permissions fixed"
fi

# Attendre que la base de données soit prête avec retry
echo "Waiting for database connection..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" --silent 2>/dev/null; then
        echo "Database is ready!"
        break
    else
        echo "Attempt $attempt/$max_attempts: Database not ready, waiting..."
        sleep 2
        attempt=$((attempt + 1))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "ERROR: Could not connect to database after $max_attempts attempts"
    exit 1
fi

# Créer le lien symbolique pour lmutil si le fichier existe
if [ -f /opt/lmtools/lmutil ]; then
    ln -sf /opt/lmtools/lmutil /usr/local/bin/lmutil
    chmod +x /opt/lmtools/lmutil 2>/dev/null || echo "Warning: Cannot change permissions on read-only volume"
    echo "lmutil linked successfully"
fi

# Créer le répertoire de cache s'il n'existe pas
mkdir -p /var/cache/phplw/
chown www-data:www-data /var/cache/phplw/

# Démarrer cron
service cron start

# Démarrer Apache au premier plan
exec apache2ctl -D FOREGROUND
