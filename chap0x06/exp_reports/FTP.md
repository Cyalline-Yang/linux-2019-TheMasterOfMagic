# FTP服务器配置任务
## 细节
- 服务端
  - 使用的软件包: `proftpd`
  - 主要配置文件:
    - `/etc/proftpd/proftpd.conf`: 和大部分做法不一样, 我将需要增添或修改的参数通通以增添的方式添加在了默认的配置文件的尾部. 亲测, 至少对于这个文件来说, 相同名字的参数, 后面的值会覆盖前面的值.
        ```
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
            Allow from 192.168.0.*
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
        ```
