#!/bin/bash

#
# An example of start/stop script. Put this in /etc/init.d
#

### BEGIN INIT INFO
# Provides:          postlogsql
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts PostLogSQL
# Description:       starts PostLogSQL using start-stop-daemon
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/postlogsql
DAEMON_PATH="/opt/postlogsql"
DAEMON_MASTER="master.rb"
DAEMON="$DAEMON_PATH/$DAEMON_MASTER"
NAME=postlogsql
RUNDIR=/var/run
PIDFILE=$RUNDIR/$NAME.pid
#DAEMON_OPTS="-P $PIDFILE"

test -x $DAEMON || exit 0

set -e

case "$1" in
  start)
        echo -e "Starting Postfix MySQL Logger"
        #start-stop-daemon --start --quiet --oknodo --pidfile $PIDFILE --exec $DAEMON# -- $DAEMON_OPTS
        cd $DAEMON_PATH
        /usr/bin/ruby $DAEMON_MASTER start
        ;;
  stop)
        echo -e "Stopping Postfix MySQL Logger"
        #start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE
        cd $DAEMON_PATH
        /usr/bin/ruby $DAEMON_MASTER stop
        ;;
  *)
        N=/etc/init.d/$NAME
        echo "Usage: $N {start|stop}" >&2
        exit 1
        ;;
esac
