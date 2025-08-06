#!/bin/bash

# Cores para o menu
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para executar comandos com feedback
executar_comando() {
    echo -e "\n${CYAN}Executando: $1${NC}"
    eval "$1"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ Concluído com sucesso${NC}"
    else
        echo -e "${RED}✖ Ocorreu um erro${NC}"
    fi
}

# Funções de atualização
executar_todas_atualizacoes() {
    echo -e "\n${BLUE}=== INICIANDO TODAS AS ATUALIZAÇÕES ===${NC}"
    
    executar_comando "sudo apt update"
    executar_comando "sudo apt upgrade -y"
    executar_comando "sudo apt full-upgrade"
    executar_comando "sudo apt dist-upgrade -y"
    executar_comando "sudo apt autoremove -y"
    executar_comando "sudo apt autoclean -y"
    executar_comando "sudo apt clean -y"
    
    echo -e "\n${GREEN}Todas as atualizações foram concluídas!${NC}"
}

# Funções de instalação
instalar_snap() {
    executar_comando "sudo apt update && sudo apt install snapd -y"
}

instalar_flatpak() {
    executar_comando "sudo apt update"
    executar_comando "sudo add-apt-repository ppa:flatpak/stable -y"
    executar_comando "sudo apt update"
    executar_comando "sudo apt install flatpak -y"
    executar_comando "sudo apt install gnome-software-plugin-flatpak -y"
    executar_comando "flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
}

# Funções para programas
instalar_programas() {
    local tipo=$1
    shift
    local programas=("$@")
    
    echo -e "\n${BLUE}Instalando programas via $tipo...${NC}"
    
    for programa in "${programas[@]}"; do
        if [ "$tipo" == "Flatpak" ]; then
            executar_comando "flatpak install flathub $programa -y"
        else
            executar_comando "sudo snap install $programa"
        fi
    done
}

# Funções de otimização
ajustar_swappiness() {
    echo -e "\n${BLUE}=== AJUSTE DE SWAPPINESS ===${NC}"
    echo -e "Valor atual: $(cat /proc/sys/vm/swappiness)"
    
    echo -e "\n${YELLOW}Adicione a linha: vm.swappiness=10 no final do arquivo${NC}"
    read -p "Pressione Enter para editar o arquivo..."
    sudo nano /etc/sysctl.conf
    
    executar_comando "sudo sysctl -p"
    echo -e "\nNovo valor: $(cat /proc/sys/vm/swappiness)"
}

desativar_swapfile() {
    echo -e "\n${BLUE}=== DESATIVANDO SWAPFILE ===${NC}"
    executar_comando "sudo swapon --show"
    executar_comando "sudo swapoff -v /swapfile"
    
    echo -e "\n${YELLOW}Comente a linha do swapfile em /etc/fstab${NC}"
    read -p "Pressione Enter para editar o arquivo..."
    sudo nano /etc/fstab
    
    executar_comando "sudo rm -v /swapfile"
    echo -e "\n${YELLOW}Recomenda-se reiniciar o sistema${NC}"
}

instalar_preload() {
    executar_comando "sudo apt install preload -y"
    executar_comando "sudo systemctl start preload"
    executar_comando "sudo systemctl enable preload"
}

configurar_cpufreq() {
    executar_comando "sudo apt install cpufrequtils -y"
    
    echo -e "\n${BLUE}Criando serviço set-cpufreq...${NC}"
    sudo bash -c 'cat > /etc/systemd/system/set-cpufreq.service << EOF
[Unit]
Description=Set CPU governor to performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/set-cpufreq.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF'
    
    sudo bash -c 'cat > /usr/bin/set-cpufreq.sh << EOF
#!/bin/bash
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
 cpufreq-set -c "${cpu##*/cpu}" -g performance
done
EOF'
    
    executar_comando "sudo chmod +x /usr/bin/set-cpufreq.sh"
    executar_comando "sudo systemctl daemon-reload"
    executar_comando "sudo systemctl enable set-cpufreq.service"
    executar_comando "sudo systemctl start set-cpufreq.service"
}

configurar_trim() {
    executar_comando "sudo systemctl start fstrim.timer"
    executar_comando "sudo systemctl enable fstrim.timer"
    echo -e "\n${BLUE}Status do TRIM:${NC}"
    systemctl status fstrim.timer | grep -E "Active|Loaded"
}

# Funções de configuração
definir_navegador_padrao() {
    executar_comando "xdg-mime default google-chrome.desktop x-scheme-handler/http"
    executar_comando "xdg-mime default google-chrome.desktop text/html"
    executar_comando "xdg-mime default google-chrome.desktop application/xhtml+xml"
    executar_comando "xdg-mime default google-chrome.desktop x-scheme-handler/https"
}

definir_vlc_padrao() {
    # Vídeo
    executar_comando "xdg-mime default vlc.desktop video/mp4"
    executar_comando "xdg-mime default vlc.desktop video/webm"
    executar_comando "xdg-mime default vlc.desktop video/x-matroska"
    # Áudio
    executar_comando "xdg-mime default vlc.desktop audio/x-mp3"
    executar_comando "xdg-mime default vlc.desktop audio/mpeg"
}

# Menus secundários
menu_programas_gui() {
    while true; do
        clear
        echo -e "${PURPLE}\nINSTALAR PROGRAMAS VIA:${NC}"
        echo -e "${BLUE}=============================${NC}"
        echo -e "1. Flatpak"
        echo -e "2. Snap"
        echo -e "0. Voltar"
        echo -e "${BLUE}=============================${NC}"
        
        read -p "Escolha: " opcao
        
        case $opcao in
            1) metodo="Flatpak";;
            2) metodo="Snap";;
            0) return;;
            *) continue;;
        esac
        
        clear
        echo -e "${PURPLE}\nCATEGORIAS:${NC}"
        echo -e "${BLUE}=============================${NC}"
        echo -e "1. Segurança (Bitwarden)"
        echo -e "2. Multimídia (VLC, Spotify)"
        echo -e "3. Produtividade (LibreOffice)"
        echo -e "4. Desenvolvimento (VS Code)"
        echo -e "5. Todos os programas"
        echo -e "0. Voltar"
        echo -e "${BLUE}=============================${NC}"
        
        read -p "Escolha: " categoria
        
        case $categoria in
            1) programas=("com.bitwarden.desktop");;
            2) programas=("org.videolan.VLC" "com.spotify.Client");;
            3) programas=("org.libreoffice.LibreOffice" "org.onlyoffice.desktopeditors");;
            4) programas=("com.visualstudio.code");;
            5) programas=("com.bitwarden.desktop" "org.videolan.VLC" "com.spotify.Client" "org.libreoffice.LibreOffice" "com.visualstudio.code");;
            0) continue;;
            *) continue;;
        esac
        
        if [ "$metodo" == "Snap" ]; then
            snap_programas=()
            for p in "${programas[@]}"; do
                case $p in
                    "com.bitwarden.desktop") snap_programas+=("bitwarden");;
                    "org.videolan.VLC") snap_programas+=("vlc");;
                    "com.spotify.Client") snap_programas+=("spotify");;
                    "org.libreoffice.LibreOffice") snap_programas+=("libreoffice");;
                    "com.visualstudio.code") snap_programas+=("code --classic");;
                esac
            done
            instalar_programas "Snap" "${snap_programas[@]}"
        else
            instalar_programas "Flatpak" "${programas[@]}"
        fi
        
        read -p $'\nPressione Enter para continuar...'
    done
}

menu_terminal() {
    while true; do
        clear
        echo -e "${PURPLE}\nINSTALAR VIA TERMINAL:${NC}"
        echo -e "${BLUE}=============================${NC}"
        echo -e "1. Programas de terceiros"
        echo -e "2. Pacote ADB"
        echo -e "3. Base e módulos de software"
        echo -e "4. Monitoramento"
        echo -e "5. Codecs extras"
        echo -e "6. Wine completo"
        echo -e "0. Voltar"
        echo -e "${BLUE}=============================${NC}"
        
        read -p "Escolha: " opcao
        
        case $opcao in
            1) executar_comando "sudo add-apt-repository ppa:git-core/ppa -y && sudo apt update && sudo apt install notepadqq stacer solaar gparted synaptic curl wget ufw gufw gnome-tweaks gnome-software neofetch apturl apturl-common cpu-x timeshift adb openjdk-21-jre git gdebi transmission gedit shotwell -y";;
            2) executar_comando "sudo apt update && sudo apt install google-android-platform-tools-installer -y";;
            3) executar_comando "sudo apt install software-properties-common build-essential dkms lsb-release apt-transport-https module-assistant -y";;
            4) executar_comando "sudo apt install htop nmon i8kutils psensor tlp tlp-rdw cpufrequtils cputool ipmitool ipmiutil smartmontools cpupower-gui -y";;
            5) executar_comando "sudo apt install arc arj cabextract lhasa p7zip p7zip-full p7zip-rar rar unrar unace unzip xz-utils zip ubuntu-restricted-extras -y";;
            6) instalar_wine;;
            0) return;;
        esac
        
        read -p $'\nPressione Enter para continuar...'
    done
}

menu_configuracoes() {
    while true; do
        clear
        echo -e "${PURPLE}\nCONFIGURAÇÕES:${NC}"
        echo -e "${BLUE}=============================${NC}"
        echo -e "1. Ativar Firewall"
        echo -e "2. Mostrar programas ocultos"
        echo -e "3. Definir Chrome como padrão"
        echo -e "4. Definir VLC como padrão"
        echo -e "0. Voltar"
        echo -e "${BLUE}=============================${NC}"
        
        read -p "Escolha: " opcao
        
        case $opcao in
            1) executar_comando "sudo ufw enable";;
            2) executar_comando "sudo sed -i \"s/NoDisplay=true/NoDisplay=false/g\" /etc/xdg/autostart/*.desktop";;
            3) definir_navegador_padrao;;
            4) definir_vlc_padrao;;
            0) return;;
        esac
        
        read -p $'\nPressione Enter para continuar...'
    done
}

menu_otimizacoes() {
    while true; do
        clear
        echo -e "${PURPLE}\nOTIMIZAÇÕES:${NC}"
        echo -e "${BLUE}=============================${NC}"
        echo -e "1. Ajustar swappiness"
        echo -e "2. Otimizações para SSD"
        echo -e "0. Voltar"
        echo -e "${BLUE}=============================${NC}"
        
        read -p "Escolha: " opcao
        
        case $opcao in
            1) ajustar_swappiness;;
            2) menu_otimizacoes_ssd;;
            0) return;;
        esac
        
        read -p $'\nPressione Enter para continuar...'
    done
}

menu_otimizacoes_ssd() {
    while true; do
        clear
        echo -e "${PURPLE}\nOTIMIZAÇÕES SSD:${NC}"
        echo -e "${BLUE}=============================${NC}"
        echo -e "1. Desativar swapfile"
        echo -e "2. Instalar Preload"
        echo -e "3. Configurar CPUFreq"
        echo -e "4. Configurar TRIM diário"
        echo -e "5. Executar todas"
        echo -e "0. Voltar"
        echo -e "${BLUE}=============================${NC}"
        
        read -p "Escolha: " opcao
        
        case $opcao in
            1) desativar_swapfile;;
            2) instalar_preload;;
            3) configurar_cpufreq;;
            4) configurar_trim;;
            5) 
                desativar_swapfile
                instalar_preload
                configurar_cpufreq
                configurar_trim
                ;;
            0) return;;
        esac
        
        read -p $'\nPressione Enter para continuar...'
    done
}

instalar_wine() {
    echo -e "\n${BLUE}=== INSTALANDO WINE ===${NC}"
    
    executar_comando "sudo dpkg --add-architecture i386"
    
    source /etc/os-release
    UBUNTU_CODENAME=$(echo "$VERSION_CODENAME" | tr '[:upper:]' '[:lower:]')
    
    executar_comando "sudo mkdir -pm755 /etc/apt/keyrings"
    executar_comando "sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key"
    
    case $UBUNTU_CODENAME in
        "noble") repo="noble";;
        "jammy") repo="jammy";;
        "focal") repo="focal";;
        *) repo="noble";;
    esac
    
    executar_comando "sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$repo/winehq-$repo.sources"
    executar_comando "sudo apt update"
    
    echo -e "\n${PURPLE}ESCOLHA A VERSÃO:${NC}"
    echo -e "1. Estável (recomendado)"
    echo -e "2. Desenvolvimento"
    echo -e "3. Staging"
    read -p "Opção: " versao
    
    case $versao in
        2) pkg="wine-devel";;
        3) pkg="wine-staging";;
        *) pkg="wine-stable";;
    esac
    
    executar_comando "sudo apt install --install-recommends $pkg -y"
}

# Menu principal
while true; do
    clear
    echo -e "${PURPLE}\nMENU PRINCIPAL${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}ATUALIZAÇÃO:${NC}"
    echo -e "1. Todas as atualizações"
    echo -e "2. Atualizar lista de pacotes"
    echo -e "3. Atualizar pacotes"
    echo -e "4. Atualização completa"
    echo -e "5. Remover pacotes não usados"
    echo -e "6. Limpar cache"
    echo -e "${YELLOW}GERENCIADORES:${NC}"
    echo -e "7. Instalar Snap"
    echo -e "8. Instalar Flatpak"
    echo -e "${YELLOW}PROGRAMAS:${NC}"
    echo -e "9. Instalar programas"
    echo -e "${YELLOW}CONFIGURAÇÕES:${NC}"
    echo -e "10. Configurações do sistema"
    echo -e "${YELLOW}OTIMIZAÇÕES:${NC}"
    echo -e "11. Otimizações"
    echo -e "${YELLOW}SAIR:${NC}"
    echo -e "0. Sair"
    echo -e "${BLUE}=============================${NC}"
    
    read -p "Escolha: " opcao
    
    case $opcao in
        1) executar_todas_atualizacoes;;
        2) executar_comando "sudo apt update";;
        3) executar_comando "sudo apt upgrade -y";;
        4) executar_comando "sudo apt full-upgrade";;
        5) executar_comando "sudo apt autoremove -y";;
        6) executar_comando "sudo apt autoclean -y && sudo apt clean -y";;
        7) instalar_snap;;
        8) instalar_flatpak;;
        9) menu_programas_gui;;
        10) menu_configuracoes;;
        11) menu_otimizacoes;;
        0) 
            echo -e "\n${GREEN}Até logo!${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Opção inválida!${NC}"
            ;;
    esac
    
    read -p $'\nPressione Enter para continuar...'
done