## GBackup
![alt tag](https://raw.githubusercontent.com/hmrserver/GBackup/master/preview.png)

## Introduction
GBackup is an automated script which would compress user mentioned Mysql / mariaDB databases ( if mentioned ) and Server files into one file and upload it at Google Drive. It would also clear up the files from google drive which are n days old in the mentioned Folder Name (user can change the number of day(n) here).

# What This Script Does
--------------
This script does some simple tasks:
* The script Installs gdrive if it does not already installed.
* The script Deletes Older files from the mentioned Folder (change DAYSKEEP @ script).
* The script dumps all of your MySQL databases individually.
* The script backs up all of your files (e.g: root of all of your virtual hosts or your important files).
* The script compresses your files and databases to a single archive.
* The script uploads the compressed archive into a folder in your Google Drive account.
* After the upload, the script cleans up the temporary files (dumps, the archive itself locally).

User can configure its settings which would be given at top portion of the script.

### I have tested on Centos-6,7/Redhat-6,7.

# Custom License
--------------
 * User may edit the item.
 * User can't re-distribute the script copy for free or paid.
 * Use it at your own risk. I'm not holding any responsibilities for any damage that this script may do (which shouldn't).

# Requirements
--------------
* `wget` - To download the gdrive installer.
* `mysql` (cli) - To list databases.
* `mysqldump` - To dump databases (in most cases, it comes with `mysql` cli).
* `nano` - To edit the script's Configurations manually.

# Installation
--------------
If you have all the requirements installed.
then Follow the below instructions:

Go to a place where you want to place the script (for now lets say /root/).
```
cd /root/
```

Now Download the Bash script by:
```
wget https://raw.githubusercontent.com/hmrserver/GBackup/master/backup_gdrive.sh
```

Now Give appropriate permissions
```
chmod 600 backup_gdrive.sh
```

Now To edit the Script's Configurations:
```
nano backup_gdrive.sh
```
and edit the Top Part configurations (its well descripted in the script about each options).

after that save it and try to run it first time manually(assuming /root/ was the folder where you came at first).
```
/root/backup_gdrive.sh
```
It would provide you a oauth link, copy and paste the link in your web browser, it will ask for you to login with your gdrive account, just do so then it will generate a key after login, copy and paste it to the terminal (where it was asking for that key).

Now its been ready to be automated.

Simply use it in a Cron and forget about it :D

# For adding in Cron
type this command to enter in the cron editor:
```
crontab -e
```

then press i to start the insert mode and paste this in the last of the editor:
```
00 01,13 * * * /root/backup_gdrive.sh >> /root/backup_log.log 2>&1
```
(replace /root/ with your firstly place where you came).
and then save it by pressing esc then typing :wq and hitting enter.
this cron will run the script twice everyday (at 1:00 & 13:00). and you can see the backup_log.log for crontab logs.
For adjusting the cron according you your need, you can have a look at [here](https://docs.acquia.com/article/cron-time-string-format).
