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

PATH_TO_SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$PATH_TO_SCRIPT")

get_latest_github_release() {
    GIT_INFO=$(curl -sL "https://api.github.com/repos/$1/releases/latest")
    get_json_value "$GIT_INFO" "tag_name"                                           
    RESULT=$JSON_VALUE                             
} 

get_json_value() {
    JSON_VALUE=$(printf "%s\n" "$1" | jq ".[\"$2\"]" -r)
}

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

if [ -z "$container" ]; then 
    # masternode is not running
    exit 1
fi
sh "$BASEDIR/node-info.sh" > /dev/null
get_latest_github_release "Snowgem/Snowgem"
# shellcheck disable=SC1003
ver=$(echo "$RESULT" | sed 's\v\\')
if grep -q "VERSION: $ver" "$BASEDIR/../data/snowgem/node.info"; then
    exit 0
else
    if docker-compose -f "$BASEDIR/../docker-compose.yml" ${frffl-"--project-name"} ${frffl-"$PROJECT"} build --no-cache; then
        if ! docker-compose -f "$BASEDIR/../docker-compose.yml" ${frffl-"--project-name"} ${frffl-"$PROJECT"} up -d --force-recreate; then
            if docker-compose -f "$1" ${frffl-"--project-name"} ${frffl-"$PROJECT"} down; then
                docker-compose -f "$1" ${frffl-"--project-name"} ${frffl-"$PROJECT"} up -d
            fi
        fi
    fi
    sleep 10
    sh "$BASEDIR/node-info.sh" > /dev/null
    if grep -q "VERSION: $ver" "$BASEDIR/../data/snowgem/node.info"; then
        exit 0
    else 
        # failed to update masternode
        exit 2
    fi
fi