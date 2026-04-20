#!/bin/bash

USER="ras"
IP="ras-desktop.local"
REMOTE_DIR="/home/$USER/Desktop/YOLO26"

echo "Syncing project to Raspberry Pi..."

rsync -rvz --delete \
    --no-times --omit-dir-times \
    --exclude ".git" \
    --exclude "out/*.txt" \
    --exclude "etc/" \
    --exclude "conv" \
    --exclude "deploy.sh" \
    ./ $USER@$IP:$REMOTE_DIR

echo "Project updated successfully!"
