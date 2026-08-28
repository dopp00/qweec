#!/usr/bin/bash
for s in qweenx ssh ftp mail db; do
    if grep "match-set f2b-${s}4" /etc/sysconfig/iptables; then
       /usr/sbin/ipset -exist create "f2b-${s}4" "hash:ip" family inet maxelem 131072
    fi
    if grep "match-set f2b-${s}6" /etc/sysconfig/ip6tables; then
       /usr/sbin/ipset -exist create "f2b-${s}6" "hash:ip" family inet6 maxelem 131072
    fi
done
