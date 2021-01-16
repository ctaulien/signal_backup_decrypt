#!/bin/bash

CUR_DIR=$(pwd);
SCRIPT_DIR=$(dirname "$0")
cd ${SCRIPT_DIR}
echo @ARGS

# user help output function
function usage {
    cat <<"EndOfCommand"

This script descrypts a signal backup

EndOfCommand
    echo "USAGE: ${PR} [-f backup-filename] [-d target-dir] [-c] -p passphrase"
    echo "USAGE:   -f <s>       Filename of backup"
    echo "USAGE:   -d <s>       Target directory for decrypted backup"
    echo "USAGE:   -p <s>       passphrase of encrypted signal backup"
    echo "USAGE:   -c           make a change owner to current user for result"
    echo
    exit 1
}

PASS=
CHOWN=
FILE=
DECRYPT_PATH=$(pwd)/signal_backups_decrypted/

# parse options
while getopts "f:d:p:c" opt; do
    case $opt in
        f)  FILE="${OPTARG}"
            ;;
        d)  DECRYPT_PATH="${OPTARG}"
            ;;
        p)  PASS="${OPTARG:-}"
            ;;
        c)  CHOWN="; chown -r $(id -u):$(id -g) /signal_backup_decrypted/"
            ;;
        \?) usage
            ;;
    esac
done

# no pass, no parse
if [ -z "${PASS}" ]; then
    usage
fi

# if no file is specified search for most recent in local folder
if [ -z "${FILE}" ]; then
    FILE=$(ls -t1 $(pwd)/signal_backups/signal-*.backup | head -n1)
    if [ ! -f "${FILE}" ]; then
        echo "no backup file found"
        exit;
    fi
fi

ENCRYPT_PATH=$(dirname ${FILE})
ENCRYPT_FILE=$(basename ${FILE})

mkdir -p ${DECRYPT_PATH}/$(date +'%Y-%m-%d')

CMD="rm -rf /signal_backup_decrypted/* && /home/ctaulien/.cargo/bin/signal-backup-decode /signal_backups/${ENCRYPT_FILE} --output-path /signal_backup_decrypted/ -p ${PASS} -f ${CHOWN}"

docker run --rm -u 1010:409 -it -v ${ENCRYPT_PATH}:/signal_backups:Z -v ${DECRYPT_PATH}/$(date +'%Y-%m-%d'):/signal_backup_decrypted:Z --name signal signal_back bash -c "${CMD}"

cd ${CUR_DIR}
