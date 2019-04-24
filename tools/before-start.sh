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
BOOTSTRAP_URL=""

SPROUT_URL="https://github.com/Snowgem/ModernWallet/releases/download/data"

SPROUT_PKEY_NAME='sprout-proving.key'
SPROUT_VKEY_NAME='sprout-verifying.key'
SAPLING_SPEND_NAME='sapling-spend.params'
SAPLING_OUTPUT_NAME='sapling-output.params'
SAPLING_SPROUT_GROTH16_NAME='sprout-groth16.params'

PARAMS_DIR="$BASEDIR/../data/zcash-params"

fetch_params() {
    filename="$1"
    output="$2"
    dlname="${output}.dl"
    expectedhash="$3"
    if [ -f "$output" ] && printf "%s %s" "$expectedhash" "$output" | sha256sum -c >/dev/null; then
        printf "$output hash OK\n"
        return
    else
        rm -f "$dlname"
        curl --output "$dlname" -# -L -C - "$SPROUT_URL/$filename"

        if printf "%s %s" "$expectedhash" "$dlname" | sha256sum -c > /dev/null; then
            [ -f "$output" ] && rm -rf "$output"
            mv -v "$dlname" "$output"
        else
            echo "Failed to verify parameter checksums!" >&2
            exit 1
        fi
    fi
}

# Sprout parameters:
fetch_params "$SPROUT_PKEY_NAME" "$PARAMS_DIR/$SPROUT_PKEY_NAME" "8bc20a7f013b2b58970cddd2e7ea028975c88ae7ceb9259a5344a16bc2c0eef7"
fetch_params "$SPROUT_VKEY_NAME" "$PARAMS_DIR/$SPROUT_VKEY_NAME" "4bd498dae0aacfd8e98dc306338d017d9c08dd0918ead18172bd0aec2fc5df82"

# Sapling parameters:
fetch_params "$SAPLING_SPEND_NAME" "$PARAMS_DIR/$SAPLING_SPEND_NAME" "8e48ffd23abb3a5fd9c5589204f32d9c31285a04b78096ba40a79b75677efc13"
fetch_params "$SAPLING_OUTPUT_NAME" "$PARAMS_DIR/$SAPLING_OUTPUT_NAME" "2f0ebbcbb9bb0bcffe95a397e7eba89c29eb4dde6191c339db88570e3f3fb0e4"
fetch_params "$SAPLING_SPROUT_GROTH16_NAME" "$PARAMS_DIR/$SAPLING_SPROUT_GROTH16_NAME" "b685d700c60328498fbde589c8c7c484c722b788b265b72af448a5bf0ee55b50"

if [ ! -d "$BASEDIR/../data/snowgem/blocks" ]; then

    if [ -n "$BOOTSTRAP_URL" ]; then
        URL="$BOOTSTRAP_URL"
    fi
    # backup URL
    if [ -z "$URL" ]; then
       printf "Loading default chain snapshot\n"
       curl -L https://github.com/Snowgem/Data/releases/download/0.0.1/blockchain_snowgem_index.zip.sf-part1 -o bc.sf-part1
       curl -L https://github.com/Snowgem/Data/releases/download/0.0.1/blockchain_snowgem_index.zip.sf-part2 -o bc.sf-part2
       curl -L https://github.com/Snowgem/Data/releases/download/0.0.1/blockchain_snowgem_index.zip.sf-part3 -o bc.sf-part3
       curl -L https://github.com/Snowgem/Data/releases/download/0.0.1/blockchain_snowgem_index.zip.sf-part4 -o bc.sf-part4
       printf "Mergin parts..."
       cat bc.sf-part* > blockchain.zip
       printf "Unziping the blockchain..."
       rm bc.sf-part*
       unzip -o blockchain.zip -d "$BASEDIR/../data/snowgem/"
       rm blockchain.zip
       [ -d "$BASEDIR/../data/snowgem/blocks" ] && printf "Chain snapshot loaded\n"
    else
       printf "Loading chain snapshot\n"
       case "$URL" in
       *.tar.gz)
           (cd "$BASEDIR/../data/snowgem/" && \
           curl -L "$URL" -o "./$FILE.tar.gz" && \
           tar -xzvf "./$FILE.tar.gz" && \
           rm -f "./$FILE.tar.gz")
       ;;
       *.zip)
           (cd "$BASEDIR/../data/snowgem/" && \
           curl -L "$URL" -o "./$FILE.zip" && \
           unzip "./$FILE.zip" && \
           rm -f "./$FILE.zip")
       ;;
       esac
       [ -d "$BASEDIR/../data/snowgem/blocks" ] && printf "Chain snapshot loaded\n"
    fi
fi
sh "$BASEDIR/fs-permissions.sh"
exit 0