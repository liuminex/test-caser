#!/bin/bash

# usage: ./test.sh [options] <program_name>
# test cases must have format: input*.txt and output*.txt

testpath=testcases/
mem_limit_KB=65535
time_limit_ms=1000

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m'

show_help() {
    echo "Usage: ./$(basename "$0") [OPTIONS] <program_name>"
    echo "Options:"
    echo "  -h: help"
    echo "  -t: time limit (in ms, default: $time_limit_ms)"
    echo "  -m: memory limit (in KB, default: $mem_limit_KB)"
    echo "  -p: testcase path (relative to this script, or absolute, default (relative): $testpath)"
    exit 0
}

while getopts ":ht:m:p:" opt; do
  case $opt in
    h)
      show_help
      exit 0
      ;;
    p)
      testpath=$OPTARG
      ;;
    t)
      time_limit_ms=$OPTARG
      ;;
    m)
      mem_limit_KB=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
    :)
      echo "Invalid option: -$OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done

if [ -z "${!OPTIND}" ]; then
    echo "Error: <program_name> is required."
    show_help
fi

myprogram="${!OPTIND}"

echo -e "time limit:${LIGHT_BLUE} $time_limit_ms ms${NC}"
echo -e "memory limit:${LIGHT_BLUE} $mem_limit_KB KB${NC}"
echo -e "testcase path:${LIGHT_BLUE} $testpath${NC}"
echo "+--------------------------------------+"



rm -f ${testpath}output*_generated342463.txt

for input_file in $(ls -v ${testpath}input*.txt)
do
	intro="~ $input_file"
    echo $intro
	test_number=$(echo "$input_file" | sed 's/.*input\([0-9]\+\).txt/\1/')
	output_file="${testpath}output${test_number}.txt"
    output_generated_file="${testpath}output${test_number}_generated342463.txt"

    start_time=$(date +%s%N)
    ./${myprogram} < "$input_file" > "$output_generated_file"
    end_time=$(date +%s%N)
    elapsed_time_ms=$(( (end_time - start_time) / 1000000 ))


    memory_usage=$(ps -o rss= -p $$)
    memory_usage_kb=$((memory_usage / 1024))


    if (($memory_usage > $mem_limit_KB));
    then 
        echo -e "${RED}FAIL\n${YELLOW}Memory limit exceeded${NC}"
        rm -f ${testpath}output*_generated342463.txt
        echo -e "${LIGHT_BLUE}[time: $elapsed_time_ms ms, mem: $memory_usage_kb KB]${NC}"
        exit
    fi

    if (($elapsed_time_ms > $time_limit_ms));
    then 
        echo -e "${RED}FAIL\n${YELLOW}Time limit exceeded${NC}"
        rm -f ${testpath}output*_generated342463.txt
        echo -e "${LIGHT_BLUE}[time: $elapsed_time_ms ms, mem: $memory_usage_kb KB]${NC}"
        exit
    fi

    thediff=$(diff "$output_generated_file" "$output_file")
    
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}PASS${NC}"
        echo -e "${LIGHT_BLUE}[time: $elapsed_time_ms ms, mem: $memory_usage_kb KB]${NC}"
    else
        echo -e "${RED}FAIL\n${YELLOW}$thediff${NC}"
        rm -f ${testpath}output*_generated342463.txt
        echo -e "${LIGHT_BLUE}[time: $elapsed_time_ms ms, mem: $memory_usage_kb KB]${NC}"
        exit
    fi
done

rm -f ${testpath}output*_generated342463.txt
exit

