#!/usr/bin/env bash
##############################################
#   NOCTIS — Dotfiles Installer
#   Arch Linux + Hyprland
##############################################

set -euo pipefail

# ── Colores ──────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Funciones ────────────────────────────────

print_header() {
    echo ""
    echo -e "${PURPLE}${BOLD}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║     🌙 NOCTIS — Dotfiles Installer   ║"
    echo "  ║     Arch Linux + Hyprland            ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

log_info()    { echo -e "  ${CYAN}[INFO]${NC}    $1"; }
log_ok()      { echo -e "  ${GREEN}[  OK]${NC}    $1"; }
log_warn()    { echo -e "  ${YELLOW}[WARN]${NC}    $1"; }
log_error()   { echo -e "  ${RED}[ERROR]${NC}   $1"; }
log_step()    { echo -e "\n  ${PURPLE}${BOLD}▸ $1${NC}"; }

confirm() {
    echo ""
    read -rp "  ¿Continuar? [s/N] " answer
    [[ "$answer" =~ ^[sS]$ ]] || { log_warn "Cancelado por el usuario."; exit 0; }
}

# ── Verificaciones ───────────────────────────

check_arch() {
    if ! command -v pacman &>/dev/null; then
        log_error "Este instalador requiere Arch Linux (pacman no encontrado)."
        exit 1
    fi
}

check_hyprland() {
    if ! command -v Hyprland &>/dev/null && ! command -v hyprctl &>/dev/null; then
        log_warn "Hyprland no está instalado. Se instalará con las dependencias."
    else
        local version
        version=$(hyprctl version 2>/dev/null | head -1 | grep -oP '[\d.]+' | head -1 || echo "desconocida")
        log_info "Hyprland detectado: v${version}"
    fi
}

# ── Instalación de paquetes ──────────────────

install_packages() {
    log_step "Instalando paquetes con pacman"

    local packages=(
        # Compositor
        hyprland

        # Utilidades de Hyprland
        hyprlock
        hypridle
        hyprpaper
        xdg-desktop-portal-hyprland

        # Barra y notificaciones
        waybar
        dunst

        # Launcher y menús
        wofi

        # Terminal
        kitty

        # Screenshots y portapapeles
        grimblast-git
        cliphist
        wl-clipboard

        # Multimedia
        playerctl
        brightnessctl
        wireplumber
        pipewire
        pipewire-pulse
        pavucontrol

        # Bluetooth y red
        blueman
        network-manager-applet

        # Fuentes
        ttf-jetbrains-mono-nerd
        otf-font-awesome
        noto-fonts
        noto-fonts-emoji

        # Temas e iconos
        papirus-icon-theme

        # Otros
        polkit-kde-agent
    )

    # Separar paquetes oficiales de AUR
    local official=()
    local aur=()

    for pkg in "${packages[@]}"; do
        if pacman -Si "$pkg" &>/dev/null; then
            official+=("$pkg")
        else
            aur+=("$pkg")
        fi
    done

    if [ ${#official[@]} -gt 0 ]; then
        log_info "Instalando ${#official[@]} paquetes oficiales..."
        sudo pacman -S --needed --noconfirm "${official[@]}" || {
            log_warn "Algunos paquetes oficiales fallaron. Continuando..."
        }
    fi

    if [ ${#aur[@]} -gt 0 ]; then
        log_info "Paquetes AUR detectados: ${aur[*]}"
        if command -v yay &>/dev/null; then
            log_info "Instalando con yay..."
            yay -S --needed --noconfirm "${aur[@]}" || log_warn "Algunos paquetes AUR fallaron."
        elif command -v paru &>/dev/null; then
            log_info "Instalando con paru..."
            paru -S --needed --noconfirm "${aur[@]}" || log_warn "Algunos paquetes AUR fallaron."
        else
            log_warn "No se encontró yay ni paru. Instálalos manualmente:"
            for pkg in "${aur[@]}"; do
                echo "        - $pkg"
            done
        fi
    fi

    log_ok "Paquetes instalados"
}

# ── Crear symlinks ───────────────────────────

backup_and_link() {
    local src="$1"
    local dest="$2"

    # Crear directorio padre si no existe
    mkdir -p "$(dirname "$dest")"

    # Backup si ya existe y no es un symlink al mismo destino
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        local backup="${dest}.bak.$(date +%Y%m%d_%H%M%S)"
        mv "$dest" "$backup"
        log_warn "Backup: $(basename "$dest") → $(basename "$backup")"
    elif [ -L "$dest" ]; then
        rm "$dest"
    fi

    ln -sf "$src" "$dest"
    log_ok "$(basename "$dest") → $(basename "$src")"
}

link_configs() {
    log_step "Enlazando configuraciones"

    # Hyprland
    backup_and_link "$DOTFILES_DIR/hypr" "$HOME/.config/hypr"

    # Waybar
    backup_and_link "$DOTFILES_DIR/waybar" "$HOME/.config/waybar"

    # Wofi
    backup_and_link "$DOTFILES_DIR/wofi" "$HOME/.config/wofi"

    # Kitty
    backup_and_link "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"

    # Dunst
    backup_and_link "$DOTFILES_DIR/dunst" "$HOME/.config/dunst"

    log_ok "Todas las configs enlazadas"
}

# ── Permisos de scripts ──────────────────────

set_permissions() {
    log_step "Configurando permisos de scripts"

    find "$DOTFILES_DIR" -name "*.sh" -exec chmod +x {} \;
    log_ok "Scripts marcados como ejecutables"
}

# ── Setup de wallpapers ──────────────────────

setup_wallpapers() {
    log_step "Configurando wallpapers"

    mkdir -p "$HOME/Pictures/wallpapers"

    if [ ! -f "$HOME/Pictures/wallpaper.png" ]; then
        log_warn "No se encontró ~/Pictures/wallpaper.png"
        log_info "Pon tu wallpaper favorito en ~/Pictures/wallpaper.png"
        log_info "O usa SUPER+SHIFT+W para el selector de fondos"
    else
        log_ok "Wallpaper encontrado"
    fi

    log_ok "Directorio ~/Pictures/wallpapers/ listo"
}

# ── Post-instalación ─────────────────────────

post_install() {
    log_step "Post-instalación"

    # Habilitar servicios si no están activos
    if command -v bluetoothctl &>/dev/null; then
        sudo systemctl enable --now bluetooth.service 2>/dev/null || true
        log_ok "Bluetooth habilitado"
    fi

    if command -v NetworkManager &>/dev/null; then
        sudo systemctl enable --now NetworkManager.service 2>/dev/null || true
        log_ok "NetworkManager habilitado"
    fi

    if command -v pipewire &>/dev/null; then
        systemctl --user enable --now pipewire.service 2>/dev/null || true
        systemctl --user enable --now pipewire-pulse.service 2>/dev/null || true
        systemctl --user enable --now wireplumber.service 2>/dev/null || true
        log_ok "PipeWire habilitado"
    fi
}

# ── Resumen final ────────────────────────────

print_summary() {
    echo ""
    echo -e "${GREEN}${BOLD}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║       ✅ Instalación completada       ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "  ${BOLD}Próximos pasos:${NC}"
    echo ""
    echo -e "  ${CYAN}1.${NC} Pon un wallpaper en ~/Pictures/wallpaper.png"
    echo -e "  ${CYAN}2.${NC} Inicia sesión en Hyprland desde tu display manager"
    echo -e "  ${CYAN}3.${NC} O desde TTY: ${BOLD}Hyprland${NC}"
    echo ""
    echo -e "  ${BOLD}Atajos clave:${NC}"
    echo -e "  ${PURPLE}SUPER + Return${NC}      Terminal (Kitty)"
    echo -e "  ${PURPLE}SUPER + Space${NC}       Launcher (Wofi)"
    echo -e "  ${PURPLE}SUPER + B${NC}           Navegador"
    echo -e "  ${PURPLE}SUPER + L${NC}           Bloquear pantalla"
    echo -e "  ${PURPLE}SUPER + SHIFT + R${NC}   Recargar config"
    echo -e "  ${PURPLE}SUPER + SHIFT + W${NC}   Cambiar wallpaper"
    echo ""
    echo -e "  ${YELLOW}Recuerda editar ~/.config/hypr/hyprland.conf${NC}"
    echo -e "  ${YELLOW}para ajustar monitor y apps por defecto.${NC}"
    echo ""
}

# ══════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════

main() {
    print_header

    log_info "Directorio de dotfiles: $DOTFILES_DIR"
    check_arch
    check_hyprland

    echo ""
    echo -e "  Este script va a:"
    echo -e "  ${CYAN}1.${NC} Instalar paquetes necesarios (pacman/yay)"
    echo -e "  ${CYAN}2.${NC} Enlazar configs a ~/.config/"
    echo -e "  ${CYAN}3.${NC} Configurar permisos y wallpapers"
    echo -e "  ${CYAN}4.${NC} Habilitar servicios (bluetooth, red, audio)"
    echo ""
    echo -e "  ${YELLOW}Se hará backup de configs existentes (.bak)${NC}"

    confirm

    install_packages
    set_permissions
    link_configs
    setup_wallpapers
    post_install
    print_summary
}

# Solo ejecutar si no se hace source
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
