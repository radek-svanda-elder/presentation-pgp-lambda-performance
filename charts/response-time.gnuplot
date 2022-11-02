set terminal png size 600,600 enhanced
# font "Helvetica,20"
set output 'response-time.png'

yellow = "#ffd320"; red = "#ff420e"; blue = "#004586";
set yrange [0:9000]
# set ytics 1000
set style data histogram
set style histogram cluster gap 1
set style fill solid
set boxwidth 0.9
set xtics format ""
set grid ytics

set title "Function response time (ms)"
plot \
     "response-time.dat" using 2:xtic(1) title "P95" linecolor rgb blue,   \
     "response-time.dat" using 3 title "P99" linecolor rgb yellow,    \
     "response-time.dat" using 4 title "Max" linecolor rgb red
