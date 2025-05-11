#!/bin/bash

# --- Configuración ---
BAR_WIDTH=10      # Ancho total de la barra en caracteres
FILLED_CHAR="█"   # Carácter para la parte llena
EMPTY_CHAR="░"    # Carácter para la parte vacía
MUTED_ICON="󰝟"    # Icono o texto para mostrar cuando está silenciado

# --- Obtener Volumen (Elige la sección para tu sistema: PipeWire, PulseAudio o ALSA) ---

# --- Opción 1: PipeWire (usando wpctl) ---
AUDIO_INFO=$(wpctl get-volume @DEFAULT_SINK@ 2>/dev/null)
IS_MUTED=$(echo "$AUDIO_INFO" | grep -q "MUTED" && echo "yes" || echo "no")
# Extrae el volumen (ej: 0.75), multiplica por 100 y redondea
VOLUME=$(echo "$AUDIO_INFO" | grep -oP '[0-9]+\.[0-9]+' | awk '{print int($1 * 100 + 0.5)}')

# --- Opción 2: PulseAudio (usando pactl) ---
# SINK_INFO=$(pactl list sinks | grep -A 15 'State: RUNNING') # Encuentra el sink activo
# IS_MUTED=$(echo "$SINK_INFO" | grep -q 'Mute: yes' && echo "yes" || echo "no")
# VOLUME=$(echo "$SINK_INFO" | grep 'Volume:' | head -n1 | awk -F '/' '{print $2}' | sed 's/[ %]//g')

# --- Opción 3: ALSA (usando amixer) ---
# INFO=$(amixer sget Master)
# IS_MUTED=$(echo "$INFO" | grep -q '\[off\]' && echo "yes" || echo "no")
# VOLUME=$(echo "$INFO" | grep -oP '\[\K[0-9]+(?=%\])' | head -n1) # Extrae el porcentaje

# --- Comprobación de Silencio ---
if [[ "$IS_MUTED" == "yes" ]]; then
  echo "$MUTED_ICON" # Muestra icono de silencio y termina
  exit 0
fi

# --- Asegurar que el volumen está entre 0 y 100 ---
if ! [[ "$VOLUME" =~ ^[0-9]+$ ]]; then VOLUME=0; fi # Si no es número, poner 0
if (( VOLUME < 0 )); then VOLUME=0; fi
if (( VOLUME > 100 )); then VOLUME=100; fi # Limitar a 100

# --- Calcular Segmentos de la Barra ---
FILLED_COUNT=$(( (VOLUME * BAR_WIDTH) / 100 ))
EMPTY_COUNT=$(( BAR_WIDTH - FILLED_COUNT ))

# --- Construir la Barra ---
BAR=""
# Parte llena
for ((i=0; i<FILLED_COUNT; i++)); do
  BAR+="$FILLED_CHAR"
done
# Parte vacía
for ((i=0; i<EMPTY_COUNT; i++)); do
  BAR+="$EMPTY_CHAR"
done

# --- Imprimir la Barra ---
echo "$BAR"

exit 0
