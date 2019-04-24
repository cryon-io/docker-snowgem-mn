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

ver=$(./get-version.sh)
type="XSG_MN"
mn_status="$(/home/snowgem/snowgem-cli masternode status 2>&1)"
if printf "%s" "$mn_status" | grep "error message"; then 
    mn_status=$(printf "%s" "$mn_status" | tail -n 1)
else 
    mn_status=$(printf "%s" "$mn_status" | jq .message)
    [ -z "$mn_status" ] && mn_status=$(/home/snowgem/snowgem-cli masternode debug)
fi

block_count="$(/home/snowgem/snowgem-cli getblockchaininfo 2>&1)"
if printf "%s" "$block_count" | grep "error message"; then 
    block_count=$(printf "%s" "$block_count" | tail -n 1)   
else 
    block_count="$(printf "%s" "$block_count" | jq .blocks)"
fi

sync_status="$(/home/snowgem/snowgem-cli getblocktemplate 2>&1)"
if printf "%s" "$sync_status" | grep "error message"; then 
    sync_status=false
else 
    sync_status=true
fi

printf "\
TYPE: %s
VERSION: %s
MN STATUS: %s
BLOCKS: %s
SYNCED: %s
" "$type" "$ver" "$mn_status" "$block_count" "$sync_status"> /home/snowgem/.snowgem/node.info

printf "\
TYPE: %s
VERSION: %s
MN STATUS: %s
BLOCKS: %s
SYNCED: %s
" "$type" "$ver" "$mn_status" "$block_count" "$sync_status"