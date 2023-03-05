#!/bin/bash
set -euxo pipefail

HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/tags/instance/Name)
MOUNT_DIR=$(curl http://169.254.169.254/latest/meta-data/tags/instance/mount_dir)
CREATE_EXTRA_DISK=$(curl http://169.254.169.254/latest/meta-data/tags/instance/create_extra_disk)

sudo hostnamectl set-hostname $HOSTNAME

if [ $CREATE_EXTRA_DISK == "true" ]; then
  if mount | awk '{if ($3 == "${MOUNT_DIR}") { exit 0}} ENDFILE{exit -1}'; then
    exit
  else
    echo -e "o\nn\np\n1\n\n\nw" | sudo fdisk /dev/xvdb
    sudo pvcreate /dev/xvdb1
    sudo vgcreate datavg /dev/xvdb1
    sudo lvcreate -l 100%FREE -n data datavg
    sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard  /dev/datavg/data; \
    sudo mkdir -p $MOUNT_DIR
    sudo mount -o discard,defaults /dev/mapper/datavg-data $MOUNT_DIR

    # Add fstab entry
    echo UUID=`sudo blkid -s UUID -o value /dev/mapper/datavg-data` $MOUNT_DIR ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
  fi
fi
