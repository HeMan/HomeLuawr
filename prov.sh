#!/usr/bin/env bash 
#===============================================================================
#
#          FILE:  prov.sh
# 
#         USAGE:  ./prov.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Jimmy Hedman (jimmy), jimmy.hedman@southpole.se
#       COMPANY: South Pole AB
#       CREATED: 2012-09-17 21:56:11 CEST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

BAUD=38400
RFXCOMTTY=/dev/ttyUSB0
if [ $# -eq 1 ]; then
	RFXCOMTTY=$1
fi


#exec < $RFXCOMTTY
stty raw $BAUD < $RFXCOMTTY
stty -a < $RFXCOMTTY
lua ./rfxserv.lua 
