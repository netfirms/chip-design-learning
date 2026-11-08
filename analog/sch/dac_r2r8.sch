v {xschem version=3.4.4 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
T {8-bit R-2R ladder DAC + reconstruction filter} 80 -330 0 0 0.7 0.7 {}
T {vdac = VREF * code / 256   (bit inputs swing 0 .. VREF = 1.8 V)} 80 -270 0 0 0.4 0.4 {}
T {R = 10k, 2R = 20k.  Output impedance of the ladder is always R.} 80 -235 0 0 0.4 0.4 {}
C {devices/res.sym} 120 0 1 0 {name=Rterm value=20k m=1}
N 150 0 200 0 {}
N 90 0 90 30 {}
C {devices/gnd.sym} 90 30 0 0 {name=g1 lab=GND}
C {devices/lab_pin.sym} 200 0 0 0 {name=l1 lab=n0}
N 200 0 200 70 {}
C {devices/res.sym} 200 100 0 0 {name=R2_0 value=20k m=1}
N 200 130 200 160 {}
C {devices/ipin.sym} 200 160 3 0 {name=p1 lab=b0}
C {devices/res.sym} 280 0 1 0 {name=R1_0 value=10k m=1}
N 200 0 250 0 {}
N 310 0 360 0 {}
C {devices/lab_pin.sym} 360 0 0 0 {name=l2 lab=n1}
N 360 0 360 70 {}
C {devices/res.sym} 360 100 0 0 {name=R2_1 value=20k m=1}
N 360 130 360 160 {}
C {devices/ipin.sym} 360 160 3 0 {name=p2 lab=b1}
C {devices/res.sym} 440 0 1 0 {name=R1_1 value=10k m=1}
N 360 0 410 0 {}
N 470 0 520 0 {}
C {devices/lab_pin.sym} 520 0 0 0 {name=l3 lab=n2}
N 520 0 520 70 {}
C {devices/res.sym} 520 100 0 0 {name=R2_2 value=20k m=1}
N 520 130 520 160 {}
C {devices/ipin.sym} 520 160 3 0 {name=p3 lab=b2}
C {devices/res.sym} 600 0 1 0 {name=R1_2 value=10k m=1}
N 520 0 570 0 {}
N 630 0 680 0 {}
C {devices/lab_pin.sym} 680 0 0 0 {name=l4 lab=n3}
N 680 0 680 70 {}
C {devices/res.sym} 680 100 0 0 {name=R2_3 value=20k m=1}
N 680 130 680 160 {}
C {devices/ipin.sym} 680 160 3 0 {name=p4 lab=b3}
C {devices/res.sym} 760 0 1 0 {name=R1_3 value=10k m=1}
N 680 0 730 0 {}
N 790 0 840 0 {}
C {devices/lab_pin.sym} 840 0 0 0 {name=l5 lab=n4}
N 840 0 840 70 {}
C {devices/res.sym} 840 100 0 0 {name=R2_4 value=20k m=1}
N 840 130 840 160 {}
C {devices/ipin.sym} 840 160 3 0 {name=p5 lab=b4}
C {devices/res.sym} 920 0 1 0 {name=R1_4 value=10k m=1}
N 840 0 890 0 {}
N 950 0 1000 0 {}
C {devices/lab_pin.sym} 1000 0 0 0 {name=l6 lab=n5}
N 1000 0 1000 70 {}
C {devices/res.sym} 1000 100 0 0 {name=R2_5 value=20k m=1}
N 1000 130 1000 160 {}
C {devices/ipin.sym} 1000 160 3 0 {name=p6 lab=b5}
C {devices/res.sym} 1080 0 1 0 {name=R1_5 value=10k m=1}
N 1000 0 1050 0 {}
N 1110 0 1160 0 {}
C {devices/lab_pin.sym} 1160 0 0 0 {name=l7 lab=n6}
N 1160 0 1160 70 {}
C {devices/res.sym} 1160 100 0 0 {name=R2_6 value=20k m=1}
N 1160 130 1160 160 {}
C {devices/ipin.sym} 1160 160 3 0 {name=p7 lab=b6}
C {devices/res.sym} 1240 0 1 0 {name=R1_6 value=10k m=1}
N 1160 0 1210 0 {}
N 1270 0 1320 0 {}
C {devices/lab_pin.sym} 1320 0 0 0 {name=l8 lab=n7}
N 1320 0 1320 70 {}
C {devices/res.sym} 1320 100 0 0 {name=R2_7 value=20k m=1}
N 1320 130 1320 160 {}
C {devices/ipin.sym} 1320 160 3 0 {name=p8 lab=b7}
T {LSB} 160 200 0 0 0.4 0.4 {}
T {MSB} 1280 200 0 0 0.4 0.4 {}
N 1320 0 1420 0 {}
C {devices/vcvs.sym} 1460 20 0 0 {name=Ebuf value=1}
C {devices/gnd.sym} 1460 50 0 0 {name=g2 lab=GND}
N 1420 40 1420 60 {}
C {devices/gnd.sym} 1420 60 0 0 {name=g3 lab=GND}
N 1460 -10 1460 -60 {}
N 1460 -60 1500 -60 {}
N 1500 -60 1500 -100 {}
C {devices/opin.sym} 1500 -100 3 0 {name=p9 lab=vdac}
N 1500 -60 1570 -60 {}
C {devices/res.sym} 1600 -60 1 0 {name=Rf1 value=10k m=1}
N 1630 -60 1670 -60 {}
C {devices/capa.sym} 1670 -30 0 0 {name=Cf1 value=2.2n m=1}
C {devices/gnd.sym} 1670 0 0 0 {name=g4 lab=GND}
C {devices/lab_pin.sym} 1670 -60 0 0 {name=l9 lab=f1}
N 1670 -60 1730 -60 {}
C {devices/vcvs.sym} 1770 -40 0 0 {name=Ef value=1}
C {devices/gnd.sym} 1770 -10 0 0 {name=g5 lab=GND}
N 1730 -20 1730 0 {}
C {devices/gnd.sym} 1730 0 0 0 {name=g6 lab=GND}
N 1770 -70 1770 -100 {}
N 1770 -100 1810 -100 {}
C {devices/res.sym} 1840 -100 1 0 {name=Rf2 value=10k m=1}
N 1870 -100 1910 -100 {}
C {devices/capa.sym} 1910 -70 0 0 {name=Cf2 value=2.2n m=1}
C {devices/gnd.sym} 1910 -40 0 0 {name=g7 lab=GND}
N 1910 -100 1970 -100 {}
C {devices/opin.sym} 1970 -100 0 0 {name=p10 lab=vout}
T {reconstruction filter} 1570 -200 0 0 0.4 0.4 {}
T {2 x RC, fc = 7.2 kHz each} 1570 -170 0 0 0.3 0.3 {}
