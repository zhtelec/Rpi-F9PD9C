#!/bin/sh

portF9P=/dev/ttyAMA0
portD9C=/dev/ttyAMA1
# see  https://rtk.silentsystem.jp/
ntripBase="ntrip://guest:guest@160.16.134.72:80/CQ-F9P"
baud=921600

### power on
gpioset gpiochip4 22=1
sleep 0.1


### set high precision mode (CFG-NMEA-HIGHPREC = true(1))
### use the not supported SV number (CFG-NMEA-SVNUMBERING = extended(1))
ubxtool -w 0.1 -f $portF9P -s $baud -z "CFG-NMEA-HIGHPREC,1"
ubxtool -w 0.1 -f $portF9P -s $baud -z "CFG-NMEA-SVNUMBERING,1"


### NAV report
### NAV-HPPOSLLH(1,20), NAV-POSLLH(1,2), NAV-PVT(1,7)
sudo ubxtool -w 0.1 -f $portF9P -s $baud -z CFG-MSGOUT-UBX_NAV_HPPOSLLH_UART1,1
sudo ubxtool -w 0.1 -f $portF9P -s $baud -z CFG-MSGOUT-UBX_NAV_HPPOSLLH_UART2,1
sudo ubxtool -w 0.1 -f $portF9P -s $baud -z CFG-MSGOUT-UBX_NAV_HPPOSLLH_USB,1
sudo ubxtool -w 0.1 -f $portF9P -s $baud -z CFG-MSGOUT-UBX_NAV_POSLLH_UART1,1
sudo ubxtool -w 0.1 -f $portF9P -s $baud -z CFG-MSGOUT-UBX_NAV_POSLLH_UART2,1
sudo ubxtool -w 0.1 -f $portF9P -s $baud -z CFG-MSGOUT-UBX_NAV_POSLLH_USB,1
sudo ubxtool -w 0.1 -f $portF9P -s $baud -z CFG-MSGOUT-UBX_NAV_PVT_UART1,1
sudo ubxtool -w 0.1 -f $portF9P -s $baud -z CFG-MSGOUT-UBX_NAV_PVT_UART2,1
sudo ubxtool -w 0.1 -f $portF9P -s $baud -z CFG-MSGOUT-UBX_NAV_PVT_USB,1


### the CLAS data is transfer to ZED-F9P
str2str -in $ntripBase -out $portF9P
