#!/usr/bin/env bash
set -e

UUID="bd1505ca-78d9-4cde-b146-52b169b68999"
DEVICE="/dev/disk/by-uuid/$UUID"
MOUNT_POINT="/run/media/rck/AI_models"

# 1. Check if the partition is already mounted
if mountpoint -q "$MOUNT_POINT"; then
    echo "AI_models is already mounted at $MOUNT_POINT"
    exit 0
fi

# 2. Verify that the Samsung SSD partition is detected
if [ ! -e "$DEVICE" ]; then
    echo "Error: Partition with UUID $UUID (/dev/nvme0n1p4) not found."
    exit 1
fi

echo "Mounting AI_models partition..."

# 3. Try udisksctl first (mounts cleanly to /run/media/rck/AI_models without sudo in desktop sessions)
if command -v udisksctl >/dev/null 2>&1 && udisksctl mount -b "$DEVICE" >/dev/null 2>&1; then
    echo "Successfully mounted at $MOUNT_POINT via udisksctl."
else
    # Fallback for SSH or headless sessions using sudo
    sudo mkdir -p "$MOUNT_POINT"
    sudo mount -U "$UUID" "$MOUNT_POINT"
    echo "Successfully mounted at $MOUNT_POINT via sudo mount."
fi
