#!/bin/bash

### set uart to /boot/firmware/config.txt
file0=/boot/firmware/config.txt
file1=/tmp/config.$$-1
#file2=/tmp/config.$$-2

if [ ! -f $file0.orig ]; then
    cp $file0 $file0.orig
fi

grep -Ev "^dtoverlay=uart|^init_uart_baud|^dtoverlay=pps-gpio" $file0 >  $file1

echo "init_uart_baud=921600" >>  $file1
echo "dtoverlay=pps-gpio,gpiopin=18,assert_falling_edge=false" >>  $file1
echo "dtoverlay=uart1" >>  $file1
echo "dtoverlay=uart2" >>  $file1
echo "dtoverlay=uart3" >>  $file1
echo "dtoverlay=uart4" >>  $file1

cat $file1 > $file0


### add "pps-gpio" to /etc/modules
file0=/etc/modules
if [ ! -f $file0.orig ]; then
    cp $file0 $file0.orig
fi

grep -Ev "pps-gpio" $file0 >  $file1
echo  "pps-gpio" >>  $file1
cat $file1 > $file0


### disable the serial console
file0=/boot/firmware/cmdline.txt
if [ ! -f $file0.orig ]; then
    cp $file0 $file0.orig
fi
sed -i "s/console=serial0,[0-9]*[ ]*//" $file0


### install the gpsd
apt update
apt install gpsd gpsd-clients gpsd-tools pps-tools


### change the baud capability of ubxtool
pushd /usr/lib/python3/dist-packages/gps/
patch -t -p0  <<EOF
*** ubx.py.orig	2025-07-09 14:04:42.412607663 +0900
--- ubx.py	2025-07-09 14:05:44.072906090 +0900
***************
*** 241,247 ****
          pass
  
      # allowable speeds
!     speeds = (460800, 230400, 153600, 115200, 57600, 38400, 19200, 9600, 4800)
  
      # UBX Satellite Numbering
      gnss_id = {0: 'GPS',
--- 241,247 ----
          pass
  
      # allowable speeds
!     speeds = (921600, 460800, 230400, 153600, 115200, 57600, 38400, 19200, 9600, 4800)
  
      # UBX Satellite Numbering
      gnss_id = {0: 'GPS',

EOF
popd


### install str2str of the RTKLIB
git clone https://github.com/tomojitakasu/RTKLIB.git
cd RTKLIB/app
chmod 755 makeall.sh
./makeall.sh
cp -f str2str/gcc/str2str /usr/local/bin/.
