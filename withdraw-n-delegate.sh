#!/bin/bash

#export path
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin:$GOBIN

# set app and network
APP_NAME="desmos"
APP_PATH=`which $APP_NAME`
CHAIN_ID="morpheus-apollo-1"
DENOM="udaric"
NODE_URL="http://127.0.0.1:26657"
MIN_WITHDRAW=1000000
MIN_BALANCE=100000
MIN_STAKE=1000000
GAS_TOTAL="--gas auto --gas-prices 0.01udaric --gas-adjustment 1.4"

# set acc & pass
VAL_ACCOUNT="lux8net"
#DEL_ACCOUNT="delegator"
PASS=$(cat ${HOME}/ppp)
VAL_ADDRESS=$(echo -e ${PASS} | ${APP_PATH} keys show ${VAL_ACCOUNT} -a)
#DEL_ADDRESS=$(echo -e ${PASS} | ${APP_PATH} keys show ${DEL_ACCOUNT} -a)
VALOPER=$(echo ${PASS} | ${APP_PATH} keys show ${VAL_ACCOUNT} --bech val --address)

# check rewards
VAL_REWARDS=$(${APP_PATH} q distribution rewards ${VAL_ADDRESS} ${VALOPER} --chain-id ${CHAIN_ID} --node ${NODE_URL} -oj | jq -r '.rewards | .[].amount' | egrep -o '[0-9]+\.' | tr -d .)

#DEL_REWARDS=$(${APP_PATH} q distribution rewards ${DEL_ADDRESS} ${VALOPER} --chain-id ${CHAIN_ID} --node ${NODE_URL} -oj | jq -r '.rewards | .[].amount' | egrep -o '[0-9]+\.' | tr -d .)

VAL_REWARDS2=$(bc -l <<< "$VAL_REWARDS/1000000")
#DEL_REWARDS2=$(bc -l <<< "$DEL_REWARDS/1000000")
# echo data
echo ""
echo "-------------------------"
echo `date`
echo "validator rewards:" $VAL_REWARDS2
#echo "delegator rewards:" $DEL_REWARDS2

sleep 5

# withdraw validator rewards
if [[ $(bc -l <<< "${VAL_REWARDS} > ${MIN_WITHDRAW}") -eq 1 ]]
  then
    echo "let's withdraw validator rewards"
    echo -e "${PASS}\n" | ${APP_PATH} tx distribution withdraw-rewards ${VALOPER} --from ${VAL_ACCOUNT} --chain-id ${CHAIN_ID} --node ${NODE_URL} ${GAS_TOTAL} --yes
  else
    echo "no validator rewards to withdraw"
fi

sleep 5

# withdraw delegator rewards
#if [[ $(bc -l <<< "${DEL_REWARDS} > ${MIN_WITHDRAW}") -eq 1 ]]
#  then
#    echo "let's withdraw delegator rewards"
#    echo -e "${PASS}\n" | ${APP_PATH} tx distribution withdraw-rewards ${VALOPER} --from ${DEL_ACCOUNT} --chain-id ${CHAIN_ID} --node ${NODE_URL} ${GAS_TOTAL} --yes
#  else
#    echo "no delegator rewards to withdraw"
#fi

# commissions status
COMMISSION_STATUS=$(echo -e $(cat ${HOME}/ppp) | ${APP_NAME} query distribution commission ${VALOPER} --chain-id ${CHAIN_ID} --node ${NODE_URL} --output json)
COMMISSION_BALANCE=$(echo ${COMMISSION_STATUS} | jq -r .commission | jq -r .[].amount)
COMMISSION_BALANCE2=$(bc -l <<< "$COMMISSION_BALANCE/1000000")

# echo data
echo ""
echo "-------------------------"
echo `date`
echo "commission balance:" $COMMISSION_BALANCE2

sleep 5

# withdraw commissions
if [[ $(bc -l <<< "${COMMISSION_BALANCE} > ${MIN_WITHDRAW}") -eq 1 ]]
  then
    echo "let's withdraw validator commissions"
    echo -e "${PASS}\n" | ${APP_NAME} tx distribution withdraw-rewards ${VALOPER} --commission --from ${VAL_ACCOUNT} --chain-id ${CHAIN_ID} --node ${NODE_URL} ${GAS_TOTAL} --yes
  else
    echo "no commissions to withdraw"
fi

sleep 30

# check updated balance
VAL_BALANCE=$(${APP_PATH} query bank balances ${VAL_ADDRESS} --node ${NODE_URL} -oj | jq ".balances" | jq ".[] | select(.denom==\"udaric\")" | jq -r .amount)
#DEL_BALANCE=$(${APP_PATH} query bank balances ${DEL_ADDRESS} --node ${NODE_URL} -oj | jq -r '.balances | .[].amount')

VAL_BALANCE2=$(bc -l <<< "$VAL_BALANCE/1000000")
#DEL_BALANCE2=$(bc -l <<< "$DEL_BALANCE/1000000")

echo "validator balance:" $VAL_BALANCE2
#echo "delegator balance:" $DEL_BALANCE2

VAL_BALANCE_TO_STAKE=$(bc -l <<< "$VAL_BALANCE - $MIN_BALANCE")
#DEL_BALANCE_TO_STAKE=$(bc -l <<< "$DEL_BALANCE - $MIN_BALANCE")

VAL_BALANCE_TO_STAKE2=$(bc -l <<< "$VAL_BALANCE_TO_STAKE/1000000")
#DEL_BALANCE_TO_STAKE2=$(bc -l <<< "$DEL_BALANCE_TO_STAKE/1000000")


# stake from validator address
sleep 5
if [[ $(bc -l <<< "${VAL_BALANCE_TO_STAKE} > ${MIN_STAKE}") -eq 1 ]]
  then
    echo "staking $VAL_BALANCE_TO_STAKE from validator address"
    echo -e "${PASS}\n" | ${APP_PATH} tx staking delegate ${VALOPER} ${VAL_BALANCE_TO_STAKE}${DENOM} --from ${VAL_ACCOUNT} --chain-id ${CHAIN_ID} --node ${NODE_URL} ${GAS_TOTAL} --yes
  else
    echo "nothing to stake from validator address"
fi

# stake from delegator address
#sleep 5
#if [[ $(bc -l <<< "${DEL_BALANCE_TO_STAKE} > ${MIN_STAKE}") -eq 1 ]]
#  then
#    echo "staking $DEL_BALANCE_TO_STAKE regen from delegator address"
#    echo -e "${PASS}\n" | ${APP_PATH} tx staking delegate ${VALOPER} ${DEL_BALANCE_TO_STAKE}udvpn --from ${DEL_ACCOUNT} --chain-id ${CHAIN_ID} --node ${NODE_URL} ${GAS_TOTAL} --yes
#  else
#    echo "nothing to stake from delegator address"
#fi

echo "done"
