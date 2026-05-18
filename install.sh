#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║            NOCTIS — Dotfiles Installer                      ║
# ║            Arch Linux + Hyprland + Cyberpunk                ║
# ╚══════════════════════════════════════════════════════════════╝
set -euo pipefail

# ─────────────────────────────────────────────────────────────────
# COLORES
# ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${CYAN}${BOLD}[*]${NC} $*"; }
ok()   { echo -e "${GREEN}${BOLD}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}${BOLD}[!]${NC} $*"; }
err()  { echo -e "${RED}${BOLD}[✗]${NC} $*"; exit 1; }

# ─────────────────────────────────────────────────────────────────
# SEGURIDAD: no ejecutar como root
# ─────────────────────────────────────────────────────────────────
if [[ "$EUID" -eq 0 ]]; then
    err "No ejecutes este script como root. Usa tu usuario normal."
fi

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo -e "${CYAN}${BOLD}"
echo "  ███╗   ██╗ ██████╗  ██████╗████████╗██╗███████╗"
echo "  ████╗  ██║██╔═══██╗██╔════╝╚══██╔══╝██║██╔════╝"
echo "  ██╔██╗ ██║██║   ██║██║        ██║   ██║███████╗"
echo "  ██║╚██╗██║██║   ██║██║        ██║   ██║╚════██║"
echo "  ██║ ╚████║╚██████╔╝╚██████╗   ██║   ██║███████║"
echo "  ╚═╝  ╚═══╝ ╚═════╝  ╚═════╝   ╚═╝   ╚═╝╚══════╝"
echo -e "${NC}"
echo -e "  ${BOLD}Dotfiles Installer — Arch + Hyprland + Cyberpunk${NC}"
echo ""

# ─────────────────────────────────────────────────────────────────
# 1. ACTUALIZAR SISTEMA
# ─────────────────────────────────────────────────────────────────
log "Actualizando sistema..."
sudo pacman -Syu --noconfirm
ok "Sistema actualizado"

# ─────────────────────────────────────────────────────────────────
# 2. PAQUETES BASE (pacman)
# ─────────────────────────────────────────────────────────────────
log "Instalando paquetes base..."

PACMAN_PKGS=(
    # ── Hyprland core ──────────────────────────────────────────
    hyprland
    hyprlock
    hypridle
    hyprpaper
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk       # fallback portal para apps GTK
    xdg-user-dirs                # crea ~/Pictures, ~/Downloads, etc.

    # ── Wayland utils ──────────────────────────────────────────
    waybar
    wofi
    dunst
    wl-clipboard
    cliphist
    grim
    slurp
    qt5-wayland
    qt6-wayland

    # ── Terminal & shell ────────────────────────────────────────
    kitty
    fish
    starship
    zoxide
    eza                          # ls con colores
    bat                          # cat con syntax highlight
    fd                           # find moderno
    ripgrep
    fzf

    # ── Audio ───────────────────────────────────────────────────
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    pavucontrol

    # ── Red & Bluetooth ─────────────────────────────────────────
    networkmanager
    network-manager-applet
    nm-connection-editor
    blueman
    bluez
    bluez-utils

    # ── Multimedia ──────────────────────────────────────────────
    playerctl
    brightnessctl
    mpv

    # ── Fuentes ─────────────────────────────────────────────────
    ttf-jetbrains-mono-nerd
    ttf-firacode-nerd
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk
    otf-font-awesome
    ttf-liberation

    # ── Iconos & temas GTK ──────────────────────────────────────
    papirus-icon-theme
    gnome-themes-extra
    adwaita-icon-theme

    # ── Polkit ──────────────────────────────────────────────────
    polkit-kde-agent

    # ── Archivos & utils ────────────────────────────────────────
    thunar
    thunar-volman
    tumbler
    gvfs
    ark
    unzip
    p7zip
    curl
    wget
    git
    base-devel
    jq

    # ── Sistema ─────────────────────────────────────────────────
    btop
    fastfetch
    man-db
)

sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
ok "Paquetes base instalados"

# ─────────────────────────────────────────────────────────────────
# 3. AUR HELPER (paru/yay)
# ─────────────────────────────────────────────────────────────────
if command -v paru &>/dev/null; then
    AUR_HELPER="paru"
    ok "paru detectado"
elif command -v yay &>/dev/null; then
    AUR_HELPER="yay"
    ok "yay detectado"
else
    log "Instalando paru (AUR helper)..."
    # CachyOS incluye paru en sus repos oficiales, intentamos con pacman primero
    if sudo pacman -S --needed --noconfirm paru 2>/dev/null; then
        AUR_HELPER="paru"
    else
        rm -rf /tmp/paru-install
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/paru.git /tmp/paru-install
        (cd /tmp/paru-install && makepkg -si --noconfirm)
        rm -rf /tmp/paru-install
        AUR_HELPER="paru"
    fi
    ok "paru instalado"
fi

# ─────────────────────────────────────────────────────────────────
# 4. PAQUETES AUR
# ─────────────────────────────────────────────────────────────────
log "Instalando paquetes AUR usando $AUR_HELPER..."

AUR_PKGS=(
    grimblast-git        # screenshot con área/ventana
    wlogout              # menú logout con botones
    hyprshot             # screenshot wrapper para Hyprland
    swww                 # wallpaper animado (alternativa a hyprpaper)
    vesktop-bin          # Discord con Wayland nativo
    spotify              # Spotify
    nwg-look             # configurar tema GTK en Wayland
    waypaper             # GUI para cambiar wallpaper
)

$AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}"
ok "Paquetes AUR instalados"

# ─────────────────────────────────────────────────────────────────
# 5. XDG USER DIRS
# ─────────────────────────────────────────────────────────────────
log "Creando directorios de usuario estándar..."
xdg-user-dirs-update
mkdir -p \
    ~/Pictures/wallpapers \
    ~/Pictures/screenshots \
    ~/Documents \
    ~/Downloads \
    ~/Videos \
    ~/Music \
    ~/.local/bin
ok "Directorios creados"

# ─────────────────────────────────────────────────────────────────
# 6. SYMLINKS DE CONFIGS
# ─────────────────────────────────────────────────────────────────
log "Enlazando configuraciones..."

mkdir -p ~/.config

# Función segura para crear symlinks (elimina si ya existe)
link_config() {
    local src="$DOTFILES_DIR/$1"
    local dst="$HOME/.config/$1"

    if [[ ! -d "$src" && ! -f "$src" ]]; then
        warn "No existe $src — saltando"
        return
    fi

    # Si ya existe como symlink o directorio, hacer backup
    if [[ -e "$dst" || -L "$dst" ]]; then
        warn "Backup: $dst → ${dst}.bak"
        rm -rf "${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -sf "$src" "$dst"
    ok "Enlazado: ~/.config/$1"
}

link_config hypr
link_config waybar
link_config wofi
link_config kitty
link_config dunst
link_config fish
link_config starship

# Starship config si está en raíz del dotfiles
if [[ -f "$DOTFILES_DIR/starship.toml" ]]; then
    ln -sf "$DOTFILES_DIR/starship.toml" ~/.config/starship.toml
    ok "Enlazado: ~/.config/starship.toml"
fi

# ─────────────────────────────────────────────────────────────────
# 7. SHELL — fish como default
# ─────────────────────────────────────────────────────────────────
log "Configurando fish como shell por defecto..."
FISH_PATH="$(command -v fish)"
if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
fi
if [[ "$SHELL" != "$FISH_PATH" ]]; then
    chsh -s "$FISH_PATH"
    ok "Shell cambiada a fish (efectivo al reiniciar sesión)"
else
    ok "fish ya es la shell por defecto"
fi

# ─────────────────────────────────────────────────────────────────
# 8. SERVICIOS DE USUARIO
# ─────────────────────────────────────────────────────────────────
log "Habilitando servicios de usuario..."
systemctl --user enable --now pipewire          2>/dev/null || true
systemctl --user enable --now pipewire-pulse    2>/dev/null || true
systemctl --user enable --now wireplumber       2>/dev/null || true
ok "Servicios de audio activos"

# ─────────────────────────────────────────────────────────────────
# 9. SERVICIOS DE SISTEMA
# ─────────────────────────────────────────────────────────────────
log "Habilitando servicios de sistema..."
sudo systemctl enable --now NetworkManager  2>/dev/null || true
sudo systemctl enable --now bluetooth       2>/dev/null || true
ok "NetworkManager y Bluetooth activos"

# ─────────────────────────────────────────────────────────────────
# 10. PERMISOS
# ─────────────────────────────────────────────────────────────────
log "Aplicando permisos a scripts..."
find "$DOTFILES_DIR" -name "*.sh" -exec chmod +x {} \;
ok "Permisos aplicados"

# ─────────────────────────────────────────────────────────────────
# FIN
# ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║        Instalación completada ✓              ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Próximos pasos:${NC}"
echo -e "  ${CYAN}1.${NC} Pon un wallpaper en ${BOLD}~/Pictures/wallpapers/${NC}"
echo -e "  ${CYAN}2.${NC} Comprueba ${BOLD}~/.config/hypr/hyprpaper.conf${NC} apunta a tu wallpaper"
echo -e "  ${CYAN}3.${NC} Reinicia o ejecuta ${BOLD}Hyprland${NC} desde tty"
echo -e "  ${CYAN}4.${NC} Configs con backup en ${BOLD}~/.config/<nombre>.bak${NC}"
echo ""
