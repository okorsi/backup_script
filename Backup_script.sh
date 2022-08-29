#!/bin/bash

now=$(date +%d-%m-%Y)
server=ENTER SERVER ALIAS NAME
tar_file=/tmp/$server-$now.tar.gz
user=$(whoami)

# backup server home directory in /tmp on server
ssh $server tar -zcvpf "$tar_file" /Users/$user

# make local backup directories, if it does not exist then create it
sudo mkdir -p /backup/archive

# check if backup directory has user priviliges, and provide them if not
if [[ ! -O /backup ]]
then
	sudo chown -R "$USER": /backup
fi

echo -e "\nSynchronizing $tar_file file\n"

rsync -vh $server:/tmp/$server-*tar.gz /backup

count_back=$(find /backup/$server*.tar.gz -type f 2> /dev/null | wc -l)
count_arch=$(find /backup/archive/$server*.tar.gz -type f 2> /dev/null | wc -l)

# if 7+ backups exist, clear out the last 7+ archives, and move the recent 7+ tar files into the archive folder.
if (( count_back >= 7 ))
then
        if (( count_arch > 0 ))
        then
                if rm /backup/archive/$server*.tar.gz && mv /backup/$server*.tar.gz /backup/archive
                then
                echo -e "\n7+ files moved to /backup/archive directory & archive cleaned\n"
                fi
        else
                if mv /backup/$server*.tar.gz /backup/archive
                then
                        echo -e "\n7+ files moved to /backup/archive\n" 
                fi
        fi
fi

# Remove temporary file
if ssh $server rm "$tar_file"
then
	echo -e "\nRemoved $tar_file file from server"
fi
