#!/bin/sh

# this runs the file serving tests that are expected to pass with samba3 against shares with various options

if [ $# -lt 5 ]; then
cat <<EOF
Usage: test_smbclient_basic.sh SERVER SERVER_IP DOMAIN USERNAME PASSWORD SMBCLIENT <smbclient arguments>
EOF
exit 1;
fi

SERVER="$1"
SERVER_IP="$2"
USERNAME="$3"
PASSWORD="$4"
smbclient="$5"
CONFIGURATION="$6"
shift 6
ADDARGS="$@"

incdir=`dirname $0`/../../../testprogs/blackbox
. $incdir/subunit.sh

test_smbclient() {
	name="$1"
	cmd="$2"
	shift
	shift
	echo "test: $name"
	$VALGRIND $smbclient $CONFIGURATION //$SERVER/tmp -c "$cmd" $@
	status=$?
	if [ x$status = x0 ]; then
		echo "success: $name"
	else
		echo "failure: $name"
	fi
	return $status
}

# TEST using \ as the separator (default)
test_smbclient "smbclient as $DOMAIN\\$USERNAME" 'ls' -U$DOMAIN\\$USERNAME%$PASSWORD $CONFIGURATION || failed=`expr $failed + 1`
# TEST using / as the separator (default)
test_smbclient "smbclient as $DOMAIN/$USERNAME" 'ls' -U$DOMAIN/$USERNAME%$PASSWORD $CONFIGURATION || failed=`expr $failed + 1`

# TEST using 'winbind separator = +'
test_smbclient "smbclient as $DOMAIN+$USERNAME" 'ls' -U$DOMAIN+$USERNAME%$PASSWORD $CONFIGURATION --option=winbindseparator=+ || failed=`expr $failed + 1`

# TEST using 'winbind separator = +' set in a config file
smbclient_config="$PREFIX/tmpsmbconf"
cat > $smbclient_config <<EOF
[global]
    include = $(echo $CONFIGURATION | cut -d= -f2)
    winbind separator = +
EOF

SAVE_CONFIGURATION="$CONFIGURATION"
CONFIGURATION="--configfile=$smbclient_config"
test_smbclient "smbclient as $DOMAIN+$USERNAME" 'ls' -U$DOMAIN+$USERNAME%$PASSWORD || failed=`expr $failed + 1`
CONFIGURATION="$SAVE_CONFIGURATION"
rm -rf $smbclient_config

exit $failed
