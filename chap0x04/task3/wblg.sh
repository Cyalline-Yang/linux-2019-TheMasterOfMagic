#!/usr/bin/env bash

set -u
set -e

# Constants
FILENAME=web_log.tsv

# Variables
typeset -A host_to_count=()
typeset -A ip_to_count=()
typeset -A url_to_count=()
typeset -A response_to_count=()
typeset -A url_403_to_count=()
typeset -A url_404_to_count=()

function read_variables() {
    line=(${line})
    host=${line[0]}
    logname=${line[1]}
    time=${line[2]}
    method=${line[3]}
    url=${line[4]}
    response=${line[5]}
    bytes=${line[6]}
}
function count_host() {
    ((host_to_count[${host}]+=1))
}
function count_ip() {
    parts=(${host//./ })
    if [[ ${#parts[@]} -eq 4 ]]
    then
        flag=1
        for part in ${parts[@]}
        do
            if ! [[ $part =~ ^[0-9]{1,3}$ ]]
            then
                flag=0
                break
            fi
        done
        if [[ ${flag} -eq 1 ]]
        then
            ((ip_to_count[${host}]+=1))
        fi
    fi
}
function count_url() {
    url=${url//\[/\\\[}
    url=${url//\`/\\\`}
    url=${url//\"/\\\"}
    url=${url//\'/\\\'}
    ((url_to_count[${url}]+=1))
    if [[ ${response} == "403" ]]
    then
        ((url_403_to_count[${url}]+=1))
    elif [[ ${response} == "404" ]]
    then
        ((url_404_to_count[${url}]+=1))
    fi
}
function count_response() {
    if [[ ${response} = 4* ]]
    then
        ((response_to_count[${response}]+=1))
    fi
}

function main_without_url() {
    while read line
    do
        read_variables
        count_host
        count_ip
        count_url
        count_response
    done < ${FILENAME}

    # 输出top100host
    echo "Top 100 host:"
    for host in ${!host_to_count[@]}
    do
        echo -e "\t${host_to_count[${host}]} ${host}"
    done | sort -n -r -k 1 | head -n 100
    echo

    # 输出top100ip
    echo "Top 100 ip:"
    for ip in ${!ip_to_count[@]}
    do
        echo -e "\t${ip_to_count[${ip}]} ${ip}"
    done | sort -n -r -k 1 | head -n 100
    echo
    
    # 输出top100url
    echo "Top 100 url:"
    for url in ${!url_to_count[@]}
    do
        echo -e "\t${url_to_count[${url}]} ${url}"
    done | sort -n -r -k 1 | head -n 100
    echo
    
    # 输出不同响应码出现次数及百分比
    echo "Responses:"
    total=0
    for count in ${response_to_count[@]}
    do
        ((total+=count))
    done
    for response in ${!response_to_count[@]}
    do
        count=${response_to_count[${response}]}
        rate=$(echo "scale=2;${count}*100/${total}" | bc)\%
        echo -e "\t${count} ${response} ${rate}"
    done | sort -n -r -k 1
    echo

    # 不同4XX状态码对应的TOP 10 URL和对应出现的总次数
    echo "Top 10 403-url:"
    for url_403 in ${!url_403_to_count[@]}
    do
        echo -e "\t${url_403_to_count[${url_403}]} ${url_403}"
    done | sort -n -r -k 1 | head -n 10
    echo
    echo "Top 10 404-url:"
    for url_404 in ${!url_404_to_count[@]}
    do
        echo -e "\t${url_404_to_count[${url_404}]} ${url_404}"
    done | sort -n -r -k 1 | head -n 10
    echo
    
}

function main_with_url() {
    while read line
    do
        line=(${line})
        host=${line[0]}
        url=${line[4]}
        if [[ ${url} == $1 ]]
        then
            ((host_to_count[$host]+=1))
        fi
    done < ${FILENAME}
    echo "Top 100 host visit \"$1\":"
    for host in ${!host_to_count[@]}
    do
        echo -e "\t${host_to_count[${host}]} ${host}"
    done | sort -n -r -k 1 | head -n 100
    echo
}
function main() {
    if [[ $# -eq 0 ]]
    then
        main_without_url
    else
        main_with_url $1
    fi
}

main "$@"