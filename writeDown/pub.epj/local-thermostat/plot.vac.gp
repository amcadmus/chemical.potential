set term post eps enh color solid font 14 size 8.5cm,6cm

set out 'fig-vac.eps'

set style line 10 lt 1 lw 3 pt 1 linecolor 1
set style line 20 lt 1 lw 3 pt 4 linecolor 2
set style line 30 lt 1 lw 3 pt 2 linecolor 3
set style line 40 lt 1 lw 3 pt 4 linecolor 5

set yrange [-0.1:.5]
set xlabel 't [ ps ]'
set ylabel 'C_v(t)'
set grid
set mytics 2

set key font "Courier,14"
set key spacing 1.5

pl \
'nve.5000.atom.tip3p/vac.txt' w l ls 10 t'Atomistic Hamiltonian',\
'nvt.5000.atom.tip3p/vac.txt' w l ls 40 t'Atomistic    Langevin',\
'nve.5000.adress.tip3p.potential/vac.txt' w p ls 20	t'AdResS potential interpol.',\
'nve.5000.adress.tip3p.force/vac.txt' w p ls 30		t'AdResS     force interpol.',\
'nve.5000.atom.tip3p/vac.txt' w l ls 10 not,\
'nvt.5000.atom.tip3p/vac.txt' w l ls 40 not'Atomistic NVT'
