#!/usr/bin/env bash

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

# make sure samba is installed
apt-get install -y samba &> /dev/null || exit_because "failed to install samba"

# make sure the user exists and the password is correct
# 9: user already exists
useradd -M -s "$(command -v nologin)" samba_user &> /dev/null || [[ $? -eq 9 ]] || exit_because "failed to create normal user for samba"
echo samba_user:samba_user | chpasswd
echo -e 'samba_password\nsamba_password' | smbpasswd -a samba_user &> /dev/null || "failed to set samba password for normal user"

# make sure the shared folder and files exists
## normal user part
mkdir -p /var/samba/norm 2> /dev/null || exit_because "failed to create shared folder for normal user"
touch /var/samba/norm/welcome_file_for_norm || exit_because "failed to create welcome file for normal user"
## anonymous user part
mkdir -p /var/samba/anon 2> /dev/null || exit_because "failed to create shared folder for anonymous user"
touch /var/samba/anon/welcome_file_for_anon || exit_because "failed to create welcome file for anonymous user"

# make sure smb.conf is modified as expected
cp smb.conf /etc/samba/smb.conf
tee -a /etc/samba/smb.conf > /dev/null << EOF
[norm]
    path = /var/samba/norm/
    read only = no
    guest ok = no
    force create mode = 0660
    force directory mode = 2770
    force user = samba_user
[anon]
    path = /var/samba/anon/
    read only = no
    guest ok = yes
EOF

# restart the service to apply
systemctl restart smbd