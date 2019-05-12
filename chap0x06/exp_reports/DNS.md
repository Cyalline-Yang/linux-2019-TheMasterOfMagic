# DNS服务的安装与配置
## 细节
- 服务端
  - 使用的软件包: `bind9`
  - 主要配置文件:
    - `/etc/netplan/01-netcfg.yaml`:
        ```
        root@vm-ubuntu:~# cat /etc/netplan/01-netcfg.yaml
        # This file describes the network interfaces available on your system
        # For more information, see netplan(5).
        network:
        version: 2
        renderer: networkd
        ethernets:
            enp0s3:
            dhcp4: yes
            enp0s8:
            addresses: [10.20.50.1/24]
            dhcp4: no
        root@vm-ubuntu:~# 
        ``` 
    - `/etc/default/isc-dhcp-server`:
        ```
        root@vm-ubuntu:~# cat /etc/default/isc-dhcp-server 
        INTERFACESv4="enp0s8"
        root@vm-ubuntu:~# 
        ```
    - `/etc/dhcp/dhcpd.conf`去掉注释与空行:
        ```
        root@vm-ubuntu:~# cat /etc/dhcp/dhcpd.conf | grep -v ^# | grep -v ^$
        option domain-name "example.org";
        option domain-name-servers ns1.example.org, ns2.example.org;
        default-lease-time 600;
        max-lease-time 7200;
        ddns-update-style none;
        subnet 10.20.50.0 netmask 255.255.255.0 {
            range 10.20.50.2 10.20.50.254;
            option subnet-mask 255.255.255.0;
            option broadcast-address 10.20.50.255;
            default-lease-time 600;
            max-lease-time 7200;
        }
        root@vm-ubuntu:~# 
        ```
