#!/bin/bash
# Log Reader Script v2 by Jeff Palmer
# Menu code used from https://bash.cyberciti.biz/guide/Menu_driven_scripts
# Includes code written by Dustan Barrett
## ----------------------------------
# Step #1: Define variables
# -----------------------------------
#EDITOR=vim
#PASSWD=/etc/passwd
RED='\033[0;41;30m'
STD='\033[0;0;39m'
clear
read -p "Enter a domain name or press Enter to skip: " phpDomain
trueUserDomain=$(grep $phpDomain /etc/trueuserdomains)
userName=${trueUserDomain#$phpDomain: }
userData=$(grep "documentroot:" /var/cpanel/userdata/$userName/$phpDomain)
documentRoot=${userData#"documentroot: "}

## -----------------------------------
# Step #2: Determine Environment
# ------------------------------------
CPANELFILE=/usr/local/cpanel/version
PLESKFILE=/usr/local/psa/admin/conf/panel.ini
# ----------------------------------
# Step #3: Define cPanel MENU
# ----------------------------------
pause(){
  read -p "PRESS ENTER TO RETURN TO MENU" fackEnterKey
}

one(){
	clear
	tail -n 25 -f /usr/local/apache/domlogs/$phpDomain-ssl_log /usr/local/apache/domlogs/$phpDomain 

}

two(){
	less +G /usr/local/apache/logs/error_log

}

three(){
	if test /var/log/mysqld.log; then
	less +G /var/log/mysqld.log

	else
	less +G /var/lib/mysql/$HOSTNAME.err

    fi
}

four(){
	read -p "Enter PHP Version Number: " phpVersion
	phpVersion=${phpVersion/./}
	less +G /opt/cpanel/ea-php$phpVersion/root/usr/var/log/php-fpm/error.log

}

five(){
	less +G /var/log/messages
        
}

six(){
	less +G /var/log/secure
        
}

seven(){
	less +G /usr/local/cpanel/logs/error_log

}

eight(){
	less +G /var/log/exim_mainlog

}

nine(){
	watch -n 1 "mysql -uroot -e 'show processlist;'"

}

ten(){
	tail -n 6 -f /home/$userName/logs/$phpDomain.php.log $(find $documentRoot -type f -name error_log -printf '%p ') 2> /dev/null	
}
 
# function to display menus
show_cpanel_menu() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo "cPanel - MAIN MENU"
	echo "SELECT A FILE TO OPEN"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. /usr/local/apache/domlogs/$phpDomain -- HTTPS and HTTP"
	echo "2. /usr/local/apache/logs/error_log"
	echo "3. /var/log/mysqld.log"
	echo "4. /opt/cpanel/ea-php*/root/usr/var/log/php-fpm/error.log"
	echo "5. /var/log/messages"
	echo "6. /var/log/secure"
	echo "7. /usr/local/cpanel/logs/error_log"
	echo "8. /var/log/exim_mainlog"
	echo "9. Monitor MySQL Processes"
	echo  "~~~~~~~~~~~~~~"
	echo "10. Scan for PHP error logs in document root and ~/logs"
	echo  "~~~~~~~~~~~~~~"
	echo "Q. Exit"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options_cpanel(){
	local choice
	read -p "Enter choice [ 1 - 16] " choice
	case $choice in
		1) one ;;
		2) two ;;
		3) three ;;
		4) four ;;
		5) five ;;
		6) six ;;
		7) seven ;;
		8) eight ;;
		9) nine ;;
		10) ten ;;
		q) clear ; exit 0;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}
# ----------------------------------
# Step #4: Define Plesk MENU
# ----------------------------------
pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}

pleskone(){
	echo "one() called"
        pause
}
 
# do something in two()
plesktwo(){
	echo "two() called"
        pause
}
 
# function to display menus
show_plesk_menu() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo "Plesk - MAIN MENU"
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Set Terminal"
	echo "2. Reset Terminal"
	echo "3. Exit"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options_plesk(){
	local choice
	read -p "Enter choice [ 1 - 3] " choice
	case $choice in
		1) pleskone ;;
		2) plesktwo ;;
		3) clear ; exit 0;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}

# ----------------------------------------------
# Step #5: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Step #6: Main logic - infinite loop
# ------------------------------------
while true
do
 if [[ -f "$CPANELFILE" ]]; then
	show_cpanel_menu
	read_options_cpanel
    elif
    [[ -f "$PLESKFILE" ]]; then
    show_plesk_menu
	read_options_plesk
    else
    echo "This script must be run as root on a cpanel or plesk host."
    exit 0
fi
done