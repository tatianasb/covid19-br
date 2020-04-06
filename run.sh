#!/bin/bash

set -e
SCRIPT_PATH=$(dirname $(readlink -f $0))
source $SCRIPT_PATH/base.sh

rm -rf $OUTPUT_PATH/*.csv.gz $ERROR_PATH
mkdir -p "$OUTPUT_PATH" "$LOG_PATH" "$ERROR_PATH"
caso_filename="$OUTPUT_PATH/caso.csv.gz"
boletim_filename="$OUTPUT_PATH/boletim.csv.gz"
full_filename="$OUTPUT_PATH/caso-full.csv.gz"
time scrapy runspider consolida.py \
	--loglevel="INFO" \
	--logfile="$LOG_PATH/consolida.log" \
	-a boletim_filename="$boletim_filename" \
	-a caso_filename="$caso_filename"
if [ $(ls $ERROR_PATH/errors-*.csv 2>/dev/null | wc -l) -gt 0 ]; then
	# Some error happened
	exit 255
fi
time python full.py "$caso_filename" "$full_filename"
