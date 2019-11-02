#!/bin/bash
# Nov,2nd,2019
#Anderson Augusto (andersonz@br.ibm.com)
#Adding and configuring a new NIC in LinuxONE with DPM and RHEL 7.XX
#After create and attach a new NIC to the partition in DPM, you can run addznet to Add and Configure the new NIC;

#Reding input of parameters
read -p "Enter the OSA PCHID in format XXXX: " PCHID
read -p "Enter the DEVICE in format XXXX: " DEV
read -p "Enter the PORTNO (0 or 1): " PN
read -p "Enter the Layer2 capability (0 or 1): " L2

#Getting CHPID by PCHID
for DIR in /sys/devices/css0/chp*
do
  if [ $(cat $DIR/chid) = $PCHID ]
  then
    CHPID=$(echo $DIR|tail -c 5)
  fi
done

#Invoking commands to add and configure new NIC
echo -e '\nExecuting "/usr/sbin/chchp -c 1 '$CHPID'"'
/usr/sbin/chchp -c 1 $CHPID
echo -e '\nExecuting "/usr/sbin/cio_ignore -r '$DEV'-'$(printf "%04X\n" $((0x$DEV+2)))'"'
/usr/sbin/cio_ignore -r $DEV'-'$(printf "%04X\n" $((0x$DEV+2)))
/usr/sbin/cio_ignore -L
echo -e '\nExecuting "/usr/sbin/znetconf -a  '$(printf "%04X\n" $((0x$DEV))) -o '"portno='$PN',layer2=1"''"'
/usr/sbin/znetconf -a  $(printf "%04X\n" $((0x$DEV))) -o '"portno='$PN',layer2=1"'
echo -e '\nExecuting "/usr/sbin/lsqeth '$(printf "enccw0.0.%04X\n" $((0x$DEV)))'"'
/usr/sbin/lsqeth $(printf "enccw0.0.%04X\n" $((0x$DEV)))
