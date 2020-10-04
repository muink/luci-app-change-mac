#!/bin/bash
# dependent: bash rgmac getopt
#
# Interface MAC changer for Openwrt
# Author: muink
# Github: https://github.com/muink/luci-app-change-mac
#

# Init
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # <--
MACPOOL=Mpool

# Get options
GETOPT=$(getopt -n $(basename $0) -o et: -l type:,help -- "$@")
[ $? -ne 0 ] && echo -e "\tUse the --help option get help" && exit 1
eval set -- "$GETOPT"
ERROR=$(echo "$GETOPT" | sed "s|'[^']*'||g; s| -- .+$||; s| --$||")

# Duplicate options
for ru in --help\|--help -e\|-e -t\|--type; do
  eval "echo \"\$ERROR\" | grep -E \" ${ru%|*}[ .+]* ($ru)| ${ru#*|}[ .+]* ($ru)\" >/dev/null && >&2 echo \"\$(basename \$0): Option '\$ru' option is repeated\" && exit 1"
done
# Independent options
for ru in --help\|--help; do
  eval "echo \"\$ERROR\" | grep -E \"^ ($ru) .+|.+ ($ru) .+|.+ ($ru) *\$\" >/dev/null && >&2 echo \"\$(basename \$0): Option '\$(echo \"\$ERROR\" | sed -E \"s,^.*($ru).*\$,\\1,\")' cannot be used with other options\" && exit 1"
done



# Sub function
_help() {
printf "\n\
Usage: change-mac.sh [OPTION]... <INTERFACE>...\n\
Interface MAC changer for Openwrt\n\
\n\
  change-mac.sh eth0                    -- Use Locally administered address for 'eth0'\n\
  change-mac.sh eth1 eth2               -- MAC address is completely randomized\n\
  change-mac.sh -e eth1 eth2            -- MAC address is sequence randomization\n\
  change-mac.sh -t console:Sony eth0    -- Generate MAC address(Sony PS)\n\
\n\
Options:\n\
  -e                                    -- Sequence randomization\n\
  -t, --type <mactype>                  -- MAC address type\n\
  --help                                -- Returns help info\n\
\n\
MACType:\n\
  <xx:xx:xx>             Valid: 06fcee, 06-fc-ee, 06:fc:ee\n\
  <VendorType:NameID>    Valid: Please use 'rgmac -l' to get the reference
\n"
}

# mac_pool <Array> <Type> [Amount]
mac_pool() {
local pool=$1; shift
local type=$1; shift
local amount=$[ $1 + 0 ]
[ "$amount" -eq "0" ] && amount=1


if [ "$MODE" == "sequence" ]; then
  local base=`rgmac -u -ac $type 2>/dev/null`
  [ "$base" == "" ] && >&2 echo -e "$(basename $0): Option '-t|--type' requires a valid argument\n\tUse the command 'rgmac -l' get valid argument" && exit 1
  local count=$[ 0x${base: -2} -$amount -1 ]
  base=${base:0:-2}
  [ "$count" -lt "0" ] && count=0

  for i in $(seq 1 $amount); do
    ((count+=1))
    eval "${pool}[$i]=${base}$(printf %x $[ $count & 0xFF ] | sed -E 's|^([0-9a-fA-F])$|0\1|' | tr 'a-f' 'A-F')"
  done
else
  for i in $(seq 1 $amount); do
    eval "${pool}[$i]=$(rgmac -u -ac $type)"
  done
fi
}



# Main
# Get options
while [ -n "$1" ]; do
  case "$1" in
    --help)
      _help
      exit
    ;;
    -e)
      MODE=sequence
    ;;
    -t|--type)
      TYPE="$(echo "$2" | sed -En "/^[0-f]{2}(:[0-f]{2}){2}$|^[^:]+:[^:]+$/ {s|^([0-f]{2}(:[0-f]{2}){2})$|-s\1|; s|^([^:]+:[^:]+)$|-t\1|; p}")"
      [ -z "$TYPE" ] && >&2 echo -e "$(basename $0): Option '$1' requires a valid argument\n\tUse the --help option get help" && exit 1
      shift
    ;;
    --)
      shift
      break
    ;;
    *)
      >&2 echo -e "$(basename $0): '$1' is not an option\n\tUse the --help option get help"
      exit 1
    ;;
  esac
  shift
done

# Get parameters
[ "$#" -eq "0" ] && >&2 echo -e "$(basename $0): No valid interfaces\n\tUse the --help option get help" && exit 1
mac_pool $MACPOOL "$TYPE" $#

# Set
for i in $(seq 1 $#); do
uci -q batch <<-EOF >/dev/null
$(eval "uci show network | grep -E \"\\.ifname='\${$i}'\$|\$(echo \"\${$i}\"|sed -E 's|^br-(.+)\$|\\1|')\\.type='bridge'\$\" | sed -E \"s,\\.(ifname|type)=.+\$,.macaddr='\${$MACPOOL[$i]}',g; s|^|set |g\"")
EOF
done

uci commit network
/etc/init.d/network restart
echo All Done!
