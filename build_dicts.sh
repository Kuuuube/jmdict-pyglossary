#!/bin/bash

mkdir -p data
mkdir -p dst
mkdir -p tmp

python -m venv .venv
source .venv/bin/activate
pip install pyglossary lxml python-idzip

function refresh_source () {
    NOW=$(date '+%s')
    YESTERDAY=$((NOW - 86400)) # 86,400 seconds in 24 hours
    if [ ! -f "data/$1" ]; then
        wget "ftp.edrdg.org/pub/Nihongo/$1.gz"
        gunzip -c "$1.gz" > "data/$1"
    elif [[ $YESTERDAY -gt $(date -r "data/$1" '+%s') ]]; then
        rsync "ftp.edrdg.org::nihongo/$1" "data/$1"
    fi
}

# $1, $2, $3, $4
# input_name, output_name, read_format, write_format
function make_dict () {
    mkdir tmp/$1_stardict
    pyglossary data/$1 tmp/$2_stardict/$2_stardict.ifo --read-format=$3 --write-format=$4
    zip -jr dst/$2_stardict.zip tmp/$2_stardict
}

refresh_source "JMdict_e_examp"
make_dict "JMdict_e_examp" "JMdict_english_with_examples" "JMDict" "Stardict"

refresh_source "JMdict_e"
make_dict "JMdict_e" "JMdict_english" "JMDict" "Stardict"

refresh_source "JMnedict.xml"
make_dict "JMnedict.xml" "JMnedict" "JMnedict" "Stardict"
