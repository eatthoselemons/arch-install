# error out if there is an error in the script
trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'
set -uo pipefail
trap "${trap_msg}" ERR

mkdir -p ~/git
echo "installing git"
sudo pacman -S --noconfirm git

echo "cloning or updating linux-config"
if [[ -d $HOME/git/linux-config ]];
then
  cd $HOME/git/linux-config
  git pull
  cd $HOME
else
  git clone https://github.com/eatthoselemons/linux-config ~/git/linux-config
fi

bash $HOME/git/linux-config/install.sh
