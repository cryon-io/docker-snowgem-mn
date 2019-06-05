#!/bin/sh

#  SNOWGEM Masternode docker template
#  Copyright © 2019 cryon.io
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published
#  by the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#  Contact: cryi@tutanota.com

BASEDIR=$(dirname "$0")

PARAM=$(echo "$1" | sed "s/=.*//")
VALUE=$(echo "$1" | sed "s/[^>]*=//")
# escape value for sed
VALUE_FOR_SED=$(echo "$VALUE" | sed -e 's/[\/&]/\\&/g')

case $PARAM in
    ip)
        case $VALUE in 
            *:*)
                TEMP=$(sed "s/externalip=.*/externalip=[$VALUE_FOR_SED]:16113/g" "$BASEDIR/../data/snowgem/snowgem.conf")
                TEMP=$(printf "%s" "$TEMP" | sed "s/masternodeaddr=.*/masternodeaddr=[$VALUE_FOR_SED]:16113/g")
            ;;
            *)
                TEMP=$(sed "s/externalip=.*/externalip=$VALUE_FOR_SED:16113/g" "$BASEDIR/../data/snowgem/snowgem.conf")
                TEMP=$(printf "%s" "$TEMP" | sed "s/masternodeaddr=.*/masternodeaddr=$VALUE_FOR_SED:16113/g")
            ;;
        esac
        printf "%s" "$TEMP" > "$BASEDIR/../data/snowgem/snowgem.conf"
        MN_CONF_PART1=$(awk '{print $1}' "$BASEDIR/../data/snowgem/masternode.conf")
        MN_CONF_PART2=$(awk '{print $3" "$4" "$5}' "$BASEDIR/../data/snowgem/masternode.conf")
        case $VALUE in 
            *:*)
                printf "%s [%s]:16113 %s" "$MN_CONF_PART1" "$VALUE" "$MN_CONF_PART2" > "$BASEDIR/../data/snowgem/masternode.conf"
            ;;
            *)
                printf "%s %s:16113 %s" "$MN_CONF_PART1" "$VALUE" "$MN_CONF_PART2" > "$BASEDIR/../data/snowgem/masternode.conf"
            ;;
        esac
    ;;
    nodeprivkey)
        TEMP=$(sed "s/masternodeprivkey=.*/masternodeprivkey=$VALUE_FOR_SED/g" "$BASEDIR/../data/snowgem/snowgem.conf")
        printf "%s" "$TEMP" > "$BASEDIR/../data/snowgem/snowgem.conf"
        MN_CONF_PART1=$(awk '{print $1" "$2}' "$BASEDIR/../data/snowgem/masternode.conf")
        MN_CONF_PART2=$(awk '{print $4" "$5}' "$BASEDIR/../data/snowgem/masternode.conf")
        printf "%s %s %s" "$MN_CONF_PART1" "$VALUE" "$MN_CONF_PART2" > "$BASEDIR/../data/snowgem/masternode.conf"
    ;;
    NODE_VERSION) 
        if grep "NODE_VERSION=" "$BASEDIR/../container/limits.conf"; then
            TEMP=$(sed "s/NODE_VERSION=.*/NODE_VERSION=$VALUE_FOR_SED/g" "$BASEDIR/../container/limits.conf")
            printf "%s" "$TEMP" > "$BASEDIR/../container/limits.conf"
        else 
            printf "\nNODE_VERSION=%s" "$VALUE" >> "$BASEDIR/../container/limits.conf"
        fi
    ;;
    PROJECT)
        printf "PROJECT=%s" "$VALUE" >  "$BASEDIR/../project_id"
        MN_CONF_PART=$(awk '{print $2" "$3" "$4" "$5}' "$BASEDIR/../data/snowgem/masternode.conf")
        printf "%s %s" "$VALUE" "$MN_CONF_PART" > "$BASEDIR/../data/snowgem/masternode.conf"
    ;;
    bootstrap)
        TEMP=$(sed "s/BOOTSTRAP_URL=.*/BOOTSTRAP_URL=\"$VALUE_FOR_SED\"/g" "$BASEDIR/before-start.sh")
        printf "%s" "$TEMP" > "$BASEDIR/before-start.sh"
    ;;
    txid)
        MN_CONF_PART1=$(awk '{print $1" "$2" "$3}' "$BASEDIR/../data/snowgem/masternode.conf")
        MN_CONF_PART2=$(awk '{print $5}' "$BASEDIR/../data/snowgem/masternode.conf")
        printf "%s %s %s" "$MN_CONF_PART1" "$VALUE" "$MN_CONF_PART2" > "$BASEDIR/../data/snowgem/masternode.conf"
    ;;
    txindex)
        MN_CONF_PART=$(awk '{print $1" "$2" "$3" "$4}' "$BASEDIR/../data/snowgem/masternode.conf")
        printf "%s %s" "$MN_CONF_PART" "$VALUE" > "$BASEDIR/../data/snowgem/masternode.conf"
    ;;
esac