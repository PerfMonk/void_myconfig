!/usr/bin/env bash

# My VoidLinux install with encrypted root and swap
# on disk usb-SPCC_Sol_id_State_Disk_1-0:0  (512MB)
# ├─sda1            ESP  /boot/efi  VFAT (2GB)  (début à 4MB)
# ├─sda2            BOOT pool /boot EXT4 (4GB))
# └─sda3           LUKS CONTAINER
#   └─cryptroot     LUKS MAPPER encrypted
#     └─void_vg
#       ├─root_lv     /      EXT4 (100GB)
#       ├─home_lv     /home  EXT4 (389GB)
#       └─cryptswap   SWAP   swap (17GB)
#
### https://docs.voidlinux.org/installation/guides/fde.html
#
set -e

pprint () {
    local cyan="\e[96m"
    local default="\e[39m"
    # ISO8601 timestamp + ms
    local timestamp
    timestamp=$(date +%FT%T.%3NZ)
    echo -e "${cyan}${timestamp} $1${default}" 1>&2
}
# Unique pool suffix
INST_UUID=$(dd if=/dev/urandom bs=1 count=100 2>/dev/null | tr -dc 'a-z0-9' | cut -c-6)

# Installation ZFS PATH
INST_ID=void

# Set DISK
select ENTRY in $(ls /dev/disk/by-id/);
do
    DISK="/dev/disk/by-id/$ENTRY"
    echo "Installing system on $ENTRY."
    break
done
###Set primary disk and vdev topology (anyway we have only one disk)
INST_PRIMARY_DISK=$(echo $DISK | cut -f1 -d\ )
INST_VDEV=

read -p "> Is this an SSD and wipe it : $ENTRY Y/N ? " -n 1 -r
echo # move to a new line
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    for i in ${DISK}; do    # wipe SSD
      blkdiscard -f $i &
    done
    wait
    # Clear disk
    #wipefs -af "$DISK"
    #sgdisk -Zo "$DISK"
fi

# Set ESP size
INST_PARTSIZE_ESP=2 # in GB

# Set Boot size (recommandation min 4Gb)
INST_PARTSIZE_BOOT=4

# Set luks container as total of swap+root+home

INST_PARTSIZE_LUKS=479

# Set swap size (I use hibernation, ajust to your need)
INST_PARTSIZE_SWAP=17

# Set root size
INST_PARTSIZE_ROOT=100

# Set home size (rest of the disk if not set)
INST_PARTSIZE_HOME=

# Partition the disk
pprint "Partitioning the disk"
for i in ${DISK}; do
sgdisk --zap-all $i
sgdisk -n1:4M:+${INST_PARTSIZE_ESP}G -t1:EF00 $i
sgdisk -n2:0:+${INST_PARTSIZE_BOOT}G -t2:bc13c2ff-59e6-4262-a352-b275fd6f7172 $i
sgdisk -n3:0:+${INST_PARTSIZE_LUKS}G -t3:8300 $i

read -p "Enter the name to assign to the LUKS partition [cryptroot]: " LUKSNAME
LUKSNAME=${LUKSNAME:-cryptroot}

# Create LUKS container and open/mount it
cryptsetup luksFormat --type luks1 ${i}-part3

# Open LUKS container
echo "Retype password to open LUKS partition: "
cryptsetup luksOpen ${i}-part3 ${LUKSNAME}

# We put this UUID into an env var to reuse later
CRYPTUUID=`blkid -o export ${i}-part3 | grep -E '^UUID='`

# export LUKSNAME
echo "export LUKSNAME=$LUKSNAME" > ./importvars.sh

vgcreate void_vg /dev/mapper/${LUKSNAME} 
lvcreate --name lv_root -L ${INST_PARTSIZE_ROOT}G void_vg 
lvcreate --name lv_swap -L ${INST_PARTSIZE_SWAP}G void_vg
lvcreate --name lv_home -l 100%FREE void_vg

done

# Inform kernel
partprobe "$DISK"
sleep 1

#pprint "Format and mount ESP"
#for i in ${DISK}; do
# mkfs.vfat -n EFI ${i}-part1
# mkdir -p /mnt/boot/efis/${i##*/}-part1
# mount -t vfat ${i}-part1 /mnt/boot/efis/${i##*/}-part1
#done


pprint "Format all"

mkfs.ext4 -L root /dev/void_vg/lv_root
mkfs.xfs -L home /dev/void_vg/lv_home
mkswap /dev/void_vg/lv_swap
swapon /dev/void_vg/lv_swapch

pprint "OK pour le chroot maintenant"

mount /dev/void_vg/lv_root  /mnt
l
mkdir -p /mnt/home
mount  /dev/void_vg/lv_home /mnt/home

pprint "Format and mount ESP"
for i in ${DISK}; do
 mkfs.vfat -n EFI ${i}-part1
 mkdir -p /mnt/boot/efi
 mount -t vfat ${i}-part1 /mnt/boot/efi
done

####TODO from the VOID iso before chroot
#
#pprint "Copy RSA keys"
#mkdir -p /mnt/var/db/xbps/keys
#cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

#pprint "Install base system"
#xbps-install -Sy -R https://repo-default.voidlinux.org/current -r /mnt base-system cryptsetup grub-x86_64-efi lvm2

pprint "Ready for chroot"
exit

