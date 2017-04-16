#!/usr/bin/env bash

ARCHIVE_NAME="${ARCHIVE_NAME:-db_data_$(date +%Y_%m_%d-%H_%M_%S).tar}"
LOCAL_BACKUP_STORE_DIR="${LOCAL_BACKUP_STORE_DIR:-/backup}"
SERVER_BACKUP_STORE_DIR="${SERVER_BACKUP_STORE_DIR:-/backup/dev}"
BACKUP_DIR="${BACKUP_DIR:-/data/db}"

LOCAL_BACKUP_FILE="$LOCAL_BACKUP_STORE_DIR/$ARCHIVE_NAME"
SERVER_BACKUP_FILE="$SERVER_BACKUP_STORE_DIR/$ARCHIVE_NAME"

if [[ -z $MONGO_URL ]]; then
    echo "Not defined variable MONGO_URL" >&2
    exit 1
fi

cmri -ls $SERVER_BACKUP_STORE_DIR
if [ $? -ne 0 ]; then
    echo "error with $1" >&2
    exit 1
fi

mkdir -p $LOCAL_BACKUP_STORE_DIR

lock_mongo() {
    mongo $MONGO_URL $MAIN_DIR/lock-mongo.js
    if [ $? -ne 0 ]; then
        echo "error with $1" >&2
        exit 1
    fi
    echo 'lock mongo'
}

unlock_mongo() {
    mongo $MONGO_URL $MAIN_DIR/unlock-mongo.js
    if [ $? -ne 0 ]; then
        echo "error with $1" >&2
        exit 1
    fi
    echo 'unlock mongo'
}

archiving() {
    echo "archiving into $LOCAL_BACKUP_FILE"
    tar cvf $LOCAL_BACKUP_FILE -C $BACKUP_DIR .
    if [ $? -ne 0 ]; then
        echo "error with $1" >&2
        unlock_mongo
        exit 1
    fi
    echo "archived directory $BACKUP_DIR into file $LOCAL_BACKUP_FILE"
}

send_file() {
    retries=$1
    echo "send file $SERVER_BACKUP_FILE retries $retries"
    cmri -put "$LOCAL_BACKUP_FILE" $SERVER_BACKUP_FILE
    if [ $? -ne 0 ]; then
        if (( retries > 0 )); then
            (( --retries ))
            send_file $retries
        else
            echo "error sent file $SERVER_BACKUP_FILE with retries $1" >&2
            exit 1
        fi
    fi
    echo "sent file on server $SERVER_BACKUP_FILE in retries $retries"
}

lock_mongo
archiving
unlock_mongo
send_file 3

echo "list files in cloud $SERVER_BACKUP_STORE_DIR"
cmri -ls $SERVER_BACKUP_STORE_DIR
