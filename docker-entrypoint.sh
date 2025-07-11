#!/bin/bash
set -e

# Attendre que la base de données soit prête
echo "Waiting for database connection..."
while ! mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
    sleep 1
done
echo "Database is ready!"

# Créer le lien symbolique pour lmutil si le fichier existe
if [ -f /opt/lmtools/lmutil ]; then
    ln -sf /opt/lmtools/lmutil /usr/local/bin/lmutil
    chmod +x /opt/lmtools/lmutil
    echo "lmutil linked successfully"
fi

# Créer le répertoire de cache s'il n'existe pas
mkdir -p /var/cache/phplw/
chown www-data:www-data /var/cache/phplw/

# Démarrer cron
service cron start

# Démarrer Apache au premier plan
exec apache2ctl -D FOREGROUND
