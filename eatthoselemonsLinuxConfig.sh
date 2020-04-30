# error out if there is an error in the script
trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'
set -uo pipefail
trap "${trap_msg}" ERR

mkdir -p ~/git

# install deepin
git clone https://github.com/Match-Yang/sddm-deepin.git ~/git

cd ~/git/sddm-deepin

bash install.sh


# install my linux config
# dependencies
sudo pacman -S universal-ctags neovim

git clone https://github.com/eatthoselemons/linux-config ~/.

cat << EOF > ~/.bashrc
if [ -f $HOME/linux-config/extra-bash ];
then
	. $HOME/linux-config/extra-bash
fi
EOF

source ~/.bashrc

cat << 'EOF' > ~/neovimCommands
:call mkdir(stdpath('config'), 'p')
:exe 'edit '.stdpath('config'). '/init.vim'
:q
EOF

nvim -s ~/neovimCommands ~/dummyFile

cat << 'EOF' > ~/.config/nvim/init.vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/linux-config/vimrc
EOF
