#!/bin/bash

set -e
SCRIPT_PATH=$(dirname $(readlink -f $0))
source $SCRIPT_PATH/base.sh
DATASET="covid19"

function upload_table_file() {
	table=$1

	log "[$table] Copying data to static file server"
	s3cmd put data/output/${table}.csv.gz s3://dataset/$DATASET/${table}.csv.gz
}

function update_table() {
	table=$1

	# TODO: change collect-date on update command
	log "[$table] Executing update command"
	ssh $BRASILIO_SSH_USER@$BRASILIO_SSH_SERVER "$BRASILIO_UPDATE_COMMAND $DATASET $table"
}

log "Cleaning data path and collecting data"
./run.sh

source $SCRIPT_PATH/.env
for table in boletim caso; do
	upload_table_file $table
	update_table $table
done
upload_table_file "caso-full"

log "Generating file list page"
python create_html.py dataset $DATASET $(date +"%Y-%m-%d") $SCRIPT_PATH/data/output/
s3cmd put data/output/SHA512SUMS s3://dataset/$DATASET/SHA512SUMS
s3cmd put data/output/_meta/list.html s3://dataset/$DATASET/_meta/list.html

log "Update complete! :) Creating report..."
tempfile=$(mktemp)
python report.py api | tee $tempfile
if [ ! -z "$ROCKETCHAT_USER_ID" ] && [ ! -z "$ROCKETCHAT_AUTH_TOKEN=" ]; then
	python $SCRIPT_PATH/bot/rocketchat.py \
		--user_id $ROCKETCHAT_USER_ID \
		--auth_token $ROCKETCHAT_AUTH_TOKEN \
		"#covid19-anuncios" "$(cat $tempfile)"
fi
rm -rf $tempfile
