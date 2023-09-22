#! /bin/bash
# 
#
# This is going to be my HACCP auto update script for HUGO
#
#

if [[ $# > 0 ]]; then
    days_ago=$(($1 * 7 - 1))
else
    days_ago=-1
fi

set_date=(\
    $(date -d "$days_ago days ago last Sunday" +%d-%m-%Y) \
    $(date -d "$days_ago days ago last Sunday" +%Y) \
    $(date -d "$days_ago days ago last Sunday" +%m) \
    $(date -d "$days_ago days ago last Sunday" +%d) \
    $(date -d "$days_ago days ago last Sunday" +%V) \
    $(date -d "$days_ago days ago last Sunday" +%Y%V) \
    $(date -d "$days_ago days ago last Sunday" +%Y%m%d))

days=(\
    $(date -d "${set_date[6]} + 0 days" +%Y%m%d) \
    $(date -d "${set_date[6]} + 1 days" +%Y%m%d) \
    $(date -d "${set_date[6]} + 2 days" +%Y%m%d) \
    $(date -d "${set_date[6]} + 3 days" +%Y%m%d) \
    $(date -d "${set_date[6]} + 4 days" +%Y%m%d) \
    $(date -d "${set_date[6]} + 5 days" +%Y%m%d) \
    $(date -d "${set_date[6]} + 6 days" +%Y%m%d))

if [ $(date +%s) -le $(date -d ${days[6]} +%s) ];
then
    now=$(date +%Y%m%d)
else
    now=${days[6]}
fi

ontvangen=(\
    "0, Spar-KW, 5, DPater" \
    "0, Spar-Vers, 2, DPater" \
    "0, Spar-Diepvries, -20, DPater" \
    "1, Weidenaar, 2, DPater" \
    "2, Spar-KW, 5, WPater" \
    "2, Spar-Vers, 2, WPater" \
    "2, Spar-Diepvries, -20, WPater" \
    "4, Spar-KW, 5, WPater" \
    "4, Spar-Vers, 2, WPater" \
    "4, Spar-Diepvries, -20, WPater" \
    "4, Drents-eitje, 4, WPater" \
    "4, Huls, 3, WPater"
)

IFS=$'\n' ontvangen=($(sort <<<"${ontvangen[*]}")); unset IFS

temp_it () {
    num=$((${set_date[1]}%$((${set_date[2]#0}+${set_date[3]#0}+$2+$3))%21))
    printf %.1f "$(($((10**3 * $1*1))-$((10**3 * $num/10))))e-3" 
    echo "°C"
}

ret () {
    for index in "${!ontvangen[@]}"
    do
        IFS=', ' read -ra ontvangst <<< "${ontvangen[index]}"
        if [ $(date -d ${days[${ontvangst[0]}]} +%s) -le $(date +%s) ];
        then
            echo "| $(date -d ${days[${ontvangst[0]}]} +%A) | ${ontvangst[1]} | $(temp_it ${ontvangst[2]} 1 $index) | &check; | &check; | | ${ontvangst[3]} |"
        fi
    done
}

path="../spar-haccp-website/content/haccp/${set_date[1]}/"
mkdir -p $path
cat > "$path${set_date[5]}-ontvangst.md" <<-EOF
---
title: 'Ontvangst goederen ${set_date[4]} jaar ${set_date[1]}'
date: $(date -d "$now" "+%F")
description: 'Ontvangst logboek'
categories:
    - 'HACCP'
tags:
    - '${set_date[1]}'
    - '${set_date[4]}'
    - '${set_date[5]}'
    - 'Ontvangst'
---
| Dag | Leverancier | Temp | tht OK | verpakking OK | Actie bij afwijking | Controle door |
|:---|:---|:---|:---|:---|:---|:---|
$(printf "%s\n" "$(ret)")

## Opmerkingen


EOF

# Update website
cd ../spar-haccp-website/