set terminal png size 1200,300 enhanced
# font "Helvetica,20"
set output 'file-sizes.png'

yellow = "#ffd320"; red = "#ff420e"; blue = "#004586";
# set yrange [0:25000000]
# set ytics 1000
# set style data histogram
# set style histogram cluster gap 1
# set style fill solid
# set boxwidth 0.9
# set xtics format ""
set grid ytics
set log y 8

set title "File sizes"
plot "file-sizes.dat" using 1 title "Size" with lines linecolor rgb red
