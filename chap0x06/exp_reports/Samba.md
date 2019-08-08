# 安装和配置Samba独立共享服务器
## 细节
- 服务端
  - 使用的软件包: `samba`
  - 主要配置文件:
    - `/etc/samba/smb.conf`去掉注释与空行: 
        ```
        root@vm-ubuntu:~# cat /etc/samba/smb.conf | grep -v ^# | grep -v ^$ | grep -v ^\;
        [global]
        workgroup = WORKGROUP
            server string = %h server (Samba, Ubuntu)
        dns proxy = no
        log file = /var/log/samba/log.%m
        max log size = 1000
        syslog = 0
        panic action = /usr/share/samba/panic-action %d
        server role = standalone server
        passdb backend = tdbsam
        obey pam restrictions = yes
        unix password sync = yes
        passwd program = /usr/bin/passwd %u
        passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
        pam password change = yes
        map to guest = bad user
        usershare allow guests = yes
        [printers]
        comment = All Printers
        browseable = no
        path = /var/spool/samba
        printable = yes
        guest ok = no
        read only = yes
        create mask = 0700
        [print$]
        comment = Printer Drivers
        path = /var/lib/samba/printers
        browseable = yes
        read only = yes
        guest ok = no
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
        root@vm-ubuntu:~# 
        ``` 
- 客户端
  - 使用的软件包: `smbclient`
