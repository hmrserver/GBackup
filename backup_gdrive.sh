#!/bin/bash

#Please note this script,I have been tested on Centos-6,7/Redhat-6,7.


######################################################################################################################################
# Change the below mentioned server details to your own Server - Database Details, Backup Local Path, Remote Backup Path Name, And WeB Server FDirectory Path.
######################################################################################################################################

#Database credentials
enable_db_backup="yes" # options: yes /  no, Choose whether you want's to backup databases also or not.
database_user="root"  # feed your Database User
database_password=' ' # feed your Database password if any
database_host="localhost"
database_port="3306"  #feed your Database PORT, leave like this if you don't know

#Define local path for backups
backup_tmp="/tmp/Server_Backup" # IMPORTANT: Only Put a Empty Folder Name (which would be used to store temp compressed files and all files would be deleted after backup!)

#Define remote backup path (which would be seen at Google DRIVE)
backup_folder="Files & MySQL Backup"

#Define Prefix used before backup filenames
PREFIX="Gbackup_" # feed the prefix which you wants to be shown at your Google Drive backuped comressed files.. leave empty if you don't want ant prefix.

#Web Server Folder Path which needs to be backuped, you can use multiple paths seperated by spaces.
file_paths="/var/www"

#Days to retain - In the DAYSKEEP variable you can specify how many days of backups you would like to keep, any older ones will be deleted from Google Drive.
#Set 0 for Not limiting backups
DAYSKEEP=300

#################################################################################################################################

echo "---------------------------------------------------------"
echo '    _____   ____                _      _    _  _____  '
echo '   / ____| |  _ \              | |    | |  | ||  __ \ '
echo '  | |  __  | |_) |  __ _   ___ | | __ | |  | || |__) |'
echo '  | | |_ | |  _ <  / _` | / __|| |/ / | |  | ||  ___/ '
echo '  | |__| | | |_) || (_| || (__ |   <  | |__| || |     '
echo '   \_____| |____/  \__,_| \___||_|\_\  \____/ |_|     '
echo '                                                      '
echo "  Created by HMR (https://github.com/hmrserver)"
echo "---------------------------------------------------------"
echo " "



#Check Internet Connection
IS=`/bin/ping -c 5 4.2.2.2 | grep -c "64 bytes"`

if (test "$IS" -gt "2") then
        internet_conn="1"

#Check File
file="/usr/bin/gdrive"
if [ -f "$file" ]
then
  echo " "
  echo "Gdrive Found!"
  echo " "
else

  echo "Gdrive Not Found!"
  echo "Installing Gdrive....."
  echo " "

#Download And Install Gdrive
if [ `getconf LONG_BIT` = "64" ]
then
        wget "https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download" -O /usr/bin/gdrive
        chmod 777 /usr/bin/gdrive
	gdrive list
	clean
else
        wget "https://docs.google.com/uc?id=0B3X9GlR6EmbnLV92dHBpTkFhTEU&export=download" -O /usr/bin/gdrive
        chmod 777 /usr/bin/gdrive
	gdrive list
	clean
fi
fi

	echo "Backup Process Starting......................."
  echo " "


#Date prefix
DATEFORM=$(date +"%d-%m-%Y")

#Calculate days as filename prefix
DAYSKEPT=$(date +"%Y-%m-%d" -d "-$DAYSKEEP days")

#Make sure the backup folder exists
mkdir -p $backup_tmp



    ## Find Folder ID if exists
  folderData=$(gdrive list -q "mimeType = 'application/vnd.google-apps.folder' AND name='$backup_folder' AND trashed=false" --no-header)

  ## If folder does not exist create new folder.
  if [[ -z "${folderData// }" ]]
  then
  	echo "$backup_folder Folder not found"
      echo "Creating Folder: $backup_folder"
  	echo " "
      new_folder=$(gdrive mkdir --parent "$backup_folder")
      new_folder=($new_folder)
      folderID=${new_folder[1]}
  else
      folder_data=($folderData)
      folderID=${folder_data[0]}

      if [[ -n "${folderID// }" ]]
      then
          #execute if the the variable is not empty and contains non space characters
          echo "FOLDER EXISTS - ID: $folderID"
          echo " "
      else
          #execute if the variable is empty or contains only spaces
          echo "ERROR CREATING FOLDER"
          echo " "
      fi

  fi

    if [ ! $DAYSKEEP=0 ]; then
    #Delete old backup, get folder id and delete if exists
    expired_backups=`gdrive list -m 1000 --query " ('$folderID' in parents) and trashed = false and modifiedTime < '$DAYSKEPT'" --order "modifiedTime asc" --no-header | cut -d ' ' -f1`;

    # Deletes backups that are more than n days old.
    if [[ -n $expired_backups ]]
    then
    echo " "
    echo "-----------------------"
    echo "Deleting FILES from $backup_folder, which are $DAYSKEEP days Older"
    while read -r backup_id; do
        echo Deleting $backup_id...
        gdrive delete --recursive $backup_id
    done <<< "$expired_backups"
    echo "-----------------------"
    echo " "
    echo " "
  fi

fi

    #Create the local backup folder if it doesn't exist
    if [ ! -e $backup_tmp ]; then
      echo " "
      echo "Local Path For Backups Not Found!"
      echo "creating one..."
      echo " "
        mkdir $backup_tmp
    fi

    if [ $enable_db_backup = "yes" ]; then
      echo " "
      echo "Backuping the DATABASES"
      echo "-----------------------"
        #Create the local mysql backup folder if it doesn't exist
        if [ ! -e $backup_tmp/mysql ]; then
          mkdir $backup_tmp/mysql
        fi

               # Let's start dumping the databases
                 databases=$(mysql --host="$database_host" --port="$database_port" --user="$database_user" --password="$database_password" -e "SHOW DATABASES;" 2>&1 | grep -v "Warning: Using a password" | tr -d "| " | grep -v Database)
                 for db in $databases; do
                     if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
                         echo "-> Dumping database: $db"
                         mysqldump --compress --host="$database_host" --port="$database_port" --user="$database_user" --password="$database_password" --events $db > $backup_tmp/mysql/$db.sql 2>&1 | grep -v "Warning: Using a password"
                     fi
             	done

    fi
    echo "-----------------------"
    echo " "

    #Back up the Web folder
    if [ ! -e $backup_tmp/files ]; then
      mkdir $backup_tmp/files
    fi
    cd $backup_tmp
    echo " "
    echo "Compressing all files for Upload....."
    if [ $enable_db_backup = "yes" ]; then
       mysql="mysql"
    else
      mysql=""
      fi
    tar -czf $backup_tmp/$PREFIX$DATEFORM.tar.gz $mysql $file_paths
    echo " "


    #Upload Server Data & Mysql database tar
    echo " "
    echo "-----------------------"
    echo "Uploading $PREFIX$DATEFORM.tar.gz at Google Drive..."
    gdrive upload --parent $folderID --delete $PREFIX$DATEFORM.tar.gz
    echo "-----------------------"

    #Final Cleanup
    echo " "
    echo "Clearing Junk files..."
    chmod -R 777 /tmp/*
    echo "-> Removing $backup_tmp"
    rm -rf $backup_tmp
    echo "Done!"
    echo " "

    #Dispaly Internet Connection Error Message
else
   internet_conn="0"

   echo "#################################### Please Check Your Internet Connection. #######################################"
   echo "-------------------------------------------------------------------------------------------------------------------"
fi
