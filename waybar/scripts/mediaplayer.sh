#!/bin/bash
# ──────────────────────────────────────────────
# Media Player module for Waybar
# Uses playerctl to get current playing media
# ──────────────────────────────────────────────

# Max length for the scrolling text
MAX_LEN=40

player_status=$(playerctl status 2>/dev/null)

if [ "$player_status" == "Playing" ]; then
    artist=$(playerctl metadata artist 2>/dev/null)
    title=$(playerctl metadata title 2>/dev/null)
    
    if [ -n "$artist" ] && [ -n "$title" ]; then
        text="${artist} — ${title}"
    elif [ -n "$title" ]; then
        text="${title}"
    else
        text="Reproduciendo..."
    fi
    
    # Truncate if too long
    if [ ${#text} -gt $MAX_LEN ]; then
        text="${text:0:$MAX_LEN}…"
    fi
    
    # JSON output for waybar custom module
    echo "{\"text\": \"󰎆  ${text}\", \"tooltip\": \"${artist} — ${title}\", \"class\": \"playing\", \"alt\": \"playing\"}"

elif [ "$player_status" == "Paused" ]; then
    artist=$(playerctl metadata artist 2>/dev/null)
    title=$(playerctl metadata title 2>/dev/null)
    
    if [ -n "$artist" ] && [ -n "$title" ]; then
        text="${artist} — ${title}"
    elif [ -n "$title" ]; then
        text="${title}"
    else
        text="Pausado"
    fi
    
    if [ ${#text} -gt $MAX_LEN ]; then
        text="${text:0:$MAX_LEN}…"
    fi
    
    echo "{\"text\": \"󰏥  ${text}\", \"tooltip\": \"${artist} — ${title} (pausado)\", \"class\": \"paused\", \"alt\": \"paused\"}"

else
    # No player running — show nothing
    echo "{\"text\": \"\", \"tooltip\": \"Sin reproducción\", \"class\": \"stopped\", \"alt\": \"stopped\"}"
fi
