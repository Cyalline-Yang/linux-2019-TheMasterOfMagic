# NFS服务器配置任务
## 任务要求
- [x] 在1台Linux上配置NFS服务，另1台电脑上配置NFS客户端挂载2个权限不同的共享目录，分别对应只读访问和读写访问权限
    - 服务端:
      - 只读目录: `/var/nfs/readonly_dir`
      - 可写目录: `/var/nfs/writable_dir`
      - 树状图:
        ```
        root@server:~# tree /var/nfs
        /var/nfs
        ├── readonly_dir
        │   └── readonly_file
        └── writable_dir
            ├── new_dir
            ├── new_file
            └── writable_file

        3 directories, 3 files
        root@server:~# 
        ```
        其中`new_dir`与`new_file`为测试脚本在客户端运行时所创建, 其他文件或子目录均为安装脚本在服务端运行时所创建
    - 客户端:
      - 只读目录挂载点: `/var/nfs/readonly_dir`
      - 可写目录挂载点: `/var/nfs/writable_dir`

## 客户端信息记录
### 共享目录中文件、子目录的属主、权限信息, 与你通过NFS客户端在NFS共享目录中新建的目录、创建的文件的属主、权限信息
结合使用`ls`与`find`指令即可查看两个共享目录下所有文件与子目录的属主与权限信息  
可以看到由客户端所创建的文件与目录, 其`owner`与`group`分别为`nobody`与`nogroup`  
```
root@client:~# ls -l $(find /var/nfs -type d)
/var/nfs:
total 8
drwxr-xr-x 2 root root 4096 5月  11 20:43 readonly_dir
drwxrwxrwx 3 root root 4096 5月  12 13:03 writable_dir

/var/nfs/readonly_dir:
total 4
-rw-r--r-- 1 root root 1 5月  12 13:02 readonly_file

/var/nfs/writable_dir:
total 8
drwxr-xr-x 2 nobody nogroup 4096 5月  12 13:01 new_dir
-rw-r--r-- 1 nobody nogroup    0 5月  12 13:03 new_file
-rwxrwxrwx 1 root   root       2 5月  12 13:03 writable_file

/var/nfs/writable_dir/new_dir:
total 0
root@client:~# 
```

### 上述共享目录中文件、子目录的属主、权限信息和在NFS服务器端上查看到的信息一样吗？无论是否一致，请给出你查到的资料是如何讲解NFS目录中的属主和属主组信息应该如何正确解读
在服务端查看到的上述信息与客户端查看到的一致   
根据[查到的资料](https://blmrgnn.blogspot.com/2015/06/what-is-use-of-rootsquah-and.html), 服务端默认是开启`root_squash`的, 即出于安全考虑, 将远程用户的身份权限`squash`为本地的`nobody`, 这样可以避免远程用户无限制地创建删除修改本地的文件. 