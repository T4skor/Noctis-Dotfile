#!/usr/bin/env bash
##############################################
#   NOCTIS — Uninstaller / Restore backups
##############################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "\n  ${RED}${BOLD}NOCTIS — Desinstalar dotfiles${NC}\n"

CONFIGS=(
    "$HOME/.config/hypr"
    "$HOME/.config/waybar"
    "$HOME/.config/wofi"
    "$HOME/.config/kitty"
    "$HOME/.config/dunst"
)

for config in "${CONFIGS[@]}"; do
    if [ -L "$config" ]; then
        rm "$config"
        echo -e "  ${GREEN}[OK]${NC} Eliminado symlink: $(basename "$config")"

        # Restaurar backup más reciente si existe
        latest_backup=$(ls -td "${config}.bak."* 2>/dev/null | head -1)
        if [ -n "$latest_backup" ]; then
            mv "$latest_backup" "$config"
            echo -e "  ${YELLOW}[OK]${NC} Restaurado backup: $(basename "$latest_backup")"
        fi
    elif [ -d "$config" ]; then
        echo -e "  ${YELLOW}[SKIP]${NC} $(basename "$config") no es un symlink, no se toca"
    fi
done

echo -e "\n  ${GREEN}Dotfiles desenlazados. Backups restaurados si existían.${NC}\n"
