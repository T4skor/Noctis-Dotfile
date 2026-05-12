# 🌙 NOCTIS — Hyprland Dotfiles

> Arch Linux · Hyprland · Cyberpunk Purple aesthetic

![Hyprland](https://img.shields.io/badge/Hyprland-0.54+-bd00ff?style=flat-square&logo=wayland&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-rolling-1793D1?style=flat-square&logo=archlinux&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-00e5c5?style=flat-square)

## ✨ Componentes

| Componente | Programa | Config |
|---|---|---|
| Compositor | Hyprland | `hypr/hyprland.conf` |
| Barra | Waybar | `waybar/config.jsonc` |
| Launcher | Wofi | `wofi/config` |
| Terminal | Kitty | `kitty/kitty.conf` |
| Notificaciones | Dunst | `dunst/dunstrc` |
| Lock screen | Hyprlock | `hypr/hyprlock.conf` |
| Idle daemon | Hypridle | `hypr/hypridle.conf` |
| Wallpaper | Hyprpaper | `hypr/hyprpaper.conf` |

## 🎨 Paleta

```
Background   #0a0a0f  ██████
Surface      #1a1a2e  ██████
Accent       #bd00ff  ██████  ← Purple neon
Accent Dark  #7b00d4  ██████
Text         #e0d7ff  ██████
Success      #00ff9d  ██████
Error        #ff2d6b  ██████
Info/Cyan    #00e5c5  ██████
```

## 🚀 Instalación

```bash
git clone https://github.com/tu-usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

El instalador:
1. Instala todos los paquetes necesarios (pacman/yay)
2. Hace backup de configs existentes (`.bak`)
3. Crea symlinks a `~/.config/`
4. Configura permisos de scripts
5. Habilita servicios (Bluetooth, NetworkManager, PipeWire)

## 🗑️ Desinstalar

```bash
./uninstall.sh
```

Elimina los symlinks y restaura los backups creados durante la instalación.

## ⌨️ Atajos de teclado

### Aplicaciones
| Atajo | Acción |
|---|---|
| `Super + Return` | Terminal (Kitty) |
| `Super + B` | Navegador (Firefox) |
| `Super + E` | Archivos (Dolphin) |
| `Super + Space` | Launcher (Wofi) |
| `Super + S` | Spotify |
| `Super + L` | Bloquear pantalla |
| `Super + V` | Portapapeles |
| `Super + Shift + S` | Screenshot (área) |
| `Print` | Screenshot (completa) |

### Ventanas
| Atajo | Acción |
|---|---|
| `Super + Q` | Cerrar ventana |
| `Super + F` | Fullscreen |
| `Super + T` | Toggle floating |
| `Super + H/J/K` | Foco (vim) |
| `Super + Shift + H/J/K/L` | Mover ventana |
| `Super + Ctrl + H/J/K/L` | Redimensionar |

### Sistema
| Atajo | Acción |
|---|---|
| `Super + 1-0` | Workspace 1-10 |
| `Super + Shift + 1-0` | Mover a workspace |
| `Super + Shift + R` | Recargar config |
| `Super + Shift + W` | Cambiar wallpaper |
| `Super + Shift + Q` | Salir de Hyprland |

## 📁 Estructura

```
dotfiles/
├── install.sh              ← Instalador
├── uninstall.sh            ← Desinstalador
├── README.md
├── hypr/
│   ├── hyprland.conf       ← Config principal (sources modulares)
│   ├── colors.conf         ← Paleta cyberpunk
│   ├── animations.conf     ← Bezier curves
│   ├── keybinds.conf       ← Atajos de teclado
│   ├── windowrules.conf    ← Reglas por app
│   ├── hyprlock.conf       ← Lock screen
│   ├── hypridle.conf       ← Timeouts de idle
│   ├── hyprpaper.conf      ← Wallpaper
│   └── scripts/
│       ├── wallpaper.sh
│       └── wallpaper-selector.sh
├── waybar/
│   ├── config.jsonc
│   ├── style.css
│   └── scripts/
│       ├── mediaplayer.sh
│       └── audio-switcher.sh
├── wofi/
│   ├── config
│   ├── style.css
│   └── powermenu.sh
├── kitty/
│   ├── kitty.conf
│   └── current-theme.conf
└── dunst/
    └── dunstrc
```

## ⚙️ Post-instalación

1. Pon tu wallpaper en `~/Pictures/wallpaper.png`
2. Crea `~/Pictures/wallpapers/` con fondos para el selector
3. Edita `hypr/hyprland.conf` para ajustar tu monitor:
   ```
   monitor = DP-2, 1920x1080@144, 0x0, 1
   ```
4. Inicia Hyprland desde TTY: `Hyprland`

## 📝 Licencia

MIT
