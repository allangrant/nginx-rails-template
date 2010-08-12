#!/bin/bash
#
# God
#
# chkconfig: - 85 15
# description: start, stop, restart God (bet you feel powerful)
#
 
RETVAL=0
 
case "$1" in
    start)
      /opt/ruby/bin/god -P /var/run/god.pid -l /var/log/god.log --config-file /etc/god.conf
      # /opt/ruby/bin/god load /etc/god.conf
      RETVAL=$?
      ;;
    stop)
      kill `cat /var/run/god.pid`
      RETVAL=$?
      ;;
    restart)
      kill `cat /var/run/god.pid`
      /opt/ruby/bin/god -P /var/run/god.pid -l /var/log/god.log
      /opt/ruby/bin/god load /etc/god.conf
      RETVAL=$?
      ;;
    status)      
      /opt/ruby/bin/god status
      RETVAL=$?
      ;;
    *)
      echo "Usage: god {start|stop|restart|status}"
      exit 1
  ;;
esac
 
exit $RETVAL