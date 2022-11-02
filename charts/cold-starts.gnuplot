set terminal png size 600,600 enhanced
# font "Helvetica,20"
set output 'cold-starts.png'

yellow = "#ffd320"; red = "#ff420e"; blue = "#004586";
set yrange [0:4500]
set ytics 1000
set style data histogram
set style histogram cluster gap 1
set style fill solid
set boxwidth 0.9
set xtics format ""
set grid ytics

set title "Cold starts (ms)"
plot "cold-starts.dat" using 2:xtic(1) title "Min" linecolor rgb blue, \
     "cold-starts.dat" using 3 title "Avg" linecolor rgb yellow, \
     "cold-starts.dat" using 4 title "Max" linecolor rgb red
