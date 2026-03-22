#!/bin/bash

USER="ras"
IP="192.168.1.100"
REMOTE_DIR="/home/$USER/Desktop/YOLO26"

echo "Syncing project to Raspberry Pi..."

rsync -rvz --delete \
    --no-times --omit-dir-times \
    --exclude ".git" \
    --exclude "out/" \
    --exclude "conv" \
    --exclude "update_pi.sh" \
    ./ $USER@$IP:$REMOTE_DIR

echo "Project updated successfully!"
