#!/usr/bin/env bash
####################################################################
# wallpaper.sh — Script de fondo de pantalla cyberpunk
#
# Función: Descarga fondos de pantalla cyberpunk desde GitHub
#          y los aplica aleatoriamente con swaybg.
#
# Modularidad: Para cambiar el repositorio de fondos, solo cambia
#              WALLPAPER_REPO y WALLPAPER_SUBDIR abajo.
#
# Dependencias: swaybg, curl, git (opcionales: feh para X11)
####################################################################

# ══════════════════════════════════════════════
# CONFIGURACIÓN — Edita estas variables para cambiar fuente de fondos
# ══════════════════════════════════════════════

# Directorio local donde se guardarán los fondos
WALLPAPER_DIR="$HOME/.local/share/wallpapers/cyberpunk"

# Repositorio de GitHub con wallpapers cyberpunk
# Opción 1 (recomendada): lo-fi/cyberpunk collection
WALLPAPER_REPO="https://github.com/michaelScopic/wallpapers"
WALLPAPER_SUBDIR="Cyberpunk"

# Modo de aplicación del fondo (para swaybg):
# fill, fit, stretch, center, tile
WALLPAPER_MODE="fill"

# ══════════════════════════════════════════════
# FUNCIONES
# ══════════════════════════════════════════════

log() {
    echo "[wallpaper.sh] $1"
}

download_wallpapers() {
    log "Creando directorio: $WALLPAPER_DIR"
    mkdir -p "$WALLPAPER_DIR"

    # Intentar clonar/actualizar el repo
    local REPO_DIR="$HOME/.local/share/wallpapers/.repo"

    if [ -d "$REPO_DIR/.git" ]; then
        log "Actualizando repositorio de fondos..."
        git -C "$REPO_DIR" pull --quiet 2>/dev/null || log "No se pudo actualizar (sin internet?)"
    else
        log "Clonando repositorio de fondos de pantalla..."
        mkdir -p "$REPO_DIR"
        git clone --depth=1 --filter=blob:none --sparse "$WALLPAPER_REPO" "$REPO_DIR" 2>/dev/null
        git -C "$REPO_DIR" sparse-checkout set "$WALLPAPER_SUBDIR" 2>/dev/null || true
    fi

    # Copiar imágenes al directorio de destino
    if [ -d "$REPO_DIR/$WALLPAPER_SUBDIR" ]; then
        find "$REPO_DIR/$WALLPAPER_SUBDIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) \
            -exec cp -n {} "$WALLPAPER_DIR/" \; 2>/dev/null
        log "Fondos copiados a $WALLPAPER_DIR"
    else
        log "Subcarpeta $WALLPAPER_SUBDIR no encontrada. Usando todos los fondos del repo..."
        find "$REPO_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) \
            -exec cp -n {} "$WALLPAPER_DIR/" \; 2>/dev/null
    fi

    # Fallback: si no hay fondos, descargar uno hardcoded
    if [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
        log "No se encontraron fondos locales. Descargando fallback..."
        curl -sL "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/evening-sky.png" \
            -o "$WALLPAPER_DIR/fallback.png" 2>/dev/null || true
    fi
}

apply_random_wallpaper() {
    # Buscar imágenes disponibles
    local WALLS=()
    while IFS= read -r -d $'\0' file; do
        WALLS+=("$file")
    done < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) -print0 2>/dev/null)

    if [ ${#WALLS[@]} -eq 0 ]; then
        log "ERROR: No se encontraron fondos de pantalla en $WALLPAPER_DIR"
        exit 1
    fi

    # Seleccionar uno aleatorio
    local SELECTED="${WALLS[$RANDOM % ${#WALLS[@]}]}"
    log "Aplicando fondo: $(basename "$SELECTED")"

    # Guardar el seleccionado para referencia
    echo "$SELECTED" > "$HOME/.local/share/wallpapers/.current"

    # Matar instancias anteriores de swaybg
    pkill swaybg 2>/dev/null || true
    sleep 0.3

    # Aplicar el fondo con swaybg (en background)
    swaybg -m "$WALLPAPER_MODE" -i "$SELECTED" &
    disown
}

# ══════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════

# Si no hay fondos descargados todavía, descargar primero
if [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    download_wallpapers
fi

apply_random_wallpaper

# Si se pasa el argumento "update", actualizar fondos y aplicar
if [ "$1" = "update" ]; then
    download_wallpapers
    apply_random_wallpaper
fi

log "Fondo aplicado correctamente."
