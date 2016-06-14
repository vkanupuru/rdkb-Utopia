#!/bin/sh
#zhicheng_qiu@cbale.comcast.com

BUTTON_THRESHOLD=15
FACTORY_RESET_KEY=factory_reset
FACTORY_RESET_RGWIFI=y
FACTORY_RESET_WIFI=w
SYSCFG_MOUNT=/nvram
SYSCFG_FILE=$SYSCFG_MOUNT/syscfg.db
PUNIT_RESET_DURATION=0;

#first time boot
if [ ! -f $SYSCFG_FILE ]; then
   echo 1;
   exit 0;
fi

# Hardware reset
if cat /proc/P-UNIT/status | grep -q "Reset duration from shadow register"; then
   # Note: Only new P-UNIT firmwares and Linux drivers (>= 1.1.x) support this.
   PUNIT_RESET_DURATION=`cat /proc/P-UNIT/status|grep "Reset duration from shadow register"|awk -F '[ |\.]' '{ print $9 }'`
elif cat /proc/P-UNIT/status | grep -q "Last reset duration"; then
   PUNIT_RESET_DURATION=`cat /proc/P-UNIT/status|grep "Last reset duration"|awk -F '[ |\.]' '{ print $7 }'`
else
   PUNIT_RESET_DURATION=0;
fi

if test "$BUTTON_THRESHOLD" -le "$PUNIT_RESET_DURATION"; then
   echo 1;
   exit 0;
fi

#software reset
SYSCFG_FR_VAL="`syscfg get $FACTORY_RESET_KEY`"
if [ "x$FACTORY_RESET_RGWIFI" = "x$SYSCFG_FR_VAL" ]; then
   echo 1;
   exit 0;
elif [ "x$FACTORY_RESET_WIFI" = "x$SYSCFG_FR_VAL" ]; then
   echo 1;
   exit 0;
fi

echo 0;
