#!/bin/sh
# ______        ____  __   ____  _        _             
#|  _ \ \      / /  \/  | / ___|| |_ __ _| |_ _   _ ___ 
#| | | \ \ /\ / /| |\/| | \___ \| __/ _` | __| | | / __|
#| |_| |\ V  V / | |  | |  ___) | || (_| | |_| |_| \__ \
#|____/  \_/\_/  |_|  |_| |____/ \__\__,_|\__|\__,_|___/
#
#Simple Program to set the Status for the DWM Bar.
#The Semi-colon separates the status into topbar and bootom bar texts.
#Network Monitor still needs some work.
#
#Dependencies -> nmcli, xbacklight, amixer, lm_sensors, curl.

#Get the connectivity params
getConnectionParams(){
	interface=$(nmcli | grep 'connected to' | sed 's/://' | awk '{print $1}')
	#line=$(grep $interface /proc/net/dev | awk '{print "in="$2, "out="$10}')
	in=$(grep $interface /proc/net/dev | awk '{print $2}')
	out=$(grep $interface /proc/net/dev | awk '{print $10}')
	#eval $line
}

#Initial Values
#getConnectionParams
#prevIn=$in
#prevOut=$out

#Calculate Connection Speeds
calcSpeeds(){
	val=$1
	prevVal=$2
	byte=1024

	vel=$(echo "scale=1;($val-$prevVal)/1024" | bc)
	ivel=$(printf %.f $vel)
	if [ $ivel -gt 1024 ]
	then
		vel=$(echo "scale=1;$vel/1024" | bc)
		echo $vel MB/s
	else
		echo $vel KB/s	
	fi
}

#Connection Details
getNetworkTraffic(){
	if nmcli | grep 'connected to' > /dev/null
	then
		#prevIn=$in
		#prevOut=$out

		interface=$(nmcli | awk '/connected to/ {print $1}')
		#in=$(grep $interface /proc/net/dev | awk '{print $2}')
		#out=$(grep $interface /proc/net/dev | awk '{print $10}')
		#inSpeed=$(calcSpeeds $in $prevIn)
		#outSpeed=$(calcSpeeds $out $prevOut)
		
		if [ $interface="wlo1:" ]
		then
			cmd=$(nmcli device wifi list | awk '/^*/ {print "ssid="$3, "bars="$9}')
			eval $cmd
			echo Connected to : $ssid $bars #Up: $outSpeed Down: $inSpeed 
		elif [ $interface="lo:" ]
		then
			ssid=$(nmcli | awk '/connected/ {print $4 }')
			echo Connected to : $ssid
		fi	
	else
		availConn=$(nmcli device wifi list | awk '$7 > 60' | wc -l)
		echo Connection : [$(($availConn-1)) *]
	fi
}

#Get Brightness
getBacklight(){
	bcklit=$(xbacklight -get)
	bcklit=${bcklit%.*}
	echo Screen : $bcklit%
}

#Volume Params
getVol(){
	if amixer get Master | grep '\[on\]' > /dev/null
	then
		echo Volume : $(amixer get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')%
	else
		echo Volume : --
	fi
}

#Local current time
getTime(){
	echo $(date +%B\ %d), $(date +%Y\ %T\ %Z)
}

#Get the current Memory stats
getMemStats(){
	echo Mem : $(free -h | awk '/^Mem/ {print $3 " / " $2}')
}

#Battery Stats
getBatStats(){
	if acpi -b | grep Full > /dev/null
	then
		echo "Battery : 100%, ="
	elif acpi -b | grep Charging > /dev/null
	then
		echo Battery : $(acpi -b | awk '{print $4 " + (" $5 ")"}')
	elif acpi -b | grep Discharging > /dev/null
	then
		echo Battery : $(acpi -b  | awk '{print $4 " - (" $5 ")"}')	
	else
		echo Battery : $(acpi -b |awk '{print $4 ", ?"}')
	fi
}

#CPU Temp
getTemp(){
	echo Temp : $(sensors | awk '/^temp1/ {print $2 $3}')
}

#CPU Load Avg
getLoad(){
	load=$(awk '{print $1}' /proc/loadavg)
	numOfCores=$(grep 'processor' /proc/cpuinfo | wc -l)
	loadAvg=$(echo "scale=2;($load/$numOfCores*100)" | bc)
	echo CPU : $loadAvg%
}

#Weather Report
oldMin=0
getWeather(){
	if $(ping -q -c 1 1.1.1.1 > /dev/null)
	then
		#wttr.in->>l=location, c=weather condition, C=wether condition text,
		#t=Temp, w=wind dir and speed, m=moonphase, M=moonday, p=precipitation/
		#location="Your,City"
		#report=$(curl wttr.in/$location\?format="%l:+%c+%C,+%t,+%w,+%m+%M")
		curl wttr.in\?format="%l:+%c+%C,+%t,+%w,+%m+%M"
	else
		echo *Weather Report Unavailable*
	fi
}

while xsetroot -name "$(getTime) ; $weather | $(getNetworkTraffic) | $(getBacklight) | $(getVol) | $(getTemp) | $(getLoad) | $(getMemStats) | $(getBatStats)"
do
	now=$(date +%M)
	if [ ! $oldMin -eq $now ] || $(echo $weather | grep Unavailable > /dev/null)
	then
		oldMin=$now
		weather=$(getWeather)
	fi
	sleep 1s;
done
