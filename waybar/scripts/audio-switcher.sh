#!/bin/bash
# ──────────────────────────────────────────────
# Audio Device Switcher for Waybar + Wofi
# Uses pactl to list and switch devices
# ──────────────────────────────────────────────

ICON_SPEAKER="󰓃"
ICON_HEADPHONES="󰋋"
ICON_HDMI="󰡁"
ICON_MIC="󰍬"
ICON_LOOPBACK="󰑈"
ICON_OUTPUT="󰕾"
ICON_INPUT="󰍬"

get_icon() {
    local name="$1" type="$2"
    local lower="${name,,}"
    
    if [[ "$lower" == *"hyperx"* || "$lower" == *"headphone"* || "$lower" == *"headset"* ]]; then
        echo "$ICON_HEADPHONES"
    elif [[ "$lower" == *"hdmi"* || "$lower" == *"display"* ]]; then
        echo "$ICON_HDMI"
    elif [[ "$lower" == *"loopback"* || "$lower" == *"loop"* ]]; then
        echo "$ICON_LOOPBACK"
    elif [[ "$type" == "source" ]]; then
        echo "$ICON_MIC"
    else
        echo "$ICON_SPEAKER"
    fi
}

# ── Get sinks (outputs) ──
default_sink=$(pactl get-default-sink)
sink_data=()
sink_menu=""

while IFS=$'\t' read -r id name _ _ _; do
    desc=$(pactl list sinks | awk -v target="Sink #${id}" '
        $0 ~ target { found=1 }
        found && /Description:/ { sub(/.*Description: /, ""); print; exit }
    ')
    [ -z "$desc" ] && desc="$name"
    
    icon=$(get_icon "$desc" "sink")
    marker=""
    [[ "$name" == "$default_sink" ]] && marker="  ✓"
    
    sink_data+=("${id}|sink|${name}")
    sink_menu+="${icon}  ${desc}${marker}\n"
done < <(pactl list sinks short)

# ── Get sources (inputs, excluding monitors) ──
default_source=$(pactl get-default-source)
source_data=()
source_menu=""

while IFS=$'\t' read -r id name _ _ _; do
    [[ "$name" == *".monitor" ]] && continue
    
    desc=$(pactl list sources | awk -v target="Source #${id}" '
        $0 ~ target { found=1 }
        found && /Description:/ { sub(/.*Description: /, ""); print; exit }
    ')
    [ -z "$desc" ] && desc="$name"
    
    icon=$(get_icon "$desc" "source")
    marker=""
    [[ "$name" == "$default_source" ]] && marker="  ✓"
    
    source_data+=("${id}|source|${name}")
    source_menu+="${icon}  ${desc}${marker}\n"
done < <(pactl list sources short)

# ── Build combined menu ──
menu="${ICON_OUTPUT}  ── Salida de audio ──\n"
menu+="${sink_menu}"
menu+="${ICON_INPUT}  ── Entrada de audio ──\n"
menu+="${source_menu}"

# ── Show wofi ──
chosen=$(echo -e "$menu" | sed '/^$/d' | wofi --dmenu \
    --prompt "Dispositivo de audio" \
    --width 520 \
    --height 380 \
    --cache-file /dev/null \
    --insensitive)

# Exit if nothing chosen or header selected
[ -z "$chosen" ] && exit 0
[[ "$chosen" == *"── "* ]] && exit 0

# ── Determine which device was selected ──
# Clean the chosen text: remove icon prefix (first 4 chars approx) and ✓ marker
chosen_clean=$(echo "$chosen" | sed 's/  ✓$//')

# Count which line was selected
line_num=0
selected_index=-1
while IFS= read -r line; do
    line_num=$((line_num + 1))
    if [[ "$line" == "$chosen" ]]; then
        selected_index=$line_num
        break
    fi
done < <(echo -e "$menu" | sed '/^$/d')

if [ $selected_index -le 0 ]; then
    exit 0
fi

# Figure out if it's a sink or source based on position
# Line 1 = header "Salida de audio"
# Lines 2 to (1 + num_sinks) = sinks
# Line (2 + num_sinks) = header "Entrada de audio"
# Lines (3 + num_sinks) to end = sources

num_sinks=${#sink_data[@]}
num_sources=${#source_data[@]}

if [ $selected_index -ge 2 ] && [ $selected_index -le $((1 + num_sinks)) ]; then
    # It's a sink
    arr_idx=$((selected_index - 2))
    entry="${sink_data[$arr_idx]}"
    dev_name=$(echo "$entry" | cut -d'|' -f3)
    pactl set-default-sink "$dev_name"
    
    desc=$(echo "$chosen_clean" | sed 's/^[^ ]* *//')
    notify-send -t 2000 -i audio-speakers "🔊 Salida de audio" "$desc"
    
elif [ $selected_index -ge $((3 + num_sinks)) ]; then
    # It's a source
    arr_idx=$((selected_index - 3 - num_sinks))
    if [ $arr_idx -ge 0 ] && [ $arr_idx -lt $num_sources ]; then
        entry="${source_data[$arr_idx]}"
        dev_name=$(echo "$entry" | cut -d'|' -f3)
        pactl set-default-source "$dev_name"
        
        desc=$(echo "$chosen_clean" | sed 's/^[^ ]* *//')
        notify-send -t 2000 -i audio-input-microphone "🎤 Entrada de audio" "$desc"
    fi
fi
