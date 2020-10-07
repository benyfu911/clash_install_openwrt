# Install clash premium on OpenWRT
 在OpenWrt系统中安装Clash Premium, 使用clash 的tun模式,尽量使用OpenWrt的uci配置来固化配置文件.
 
 在OpenWrt19.07.4中测试通过，理论上在OpenWrt 18.06及以后版本均可

# TODO
* [x] 支持路由规则自动配置
* [ ] DNS自动配置转发到clash
* [ ] 支持本地(OpenWrt)流量代理
* [x] 支持OpenWrt的端口转发

# Install
```bash
wget https://github.com/benyfu911/clash_install_openwrt/raw/main/install.sh
sh install.sh
```
安装后需要自行解决DNS污染问题,可选的方案有：
 - dnscrypt
 - adguard home
 - clash dns
 
 # Config Example
 ```yaml
mode: Rule
log-level: silent
external-controller: '0.0.0.0:6170'
experimental:
  ignore-resolve-fail: true

tun:
  enable: true
  stack: system
  dns-hijack:
    - tcp://8.8.8.8:53

dns:
  enable: true
  ipv6: false
  listen: '0.0.0.0:1053'
  enhanced-mode: redir-host
  default-nameserver:
    - 119.29.29.29
    - 119.28.28.28
  nameserver:
    - 'https://1.1.1.1/dns-query'
    - 'tls://dns.adguard.com:853'
    - 'https://dns.alidns.com/dns-query'

proxies:
proxy-groups:
rules:
 ```
 
