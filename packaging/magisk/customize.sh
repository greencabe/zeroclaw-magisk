#!/system/bin/sh

ui_print "Installing ZeroClaw"
ui_print "CLI: /system/bin/zeroclaw"
ui_print "Config/state: /data/adb/zeroclaw"
ui_print "Dashboard: embedded in binary; start gateway to use it"

set_perm "$MODPATH/system/bin/zeroclaw" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
