#!/bin/sh

#######################################################################################################################
#
# Globz
#
##

APP="$(basename $0)"
DNS_SERVER=""
ICMP_TIMEOUT=3
ICMP_COUNT=2



#######################################################################################################################
#
# Funcz
#
##

function set_dns_server() {
	[ "$(uname)" = "Linux" ]  && DNS_SERVER="$(awk '/^nameserver/ { print $2 }' /etc/resolv.conf|head -n1)"
	[ "$(uname)" = "Darwin" ] && DNS_SERVER="$(scutil --dns|grep -B4 Reachable|awk '/nameserver/ { print $3 }'|head -n1)"
}

function die() {
	echo "Error: $1"
	exit $2
}


#######################################################################################################################
#
# Argz
#
##

if [ $# -ne 1 ]; then
	echo "
Usage: $APP <host>

Send one ICMP request to know if host is dead or alive. Timeout is 3s.
"
	exit 0
fi



#######################################################################################################################
#
# Main
#
##


same=0
target="$1"
ip="$target"

set_dns_server # set DNS_SERVER

# Try to resolve if not an IP
echo "$target"|egrep -sqi '[a-z]' && ip="$(host "$target" "$DNS_SERVER"|awk '/ has addr/ { print $4 }'|grep -oE "(([0-9]){1,3}\.){3}([0-9]){1,3}"|head -n1)"
echo "$target"|grep -Fsq "$ip" && same=1

# Resolution failed
[ -z "$ip" ] && die "unable to resolve '$target'" 2

# Catch state
res=$(ping -t $ICMP_TIMEOUT -c $ICMP_COUNT "$ip" 2>&1|grep "bytes from") && state="alive" || state="dead"

[ $same -eq 0 ] && target="$target ($ip)"

if [ "$state" = "alive" ]; then
	# Catch TTL
	ttl=$(echo "$res"|awk '/bytes from.+ttl=/ { print $6 }'|cut -d'=' -f2|head -n1)
	verb="is"
	state="$state, ttl:$ttl"
else
	verb="seems"
	state="dead."
fi

echo "$target $verb $state"


