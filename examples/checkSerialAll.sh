#!/bin/bash

# this script is to check all serial interfaces to GNSS modules
# 2 serials are for ZED-F9P, other 2 is for NEO-D9C
# when this script is executed, all program of to open 4 serials must be terminated.
#
#
# the following commands must be execute before use for pps check
#    add "dtoverlay=pps-gpio,gpiopin=18,assert_falling_edge=false" to /boot/firmware/config/txt
#    add pps-gpio to /dev/modules
#    reboot
#    sudo apt-get install pps-tools
#

strSerial=("ZED-F9P UART1" "NEO-D9C UART1" "" "NEO-D9C UART2" "ZED-F9P UART2")

setBaud() {
    log=`ubxtool -w 0.1 -f $1 -z "CFG-$2-BAUDRATE,921600"`
    echo $log | grep "UBX-ACK-ACK" > /dev/null 2>&2
    if [ ! $? ]; then
        echo fail
    else
        echo done
    fi
}


# power on
gpioset gpiochip4 22=1
sleep 0.5

echo \# set baud
echo -n " 1. set 921600 to CFG-UART1-BAUDRATE (${strSerial[0]}): "
setBaud /dev/ttyACM0 UART1
echo -n " 2. set 921600 to CFG-UART2-BAUDRATE (${strSerial[4]}): "
setBaud /dev/ttyACM0 UART2
echo -n " 3. set 921600 to CFG-UART1-BAUDRATE (${strSerial[1]}): "
setBaud /dev/ttyACM1 UART1
echo -n " 4. set 921600 to CFG-UART2-BAUDRATE (${strSerial[3]}): "
setBaud /dev/ttyACM1 UART2


echo \# check VER
for i in 0 4 1 3
do
    echo -n "${strSerial[$i]}(ttyAMA$i) check VER: "
    log=`ubxtool  -w 0.2  -f /dev/ttyAMA$i -s 921600 -p MON-VER | grep VER`
    echo $log
done


echo \# check pps
ppstest /dev/pps0 | head -8
