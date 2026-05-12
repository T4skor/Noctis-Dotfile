#!/usr/bin/env bash
# NOCTIS — Power menu

chosen=$(printf "  Bloquear\n󰤄  Suspender\n  Reiniciar\n⏻  Apagar\n  Cerrar sesión" | \
    wofi --dmenu --width 260 --height 250 --location center \
         --prompt "" --cache-file /dev/null --hide-scroll --no-actions)

case "$chosen" in
    "  Bloquear")       hyprlock ;;
    "󰤄  Suspender")     systemctl suspend ;;
    "  Reiniciar")     systemctl reboot ;;
    "⏻  Apagar")        systemctl poweroff ;;
    "  Cerrar sesión") hyprctl dispatch exit 0 ;;
esac
