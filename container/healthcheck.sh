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

RESULT=$(curl -s -X POST -w "\n%{http_code}\n" --user "healthcheck:healthcheck_pass" --url http://localhost:10000 \
                                        --header 'Cache-Control: no-cache' \
                                        --header 'Content-Type: application/json' \
                                        --data '{"jsonrpc":"2.0","id":"healthcheck","method":"getblockchaininfo","params":[]}' \
                                        --silent -k)

HTTP_CODE=$(printf "%s" "$RESULT" | tail -n 1) 
if [ "$HTTP_CODE" = "200" ]; then exit 0; fi


CONTENT_LINES_COUNT=$(($(printf "%s" "$RESULT" | wc -l) - 1))
ERROR_MESSAGE=$(printf "%s" "$RESULT" | head -n $CONTENT_LINES_COUNT | jq .error.message -r)
# loading index is proper behaviour, so exit with 0
if [ "$ERROR_MESSAGE" = "Loading block index..." ]; then exit 0; fi

exit 1