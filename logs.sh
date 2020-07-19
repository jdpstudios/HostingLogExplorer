#!/bin/bash
# Log Reader Script by Jeffrey Palmer
# Menu code sourced from https://bash.cyberciti.biz/guide/Menu_driven_scripts

## -----------------------------------
# Step #1: Determine Environment
# ------------------------------------
CPANELFILE=/usr/local/cpanel/version
PLESKFILE=/usr/local/psa/admin/conf/panel.ini

## ----------------------------------
# Step #2: Define variables
# -----------------------------------
#EDITOR=vim
#PASSWD=/etc/passwd
RED='\033[0;41;30m'
STD='\033[0;0;39m'
clear
read -p "Enter a domain name or press Enter to skip: " phpDomain

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
    clear
	tail -n 6 -f /home/$userName/logs/$phpDomain.php.log $(find $documentRoot -type f -name error_log -printf '%p ') 2> /dev/null	
}

ten(){
    clear
	watch -n 1 "mysql -uroot -e 'show processlist;'"
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
	echo  "~~~~~~~~~~~~~~"
	echo "9. Scan for PHP error logs in document root and ~/logs"
	echo "10. Monitor MySQL Processes"
	echo  "~~~~~~~~~~~~~~"
	echo "Q. Exit"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options_cpanel(){
	local choice
	read -p "Enter choice [ 1 - 10] " choice
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
	clear
	tail -n 25 -f /var/www/vhosts/system/$phpdomain/logs/access_ssl_log /var/www/vhosts/system/$phpdomain/logs/access_log
}

plesktwo(){
    less +G /var/www/vhosts/$phpdomain/error_log
}

pleskthree(){
    less +G /var/log/httpd/error_log
}

pleskfour(){
    less +G /var/log/mysqld.log
}

pleskfive(){
    less +G /var/log/messages
}

plesksix(){
    less +G /var/log/secure
}

pleskseven(){
    less +G /var/log/sw-cp-server/error_log
}

pleskeight(){
	watch -n 1 "mysql -uroot -e 'show processlist;'"
}
 
# function to display menus
show_plesk_menu() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo "Plesk - MAIN MENU"
	echo "SELECT A FILE TO OPEN"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. /var/www/vhosts/system/$phpdomain/logs/access_log -- HTTPS and HTTP"
    echo "2. /var/www/vhosts/$phpdomain/error_log"
    echo "3. /var/log/httpd/error_log"
	echo "4. /var/log/mysqld.log"
	echo "5. /var/log/messages"
	echo "6. /var/log/secure"
	echo "7. /var/log/sw-cp-server/error_log"
	echo  "~~~~~~~~~~~~~~"
	echo "8. Monitor MySQL Processes"
	echo  "~~~~~~~~~~~~~~"
	echo "Q. Exit"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options_plesk(){
	local choice
	read -p "Enter choice [ 1 - 8] " choice
	case $choice in
		1) pleskone ;;
		2) plesktwo ;;
        3) plesktwo ;;
        4) plesktwo ;;
        5) plesktwo ;;
        6) plesktwo ;;
        7) plesktwo ;;
		q) clear ; exit 0;;
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
    trueUserDomain=$(grep $phpDomain /etc/trueuserdomains)
    userName=${trueUserDomain#$phpDomain: }
    userData=$(grep "documentroot:" /var/cpanel/userdata/$userName/$phpDomain)
    documentRoot=${userData#"documentroot: "}
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