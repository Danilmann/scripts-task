#!/bin/bash

# Configuration parameters
DB_USER="backup_user"                    # Database user with read permissions
DB_PASS="..."                             # Database user's password
REMOTE_USER="ubuntu"                      # SSH user on the remote AWS server (e.g., ubuntu for Ubuntu Server)
REMOTE_HOST="54.123.45.67"                # IP address or hostname of the AWS server
REMOTE_DIR="/var/backups/db_backups"      # Directory on the remote server to store backups
LOCAL_TMP_DIR="/tmp/db_backups"           # Local temporary directory for backup files
DATE=$(date +'%Y-%m-%d')

# Create a temporary directory for backups
mkdir -p "$LOCAL_TMP_DIR/$DATE"

# Retrieve a list of databases (excluding system databases)
databases=$(mysql -u $DB_USER -p$DB_PASS -e 'SHOW DATABASES;' | grep -v -E 'Database|information_schema|performance_schema|mysql|sys')

# Loop through each database and back it up
for db in $databases; do
    echo "Backing up database: $db"
    
    # Dump the database and compress it
    mysqldump -u $DB_USER -p$DB_PASS --databases $db | gzip > "$LOCAL_TMP_DIR/$DATE/$db.sql.gz"
done

# Transfer backups to the remote AWS server
echo "Transferring backups to remote server..."
ssh $REMOTE_USER@$REMOTE_HOST "mkdir -p $REMOTE_DIR/$DATE"
scp "$LOCAL_TMP_DIR/$DATE/"*.sql.gz "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/$DATE/"

# Clean up local backup files
rm -rf "$LOCAL_TMP_DIR/$DATE"

echo "Backup completed and transferred to $REMOTE_HOST:$REMOTE_DIR/$DATE"
