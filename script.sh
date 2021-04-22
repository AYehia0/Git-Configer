#!/bin/bash 

# checking if root is given 
if ! [ $(id -u) = 0 ];
then
    echo "Run it as root using sudo" >&2
    exit 1
fi


# getting info about the distro
OS=`uname -s`
CODE_NAME=$(lsb_release -i -s)
DEBIAN="debian"
ARCH="arch"
FEDORA="fedora"

# Checking if git is installed or not 
check_git() {
    if ! [ -x "$(command -v git)" ]; 
    then
      echo "Error: git is not installed." >&2
      return 0
    else
        return 1
    fi
}

for f in $( find /etc -type f -maxdepth 1 \( ! -wholename /etc/os-release ! -wholename /etc/lsb-release -wholename /etc/\*release -o -wholename /etc/\*version \) 2> /dev/null )
do 
    OS_TYPE=${f}
done

case "$OS_TYPE" in
  *${DEBIAN}*) 
        if check_git; then
            echo "Installing git for debian..." 
            apt-get install git
        else
            echo "git is installed"
        fi
    ;;
  *${ARCH}*)

        if check_git; then
            echo "Installing git for arch..." 
            pacman -S git
        else
            echo "git is installed"
        fi
    ;;

  *${FEDORA}*) 
 
        if check_git; then
            echo "Installing git for fedora..." 
            dnf install git
        else
            echo "git is installed"
        fi
    ;;
  *)         
    echo "I don't know this distro, exiting..." 
    exit 1
    ;;
esac

# Dropping the root 
if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
    echo $real_user
else
    real_user=$(whoami)
fi


# configuring git
echo "Configuring git..."
echo "What is your Username ?"
read USERNAME

echo "What is your github Email ?"
read EMAIL

echo "Which text editor you use ? (choose default : nano/vim/emacs)"
read EDITOR

sudo -u $real_user git config --global user.name "$USERNAME"
sudo -u $real_user git config --global user.email "$EMAIL"
sudo -u $real_user git config --global user.editor "$EDITOR"

echo "Generating a new SSH key..."
sudo -u $real_user ssh-keygen -t ed25519 -C "$EMAIL"

echo "Adding your SSH key to the ssh-agent..."
echo "Starting SSH agent in the backgroud..."
eval "$(ssh-agent -s)"

echo "Adding your private key to the ssh-agent ..."
ssh-add ~/.ssh/id_ed25519

echo "Please copy the Public SSH key to your account : https://github.com/settings/ssh/new "
cat ~/.ssh/id_ed25519




