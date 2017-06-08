#!/usr/bin/env bash

LOCAL_BACKUP_STORE_DIR="${LOCAL_BACKUP_STORE_DIR:-/backup}"
SERVER_BACKUP_STORE_DIR="${SERVER_BACKUP_STORE_DIR:-/backup/dev}"
BACKUP_DIR="${BACKUP_DIR:-/data/db}"

mkdir -p $LOCAL_BACKUP_STORE_DIR

if [[ $@ == *'-local'* ]]; then
    fileName=$(ls -l $LOCAL_BACKUP_STORE_DIR | awk '{print $9}' | awk '/db_data_/{print}' | sort -r | head -n 1)
    if [[ -z $fileName ]]; then
        echo "Not found backup file" >&2
        exit 1
    fi
else
    fileName=$(cmri -ls $SERVER_BACKUP_STORE_DIR | awk '{if ($1 == "file") print $6}' | awk '/db_data_/{print}' | sort -r | head -n 1)
    if [ $? -ne 0 ]; then
        echo "error with $1" >&2
        exit 1
    fi

    echo "file: $SERVER_BACKUP_STORE_DIR/$fileName"
    if [[ -z $fileName ]]; then
        echo "Not found backup file" >&2
        exit 1
    fi

    echo "downloading file $SERVER_BACKUP_STORE_DIR/$fileName"
    cmri -get $SERVER_BACKUP_STORE_DIR/$fileName $LOCAL_BACKUP_STORE_DIR/$fileName
    if [ $? -ne 0 ]; then
        echo "error with $1" >&2
        exit 1
    fi
fi

echo "extracting file $LOCAL_BACKUP_STORE_DIR/$fileName"
rm -rf ${BACKUP_DIR}/*
7z -y x $LOCAL_BACKUP_STORE_DIR/$fileName -o$BACKUP_DIR
if [ $? -ne 0 ]; then
    echo "error with $1" >&2
    exit 1
fi
