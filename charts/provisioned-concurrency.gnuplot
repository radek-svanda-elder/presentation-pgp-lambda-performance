set terminal png size 600,600 enhanced
set output 'provisioned-concurrency.png'

yellow = "#ffd320"; red = "#ff420e"; blue = "#004586"; green = "#579d1c"
set yrange [0:3000]
# set ytics 1000
set style data histogram
set style histogram cluster gap 1
set style fill solid
set boxwidth 0.9
set xtics format ""
set grid ytics

set title "Function response time (ms)"
plot \
     "provisioned-concurrency.dat" using 2:xtic(1) title "P50" linecolor rgb green,   \
     "provisioned-concurrency.dat" using 3 title "P95" linecolor rgb blue,    \
     "provisioned-concurrency.dat" using 4 title "P99" linecolor rgb yellow,    \
     "provisioned-concurrency.dat" using 5 title "Max" linecolor rgb red
