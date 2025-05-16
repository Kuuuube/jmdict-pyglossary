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
        wget -nc "ftp.edrdg.org/pub/Nihongo/$1.gz"
        gunzip -c "$1.gz" > "data/$1"
    elif [[ $YESTERDAY -gt $(date -r "data/$1" '+%s') ]]; then
        rsync "ftp.edrdg.org::nihongo/$1" "data/$1"
    fi
}

function make_dict () {
    local input_name=$1 output_name=$2 read_format=$3 write_format=$4

    mkdir -p tmp/${output_name}_${write_format}
    pyglossary data/${input_name} tmp/${output_name}_${write_format}/${output_name}_${write_format} --read-format=${read_format} --write-format=${write_format}
    zip -jr dst/${output_name}_${write_format}.zip tmp/${output_name}_${write_format}
}

refresh_source "JMdict_e_examp"
make_dict "JMdict_e_examp" "JMdict_english_with_examples" "JMDict" "Stardict"

refresh_source "JMdict_e"
make_dict "JMdict_e" "JMdict_english" "JMDict" "Stardict"

refresh_source "JMnedict.xml"
make_dict "JMnedict.xml" "JMnedict" "JMnedict" "Stardict"
