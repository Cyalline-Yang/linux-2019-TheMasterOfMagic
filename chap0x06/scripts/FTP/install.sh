#!/usr/bin/env bash

cd "$(dirname "$0")" || (exit 0)
source ../functions.sh
[[ "$(whoami)" == root ]] || exit_because "root previledge is required"

# make sure proftpd is installed
apt-get install -y proftpd &> /dev/null || exit_because "failed to install proftpd"

# make sure the user exists and the password is correct
# 9: user already exists
useradd -M ftp_user &> /dev/null || [[ $? -eq 9 ]] || exit_because "failed to create normal user for ftp"
usermod -s "$(command -v nologin)" ftp_user &> /dev/null || exit_because "failed to change shell of normal user to nologin"
echo ftp_user:ftp_pswd | chpasswd

# make sure the shared folder and files exists
mkdir -p /var/ftp
chown -R proftpd /var/ftp
chmod -R 777 /var/ftp
## normal user part
mkdir -p /var/ftp/norm 2> /dev/null || exit_because "failed to create shared folder for normal user"
touch /var/ftp/norm/welcome_file_for_norm || exit_because "failed to create welcome file for normal user"
## anonymous user part
mkdir -p /var/ftp/anon 2> /dev/null || exit_because "failed to create shared folder for anonymous user"
touch /var/ftp/anon/welcome_file_for_anon || exit_because "failed to create welcome file for anonymous user"

# make sure ssl key and cert exist
openssl req -x509 -newkey rsa:4096 -nodes -subj "/C=CN/ST=Beijing/L=Beijing/O=CUC/OU=FTP/CN=example.com" -keyout /etc/proftpd/key.pem -out /etc/proftpd/cert.pem -days 365 &> /dev/null

# make sure proftpd.conf is modified as expected
cp proftpd.conf /etc/proftpd/proftpd.conf
tee -a /etc/proftpd/proftpd.conf > /dev/null << EOF

<Anonymous /var/ftp/anon>
User ftp
Group ftp
UserAlias anonymous ftp
RequireValidShell no
<Directory *>
    <Limit WRITE>
        DenyAll
    </Limit>
</Directory>
<Limit LOGIN /home/ftp/*>
    Order allow,deny
    Allow from 10.20.50.*
    Deny from all
</Limit>
</Anonymous>

DefaultRoot /var/ftp/norm
RequireValidShell no

<IfModule mod_tls.c>
    TLSEngine                  on
    TLSLog                     /var/log/proftpd/tls.log
    TLSCipherSuite AES128+EECDH:AES128+EDH
    TLSOptions                 NoCertRequest AllowClientRenegotiations
    TLSRSACertificateFile      /etc/proftpd/cert.pem
    TLSRSACertificateKeyFile   /etc/proftpd/key.pem
    TLSVerifyClient            off
    TLSRequired                on
    RequireValidShell          no
</IfModule>

EOF

# restart the service to apply the lastest config
systemctl restart proftpd

# test
## Part 3 - just ftp, no shell login
su ftp_user -c echo &> /dev/null
[[ $? -ne 0 ]] || exit_because "failed to prevent ftp_user from shell login"