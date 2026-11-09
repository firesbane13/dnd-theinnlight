#!/bin/sh
set -e

# The project is a host bind mount. Apache workers run as www-data.
# Match that user to the mount owner so storage/ and bootstrap/cache are writable
# and new files stay owned by the host account. Skip uid 0: Apache will not run
# workers as root, and Docker Desktop sometimes reports the mount as root.
if [ -d /var/www/html ]; then
    uid=$(stat -c '%u' /var/www/html)
    gid=$(stat -c '%g' /var/www/html)
    if [ "$uid" -gt 0 ]; then
        usermod -o -u "$uid" www-data
        groupmod -o -g "$gid" www-data
    fi
fi

if [ "$1" = "apache2-foreground" ] && [ ! -f /var/www/html/public/index.php ]; then
    echo "The mounted project has no public/index.php." >&2
    echo "Create the Laravel app in this directory, then start the container again." >&2
    exit 1
fi

exec docker-php-entrypoint "$@"
