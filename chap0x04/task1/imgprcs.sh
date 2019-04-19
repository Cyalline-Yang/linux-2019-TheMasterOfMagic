#!/usr/bin/env bash

# Constants
TOOL_NAME=imgprcs
## Return Codes
RC_OK=0
RC_ILLEGAL_OPTION=1
RC_EMPTY_PATH=2
RC_CONVERT_ERROR=3

# Variables
INPUT=""
OUTPUT=""
FILETYPE=""
QUALITY=""
RESOLUTION=""
WATERMARK=""
FORMAT=""
PREFIX=""
SUFFIX=""
## Flags
FLAG_HELP=0
FLAG_ERROR=0

# Functions
## About help
function show_help() {
    function strong() {
        echo -e "\033[1m$1\033[0m"
    }
    function underline() {
        echo -e "\033[4m$1\033[0m"
    }
    echo "Usage:"
    echo "  `strong ${TOOL_NAME}` [options] "
    echo "Options:"
    echo "  `strong -h`, `strong --help`"
    echo "      show this help info"
    echo "  `strong -i` `underline path`, `strong --input` `underline path`"
    echo "      path to input file or the directory that contains all the input files"
    echo "  `strong -q` `underline quality`, `strong --quality`=`underline quality`"
    echo "      compress quality of input file(s) to `underline quality`"
    echo "  `strong -r` `underline width`x`underline height`, `strong --resize`=`underline width`x`underline height`"
    echo "      resize input file(s) to `underline width`x`underline height`"
    echo "  `strong -w` `underline pos`-`underline fill`-`underline text`, `strong --watermark`=`underline pos`-`underline fill`-`underline text`"
    echo "      add watermark on input file(s)"
    echo "      avaliable `underline pos` value:"
    echo "          1 2 3 --- ↖ ↑ ↗"
    echo "          4 5 6 --- ← · →"
    echo "          7 8 9 --- ↙ ↓ ↘"
    echo "  `strong -f` `underline format`, `strong --format`=`underline format`"
    echo "      specify the format of output file(s)"
    echo "  `strong -p` `underline prefix`, `strong --prefix`=`underline prefix`"
    echo "  `strong -s` `underline suffix`, `strong --suffix`=`underline suffix`"
    echo "      add prefix and/or suffix on the filename of output file(s)"
}
## About parse options
function parse_input() {
    INPUT=$1
    if [ -d $1 ] || [ -f $1 ]
    then
        INPUT=$1
    else
        error "cannot find file or directory: \"$1\""
    fi
}
function parse_quality() {
    if [[ $1 = "" ]]
    then
        error "empty `underline quality`"
    fi
    if [[ $1 =~ ^[0-9]+(\.[0-9]+)?$ ]]
    then
        QUALITY=$1
    else
        error "invalid `underline quality`: \"$1\""
    fi
}
function parse_resolution() {
    if [[ $1 = "" ]]
    then
        error "empty `underline resolution`"
    fi
    if [[ $1 =~ ^[0-9]+x[0-9]+$ ]]
    then
        RESOLUTION=$1
    else
        error "invalid `underline resolution`: \"$1\""
    fi
}
function parse_watermark() {
    WATERMARK=(${1//-/ })
    POS=${WATERMARK[0]}
    if [ 1 -le ${POS} ] && [ ${POS} -le 9 ]
    then
        :  # do nothing
    else
        error "invalid watermark position: ${POS}"
    fi
}
function parse_format() {
    FORMAT=`echo $1 | tr "A-Z" "a-z"`  # 转为小写
    if [[ ${FORMAT} != "jpg" ]] && [[ ${FORMAT} != "png" ]]
    then
        error "invalid format: \"${FORMAT}\" (only \"jpg\" and \"png\" are supported)"
    fi
}
function parse_prefix() {
    if [[ $1 = "" ]]
    then
        error "empty prefix"
    else
        PREFIX=$1
    fi
}
function parse_suffix() {
    if [[ $1 = "" ]]
    then
        error "empty suffix"
    else
        SUFFIX=$1
    fi
}
function parse_short_option() {
    rc=2
    PARAM=${1:1}  # 截取从下标1开始的部分
    VALUE=${2:-}
    case ${PARAM} in
        h)  FLAG_HELP=1; rc=1 ;;
        i)  parse_input ${VALUE} ;;
        q)  parse_quality ${VALUE} ;;
        r)  parse_resolution ${VALUE} ;;
        w)  parse_watermark ${VALUE} ;;
        f)  parse_format ${VALUE} ;;
        p)  parse_prefix ${VALUE} ;;
        s)  parse_suffix ${VALUE} ;;
        *)  if [ "${PARAM}" = "" ]
            then
                error "empty short param"
            else
                error "illegal option: \"${PARAM}\""
            fi
    esac
    return ${rc}
}
function parse_long_option() {
    PARAM=${1:2}  # 截取从下标2开始的部分
    VALUE=""
    # 如果包含等号则需要进行分割
    if [[ ${PARAM} =~ (.*)=(.*) ]]
    then
        PARAM=(${PARAM//=/ })  # 将等号替换为空格并形成数组
        VALUE=${PARAM[1]}
        PARAM=${PARAM[0]}
        rc=2
    else
        rc=1
    fi
    case ${PARAM} in
        help)       FLAG_HELP=1 ;;
        input)      parse_input ${VALUE} ;;
        quality)    parse_quality ${VALUE} ;;
        resolution) parse_resolution ${VALUE} ;;
        watermark)  parse_watermark ${VALUE} ;;
        format)     parse_format ${VALUE} ;;
        prefix)     parse_prefix ${VALUE} ;;
        suffix)     parse_suffix ${VALUE} ;;
        *)  if [ "${PARAM}" = "" ]
            then
                error "empty long param"
            else
                error "illegal option: \"${PARAM}\""
            fi
    esac
    return ${rc}
}
## About errors and warnings
function error() {
    # show error info and set flag to 1
    >&2 echo -e "[ERROR] ${TOOL_NAME}: $1"
    FLAG_ERROR=1
}
function warn() {
    # show warn info and do nothing
    >&2 echo -e "[WARN] ${TOOL_NAME}: $1"
}
## About main
function main {
    # Parse Arguments
    while [ "${1:-}" != "" ]; do
        if [[ $1 =~ --(.*) ]]
        then
            parse_long_option $@
            shift $?
        elif [[ $1 =~ -(.*) ]]
        then
            parse_short_option $@
            shift $?
        else
            error "illegal option -- ${1}"
            shift
        fi
    done
    if [[ "${INPUT}" = "" && ${FLAG_HELP} = 0 ]]
    then
        error "empty input path"
    fi
    if [[ "${FORMAT}" == "" && ${INPUT##*.} != "" ]]
    then
        parse_format ${INPUT##*.}
    fi
    if [[ "${FORMAT}" != "" && "${FORMAT}" == "${INPUT##*.}" ]]
    then
        PREFIX="imgprcs_"
        warn "same filename of the input file and the output file. Default prefix was added"
    fi
    
    # Act
    ## if we just need to show help info
    if [[ ${FLAG_HELP} = 1 ]]
    then
        show_help
        exit ${RC_OK}
    fi
    ## else if there's something wrong with the arguments
    if [[ ${FLAG_ERROR} = 1 ]]
    then
        echo
        >&2 show_help
        exit ${RC_ILLEGAL_OPTION}
    fi
    ## else we can do our jobs
    if [ -d ${INPUT} ]
    then
        for FILENAME in `ls ${INPUT}`
        do
            FILETYPE=${FILENAME##*.}
            FILETYPE=`echo ${FILETYPE} | tr "A-Z" "a-z"`  # 转为小写
            if [[ ${FILETYPE} = jpg || ${FILETYPE} = jpeg || ${FILETYPE} = png || ${FILETYPE} = svg ]]
            then
                COMMAND="$0 -i ${INPUT}/${FILENAME}"
                # qrwfps
                if [[ ${QUALITY} != "" ]]; then COMMAND="${COMMAND} -q ${QUALITY}"; fi
                if [[ ${RESOLUTION} != "" ]]; then COMMAND="${COMMAND} -r ${RESOLUTION}"; fi
                if [[ ${WATERMARK} != "" ]]; then COMMAND="${COMMAND} -w ${WATERMARK}"; fi
                if [[ ${FORMAT} != "" ]]; then COMMAND="${COMMAND} -f ${FORMAT}"; fi
                if [[ ${PREFIX} != "" ]]; then COMMAND="${COMMAND} -p ${PREFIX}"; fi
                if [[ ${SUFFIX} != "" ]]; then COMMAND="${COMMAND} -s ${SUFFIX}"; fi
                `${COMMAND}`
            fi
        done
        exit ${RC_OK}
    else
        :  # just go down
    fi
    
    cd `dirname ${INPUT}`
    INPUT=`basename ${INPUT}`
    COMMAND="convert ${INPUT}"
    ## Compress Quality
    if [[ "${QUALITY}" != "" ]]
    then
        COMMAND="${COMMAND} -quality ${QUALITY}"
    fi
    ## Resize
    if [[ "${RESOLUTION}" != "" ]]
    then
        COMMAND="${COMMAND} -resize ${RESOLUTION}"
    fi
    ## Add Watermark
    if [[ "${WATERMARK}" != "" ]]
    then
        GRAVITIES=(undefined \
        northwest north northeast \
        west center east \
        southwest south southeast \
        )
        COMMAND="${COMMAND} \
        -gravity ${GRAVITIES[${WATERMARK[0]}]} \
        -fill ${WATERMARK[1]} \
        -pointsize 32 \
        -annotate 0 ${WATERMARK[2]}"
    fi
    ## Convert Format
    OUTPUT=${INPUT%.*}.${FORMAT}
    COMMAND="${COMMAND} ${OUTPUT}"
    `${COMMAND}`

    COMMAND="mv ${OUTPUT} "
    ## Add prefix and suffix
    if [[ "${PREFIX}" != "" ]]
    then
        OUTPUT=${PREFIX}${OUTPUT}
    fi
    if [[ "${SUFFIX}" != "" ]]
    then
        OUTPUT=${OUTPUT}${SUFFIX}
    fi
    COMMAND="${COMMAND} ${OUTPUT}"
    `${COMMAND}`
}

# Entry point
main $@
