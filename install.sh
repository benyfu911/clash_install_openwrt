#!/bin/sh

MARK=0x233
TABLE=233

# 1. pre-intall
## install kmod-tun
opkg update && opkg install kmod-tun ca-bundle

# 2. network
## add clash0 interface
uci set network.clash0=interface
uci set network.clash0.ifname='utun'
uci set network.clash0.proto='static'
uci set network.clash0.ipaddr='198.18.0.1'
uci set network.clash0.netmask='255.255.0.0'
uci set network.clash0.ip4table=$TABLE
uci set network.clash0.gateway='198.18.0.2'
uci set network.clash0.auto='1'

## add route rule
uci add network rule
uci set network.@rule[-1].mark=$MARK
uci set network.@rule[-1].lookup=$TABLE

## commit changes
uci commit network

# 3. firewall
## add firewall rules
uci add firewall rule
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].name='CLASH'
uci set firewall.@rule[-1].target='MARK'
uci set firewall.@rule[-1].set_mark=$MARK
uci set firewall.@rule[-1].proto='all'
uci set firewall.@rule[-1].src_ip=$(uci get network.lan.ipaddr)/$(uci get network.lan.netmask)
uci set firewall.@rule[-1].extra="! -d $(uci get network.lan.ipaddr)/$(uci get network.lan.netmask)"

## add clash zone
uci add firewall zone
uci set firewall.@zone[-1].name='clash'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci set firewall.@zone[-1].output='ACCEPT'
uci add_list firewall.@zone[-1].network='clash0'

## add forwarding
uci add firewall forwarding
uci set firewall.@forwarding[-1].dest='clash'
uci set firewall.@forwarding[-1].src='lan'

## commit changes
uci commit firewall

# 4. reloading
## reloading changes
/etc/init.d/network reload
/etc/init.d/firewall restart

# 5. init scripts
## install clash
cat << EOF >> /etc/init.d/clash
#!/bin/sh /etc/rc.common
START=99
STOP=10
NAME=clash
DAEMON=/usr/bin/clash
PIDFILE=/var/run/\$NAME.pid
DAEMON_OPTS="-d /etc/clash"
USER=root
start() {
    start-stop-daemon -S -q -c \$USER -p \$PIDFILE -x \$DAEMON -b -m -- \$DAEMON_OPTS
}
stop() {
    start-stop-daemon -K -q -p \$PIDFILE
    rm -f \$PIDFILE
}
restart() {
    stop
    start
}
EOF
chmod +x /etc/init.d/clash
mkdir -p /etc/clash

# 6. final
echo "Copying clash configuration file to /etc/clash"
echo "Copying clash binary to /usr/bin/clash"
echo "Enable clash auto-start via \"/etc/init.d/clash enable\""
