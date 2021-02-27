#!/bin/bash
#
# Author: Starke427
# Modified: 2021 Feb 26
#

# ------------------------------------------------------------
# -- Install dependencies
# ------------------------------------------------------------

cat << EOF

Before we can start gathering forensic data there are a couple tools we need to ensure are installed.

If you'd like to grab command history, please ensure you've run 'history -w' prior to running this script.

EOF

function aptInstall() {
if ! command -v tree &>/dev/null
then
	echo "In order to leverage the Linux command 'tree' you will need to enable the universe repository for Ubuntu."
	read -p "Would you like to add the universe repo and install tree? [Y/n] " response
	case $response in [yY][eE][sS]|[yY]|[jJ]|'')

		echo
		sudo add-apt-repository universe
		sudo apt update
		sudo apt install tree
		;;
		*)
		echo
		echo "The universe repo will not be added."
		echo "Your output will be missing some data where tree would have been used."
		echo
	esac
fi
}


function yumInstall() {
yum install lsof tree -y
}

operatingSystem=$(hostnamectl | grep System | cut -d " " -f5)
if [ $operatingSystem == CentOS ]; then
  echo "Preparing YUM Installation...
  "
  yumInstall
elif [ $operatingSystem == Ubuntu ]; then
  echo "Checking APT Dependencies...
  "
  aptInstall
else
  echo "Unable to identify the current operating system. Please ensure the system is either CentOS or Ubuntu."
fi

#lsof
#tree

# ------------------------------------------------------------
# -- Setup parameters
# ------------------------------------------------------------

TIMESTAMP=$(date +"%Y_%m_%d_%H%M")
OUTDIR=Output_$TIMESTAMP
mkdir -p $OUTDIR
env_file="$OUTDIR/env_info.txt"
shell_file="$OUTDIR/shell_info.txt"
user_file="$OUTDIR/user_info.txt"
system_file="$OUTDIR/system_info.txt"
history_file="$OUTDIR/history_info.txt"
crontab_file="$OUTDIR/crontab_info.txt"
process_file="$OUTDIR/process_info.txt"
network_file="$OUTDIR/network_service.txt"
network_config="$OUTDIR/network_config.txt"
install_file_info="$OUTDIR/install_file.txt"
timeline_file="$OUTDIR/timeline.txt"
interest_file="$OUTDIR/files_of_interest.txt"
http_file="$OUTDIR/HTTP_SERVER_info.txt"
abnormal_file="$OUTDIR/nouser_nogroup_info.txt"

# ------------------------------------------------------------
# -- Start the procedure
# ------------------------------------------------------------

cat << EOF

Starting forensic collection...

EOF

# Save the command history, if existed
echo "[COMMAND HISTORY LIST]" >> $history_file 
cat $HISTFILE >> $history_file


# Fetch environment variables
echo "[ENVIRONMENT VARIABLES]" >> $env_file
env >> $env_file
echo -e "\n" >> $env_file
#echo "[SHELL VARIABLES]" >> $env_file
#set >> $env_file


# Fetch shell config file
echo "[SHELL]" >> $shell_file
echo -e "\n" >> $shell_file

# /etc/profile
if [ -e "/etc/profile" ] ; then
    echo "[/etc/profile]" >> $shell_file
    cat /etc/profile >> $shell_file
    echo -e "\n" >> $shell_file
fi

# /root/.bash_profile
if [ -e "/root/.bash_profile" ] ; then
    echo "[/root/.bash_profile]" >> $shell_file
    cat ~/.bash_profile >> $shell_file
    echo -e "\n" >> $shell_file
fi

# /root/.bash_login
if [ -e "/root/.bash_login" ] ; then
    echo "[/root/.bash_login]" >> $shell_file
    cat ~/.bash_login >> $shell_file
    echo -e "\n" >> $shell_file
fi

# /root/.profile
if [ -e "/root/.profile" ] ; then
    echo "[/root/.profile]" >> $shell_file
    cat /root/.profile >> $shell_file
    echo -e "\n" >> $shell_file
fi

# /root/.bashrc
if [ -e "/root/.bashrc" ] ; then
    echo "[/root/.bashrc]" >> $shell_file
    cat /root/.bashrc >> $shell_file
    echo -e "\n" >> $shell_file
fi

# /root/.bash_logout
if [ -e "/root/.bash_logout" ] ; then
    echo "[/root/.bash_logout]" >> $shell_file
    cat /root/.bash_logout >> $shell_file
    echo -e "\n" >> $shell_file
fi

# Fetch default information

# time information
echo "[BIOS TIME]" >> $system_file 
hwclock -r >> $system_file 
echo -e "\n" >> $system_file
echo "[SYSTEM TIME]" >> $system_file
date >> $system_file
echo -e "\n" >> $system_file
echo "[SYSTEM UPTIME]" >> $system_file
uptime >> $system_file
echo -e "\n" >> $system_file

# system information
echo "[KERNEL INFO]" >> $system_file
uname -a >> $system_file
echo -e "\n" >> $system_file

# storage information
echo "[STORAGE INFO]" >> $system_file
df -h >> $system_file
echo -e "\n" >> $system_file
echo "[PARTITION INFO]" >> $system_file
fdisk -l >> $system_file
echo -e "\n" >> $system_file

# user information
echo "[USER INFO]" >> $user_file
w >> $user_file
echo -e "\n" >> $user_file

#last information
echo "[CURRENT USER LAST LOGIN]" >> $user_file
whoami >> $user_file
echo -e "\n" >> $user_file
last >> $user_file
echo -e "\n" >> $user_file

#lastlog information
echo "[USERS LAST LOGIN]" >> $user_file
lastlog >> $user_file
echo -e "\n" >> $user_file

# privilege information
echo "[SUDO USERS]" >> $user_file
cat /etc/sudoers >> $user_file
echo -e "\n" >> $user_file

echo "[PRIVILEGE - LOGIN]" >> $user_file
cat /etc/passwd | cut -d: -f1,3,4,5,6,7 | grep -vE '(nologin|halt|false|shutdown|sync)' | sort >> $user_file
echo -e "\n" >> $user_file

echo "[PRIVILEGE - NO LOGIN]" >> $user_file
cat /etc/passwd | cut -d: -f1,3,4,5,6,7 | grep -E '(nologin|halt|false|shutdown|sync)' | sort >> $user_file
echo -e "\n" >> $user_file

# /home/
for name in $(ls /home)
do
    echo "[${name} HOME DIRECTORY CONTENTS]"  2>/dev/null >> $user_file
    tree /home/$name -ashfDpqt >> $user_file
    echo -e "\n" >> $user_file
    #tar -zc -f $OUTDIR/HOME_$name.tar.gz /home/$name 2>/dev/null # Tar user directory
done


#  Fetch crontab records
crontab -l 2>/dev/null >> $crontab_file 


# Fetch process information

# ps -l (ROOT)
echo "[PROCESS ROOT]" >> $process_file
ps -l >> $process_file
echo -e "\n" >> $process_file

# ps aux (ALL)
echo "[PROCESS ALL]" >> $process_file
ps auxef >> $process_file
echo -e "\n" >> $process_file

# pstree
echo "[PROCESS TREE]" >> $process_file
pstree -Aup >> $process_file
echo -e "\n" >> $process_file


# Fetch network config

# ip config
echo "[NETWORK CONFIG]" >> $network_config
ip addr show >> $network_config
echo -e "\n" >> $network_config

# interface
echo "[NETWORK INTERFACE]" >> $network_config
cat /etc/network/interfaces 2>/dev/null >> $network_config
echo -e "\n" >> $network_config

# DNS
echo "[NETWORK DNS]" >> $network_config
cat /etc/resolv.conf >> $network_config
echo -e "\n" >> $network_config

# hostname
echo "[NETWORK HOSTS]" >> $network_config
cat /etc/hosts >> $network_config
echo -e "\n" >> $network_config
echo "[NETWORK HOSTNAME]" >> $network_config
cat /etc/hostname >> $network_config
echo -e "\n" >> $network_config


# Fetch network services

# services
echo "[Network Services]" >> $network_file
netstat -anp | sort>> $network_file
echo -e "\n" >> $network_file

# connection
echo "[Network Connection]" >> $network_file
lsof -nPi | sort -k10 >> $network_file
echo -e "\n" >> $network_file



# HTTP server inforamtion collection

# Nginx collection
echo "[Nginx Info]" >> $http_file
find / -name 'nginx' 2>/dev/null >> $http_file
echo -e "\n" >> $http_file
# tar default directory
#if [ -e "/usr/local/nginx" ] ; then
#    tar -zc -f HTTP_SERVER_DIR_nginx.tar.gz /usr/local/nginx 2>/dev/null
#fi

# Apache2 collection
echo "[Apache Info]" >> $http_file
find / -name 'apache2' 2>/dev/null >> $http_file
echo -e "\n" >> $http_file
# tar default directory
#if [ -e "/etc/apache2" ] ; then
#    tar -zc -f HTTP_SERVER_DIR_apache.tar.gz /etc/apache2 2>/dev/null
#fi


# Malware Collection Function

collect() {
	results=$(find / -name \*.$1 2>/dev/null)
	for result in $results
	do
		ls -lisanh $result >> $1file.txt
	done
	echo "[$1 FILES]" >> $interest_file
	cat $1file.txt | sort -k11 -h -r >> $interest_file
	echo -e "\n" >> $interest_file
	rm -f $1file.txt
}

collect "exe" 2>/dev/null
collect "doc" 2>/dev/null
collect "docx" 2>/dev/null
collect "xls" 2>/dev/null
collect "xlsx" 2>/dev/null
collect "js" 2>/dev/null
collect "jar" 2>/dev/null
collect "php" 2>/dev/null
collect "rar" 2>/dev/null
collect "sh" 2>/dev/null
collect "py" 2>/dev/null
collect "ps1" 2>/dev/null
collect "bat" 2>/dev/null
collect "bin" 2>/dev/null



# Find nouser or nogroup  data
echo "[NOUSER]" >> $abnormal_file
find / -nouser 2>/dev/null >> $abnormal_file
echo -e "\n" >> $abnormal_file

echo "[NOGROUP]" >> $abnormal_file
find / -nogroup 2>/dev/null >> $abnormal_file
echo -e "\n" >> $abnormal_file

# Install files
echo "[lsmod]" >> $install_file_info.txt
lsmod >> $install_file_info.txt
echo -e "\n" >> $install_file_info.txt

# File timeline
find / -type f -printf "%P,%A+,%T+,%C+,%u,%g,%M,%s\n" 2>/dev/null | tail -10000 >> $timeline_file

# /var/log/
tar -zc -f $OUTDIR/VAR_LOG.tar.gz /var/log/ 2>/dev/null


cat << EOF

Forensic collection was successful. You're output is now availabe in the current directory.

EOF
