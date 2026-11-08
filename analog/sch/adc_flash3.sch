v {xschem version=3.4.4 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
T {3-bit flash ADC (7 comparators)} -40 -150 0 0 0.7 0.7 {}
T {code = number of comparators that see vin above their tap} -40 -90 0 0 0.4 0.4 {}
T {thresholds at (k - 1/2) LSB, LSB = VREF / 8} -40 -55 0 0 0.4 0.4 {}
C {devices/ipin.sym} 0 0 0 0 {name=p1 lab=vin}
N 0 0 140 0 {}
N 140 0 140 10 {}
C {devices/switch_ngspice.sym} 140 40 0 0 {name=Ssh model=SH_SW}
C {devices/ipin.sym} 40 40 0 0 {name=p2 lab=clk}
N 40 40 100 40 {}
N 100 60 100 80 {}
C {devices/gnd.sym} 100 80 0 0 {name=g1 lab=GND}
N 140 70 140 100 {}
C {devices/lab_pin.sym} 140 100 0 0 {name=l1 lab=vh}
N 140 100 220 100 {}
C {devices/capa.sym} 140 130 0 0 {name=Chold value=1p m=1}
C {devices/gnd.sym} 140 160 0 0 {name=g2 lab=GND}
C {devices/vcvs.sym} 260 120 0 0 {name=Esh value=1}
C {devices/gnd.sym} 260 150 0 0 {name=g3 lab=GND}
N 220 140 220 160 {}
C {devices/gnd.sym} 220 160 0 0 {name=g4 lab=GND}
N 260 90 260 60 {}
N 260 60 300 60 {}
C {devices/lab_pin.sym} 300 60 0 1 {name=l2 lab=vs}
T {sample & hold} 0 190 0 0 0.4 0.4 {}
C {devices/code_shown.sym} 0 260 0 0 {name=models only_toplevel=false value=".model SH_SW SW(vt=0.9 vh=0.1 ron=10 roff=1e12)"}
C {devices/ipin.sym} 420 200 0 0 {name=p3 lab=vref}
N 420 200 500 200 {}
C {devices/res.sym} 500 240 0 0 {name=Rtop value=1500 m=1}
N 500 200 500 210 {}
N 500 270 500 280 {}
C {devices/res.sym} 500 320 0 0 {name=R6 value=1000 m=1}
N 500 280 500 290 {}
N 500 350 500 360 {}
C {devices/res.sym} 500 400 0 0 {name=R5 value=1000 m=1}
N 500 360 500 370 {}
N 500 430 500 440 {}
C {devices/res.sym} 500 480 0 0 {name=R4 value=1000 m=1}
N 500 440 500 450 {}
N 500 510 500 520 {}
C {devices/res.sym} 500 560 0 0 {name=R3 value=1000 m=1}
N 500 520 500 530 {}
N 500 590 500 600 {}
C {devices/res.sym} 500 640 0 0 {name=R2 value=1000 m=1}
N 500 600 500 610 {}
N 500 670 500 680 {}
C {devices/res.sym} 500 720 0 0 {name=R1 value=1000 m=1}
N 500 680 500 690 {}
N 500 750 500 760 {}
C {devices/res.sym} 500 800 0 0 {name=Rbot value=500 m=1}
N 500 760 500 770 {}
N 500 830 500 840 {}
C {devices/gnd.sym} 500 840 0 0 {name=g5 lab=GND}
C {devices/lab_pin.sym} 500 760 0 1 {name=l3 lab=r1}
N 500 760 560 760 {}
C {devices/lab_pin.sym} 560 740 0 0 {name=l4 lab=vs}
C {comparator.sym} 600 750 0 0 {name=Bc1 vhigh=1.8 gain=1e5}
N 640 750 700 750 {}
C {devices/lab_pin.sym} 700 750 0 1 {name=l5 lab=t1}
C {devices/lab_pin.sym} 500 680 0 1 {name=l6 lab=r2}
N 500 680 560 680 {}
C {devices/lab_pin.sym} 560 660 0 0 {name=l7 lab=vs}
C {comparator.sym} 600 670 0 0 {name=Bc2 vhigh=1.8 gain=1e5}
N 640 670 700 670 {}
C {devices/lab_pin.sym} 700 670 0 1 {name=l8 lab=t2}
C {devices/lab_pin.sym} 500 600 0 1 {name=l9 lab=r3}
N 500 600 560 600 {}
C {devices/lab_pin.sym} 560 580 0 0 {name=l10 lab=vs}
C {comparator.sym} 600 590 0 0 {name=Bc3 vhigh=1.8 gain=1e5}
N 640 590 700 590 {}
C {devices/lab_pin.sym} 700 590 0 1 {name=l11 lab=t3}
C {devices/lab_pin.sym} 500 520 0 1 {name=l12 lab=r4}
N 500 520 560 520 {}
C {devices/lab_pin.sym} 560 500 0 0 {name=l13 lab=vs}
C {comparator.sym} 600 510 0 0 {name=Bc4 vhigh=1.8 gain=1e5}
N 640 510 700 510 {}
C {devices/lab_pin.sym} 700 510 0 1 {name=l14 lab=t4}
C {devices/lab_pin.sym} 500 440 0 1 {name=l15 lab=r5}
N 500 440 560 440 {}
C {devices/lab_pin.sym} 560 420 0 0 {name=l16 lab=vs}
C {comparator.sym} 600 430 0 0 {name=Bc5 vhigh=1.8 gain=1e5}
N 640 430 700 430 {}
C {devices/lab_pin.sym} 700 430 0 1 {name=l17 lab=t5}
C {devices/lab_pin.sym} 500 360 0 1 {name=l18 lab=r6}
N 500 360 560 360 {}
C {devices/lab_pin.sym} 560 340 0 0 {name=l19 lab=vs}
C {comparator.sym} 600 350 0 0 {name=Bc6 vhigh=1.8 gain=1e5}
N 640 350 700 350 {}
C {devices/lab_pin.sym} 700 350 0 1 {name=l20 lab=t6}
C {devices/lab_pin.sym} 500 280 0 1 {name=l21 lab=r7}
N 500 280 560 280 {}
C {devices/lab_pin.sym} 560 260 0 0 {name=l22 lab=vs}
C {comparator.sym} 600 270 0 0 {name=Bc7 vhigh=1.8 gain=1e5}
N 640 270 700 270 {}
C {devices/lab_pin.sym} 700 270 0 1 {name=l23 lab=t7}
C {devices/bsource.sym} 900 270 0 0 {name=Bcount VAR=V FUNC="u(V(t1)-0.9)+u(V(t2)-0.9)+u(V(t3)-0.9)+u(V(t4)-0.9)+u(V(t5)-0.9)+u(V(t6)-0.9)+u(V(t7)-0.9)"}
C {devices/gnd.sym} 900 300 0 0 {name=g6 lab=GND}
N 900 240 900 220 {}
N 900 220 980 220 {}
C {devices/opin.sym} 980 220 0 0 {name=p4 lab=code}
T {ones counter: code = sum of t1..t7
(1 V per LSB, an analog probe of the output code)} 940 130 0 0 0.3 0.3 {}
C {devices/bsource.sym} 940 500 0 0 {name=Bd0 VAR=V FUNC="1.8*(floor((V(code)+0.25)/1)-2*floor((V(code)+0.25)/2))"}
C {devices/gnd.sym} 940 530 0 0 {name=g7 lab=GND}
N 940 470 940 440 {}
C {devices/opin.sym} 940 440 3 0 {name=p5 lab=d0}
C {devices/bsource.sym} 1260 500 0 0 {name=Bd1 VAR=V FUNC="1.8*(floor((V(code)+0.25)/2)-2*floor((V(code)+0.25)/4))"}
C {devices/gnd.sym} 1260 530 0 0 {name=g8 lab=GND}
N 1260 470 1260 440 {}
C {devices/opin.sym} 1260 440 3 0 {name=p6 lab=d1}
C {devices/bsource.sym} 1580 500 0 0 {name=Bd2 VAR=V FUNC="1.8*(floor((V(code)+0.25)/4)-2*floor((V(code)+0.25)/8))"}
C {devices/gnd.sym} 1580 530 0 0 {name=g9 lab=GND}
N 1580 470 1580 440 {}
C {devices/opin.sym} 1580 440 3 0 {name=p7 lab=d2}
