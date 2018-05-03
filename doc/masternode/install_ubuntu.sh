#!/bin/bash

function printError
{
   printf "\33[0;31m$1\033[0m\n"
}

function printSuccess
{
   printf "\33[0;32m$1\033[0m\n"

}

function printWarning
{
   printf "\33[0;33m$1\033[0m\n"

}
root_path="$(pwd)"
conf_path="$root_path/.absolutecore/absolute.conf"
ext_ip=""
mn_key=$1
p_version=""


if [ -z $mn_key ]; then
	printError "MN key is missing\n Usage $0 <mn_key>\n\n"
	exit 0
fi

clear
printf  "\n\n******* Starting Absolute-Community Masternode installation *******\n\n"
printf " working directory is $(pwd)\n"
{
echo "Step 1 : Updating packages"
	sudo apt-get update -y -qq
	sudo apt-get upgrade -y -qq
	sudo apt-get dist-upgrade -y -qq
	sudo apt-get install nano htop -y -qq
	sudo apt-get install pwgen  -y -qq
	
	printf "Detect python version "
	p_version="$(python -V)"

	if [ -z $p_version ]; then
		sudo apt-get -y -qq install python
	fi
	
	sudo apt-get -y -qq install python-virtualenv
	sudo apt-get install git -y -qq


	#sudo apt-get -y install python-virtualenv -y -qq
	echo "changing working folder to $root_path"
	cd $root_path
	printSuccess "Done"
} || {
	printError "Fail"
	exit 1
}

{
	echo "Step 2 : Downloading binaries - extract"
	
	if [ ! -f absolute_12.2.1_linux.tar.gz ]; then
		echo "Dowloading..."
		wget https://github.com/absolute-community/absolute/releases/download/12.2.1/absolute_12.2.1_linux.tar.gz -O absolute_12.2.1_linux.tar.gz -q
	else
		printWarning "File already exist"
	fi

	if [ ! -d Absolute ]; then
		echo "Extracting"
		tar -zxvf absolute_12.2.1_linux.tar.gz &&
		echo "Rename daemon folder"
		mv absolute_12.2.1_linux Absolute
	else
		printWarning "Daemon already exist"
	fi
		printSuccess "Done"
		
} || {
	printError "Fail"
	exit 1
}


{
	echo "Step 3: Configure"

	if [ ! -f "$conf_path" ]; then
		ext_ip=`wget -qO- eth0.me`
		PASS=`pwgen -1 20 -n`
		
		mkdir -p "$(dirname "$conf_path")" &&
		touch $conf_path &&

		printf "\n#--- basic configuration --- \nrpcuser=user\nrpcpassword=$PASS\nrpcport=18889\ndaemon=1\nlisten=1\nserver=1\nmaxconnections=256\nrpcallowip=127.0.0.1\nexternalip=$ext_ip:18888\n" > $conf_path
		printf "\n#--- masternode ---\nmasternode=1\nmasternodeprivkey=$mn_key\n" >> $conf_path
		printf "\n#--- new nodes ---\naddnode=139.99.98.145:18888\naddnode=51.255.174.238:18888\naddnode=54.37.14.240:18888\naddnode=164.132.195.79:18888\naddnode=208.167.248.187:18888\naddnode=45.77.146.105:18888\naddnode=45.77.221.206:18888\naddnode=45.76.171.105:18888" >> $conf_path
		
	else
		printError "Configuration already exist. Remove this file '$conf_path' or configure manyally"
	fi
	
	printSuccess "Done"


} || {

	printError "Fail"
	exit 1
}

{
	echo "Step 4 : Installing Sentinel watch dog"
	
	if [ ! -d "$HOME/.absolutecore/sentinel" ]; then
		git clone https://github.com/absolute-community/sentinel.git --q
	fi
	
	cd /root/.absolutecore/sentinel &&
	virtualenv ./venv &&
	./venv/bin/pip install -r requirements.txt

	printSuccess "Done"

} || {
	printError "Fail"
	exit 1
}

{
	echo "Step 5 : Configuring sentinel"

	if  grep -q "absolute_conf=$conf_path" "$root_path/.absolutecore/sentinel/sentinel.conf" ; then
		printWarning "absolute path already set in sentinel conf"
	else
		printf "absolute_conf=$conf_path" >> "$root_path/.absolutecore/sentinel/sentinel.conf"
	fi

	printSuccess "Done"
} || {
	printError "Fail"
	exit 1
}

printSuccess "\nInstallation done you can continue to follow last steps from the guide"
printSuccess "\nPlease note this line for your crontab"
printSuccess "\n* * * * * cd $root_path/.absolutecore/sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1"
