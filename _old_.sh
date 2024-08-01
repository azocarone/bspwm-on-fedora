
# VARIABLE DATABASE AND OTHER THINGS
USERNAME=$(whoami)
LOCALPATH="/home/${USERNAME}"
RUTE=$(pwd)


echo -e "${White} [${Blue}i${White}] Step 12 Installing the powerlevel10k, fzf, sudo-plugin, and others for the normal user"

cd ${RUTE}
cp -r .zshrc .p10k.zsh ${LOCALPATH}
cd /usr/share ; sudo mkdir -p zsh-sudo
cd zsh-sudo ; sudo wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh

cd ; git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

cd ${LOCALPATH}/scripts ; git clone https://github.com/charitarthchugh/shell-color-scripts.git

sudo rm -rf ${LOCALPATH}/scripts/shell-color-scripts/colorscripts
sudo rm -rf ${LOCALPATH}/scripts/shell-color-scripts/colorscript.sh
cd ${LOCALPATH}/scripts
mv colorscripts colorscript.sh ${LOCALPATH}/scripts/shell-color-scripts
chmod +x ${LOCALPATH}/scripts/shell-color-scripts/colorscript.sh
cd ${LOCALPATH}/scripts/shell-color-scripts/colorscripts
chmod +x *
cd
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

cd ${LOCALPATH}/scripts ; git clone https://github.com/pipeseroni/pipes.sh.git

echo -e "${White} [${Blue}i${White}] Step 13 clone ghostscript and falcón repositories"

#
# Not deployed
#
#cd ${LOCALPATH}/scripts ; git clone https://github.com/AlvinPix/Ghost-script.git

#
# Not deployed
#
#cd ${LOCALPATH}/scripts ; git clone https://github.com/AlvinPix/Falcon.git
