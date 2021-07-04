### Script to automate desmos validator redelegations
This guide is testet on Ubuntu 20.04 and probably will work flawless on other distros as well.

### Installation
1. Clone this repository to your server
```sh
cd $HOME && git clone https://github.com/ama31337/desmos-tips.git
```
2. Check and edit if necessary variables in script
```sh
vim $HOME/desmos-tips/withdraw-n-delegate.sh
```
- CHAIN_ID: put current chain-id
- NODE_URL: your rpc node
- MIN_WITHDRAW: minimal rewards amount to withdraw
- MIN_BALANCE: minimal balance on your validator account to keep
- MIN_STAKE: minimal amount to stake
- VAL_ACCOUNT: your validator wallet name
- DEL_ACCOUNT: your delegator account * if you have separate account for delegations and also want to setup auto-redelegation, uncomment lines related to delegator (start with "DEL_*")

- NB! this script also withdraw your validator commission and redelegate it.
If you want to keep your commissions undelegated, comment lines related to it (line 77-84)

3. Script need your wallet password to operate, save it to $HOME/ppp:
```sh
echo "<your pass>" > $HOME/ppp
```

4. Add auto-redelegation script to crontab
```sh
cd $HOME/desmos-tips && ./add_to_cron.sh
```
This script will overwrite your crontab, so if you have something extra in your cron you need to add it to this script or add to crontab manually.

Done.
