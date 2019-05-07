#!/usr/bin/env bash

set -u
set -e

# Variables
## about age
young_man=0  # age < 20
hard_man=0  # 20 <= age <= 30 
old_man=0  # 30 < age
max_age=0
min_age=99999
youngest_man=""
oldest_man=""
## about position
defender=0
forward=0
goalie=0
midfielder=0
## about player name
max_length=0
min_length=99999
longest_name=""
shortest_name=""

function read_variables() {
    line=${line// /_}
    read -ra line < <(echo "${line}")
    position="${line[4]}"
    age="${line[5]}"
    player_name="${line[8]}"
}
function count_age() {
    ((age+=0))
    if ((age > 0))
    then
        if ((age < 20))
        then
            ((young_man+=1))
        elif ((age > 30))
        then
            ((old_man+=1))
        else
            ((hard_man+=1))
        fi
    fi
}
function count_position() {
    case ${position} in
        Defender) ((defender+=1)) ;;
        Forward) ((forward+=1)) ;;
        Goalie) ((goalie+=1)) ;;
        Midfielder) ((midfielder+=1)) ;;
    esac
}
function compare_name() {
    length=${#player_name}
    if [[ ${length} -lt ${min_length} ]]
    then
        min_length=${length}
        shortest_name=${player_name}
    fi
    if [[ ${length} -gt ${max_length} ]]
    then
        max_length=${length}
        longest_name=${player_name}
    fi
}
function compare_age() {
    if [[ ${age} -lt ${min_age} ]]
    then
        min_age=${age}
        youngest_man=${player_name}
    fi
    if [[ ${age} -gt ${max_age} ]]
    then
        max_age=${age}
        oldest_man=${player_name}
    fi
}
function div() {
    echo "scale=2; $1*100/$2" | bc
}
function show_statistics() {
    total=$((young_man + hard_man + old_man))
    echo "总共有${total}位球员. 其中:"
    echo "  20岁以下的球员有${young_man}位, 占比$(div ${young_man} ${total})%"
    echo "  20~30岁以下的球员有${hard_man}位, 占比$(div ${hard_man} ${total})%"
    echo "  30岁以上的球员有${old_man}位, 占比$(div ${old_man} ${total})%"
    echo "  defender有${defender}位, 占比$(div ${defender} ${total})%"
    echo "  forward有${forward}位, 占比$(div ${forward} ${total})%"
    echo "  goalie有${goalie}位, 占比$(div ${goalie} ${total})%"
    echo "  midfielder有${midfielder}位, 占比$(div ${midfielder} ${total})%"
    echo "  名字最短的球员是${shortest_name}, 其名字长度为${min_length}"
    echo "  名字最长的球员是${longest_name}, 其名字长度为${max_length}"
    echo "  最年轻的球员是${youngest_man}, 年龄${min_age}"
    echo "  最年长的球员是${oldest_man}, 年龄${max_age}"
}
function main() {
    while read -r line
    do
        read_variables
        count_age
        count_position
        compare_name
        compare_age
    done < "$1"
    show_statistics
}

main "$@"
