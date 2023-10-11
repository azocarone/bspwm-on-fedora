# Obtén el tamaño del monitor primario (e.g., HDMI-1)
monitor_size=$(xrandr | grep "primary" | awk '{print $4}')
# Divide el tamaño en ancho y alto
width=$(echo $monitor_size | cut -d'x' -f1)
height=$(echo $monitor_size | cut -d'x' -f2)
# Calcula las coordenadas para centrar la ventana en el monitor
x_pos=$((($width - 1050) / 2))  # Ajusta el ancho deseado (800)
y_pos=$((($height - 600) / 2))  # Ajusta el alto deseado (600)

# Abre la ventana Kitty en modo flotante con las coordenadas calculadas
bspc node -t floating -g hidden=off
xdotool search --classname Kitty windowsize %@ 1050 600
xdotool search --classname Kitty windowmove %@ $x_pos $y_pos
