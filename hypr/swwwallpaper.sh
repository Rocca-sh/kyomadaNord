#!/bin/bash

# Directorio de las imágenes
WALLPAPER_DIR="/home/h1t/KyomadaNord/wp1"
# Archivo para guardar el índice del último wallpaper usado
# Se guardará en el directorio HOME del usuario como un archivo oculto
STATE_FILE="$HOME/.current_wallpaper_idx"

# Verificar si el directorio existe
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "Error: El directorio $WALLPAPER_DIR no existe."
  exit 1
fi

# Obtener la lista de imágenes ordenadas alfabéticamente
# Usamos find ... -print0 | sort -z y mapfile para manejar nombres de archivo con caracteres especiales de forma segura.
# -maxdepth 1 evita buscar en subdirectorios.
mapfile -d $'\0' wallpapers < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) -print0 | sort -z)

# Contar el número total de imágenes encontradas
num_wallpapers=${#wallpapers[@]}

# Verificar si se encontraron imágenes
if [ "$num_wallpapers" -eq 0 ]; then
  echo "No se encontraron imágenes (.jpg o .png) en $WALLPAPER_DIR."
  exit 1
fi

# Leer el índice del último wallpaper usado.
# Si el archivo no existe o no contiene un número válido, empezar desde el principio (índice -1).
last_index=-1
if [ -f "$STATE_FILE" ]; then
  read last_index < "$STATE_FILE"
  # Simple validación para asegurarse de que es un número
  if ! [[ "$last_index" =~ ^[0-9]+$ ]]; then
      echo "Advertencia: El archivo de estado $STATE_FILE no contiene un índice válido. Reiniciando."
      last_index=-1
  # Validación extra: si el índice guardado es mayor o igual al número actual de fondos (quizás se borraron archivos), reiniciar.
  elif [ "$last_index" -ge "$num_wallpapers" ]; then
      echo "Advertencia: El índice guardado ($last_index) es inválido para el número actual de fondos ($num_wallpapers). Reiniciando."
      last_index=-1
  fi
fi

# Calcular el índice del siguiente wallpaper a usar.
# El operador % (módulo) asegura que volvamos al inicio (índice 0) después del último.
current_index=$(( (last_index + 1) % num_wallpapers ))

# Obtener la ruta completa del wallpaper seleccionado
SELECTED_WALLPAPER="${wallpapers[$current_index]}"

# Cambiar el fondo con swww
echo "Estableciendo wallpaper ($((current_index + 1))/$num_wallpapers): $SELECTED_WALLPAPER" # Mensaje informativo (opcional)
swww img "$SELECTED_WALLPAPER" --transition-type fade --transition-duration 1

# Guardar el índice actual para la próxima ejecución del script
echo "$current_index" > "$STATE_FILE"

exit 0
