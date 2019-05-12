# DHCP自动安装与配置
## 细节
- 服务端
  - 使用的软件包: `isc-dhcp-server`
  - 主要配置文件:
    - `/etc/default/isc-dhcp-server`:
        ```
        root@vm-ubuntu:~# cat /etc/default/isc-dhcp-server 
        INTERFACESv4="enp0s8"
        root@vm-ubuntu:~# 
        ```
    - `/etc/dhcp/dhcpd.conf`(去掉注释与空行):
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
            option routers 10.20.50.1;
            option broadcast-address 10.20.50.255;
            default-lease-time 600;
            max-lease-time 7200;
        }
        ```
- 客户端
  - 分配到的ip地址
      ```
      root@vm-ubuntu2:~# ip addr show dev enp0s8
      3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
          link/ether 08:00:27:d9:9f:79 brd ff:ff:ff:ff:ff:ff
          inet 10.20.50.2/24 brd 10.20.50.255 scope global enp0s8
          valid_lft forever preferred_lft forever
          inet6 fe80::a00:27ff:fed9:9f79/64 scope link 
          valid_lft forever preferred_lft forever
      root@vm-ubuntu2:~# 
      ```