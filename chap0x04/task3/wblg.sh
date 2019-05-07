#!/usr/bin/env bash

set -u
set -e

function main_without_url() {
    # 输出top100host
    echo "Top 100 host:"
    awk '{sum[$1]+=1} END {for(i in sum) {print "\t",sum[i],i}}' "$1" | sort -n -r -k 1 | head -n 100
    echo
    
    # 输出top100ip
    echo "Top 100 ip:"
    awk '{sum[$1]+=1} END {for(i in sum) {print "\t",sum[i],i}}' "$1" | grep -E "[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]" |  sort -n -r -k 1 | head -n 100
    echo
    
    # 输出top100url
    echo "Top 100 url:"
    awk '{sum[$5]+=1} END {for(i in sum) {print "\t",sum[i],i}}' "$1" | sort -n -r -k 1 | head -n 100
    echo
    
    # 输出不同响应码出现次数及百分比
    echo "Responses:"
    awk '{sum[$6]+=1;total+=1} END {for(i in sum) {printf("\t%d %d %.2f%\n",i,sum[i],sum[i]*100.0/total)}}' "$1" | sort -n -r -k 2
    echo

    # 不同4XX状态码对应的TOP 10 URL和对应出现的总次数
    echo "Top 10 403-url:"
    awk -F '\t' '{if($6~/^403/) sum[$5]+=1} END {for(i in sum){print "\t",sum[i],i}}' "$1" | sort -n -r -k 1 | head -n 10
    echo
    echo "Top 10 404-url:"
    awk -F '\t' '{if($6~/^404/) sum[$5]+=1} END {for(i in sum){print "\t",sum[i],i}}' "$1" | sort -n -r -k 1 | head -n 10
    echo
}

function main_with_url() {
    echo "Top 100 host visit \"$2\":"
    awk -F '\t' '{if($5=="'"$2"'") sum[$1]+=1} END {for(i in sum){print "\t",sum[i],i}}' "$1" | sort -n -r -k 1 | head -n 100
    echo
}

function main() {
    if [[ $# -eq 1 ]]
    then
        main_without_url "$1"
    else
        main_with_url "$1" "$2"
    fi
}

main "$@"
