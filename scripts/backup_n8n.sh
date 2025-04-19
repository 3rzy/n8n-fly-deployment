#!/bin/bash
# Script: backup_n8n.sh
# Description: Creates a backup of n8n data from Fly.io
# Usage: ./backup_n8n.sh [app_name]

# Default values
APP_NAME=${1:-"krzyk-n8n"}
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILENAME="n8n_backup_${TIMESTAMP}.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "📦 Starting backup of n8n data from $APP_NAME on Fly.io..."

# Check if the app exists
echo "✓ Checking if the app $APP_NAME exists..."
if ! fly status -a "$APP_NAME" &> /dev/null; then
  echo "❌ Error: Application $APP_NAME does not exist or is not accessible."
  exit 1
fi

# Create a temporary file for backup commands
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE" << 'EOF'
#!/bin/bash
cd /home/node/.n8n
echo "✓ Creating archive of n8n data..."
tar -czf /tmp/n8n_backup.tar.gz .
echo "✓ Archive created at /tmp/n8n_backup.tar.gz"
EOF

# Upload the script to the Fly.io VM
echo "✓ Uploading backup script to VM..."
fly ssh sftp shell -a "$APP_NAME" <<EOF
put $TEMP_FILE /tmp/backup_script.sh
EOF

# Execute the backup script on the Fly.io VM
echo "✓ Executing backup script on VM..."
fly ssh console -a "$APP_NAME" -C "chmod +x /tmp/backup_script.sh && /tmp/backup_script.sh"

# Download the backup file
echo "✓ Downloading backup file from VM..."
fly ssh sftp get /tmp/n8n_backup.tar.gz "$BACKUP_DIR/$BACKUP_FILENAME" -a "$APP_NAME"

# Cleanup the remote files
echo "✓ Cleaning up temporary files on VM..."
fly ssh console -a "$APP_NAME" -C "rm /tmp/backup_script.sh /tmp/n8n_backup.tar.gz"

# Cleanup the local temporary file
rm "$TEMP_FILE"

if [ -f "$BACKUP_DIR/$BACKUP_FILENAME" ]; then
  FILESIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILENAME" | cut -f1)
  echo "✅ Backup completed successfully!"
  echo "📁 Backup saved to: $BACKUP_DIR/$BACKUP_FILENAME (Size: $FILESIZE)"
  echo "🔒 Keep this file secure as it may contain sensitive information."
else
  echo "❌ Error: Backup file was not created successfully."
  exit 1
fi