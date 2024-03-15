# aliddns-script
基于阿里云 OpenAPI v3 接口实现，可实现获取当前设备IP地址后更新云解析记录

## 使用前提
1. 拥有实名注册的阿里云账号
2. 在阿里云云解析上有管理权限的域名
3. 需要自行先在阿里云云解析上添加A或者AAAA记录
4. 然后通过[aliddns_query.sh](./aliddns_query.sh)获取对应的RecordId
5. 申请AK，具体申请方法见[创建AccessKey](https://help.aliyun.com/zh/ram/user-guide/create-an-accesskey-pair)

## 支持范围
- 支持IPv6与IPv4更新，根据 type 的配置，可以自动更新记录（A 对应 IPv4，AAAA 对应 IPv6）
- 支持 OpenWRT、macOS、Linux

## 使用说明
设置[aliddns_query.sh](./aliddns_query.sh)、[aliddns_update.sh](./aliddns_update.sh)两个文件中的配置项，然后使用以下方式调用：
```bash
bash aliddns_query.sh
bash aliddns_update.sh
```
