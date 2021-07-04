#!/bin/bash

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`
mkdir -p $HOME/logs

crontab -l | 
{
    echo "#crontab for $USER on $HOSTANME"
    echo "0 * * * * cd $SCRIPT_DIR && ./withdraw-n-delegate.sh >> $HOME/logs/withdraw-n-delegate.log ";
} | crontab -

crontab -l
