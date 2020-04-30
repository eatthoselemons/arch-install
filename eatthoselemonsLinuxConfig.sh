# error out if there is an error in the script
trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'
set -uo pipefail
trap "${trap_msg}" ERR

mkdir -p ~/git

if [[ -d $HOME/git/sddm-deepin ]];
then
	rm -rf "$HOME/git/sddm-deepin"
fi

# install deepin
git clone https://github.com/Match-Yang/sddm-deepin.git ~/git/sddm-deepin

cd ~/git/sddm-deepin

bash install.sh

# install usefull utilities
sudo pacman --noconfirm -S ripgrep

# install my linux config
# dependencies
sudo pacman --noconfirm -S universal-ctags neovim

if [[ -d $HOME/linux-config ]];
then
	rm -rf "$HOME/linux-config"
fi

git clone https://github.com/eatthoselemons/linux-config ~/linux-config

cat << EOF > ~/.bashrc
if [ -f $HOME/linux-config/extra-bash ];
then
	. $HOME/linux-config/extra-bash
fi
EOF

source ~/.bashrc

nvim -s $HOME/git/arch-install/neovimCommands

cat << 'EOF' > ~/.config/nvim/init.vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/linux-config/vimrc
EOF
