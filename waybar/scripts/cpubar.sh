#!/bin/bash

# --- Configuración ---
BAR_WIDTH=10      # Ancho total de la barra en caracteres
FILLED_CHAR="█"   # Carácter para la parte llena
EMPTY_CHAR="░"    # Carácter para la parte vacía

# --- Obtener Uso de CPU ---

# Método 1: Usando mpstat (Recomendado, necesita 'sysstat')
# Asegúrate de tener 'sysstat' instalado: sudo dnf install sysstat
if command -v mpstat &> /dev/null; then
    # mpstat 1 1: Reporta estadísticas durante 1 segundo, 1 vez.
    # awk '/Average:/': Busca la línea que contiene el promedio.
    # '{print $12}': Extrae el campo 12, que es el porcentaje de tiempo inactivo (%idle).
    CPU_IDLE=$(mpstat 1 1 | awk '/Average:/ {print $12}')

    # Verifica si se obtuvo un número válido
    if [[ "$CPU_IDLE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        # Calcula el uso: 100 - %inactivo. Usa awk para manejar decimales y redondear.
        PERCENTAGE=$(awk -v idle="$CPU_IDLE" 'BEGIN { printf "%.0f", 100 - idle }')
    else
        PERCENTAGE=-1 # Indica error
    fi
else
    # Método 2: Usando top (Alternativa si no quieres sysstat)
    # top -bn1: Corre top en modo batch, 1 iteración.
    # grep '%Cpu(s)': Filtra la línea de CPU.
    # awk '{print $2 + $4}': Suma el uso de usuario ($2) y sistema ($4). Puede variar según tu 'top'.
    PERCENTAGE=$(top -bn1 | grep '%Cpu(s)' | awk '{printf "%.0f", $2 + $4}')

    # Verifica si se obtuvo un número válido
    if ! [[ "$PERCENTAGE" =~ ^[0-9]+$ ]]; then
       PERCENTAGE=-1 # Indica error
    fi
fi

# Si hubo error al obtener el porcentaje
if (( PERCENTAGE == -1 )); then
    echo "ERR"
    exit 1
fi


# --- Asegurar que está entre 0 y 100 ---
if (( PERCENTAGE < 0 )); then PERCENTAGE=0; fi
if (( PERCENTAGE > 100 )); then PERCENTAGE=100; fi

# --- Calcular Segmentos ---
FILLED_COUNT=$(( (PERCENTAGE * BAR_WIDTH) / 100 ))
EMPTY_COUNT=$(( BAR_WIDTH - FILLED_COUNT ))

# --- Construir Barra ---
BAR=""
for ((i=0; i<FILLED_COUNT; i++)); do
  BAR+="$FILLED_CHAR"
done
for ((i=0; i<EMPTY_COUNT; i++)); do
  BAR+="$EMPTY_CHAR"
done

# --- Imprimir Barra ---
echo "$BAR"

exit 0