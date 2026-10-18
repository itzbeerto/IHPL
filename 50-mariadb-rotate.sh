#!/bin/bash
# 50-mariadb-rotate.sh  --  MANIFEST (Windows, but MariaDB). Rotate a DB user's password
# SAFELY. The trap: PlinkCom on GUIDANCE reads this DB, so its site config must match or
# the website goes down (and you lose uptime on TWO boxes). This script changes the DB
# side and REMINDS you to do the app side + NEIGH.
#
# Run from a shell that has the mysql/mariadb client (on manifest, or via SSH).
#   bash 50-mariadb-rotate.sh <dbuser> <newpass>
set -u
U="${1:?usage: $0 <dbuser> <newpass>}"
P="${2:?usage: $0 <dbuser> <newpass>}"

echo "== backup ALL databases first =="
mysqldump -u root -p --all-databases > "mariadb_backup_$(date +%s).sql" && echo "backup ok"

echo "== change password for '$U' =="
mysql -u root -p <<SQL
ALTER USER '$U'@'localhost' IDENTIFIED BY '$P';
ALTER USER '$U'@'%' IDENTIFIED BY '$P';
FLUSH PRIVILEGES;
SELECT user, host FROM mysql.user;
SQL

cat <<EOF

!!!! NOT DONE YET -- or PlinkCom on GUIDANCE goes DOWN !!!!
  1. On GUIDANCE, edit the site's DB password to '$P':
       WordPress  -> /var/www/html/wp-config.php   (define('DB_PASSWORD', ...))
       MediaWiki  -> /var/www/.../LocalSettings.php (\$wgDBpassword = ...)
     then restart the web server (systemctl restart httpd  OR  apache2 / nginx).
  2. If jmoney is the scored MariaDB user, update his password in NEIGH -> Users.
  3. Verify: reload PlinkCom in a browser, and check NEIGH shows MariaDB + PlinkCom green.
EOF
