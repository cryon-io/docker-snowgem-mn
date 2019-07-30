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

if [ -f "$BASEDIR/../project_id" ]; then
    PROJECT=$(sed 's/PROJECT=//g' "$BASEDIR/../project_id")
    #PROJECT="--project-name $PROJECT"
else
    frffl=""
fi

container=$(for c in $(docker-compose -f "$BASEDIR/../docker-compose.yml" ${frffl-"--project-name"} ${frffl-"$PROJECT"} ps -q mn 2>/dev/null); do
    if [ "$(docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null)" = "true" ]; then
        printf "%s" "$c"
        break
    fi
done)

STATUS="NOT RUNNING"
CREATED_AT="-"

if [ -z "$container" ]; then 
    printf "\
CREATED AT: %s
STATUS: %s" "$CREATED_AT" "$STATUS"
    exit
fi

docker exec "$container" /home/snowgem/get-node-info.sh

CONTAINER_INFO=$(docker ps --filter "id=$container" --format "{{.CreatedAt}}\t{{.Status}}" --no-trunc 2> /dev/null)
CREATED_AT=$(printf "%s" "$CONTAINER_INFO" | awk -F "\t" '{print $1}')
STATUS=$(printf "%s" "$CONTAINER_INFO" | awk -F "\t" '{print $2}')

if [ -z "$STATUS" ]; then
    STATUS="NOT RUNNING"
fi
if [ -z "$CREATED_AT" ]; then
    CREATED_AT="-"
fi

printf "\
CREATED AT: %s
STATUS: %s" "$CREATED_AT" "$STATUS"