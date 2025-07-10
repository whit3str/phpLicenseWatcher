#!/bin/bash
set -e

# Démarrer le service cron
service cron start

# Vérifier si le fichier de configuration existe
if [ ! -f /var/www/html/config.php ]; then
    echo "Configuration file not found. Please mount your config.php file."
    echo "Example: docker run -v /path/to/your/config.php:/var/www/html/config.php ..."
fi

# Attendre que la base de données soit disponible si DB_HOST est défini
if [ ! -z "$DB_HOST" ]; then
    echo "Waiting for database connection..."
    while ! mysqladmin ping -h"$DB_HOST" -P"${DB_PORT:-3306}" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
        sleep 1
    done
    echo "Database is ready!"
fi

# Exécuter la commande par défaut
exec "$@"
