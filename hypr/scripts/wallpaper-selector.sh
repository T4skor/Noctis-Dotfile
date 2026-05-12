#!/usr/bin/env bash
####################################################################
# wallpaper-selector.sh — Selector de fondos de pantalla con wofi
#
# Muestra los wallpapers disponibles en ~/Pictures/wallpapers/
# usando wofi como menú, y aplica el seleccionado con hyprpaper.
#
# Dependencias: wofi, hyprpaper, hyprctl
####################################################################

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CURRENT_FILE="$HOME/Pictures/wallpaper.png"

# ── Verificar que hay fondos ─────────────────────────────────────
if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    notify-send "Wallpaper Selector" "No hay fondos en $WALLPAPER_DIR" -u critical
    exit 1
fi

# ── Construir lista de nombres ───────────────────────────────────
# Genera nombres legibles: reemplaza _ por espacios y quita extensión
entries=""
while IFS= read -r -d $'\0' file; do
    fname=$(basename "$file")
    # Nombre bonito: quitar extensión, reemplazar _ por espacios, capitalizar
    pretty=$(echo "${fname%.*}" | sed 's/_/ /g; s/\b\(.\)/\u\1/g')
    entries+="$pretty\n"
done < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) -print0 | sort -z)

# ── Mostrar en wofi ──────────────────────────────────────────────
selected=$(echo -e "$entries" | wofi --dmenu \
    --prompt "  Wallpaper" \
    --width 500 \
    --height 400 \
    --cache-file /dev/null \
    --style "$HOME/.config/wofi/style.css" 2>/dev/null)

# Si se cancela
[ -z "$selected" ] && exit 0

# ── Buscar el archivo correspondiente ────────────────────────────
# Revertir: lowercase, espacios a _
search_name=$(echo "$selected" | sed 's/ /_/g' | tr '[:upper:]' '[:lower:]')

matched=""
while IFS= read -r -d $'\0' file; do
    fname=$(basename "$file")
    fname_lower=$(echo "${fname%.*}" | tr '[:upper:]' '[:lower:]')
    if [ "$fname_lower" = "$search_name" ]; then
        matched="$file"
        break
    fi
done < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) -print0)

if [ -z "$matched" ]; then
    notify-send "Wallpaper Selector" "No se encontró: $selected" -u critical
    exit 1
fi

# ── Copiar como wallpaper activo ─────────────────────────────────
cp "$matched" "$CURRENT_FILE"

# ── Aplicar con hyprpaper ────────────────────────────────────────
# Reiniciar hyprpaper para que recargue la config con el nuevo archivo
pkill hyprpaper 2>/dev/null
sleep 0.3
hyprpaper &
disown

notify-send "Wallpaper" "Aplicado: $(basename "$matched")" -t 3000
