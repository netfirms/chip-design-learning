v {xschem version=3.4.4 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
T {8-bit flash ADC (255 comparators)} -40 -150 0 0 0.7 0.7 {}
T {code = number of comparators that see vin above their tap} -40 -90 0 0 0.4 0.4 {}
T {thresholds at (k - 1/2) LSB, LSB = VREF / 256} -40 -55 0 0 0.4 0.4 {}
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
C {devices/res.sym} 500 320 0 0 {name=R254 value=1000 m=1}
N 500 280 500 290 {}
N 500 350 500 360 {}
C {devices/res.sym} 500 400 0 0 {name=R253 value=1000 m=1}
N 500 360 500 370 {}
N 500 430 500 440 {}
C {devices/res.sym} 500 480 0 0 {name=R252 value=1000 m=1}
N 500 440 500 450 {}
N 500 510 500 520 {}
C {devices/res.sym} 500 560 0 0 {name=R251 value=1000 m=1}
N 500 520 500 530 {}
N 500 590 500 600 {}
C {devices/res.sym} 500 640 0 0 {name=R250 value=1000 m=1}
N 500 600 500 610 {}
N 500 670 500 680 {}
C {devices/res.sym} 500 720 0 0 {name=R249 value=1000 m=1}
N 500 680 500 690 {}
N 500 750 500 760 {}
C {devices/res.sym} 500 800 0 0 {name=R248 value=1000 m=1}
N 500 760 500 770 {}
N 500 830 500 840 {}
C {devices/res.sym} 500 880 0 0 {name=R247 value=1000 m=1}
N 500 840 500 850 {}
N 500 910 500 920 {}
C {devices/res.sym} 500 960 0 0 {name=R246 value=1000 m=1}
N 500 920 500 930 {}
N 500 990 500 1000 {}
C {devices/res.sym} 500 1040 0 0 {name=R245 value=1000 m=1}
N 500 1000 500 1010 {}
N 500 1070 500 1080 {}
C {devices/res.sym} 500 1120 0 0 {name=R244 value=1000 m=1}
N 500 1080 500 1090 {}
N 500 1150 500 1160 {}
C {devices/res.sym} 500 1200 0 0 {name=R243 value=1000 m=1}
N 500 1160 500 1170 {}
N 500 1230 500 1240 {}
C {devices/res.sym} 500 1280 0 0 {name=R242 value=1000 m=1}
N 500 1240 500 1250 {}
N 500 1310 500 1320 {}
C {devices/res.sym} 500 1360 0 0 {name=R241 value=1000 m=1}
N 500 1320 500 1330 {}
N 500 1390 500 1400 {}
C {devices/res.sym} 500 1440 0 0 {name=R240 value=1000 m=1}
N 500 1400 500 1410 {}
N 500 1470 500 1480 {}
C {devices/res.sym} 500 1520 0 0 {name=R239 value=1000 m=1}
N 500 1480 500 1490 {}
N 500 1550 500 1560 {}
C {devices/res.sym} 500 1600 0 0 {name=R238 value=1000 m=1}
N 500 1560 500 1570 {}
N 500 1630 500 1640 {}
C {devices/res.sym} 500 1680 0 0 {name=R237 value=1000 m=1}
N 500 1640 500 1650 {}
N 500 1710 500 1720 {}
C {devices/res.sym} 500 1760 0 0 {name=R236 value=1000 m=1}
N 500 1720 500 1730 {}
N 500 1790 500 1800 {}
C {devices/res.sym} 500 1840 0 0 {name=R235 value=1000 m=1}
N 500 1800 500 1810 {}
N 500 1870 500 1880 {}
C {devices/res.sym} 500 1920 0 0 {name=R234 value=1000 m=1}
N 500 1880 500 1890 {}
N 500 1950 500 1960 {}
C {devices/res.sym} 500 2000 0 0 {name=R233 value=1000 m=1}
N 500 1960 500 1970 {}
N 500 2030 500 2040 {}
C {devices/res.sym} 500 2080 0 0 {name=R232 value=1000 m=1}
N 500 2040 500 2050 {}
N 500 2110 500 2120 {}
C {devices/res.sym} 500 2160 0 0 {name=R231 value=1000 m=1}
N 500 2120 500 2130 {}
N 500 2190 500 2200 {}
C {devices/res.sym} 500 2240 0 0 {name=R230 value=1000 m=1}
N 500 2200 500 2210 {}
N 500 2270 500 2280 {}
C {devices/res.sym} 500 2320 0 0 {name=R229 value=1000 m=1}
N 500 2280 500 2290 {}
N 500 2350 500 2360 {}
C {devices/res.sym} 500 2400 0 0 {name=R228 value=1000 m=1}
N 500 2360 500 2370 {}
N 500 2430 500 2440 {}
C {devices/res.sym} 500 2480 0 0 {name=R227 value=1000 m=1}
N 500 2440 500 2450 {}
N 500 2510 500 2520 {}
C {devices/res.sym} 500 2560 0 0 {name=R226 value=1000 m=1}
N 500 2520 500 2530 {}
N 500 2590 500 2600 {}
C {devices/res.sym} 500 2640 0 0 {name=R225 value=1000 m=1}
N 500 2600 500 2610 {}
N 500 2670 500 2680 {}
C {devices/res.sym} 500 2720 0 0 {name=R224 value=1000 m=1}
N 500 2680 500 2690 {}
N 500 2750 500 2760 {}
C {devices/res.sym} 500 2800 0 0 {name=R223 value=1000 m=1}
N 500 2760 500 2770 {}
N 500 2830 500 2840 {}
C {devices/res.sym} 500 2880 0 0 {name=R222 value=1000 m=1}
N 500 2840 500 2850 {}
N 500 2910 500 2920 {}
C {devices/res.sym} 500 2960 0 0 {name=R221 value=1000 m=1}
N 500 2920 500 2930 {}
N 500 2990 500 3000 {}
C {devices/res.sym} 500 3040 0 0 {name=R220 value=1000 m=1}
N 500 3000 500 3010 {}
N 500 3070 500 3080 {}
C {devices/res.sym} 500 3120 0 0 {name=R219 value=1000 m=1}
N 500 3080 500 3090 {}
N 500 3150 500 3160 {}
C {devices/res.sym} 500 3200 0 0 {name=R218 value=1000 m=1}
N 500 3160 500 3170 {}
N 500 3230 500 3240 {}
C {devices/res.sym} 500 3280 0 0 {name=R217 value=1000 m=1}
N 500 3240 500 3250 {}
N 500 3310 500 3320 {}
C {devices/res.sym} 500 3360 0 0 {name=R216 value=1000 m=1}
N 500 3320 500 3330 {}
N 500 3390 500 3400 {}
C {devices/res.sym} 500 3440 0 0 {name=R215 value=1000 m=1}
N 500 3400 500 3410 {}
N 500 3470 500 3480 {}
C {devices/res.sym} 500 3520 0 0 {name=R214 value=1000 m=1}
N 500 3480 500 3490 {}
N 500 3550 500 3560 {}
C {devices/res.sym} 500 3600 0 0 {name=R213 value=1000 m=1}
N 500 3560 500 3570 {}
N 500 3630 500 3640 {}
C {devices/res.sym} 500 3680 0 0 {name=R212 value=1000 m=1}
N 500 3640 500 3650 {}
N 500 3710 500 3720 {}
C {devices/res.sym} 500 3760 0 0 {name=R211 value=1000 m=1}
N 500 3720 500 3730 {}
N 500 3790 500 3800 {}
C {devices/res.sym} 500 3840 0 0 {name=R210 value=1000 m=1}
N 500 3800 500 3810 {}
N 500 3870 500 3880 {}
C {devices/res.sym} 500 3920 0 0 {name=R209 value=1000 m=1}
N 500 3880 500 3890 {}
N 500 3950 500 3960 {}
C {devices/res.sym} 500 4000 0 0 {name=R208 value=1000 m=1}
N 500 3960 500 3970 {}
N 500 4030 500 4040 {}
C {devices/res.sym} 500 4080 0 0 {name=R207 value=1000 m=1}
N 500 4040 500 4050 {}
N 500 4110 500 4120 {}
C {devices/res.sym} 500 4160 0 0 {name=R206 value=1000 m=1}
N 500 4120 500 4130 {}
N 500 4190 500 4200 {}
C {devices/res.sym} 500 4240 0 0 {name=R205 value=1000 m=1}
N 500 4200 500 4210 {}
N 500 4270 500 4280 {}
C {devices/res.sym} 500 4320 0 0 {name=R204 value=1000 m=1}
N 500 4280 500 4290 {}
N 500 4350 500 4360 {}
C {devices/res.sym} 500 4400 0 0 {name=R203 value=1000 m=1}
N 500 4360 500 4370 {}
N 500 4430 500 4440 {}
C {devices/res.sym} 500 4480 0 0 {name=R202 value=1000 m=1}
N 500 4440 500 4450 {}
N 500 4510 500 4520 {}
C {devices/res.sym} 500 4560 0 0 {name=R201 value=1000 m=1}
N 500 4520 500 4530 {}
N 500 4590 500 4600 {}
C {devices/res.sym} 500 4640 0 0 {name=R200 value=1000 m=1}
N 500 4600 500 4610 {}
N 500 4670 500 4680 {}
C {devices/res.sym} 500 4720 0 0 {name=R199 value=1000 m=1}
N 500 4680 500 4690 {}
N 500 4750 500 4760 {}
C {devices/res.sym} 500 4800 0 0 {name=R198 value=1000 m=1}
N 500 4760 500 4770 {}
N 500 4830 500 4840 {}
C {devices/res.sym} 500 4880 0 0 {name=R197 value=1000 m=1}
N 500 4840 500 4850 {}
N 500 4910 500 4920 {}
C {devices/res.sym} 500 4960 0 0 {name=R196 value=1000 m=1}
N 500 4920 500 4930 {}
N 500 4990 500 5000 {}
C {devices/res.sym} 500 5040 0 0 {name=R195 value=1000 m=1}
N 500 5000 500 5010 {}
N 500 5070 500 5080 {}
C {devices/res.sym} 500 5120 0 0 {name=R194 value=1000 m=1}
N 500 5080 500 5090 {}
N 500 5150 500 5160 {}
C {devices/res.sym} 500 5200 0 0 {name=R193 value=1000 m=1}
N 500 5160 500 5170 {}
N 500 5230 500 5240 {}
C {devices/res.sym} 500 5280 0 0 {name=R192 value=1000 m=1}
N 500 5240 500 5250 {}
N 500 5310 500 5320 {}
C {devices/res.sym} 500 5360 0 0 {name=R191 value=1000 m=1}
N 500 5320 500 5330 {}
N 500 5390 500 5400 {}
C {devices/res.sym} 500 5440 0 0 {name=R190 value=1000 m=1}
N 500 5400 500 5410 {}
N 500 5470 500 5480 {}
C {devices/res.sym} 500 5520 0 0 {name=R189 value=1000 m=1}
N 500 5480 500 5490 {}
N 500 5550 500 5560 {}
C {devices/res.sym} 500 5600 0 0 {name=R188 value=1000 m=1}
N 500 5560 500 5570 {}
N 500 5630 500 5640 {}
C {devices/res.sym} 500 5680 0 0 {name=R187 value=1000 m=1}
N 500 5640 500 5650 {}
N 500 5710 500 5720 {}
C {devices/res.sym} 500 5760 0 0 {name=R186 value=1000 m=1}
N 500 5720 500 5730 {}
N 500 5790 500 5800 {}
C {devices/res.sym} 500 5840 0 0 {name=R185 value=1000 m=1}
N 500 5800 500 5810 {}
N 500 5870 500 5880 {}
C {devices/res.sym} 500 5920 0 0 {name=R184 value=1000 m=1}
N 500 5880 500 5890 {}
N 500 5950 500 5960 {}
C {devices/res.sym} 500 6000 0 0 {name=R183 value=1000 m=1}
N 500 5960 500 5970 {}
N 500 6030 500 6040 {}
C {devices/res.sym} 500 6080 0 0 {name=R182 value=1000 m=1}
N 500 6040 500 6050 {}
N 500 6110 500 6120 {}
C {devices/res.sym} 500 6160 0 0 {name=R181 value=1000 m=1}
N 500 6120 500 6130 {}
N 500 6190 500 6200 {}
C {devices/res.sym} 500 6240 0 0 {name=R180 value=1000 m=1}
N 500 6200 500 6210 {}
N 500 6270 500 6280 {}
C {devices/res.sym} 500 6320 0 0 {name=R179 value=1000 m=1}
N 500 6280 500 6290 {}
N 500 6350 500 6360 {}
C {devices/res.sym} 500 6400 0 0 {name=R178 value=1000 m=1}
N 500 6360 500 6370 {}
N 500 6430 500 6440 {}
C {devices/res.sym} 500 6480 0 0 {name=R177 value=1000 m=1}
N 500 6440 500 6450 {}
N 500 6510 500 6520 {}
C {devices/res.sym} 500 6560 0 0 {name=R176 value=1000 m=1}
N 500 6520 500 6530 {}
N 500 6590 500 6600 {}
C {devices/res.sym} 500 6640 0 0 {name=R175 value=1000 m=1}
N 500 6600 500 6610 {}
N 500 6670 500 6680 {}
C {devices/res.sym} 500 6720 0 0 {name=R174 value=1000 m=1}
N 500 6680 500 6690 {}
N 500 6750 500 6760 {}
C {devices/res.sym} 500 6800 0 0 {name=R173 value=1000 m=1}
N 500 6760 500 6770 {}
N 500 6830 500 6840 {}
C {devices/res.sym} 500 6880 0 0 {name=R172 value=1000 m=1}
N 500 6840 500 6850 {}
N 500 6910 500 6920 {}
C {devices/res.sym} 500 6960 0 0 {name=R171 value=1000 m=1}
N 500 6920 500 6930 {}
N 500 6990 500 7000 {}
C {devices/res.sym} 500 7040 0 0 {name=R170 value=1000 m=1}
N 500 7000 500 7010 {}
N 500 7070 500 7080 {}
C {devices/res.sym} 500 7120 0 0 {name=R169 value=1000 m=1}
N 500 7080 500 7090 {}
N 500 7150 500 7160 {}
C {devices/res.sym} 500 7200 0 0 {name=R168 value=1000 m=1}
N 500 7160 500 7170 {}
N 500 7230 500 7240 {}
C {devices/res.sym} 500 7280 0 0 {name=R167 value=1000 m=1}
N 500 7240 500 7250 {}
N 500 7310 500 7320 {}
C {devices/res.sym} 500 7360 0 0 {name=R166 value=1000 m=1}
N 500 7320 500 7330 {}
N 500 7390 500 7400 {}
C {devices/res.sym} 500 7440 0 0 {name=R165 value=1000 m=1}
N 500 7400 500 7410 {}
N 500 7470 500 7480 {}
C {devices/res.sym} 500 7520 0 0 {name=R164 value=1000 m=1}
N 500 7480 500 7490 {}
N 500 7550 500 7560 {}
C {devices/res.sym} 500 7600 0 0 {name=R163 value=1000 m=1}
N 500 7560 500 7570 {}
N 500 7630 500 7640 {}
C {devices/res.sym} 500 7680 0 0 {name=R162 value=1000 m=1}
N 500 7640 500 7650 {}
N 500 7710 500 7720 {}
C {devices/res.sym} 500 7760 0 0 {name=R161 value=1000 m=1}
N 500 7720 500 7730 {}
N 500 7790 500 7800 {}
C {devices/res.sym} 500 7840 0 0 {name=R160 value=1000 m=1}
N 500 7800 500 7810 {}
N 500 7870 500 7880 {}
C {devices/res.sym} 500 7920 0 0 {name=R159 value=1000 m=1}
N 500 7880 500 7890 {}
N 500 7950 500 7960 {}
C {devices/res.sym} 500 8000 0 0 {name=R158 value=1000 m=1}
N 500 7960 500 7970 {}
N 500 8030 500 8040 {}
C {devices/res.sym} 500 8080 0 0 {name=R157 value=1000 m=1}
N 500 8040 500 8050 {}
N 500 8110 500 8120 {}
C {devices/res.sym} 500 8160 0 0 {name=R156 value=1000 m=1}
N 500 8120 500 8130 {}
N 500 8190 500 8200 {}
C {devices/res.sym} 500 8240 0 0 {name=R155 value=1000 m=1}
N 500 8200 500 8210 {}
N 500 8270 500 8280 {}
C {devices/res.sym} 500 8320 0 0 {name=R154 value=1000 m=1}
N 500 8280 500 8290 {}
N 500 8350 500 8360 {}
C {devices/res.sym} 500 8400 0 0 {name=R153 value=1000 m=1}
N 500 8360 500 8370 {}
N 500 8430 500 8440 {}
C {devices/res.sym} 500 8480 0 0 {name=R152 value=1000 m=1}
N 500 8440 500 8450 {}
N 500 8510 500 8520 {}
C {devices/res.sym} 500 8560 0 0 {name=R151 value=1000 m=1}
N 500 8520 500 8530 {}
N 500 8590 500 8600 {}
C {devices/res.sym} 500 8640 0 0 {name=R150 value=1000 m=1}
N 500 8600 500 8610 {}
N 500 8670 500 8680 {}
C {devices/res.sym} 500 8720 0 0 {name=R149 value=1000 m=1}
N 500 8680 500 8690 {}
N 500 8750 500 8760 {}
C {devices/res.sym} 500 8800 0 0 {name=R148 value=1000 m=1}
N 500 8760 500 8770 {}
N 500 8830 500 8840 {}
C {devices/res.sym} 500 8880 0 0 {name=R147 value=1000 m=1}
N 500 8840 500 8850 {}
N 500 8910 500 8920 {}
C {devices/res.sym} 500 8960 0 0 {name=R146 value=1000 m=1}
N 500 8920 500 8930 {}
N 500 8990 500 9000 {}
C {devices/res.sym} 500 9040 0 0 {name=R145 value=1000 m=1}
N 500 9000 500 9010 {}
N 500 9070 500 9080 {}
C {devices/res.sym} 500 9120 0 0 {name=R144 value=1000 m=1}
N 500 9080 500 9090 {}
N 500 9150 500 9160 {}
C {devices/res.sym} 500 9200 0 0 {name=R143 value=1000 m=1}
N 500 9160 500 9170 {}
N 500 9230 500 9240 {}
C {devices/res.sym} 500 9280 0 0 {name=R142 value=1000 m=1}
N 500 9240 500 9250 {}
N 500 9310 500 9320 {}
C {devices/res.sym} 500 9360 0 0 {name=R141 value=1000 m=1}
N 500 9320 500 9330 {}
N 500 9390 500 9400 {}
C {devices/res.sym} 500 9440 0 0 {name=R140 value=1000 m=1}
N 500 9400 500 9410 {}
N 500 9470 500 9480 {}
C {devices/res.sym} 500 9520 0 0 {name=R139 value=1000 m=1}
N 500 9480 500 9490 {}
N 500 9550 500 9560 {}
C {devices/res.sym} 500 9600 0 0 {name=R138 value=1000 m=1}
N 500 9560 500 9570 {}
N 500 9630 500 9640 {}
C {devices/res.sym} 500 9680 0 0 {name=R137 value=1000 m=1}
N 500 9640 500 9650 {}
N 500 9710 500 9720 {}
C {devices/res.sym} 500 9760 0 0 {name=R136 value=1000 m=1}
N 500 9720 500 9730 {}
N 500 9790 500 9800 {}
C {devices/res.sym} 500 9840 0 0 {name=R135 value=1000 m=1}
N 500 9800 500 9810 {}
N 500 9870 500 9880 {}
C {devices/res.sym} 500 9920 0 0 {name=R134 value=1000 m=1}
N 500 9880 500 9890 {}
N 500 9950 500 9960 {}
C {devices/res.sym} 500 10000 0 0 {name=R133 value=1000 m=1}
N 500 9960 500 9970 {}
N 500 10030 500 10040 {}
C {devices/res.sym} 500 10080 0 0 {name=R132 value=1000 m=1}
N 500 10040 500 10050 {}
N 500 10110 500 10120 {}
C {devices/res.sym} 500 10160 0 0 {name=R131 value=1000 m=1}
N 500 10120 500 10130 {}
N 500 10190 500 10200 {}
C {devices/res.sym} 500 10240 0 0 {name=R130 value=1000 m=1}
N 500 10200 500 10210 {}
N 500 10270 500 10280 {}
C {devices/res.sym} 500 10320 0 0 {name=R129 value=1000 m=1}
N 500 10280 500 10290 {}
N 500 10350 500 10360 {}
C {devices/res.sym} 500 10400 0 0 {name=R128 value=1000 m=1}
N 500 10360 500 10370 {}
N 500 10430 500 10440 {}
C {devices/res.sym} 500 10480 0 0 {name=R127 value=1000 m=1}
N 500 10440 500 10450 {}
N 500 10510 500 10520 {}
C {devices/res.sym} 500 10560 0 0 {name=R126 value=1000 m=1}
N 500 10520 500 10530 {}
N 500 10590 500 10600 {}
C {devices/res.sym} 500 10640 0 0 {name=R125 value=1000 m=1}
N 500 10600 500 10610 {}
N 500 10670 500 10680 {}
C {devices/res.sym} 500 10720 0 0 {name=R124 value=1000 m=1}
N 500 10680 500 10690 {}
N 500 10750 500 10760 {}
C {devices/res.sym} 500 10800 0 0 {name=R123 value=1000 m=1}
N 500 10760 500 10770 {}
N 500 10830 500 10840 {}
C {devices/res.sym} 500 10880 0 0 {name=R122 value=1000 m=1}
N 500 10840 500 10850 {}
N 500 10910 500 10920 {}
C {devices/res.sym} 500 10960 0 0 {name=R121 value=1000 m=1}
N 500 10920 500 10930 {}
N 500 10990 500 11000 {}
C {devices/res.sym} 500 11040 0 0 {name=R120 value=1000 m=1}
N 500 11000 500 11010 {}
N 500 11070 500 11080 {}
C {devices/res.sym} 500 11120 0 0 {name=R119 value=1000 m=1}
N 500 11080 500 11090 {}
N 500 11150 500 11160 {}
C {devices/res.sym} 500 11200 0 0 {name=R118 value=1000 m=1}
N 500 11160 500 11170 {}
N 500 11230 500 11240 {}
C {devices/res.sym} 500 11280 0 0 {name=R117 value=1000 m=1}
N 500 11240 500 11250 {}
N 500 11310 500 11320 {}
C {devices/res.sym} 500 11360 0 0 {name=R116 value=1000 m=1}
N 500 11320 500 11330 {}
N 500 11390 500 11400 {}
C {devices/res.sym} 500 11440 0 0 {name=R115 value=1000 m=1}
N 500 11400 500 11410 {}
N 500 11470 500 11480 {}
C {devices/res.sym} 500 11520 0 0 {name=R114 value=1000 m=1}
N 500 11480 500 11490 {}
N 500 11550 500 11560 {}
C {devices/res.sym} 500 11600 0 0 {name=R113 value=1000 m=1}
N 500 11560 500 11570 {}
N 500 11630 500 11640 {}
C {devices/res.sym} 500 11680 0 0 {name=R112 value=1000 m=1}
N 500 11640 500 11650 {}
N 500 11710 500 11720 {}
C {devices/res.sym} 500 11760 0 0 {name=R111 value=1000 m=1}
N 500 11720 500 11730 {}
N 500 11790 500 11800 {}
C {devices/res.sym} 500 11840 0 0 {name=R110 value=1000 m=1}
N 500 11800 500 11810 {}
N 500 11870 500 11880 {}
C {devices/res.sym} 500 11920 0 0 {name=R109 value=1000 m=1}
N 500 11880 500 11890 {}
N 500 11950 500 11960 {}
C {devices/res.sym} 500 12000 0 0 {name=R108 value=1000 m=1}
N 500 11960 500 11970 {}
N 500 12030 500 12040 {}
C {devices/res.sym} 500 12080 0 0 {name=R107 value=1000 m=1}
N 500 12040 500 12050 {}
N 500 12110 500 12120 {}
C {devices/res.sym} 500 12160 0 0 {name=R106 value=1000 m=1}
N 500 12120 500 12130 {}
N 500 12190 500 12200 {}
C {devices/res.sym} 500 12240 0 0 {name=R105 value=1000 m=1}
N 500 12200 500 12210 {}
N 500 12270 500 12280 {}
C {devices/res.sym} 500 12320 0 0 {name=R104 value=1000 m=1}
N 500 12280 500 12290 {}
N 500 12350 500 12360 {}
C {devices/res.sym} 500 12400 0 0 {name=R103 value=1000 m=1}
N 500 12360 500 12370 {}
N 500 12430 500 12440 {}
C {devices/res.sym} 500 12480 0 0 {name=R102 value=1000 m=1}
N 500 12440 500 12450 {}
N 500 12510 500 12520 {}
C {devices/res.sym} 500 12560 0 0 {name=R101 value=1000 m=1}
N 500 12520 500 12530 {}
N 500 12590 500 12600 {}
C {devices/res.sym} 500 12640 0 0 {name=R100 value=1000 m=1}
N 500 12600 500 12610 {}
N 500 12670 500 12680 {}
C {devices/res.sym} 500 12720 0 0 {name=R99 value=1000 m=1}
N 500 12680 500 12690 {}
N 500 12750 500 12760 {}
C {devices/res.sym} 500 12800 0 0 {name=R98 value=1000 m=1}
N 500 12760 500 12770 {}
N 500 12830 500 12840 {}
C {devices/res.sym} 500 12880 0 0 {name=R97 value=1000 m=1}
N 500 12840 500 12850 {}
N 500 12910 500 12920 {}
C {devices/res.sym} 500 12960 0 0 {name=R96 value=1000 m=1}
N 500 12920 500 12930 {}
N 500 12990 500 13000 {}
C {devices/res.sym} 500 13040 0 0 {name=R95 value=1000 m=1}
N 500 13000 500 13010 {}
N 500 13070 500 13080 {}
C {devices/res.sym} 500 13120 0 0 {name=R94 value=1000 m=1}
N 500 13080 500 13090 {}
N 500 13150 500 13160 {}
C {devices/res.sym} 500 13200 0 0 {name=R93 value=1000 m=1}
N 500 13160 500 13170 {}
N 500 13230 500 13240 {}
C {devices/res.sym} 500 13280 0 0 {name=R92 value=1000 m=1}
N 500 13240 500 13250 {}
N 500 13310 500 13320 {}
C {devices/res.sym} 500 13360 0 0 {name=R91 value=1000 m=1}
N 500 13320 500 13330 {}
N 500 13390 500 13400 {}
C {devices/res.sym} 500 13440 0 0 {name=R90 value=1000 m=1}
N 500 13400 500 13410 {}
N 500 13470 500 13480 {}
C {devices/res.sym} 500 13520 0 0 {name=R89 value=1000 m=1}
N 500 13480 500 13490 {}
N 500 13550 500 13560 {}
C {devices/res.sym} 500 13600 0 0 {name=R88 value=1000 m=1}
N 500 13560 500 13570 {}
N 500 13630 500 13640 {}
C {devices/res.sym} 500 13680 0 0 {name=R87 value=1000 m=1}
N 500 13640 500 13650 {}
N 500 13710 500 13720 {}
C {devices/res.sym} 500 13760 0 0 {name=R86 value=1000 m=1}
N 500 13720 500 13730 {}
N 500 13790 500 13800 {}
C {devices/res.sym} 500 13840 0 0 {name=R85 value=1000 m=1}
N 500 13800 500 13810 {}
N 500 13870 500 13880 {}
C {devices/res.sym} 500 13920 0 0 {name=R84 value=1000 m=1}
N 500 13880 500 13890 {}
N 500 13950 500 13960 {}
C {devices/res.sym} 500 14000 0 0 {name=R83 value=1000 m=1}
N 500 13960 500 13970 {}
N 500 14030 500 14040 {}
C {devices/res.sym} 500 14080 0 0 {name=R82 value=1000 m=1}
N 500 14040 500 14050 {}
N 500 14110 500 14120 {}
C {devices/res.sym} 500 14160 0 0 {name=R81 value=1000 m=1}
N 500 14120 500 14130 {}
N 500 14190 500 14200 {}
C {devices/res.sym} 500 14240 0 0 {name=R80 value=1000 m=1}
N 500 14200 500 14210 {}
N 500 14270 500 14280 {}
C {devices/res.sym} 500 14320 0 0 {name=R79 value=1000 m=1}
N 500 14280 500 14290 {}
N 500 14350 500 14360 {}
C {devices/res.sym} 500 14400 0 0 {name=R78 value=1000 m=1}
N 500 14360 500 14370 {}
N 500 14430 500 14440 {}
C {devices/res.sym} 500 14480 0 0 {name=R77 value=1000 m=1}
N 500 14440 500 14450 {}
N 500 14510 500 14520 {}
C {devices/res.sym} 500 14560 0 0 {name=R76 value=1000 m=1}
N 500 14520 500 14530 {}
N 500 14590 500 14600 {}
C {devices/res.sym} 500 14640 0 0 {name=R75 value=1000 m=1}
N 500 14600 500 14610 {}
N 500 14670 500 14680 {}
C {devices/res.sym} 500 14720 0 0 {name=R74 value=1000 m=1}
N 500 14680 500 14690 {}
N 500 14750 500 14760 {}
C {devices/res.sym} 500 14800 0 0 {name=R73 value=1000 m=1}
N 500 14760 500 14770 {}
N 500 14830 500 14840 {}
C {devices/res.sym} 500 14880 0 0 {name=R72 value=1000 m=1}
N 500 14840 500 14850 {}
N 500 14910 500 14920 {}
C {devices/res.sym} 500 14960 0 0 {name=R71 value=1000 m=1}
N 500 14920 500 14930 {}
N 500 14990 500 15000 {}
C {devices/res.sym} 500 15040 0 0 {name=R70 value=1000 m=1}
N 500 15000 500 15010 {}
N 500 15070 500 15080 {}
C {devices/res.sym} 500 15120 0 0 {name=R69 value=1000 m=1}
N 500 15080 500 15090 {}
N 500 15150 500 15160 {}
C {devices/res.sym} 500 15200 0 0 {name=R68 value=1000 m=1}
N 500 15160 500 15170 {}
N 500 15230 500 15240 {}
C {devices/res.sym} 500 15280 0 0 {name=R67 value=1000 m=1}
N 500 15240 500 15250 {}
N 500 15310 500 15320 {}
C {devices/res.sym} 500 15360 0 0 {name=R66 value=1000 m=1}
N 500 15320 500 15330 {}
N 500 15390 500 15400 {}
C {devices/res.sym} 500 15440 0 0 {name=R65 value=1000 m=1}
N 500 15400 500 15410 {}
N 500 15470 500 15480 {}
C {devices/res.sym} 500 15520 0 0 {name=R64 value=1000 m=1}
N 500 15480 500 15490 {}
N 500 15550 500 15560 {}
C {devices/res.sym} 500 15600 0 0 {name=R63 value=1000 m=1}
N 500 15560 500 15570 {}
N 500 15630 500 15640 {}
C {devices/res.sym} 500 15680 0 0 {name=R62 value=1000 m=1}
N 500 15640 500 15650 {}
N 500 15710 500 15720 {}
C {devices/res.sym} 500 15760 0 0 {name=R61 value=1000 m=1}
N 500 15720 500 15730 {}
N 500 15790 500 15800 {}
C {devices/res.sym} 500 15840 0 0 {name=R60 value=1000 m=1}
N 500 15800 500 15810 {}
N 500 15870 500 15880 {}
C {devices/res.sym} 500 15920 0 0 {name=R59 value=1000 m=1}
N 500 15880 500 15890 {}
N 500 15950 500 15960 {}
C {devices/res.sym} 500 16000 0 0 {name=R58 value=1000 m=1}
N 500 15960 500 15970 {}
N 500 16030 500 16040 {}
C {devices/res.sym} 500 16080 0 0 {name=R57 value=1000 m=1}
N 500 16040 500 16050 {}
N 500 16110 500 16120 {}
C {devices/res.sym} 500 16160 0 0 {name=R56 value=1000 m=1}
N 500 16120 500 16130 {}
N 500 16190 500 16200 {}
C {devices/res.sym} 500 16240 0 0 {name=R55 value=1000 m=1}
N 500 16200 500 16210 {}
N 500 16270 500 16280 {}
C {devices/res.sym} 500 16320 0 0 {name=R54 value=1000 m=1}
N 500 16280 500 16290 {}
N 500 16350 500 16360 {}
C {devices/res.sym} 500 16400 0 0 {name=R53 value=1000 m=1}
N 500 16360 500 16370 {}
N 500 16430 500 16440 {}
C {devices/res.sym} 500 16480 0 0 {name=R52 value=1000 m=1}
N 500 16440 500 16450 {}
N 500 16510 500 16520 {}
C {devices/res.sym} 500 16560 0 0 {name=R51 value=1000 m=1}
N 500 16520 500 16530 {}
N 500 16590 500 16600 {}
C {devices/res.sym} 500 16640 0 0 {name=R50 value=1000 m=1}
N 500 16600 500 16610 {}
N 500 16670 500 16680 {}
C {devices/res.sym} 500 16720 0 0 {name=R49 value=1000 m=1}
N 500 16680 500 16690 {}
N 500 16750 500 16760 {}
C {devices/res.sym} 500 16800 0 0 {name=R48 value=1000 m=1}
N 500 16760 500 16770 {}
N 500 16830 500 16840 {}
C {devices/res.sym} 500 16880 0 0 {name=R47 value=1000 m=1}
N 500 16840 500 16850 {}
N 500 16910 500 16920 {}
C {devices/res.sym} 500 16960 0 0 {name=R46 value=1000 m=1}
N 500 16920 500 16930 {}
N 500 16990 500 17000 {}
C {devices/res.sym} 500 17040 0 0 {name=R45 value=1000 m=1}
N 500 17000 500 17010 {}
N 500 17070 500 17080 {}
C {devices/res.sym} 500 17120 0 0 {name=R44 value=1000 m=1}
N 500 17080 500 17090 {}
N 500 17150 500 17160 {}
C {devices/res.sym} 500 17200 0 0 {name=R43 value=1000 m=1}
N 500 17160 500 17170 {}
N 500 17230 500 17240 {}
C {devices/res.sym} 500 17280 0 0 {name=R42 value=1000 m=1}
N 500 17240 500 17250 {}
N 500 17310 500 17320 {}
C {devices/res.sym} 500 17360 0 0 {name=R41 value=1000 m=1}
N 500 17320 500 17330 {}
N 500 17390 500 17400 {}
C {devices/res.sym} 500 17440 0 0 {name=R40 value=1000 m=1}
N 500 17400 500 17410 {}
N 500 17470 500 17480 {}
C {devices/res.sym} 500 17520 0 0 {name=R39 value=1000 m=1}
N 500 17480 500 17490 {}
N 500 17550 500 17560 {}
C {devices/res.sym} 500 17600 0 0 {name=R38 value=1000 m=1}
N 500 17560 500 17570 {}
N 500 17630 500 17640 {}
C {devices/res.sym} 500 17680 0 0 {name=R37 value=1000 m=1}
N 500 17640 500 17650 {}
N 500 17710 500 17720 {}
C {devices/res.sym} 500 17760 0 0 {name=R36 value=1000 m=1}
N 500 17720 500 17730 {}
N 500 17790 500 17800 {}
C {devices/res.sym} 500 17840 0 0 {name=R35 value=1000 m=1}
N 500 17800 500 17810 {}
N 500 17870 500 17880 {}
C {devices/res.sym} 500 17920 0 0 {name=R34 value=1000 m=1}
N 500 17880 500 17890 {}
N 500 17950 500 17960 {}
C {devices/res.sym} 500 18000 0 0 {name=R33 value=1000 m=1}
N 500 17960 500 17970 {}
N 500 18030 500 18040 {}
C {devices/res.sym} 500 18080 0 0 {name=R32 value=1000 m=1}
N 500 18040 500 18050 {}
N 500 18110 500 18120 {}
C {devices/res.sym} 500 18160 0 0 {name=R31 value=1000 m=1}
N 500 18120 500 18130 {}
N 500 18190 500 18200 {}
C {devices/res.sym} 500 18240 0 0 {name=R30 value=1000 m=1}
N 500 18200 500 18210 {}
N 500 18270 500 18280 {}
C {devices/res.sym} 500 18320 0 0 {name=R29 value=1000 m=1}
N 500 18280 500 18290 {}
N 500 18350 500 18360 {}
C {devices/res.sym} 500 18400 0 0 {name=R28 value=1000 m=1}
N 500 18360 500 18370 {}
N 500 18430 500 18440 {}
C {devices/res.sym} 500 18480 0 0 {name=R27 value=1000 m=1}
N 500 18440 500 18450 {}
N 500 18510 500 18520 {}
C {devices/res.sym} 500 18560 0 0 {name=R26 value=1000 m=1}
N 500 18520 500 18530 {}
N 500 18590 500 18600 {}
C {devices/res.sym} 500 18640 0 0 {name=R25 value=1000 m=1}
N 500 18600 500 18610 {}
N 500 18670 500 18680 {}
C {devices/res.sym} 500 18720 0 0 {name=R24 value=1000 m=1}
N 500 18680 500 18690 {}
N 500 18750 500 18760 {}
C {devices/res.sym} 500 18800 0 0 {name=R23 value=1000 m=1}
N 500 18760 500 18770 {}
N 500 18830 500 18840 {}
C {devices/res.sym} 500 18880 0 0 {name=R22 value=1000 m=1}
N 500 18840 500 18850 {}
N 500 18910 500 18920 {}
C {devices/res.sym} 500 18960 0 0 {name=R21 value=1000 m=1}
N 500 18920 500 18930 {}
N 500 18990 500 19000 {}
C {devices/res.sym} 500 19040 0 0 {name=R20 value=1000 m=1}
N 500 19000 500 19010 {}
N 500 19070 500 19080 {}
C {devices/res.sym} 500 19120 0 0 {name=R19 value=1000 m=1}
N 500 19080 500 19090 {}
N 500 19150 500 19160 {}
C {devices/res.sym} 500 19200 0 0 {name=R18 value=1000 m=1}
N 500 19160 500 19170 {}
N 500 19230 500 19240 {}
C {devices/res.sym} 500 19280 0 0 {name=R17 value=1000 m=1}
N 500 19240 500 19250 {}
N 500 19310 500 19320 {}
C {devices/res.sym} 500 19360 0 0 {name=R16 value=1000 m=1}
N 500 19320 500 19330 {}
N 500 19390 500 19400 {}
C {devices/res.sym} 500 19440 0 0 {name=R15 value=1000 m=1}
N 500 19400 500 19410 {}
N 500 19470 500 19480 {}
C {devices/res.sym} 500 19520 0 0 {name=R14 value=1000 m=1}
N 500 19480 500 19490 {}
N 500 19550 500 19560 {}
C {devices/res.sym} 500 19600 0 0 {name=R13 value=1000 m=1}
N 500 19560 500 19570 {}
N 500 19630 500 19640 {}
C {devices/res.sym} 500 19680 0 0 {name=R12 value=1000 m=1}
N 500 19640 500 19650 {}
N 500 19710 500 19720 {}
C {devices/res.sym} 500 19760 0 0 {name=R11 value=1000 m=1}
N 500 19720 500 19730 {}
N 500 19790 500 19800 {}
C {devices/res.sym} 500 19840 0 0 {name=R10 value=1000 m=1}
N 500 19800 500 19810 {}
N 500 19870 500 19880 {}
C {devices/res.sym} 500 19920 0 0 {name=R9 value=1000 m=1}
N 500 19880 500 19890 {}
N 500 19950 500 19960 {}
C {devices/res.sym} 500 20000 0 0 {name=R8 value=1000 m=1}
N 500 19960 500 19970 {}
N 500 20030 500 20040 {}
C {devices/res.sym} 500 20080 0 0 {name=R7 value=1000 m=1}
N 500 20040 500 20050 {}
N 500 20110 500 20120 {}
C {devices/res.sym} 500 20160 0 0 {name=R6 value=1000 m=1}
N 500 20120 500 20130 {}
N 500 20190 500 20200 {}
C {devices/res.sym} 500 20240 0 0 {name=R5 value=1000 m=1}
N 500 20200 500 20210 {}
N 500 20270 500 20280 {}
C {devices/res.sym} 500 20320 0 0 {name=R4 value=1000 m=1}
N 500 20280 500 20290 {}
N 500 20350 500 20360 {}
C {devices/res.sym} 500 20400 0 0 {name=R3 value=1000 m=1}
N 500 20360 500 20370 {}
N 500 20430 500 20440 {}
C {devices/res.sym} 500 20480 0 0 {name=R2 value=1000 m=1}
N 500 20440 500 20450 {}
N 500 20510 500 20520 {}
C {devices/res.sym} 500 20560 0 0 {name=R1 value=1000 m=1}
N 500 20520 500 20530 {}
N 500 20590 500 20600 {}
C {devices/res.sym} 500 20640 0 0 {name=Rbot value=500 m=1}
N 500 20600 500 20610 {}
N 500 20670 500 20680 {}
C {devices/gnd.sym} 500 20680 0 0 {name=g5 lab=GND}
C {devices/lab_pin.sym} 500 20600 0 1 {name=l3 lab=r1}
N 500 20600 560 20600 {}
C {devices/lab_pin.sym} 560 20580 0 0 {name=l4 lab=vs}
C {comparator.sym} 600 20590 0 0 {name=Bc1 vhigh=1.8 gain=1e5}
N 640 20590 700 20590 {}
C {devices/lab_pin.sym} 700 20590 0 1 {name=l5 lab=t1}
C {devices/lab_pin.sym} 500 20520 0 1 {name=l6 lab=r2}
N 500 20520 560 20520 {}
C {devices/lab_pin.sym} 560 20500 0 0 {name=l7 lab=vs}
C {comparator.sym} 600 20510 0 0 {name=Bc2 vhigh=1.8 gain=1e5}
N 640 20510 700 20510 {}
C {devices/lab_pin.sym} 700 20510 0 1 {name=l8 lab=t2}
C {devices/lab_pin.sym} 500 20440 0 1 {name=l9 lab=r3}
N 500 20440 560 20440 {}
C {devices/lab_pin.sym} 560 20420 0 0 {name=l10 lab=vs}
C {comparator.sym} 600 20430 0 0 {name=Bc3 vhigh=1.8 gain=1e5}
N 640 20430 700 20430 {}
C {devices/lab_pin.sym} 700 20430 0 1 {name=l11 lab=t3}
C {devices/lab_pin.sym} 500 20360 0 1 {name=l12 lab=r4}
N 500 20360 560 20360 {}
C {devices/lab_pin.sym} 560 20340 0 0 {name=l13 lab=vs}
C {comparator.sym} 600 20350 0 0 {name=Bc4 vhigh=1.8 gain=1e5}
N 640 20350 700 20350 {}
C {devices/lab_pin.sym} 700 20350 0 1 {name=l14 lab=t4}
C {devices/lab_pin.sym} 500 20280 0 1 {name=l15 lab=r5}
N 500 20280 560 20280 {}
C {devices/lab_pin.sym} 560 20260 0 0 {name=l16 lab=vs}
C {comparator.sym} 600 20270 0 0 {name=Bc5 vhigh=1.8 gain=1e5}
N 640 20270 700 20270 {}
C {devices/lab_pin.sym} 700 20270 0 1 {name=l17 lab=t5}
C {devices/lab_pin.sym} 500 20200 0 1 {name=l18 lab=r6}
N 500 20200 560 20200 {}
C {devices/lab_pin.sym} 560 20180 0 0 {name=l19 lab=vs}
C {comparator.sym} 600 20190 0 0 {name=Bc6 vhigh=1.8 gain=1e5}
N 640 20190 700 20190 {}
C {devices/lab_pin.sym} 700 20190 0 1 {name=l20 lab=t6}
C {devices/lab_pin.sym} 500 20120 0 1 {name=l21 lab=r7}
N 500 20120 560 20120 {}
C {devices/lab_pin.sym} 560 20100 0 0 {name=l22 lab=vs}
C {comparator.sym} 600 20110 0 0 {name=Bc7 vhigh=1.8 gain=1e5}
N 640 20110 700 20110 {}
C {devices/lab_pin.sym} 700 20110 0 1 {name=l23 lab=t7}
C {devices/lab_pin.sym} 500 20040 0 1 {name=l24 lab=r8}
N 500 20040 560 20040 {}
C {devices/lab_pin.sym} 560 20020 0 0 {name=l25 lab=vs}
C {comparator.sym} 600 20030 0 0 {name=Bc8 vhigh=1.8 gain=1e5}
N 640 20030 700 20030 {}
C {devices/lab_pin.sym} 700 20030 0 1 {name=l26 lab=t8}
C {devices/lab_pin.sym} 500 19960 0 1 {name=l27 lab=r9}
N 500 19960 560 19960 {}
C {devices/lab_pin.sym} 560 19940 0 0 {name=l28 lab=vs}
C {comparator.sym} 600 19950 0 0 {name=Bc9 vhigh=1.8 gain=1e5}
N 640 19950 700 19950 {}
C {devices/lab_pin.sym} 700 19950 0 1 {name=l29 lab=t9}
C {devices/lab_pin.sym} 500 19880 0 1 {name=l30 lab=r10}
N 500 19880 560 19880 {}
C {devices/lab_pin.sym} 560 19860 0 0 {name=l31 lab=vs}
C {comparator.sym} 600 19870 0 0 {name=Bc10 vhigh=1.8 gain=1e5}
N 640 19870 700 19870 {}
C {devices/lab_pin.sym} 700 19870 0 1 {name=l32 lab=t10}
C {devices/lab_pin.sym} 500 19800 0 1 {name=l33 lab=r11}
N 500 19800 560 19800 {}
C {devices/lab_pin.sym} 560 19780 0 0 {name=l34 lab=vs}
C {comparator.sym} 600 19790 0 0 {name=Bc11 vhigh=1.8 gain=1e5}
N 640 19790 700 19790 {}
C {devices/lab_pin.sym} 700 19790 0 1 {name=l35 lab=t11}
C {devices/lab_pin.sym} 500 19720 0 1 {name=l36 lab=r12}
N 500 19720 560 19720 {}
C {devices/lab_pin.sym} 560 19700 0 0 {name=l37 lab=vs}
C {comparator.sym} 600 19710 0 0 {name=Bc12 vhigh=1.8 gain=1e5}
N 640 19710 700 19710 {}
C {devices/lab_pin.sym} 700 19710 0 1 {name=l38 lab=t12}
C {devices/lab_pin.sym} 500 19640 0 1 {name=l39 lab=r13}
N 500 19640 560 19640 {}
C {devices/lab_pin.sym} 560 19620 0 0 {name=l40 lab=vs}
C {comparator.sym} 600 19630 0 0 {name=Bc13 vhigh=1.8 gain=1e5}
N 640 19630 700 19630 {}
C {devices/lab_pin.sym} 700 19630 0 1 {name=l41 lab=t13}
C {devices/lab_pin.sym} 500 19560 0 1 {name=l42 lab=r14}
N 500 19560 560 19560 {}
C {devices/lab_pin.sym} 560 19540 0 0 {name=l43 lab=vs}
C {comparator.sym} 600 19550 0 0 {name=Bc14 vhigh=1.8 gain=1e5}
N 640 19550 700 19550 {}
C {devices/lab_pin.sym} 700 19550 0 1 {name=l44 lab=t14}
C {devices/lab_pin.sym} 500 19480 0 1 {name=l45 lab=r15}
N 500 19480 560 19480 {}
C {devices/lab_pin.sym} 560 19460 0 0 {name=l46 lab=vs}
C {comparator.sym} 600 19470 0 0 {name=Bc15 vhigh=1.8 gain=1e5}
N 640 19470 700 19470 {}
C {devices/lab_pin.sym} 700 19470 0 1 {name=l47 lab=t15}
C {devices/lab_pin.sym} 500 19400 0 1 {name=l48 lab=r16}
N 500 19400 560 19400 {}
C {devices/lab_pin.sym} 560 19380 0 0 {name=l49 lab=vs}
C {comparator.sym} 600 19390 0 0 {name=Bc16 vhigh=1.8 gain=1e5}
N 640 19390 700 19390 {}
C {devices/lab_pin.sym} 700 19390 0 1 {name=l50 lab=t16}
C {devices/lab_pin.sym} 500 19320 0 1 {name=l51 lab=r17}
N 500 19320 560 19320 {}
C {devices/lab_pin.sym} 560 19300 0 0 {name=l52 lab=vs}
C {comparator.sym} 600 19310 0 0 {name=Bc17 vhigh=1.8 gain=1e5}
N 640 19310 700 19310 {}
C {devices/lab_pin.sym} 700 19310 0 1 {name=l53 lab=t17}
C {devices/lab_pin.sym} 500 19240 0 1 {name=l54 lab=r18}
N 500 19240 560 19240 {}
C {devices/lab_pin.sym} 560 19220 0 0 {name=l55 lab=vs}
C {comparator.sym} 600 19230 0 0 {name=Bc18 vhigh=1.8 gain=1e5}
N 640 19230 700 19230 {}
C {devices/lab_pin.sym} 700 19230 0 1 {name=l56 lab=t18}
C {devices/lab_pin.sym} 500 19160 0 1 {name=l57 lab=r19}
N 500 19160 560 19160 {}
C {devices/lab_pin.sym} 560 19140 0 0 {name=l58 lab=vs}
C {comparator.sym} 600 19150 0 0 {name=Bc19 vhigh=1.8 gain=1e5}
N 640 19150 700 19150 {}
C {devices/lab_pin.sym} 700 19150 0 1 {name=l59 lab=t19}
C {devices/lab_pin.sym} 500 19080 0 1 {name=l60 lab=r20}
N 500 19080 560 19080 {}
C {devices/lab_pin.sym} 560 19060 0 0 {name=l61 lab=vs}
C {comparator.sym} 600 19070 0 0 {name=Bc20 vhigh=1.8 gain=1e5}
N 640 19070 700 19070 {}
C {devices/lab_pin.sym} 700 19070 0 1 {name=l62 lab=t20}
C {devices/lab_pin.sym} 500 19000 0 1 {name=l63 lab=r21}
N 500 19000 560 19000 {}
C {devices/lab_pin.sym} 560 18980 0 0 {name=l64 lab=vs}
C {comparator.sym} 600 18990 0 0 {name=Bc21 vhigh=1.8 gain=1e5}
N 640 18990 700 18990 {}
C {devices/lab_pin.sym} 700 18990 0 1 {name=l65 lab=t21}
C {devices/lab_pin.sym} 500 18920 0 1 {name=l66 lab=r22}
N 500 18920 560 18920 {}
C {devices/lab_pin.sym} 560 18900 0 0 {name=l67 lab=vs}
C {comparator.sym} 600 18910 0 0 {name=Bc22 vhigh=1.8 gain=1e5}
N 640 18910 700 18910 {}
C {devices/lab_pin.sym} 700 18910 0 1 {name=l68 lab=t22}
C {devices/lab_pin.sym} 500 18840 0 1 {name=l69 lab=r23}
N 500 18840 560 18840 {}
C {devices/lab_pin.sym} 560 18820 0 0 {name=l70 lab=vs}
C {comparator.sym} 600 18830 0 0 {name=Bc23 vhigh=1.8 gain=1e5}
N 640 18830 700 18830 {}
C {devices/lab_pin.sym} 700 18830 0 1 {name=l71 lab=t23}
C {devices/lab_pin.sym} 500 18760 0 1 {name=l72 lab=r24}
N 500 18760 560 18760 {}
C {devices/lab_pin.sym} 560 18740 0 0 {name=l73 lab=vs}
C {comparator.sym} 600 18750 0 0 {name=Bc24 vhigh=1.8 gain=1e5}
N 640 18750 700 18750 {}
C {devices/lab_pin.sym} 700 18750 0 1 {name=l74 lab=t24}
C {devices/lab_pin.sym} 500 18680 0 1 {name=l75 lab=r25}
N 500 18680 560 18680 {}
C {devices/lab_pin.sym} 560 18660 0 0 {name=l76 lab=vs}
C {comparator.sym} 600 18670 0 0 {name=Bc25 vhigh=1.8 gain=1e5}
N 640 18670 700 18670 {}
C {devices/lab_pin.sym} 700 18670 0 1 {name=l77 lab=t25}
C {devices/lab_pin.sym} 500 18600 0 1 {name=l78 lab=r26}
N 500 18600 560 18600 {}
C {devices/lab_pin.sym} 560 18580 0 0 {name=l79 lab=vs}
C {comparator.sym} 600 18590 0 0 {name=Bc26 vhigh=1.8 gain=1e5}
N 640 18590 700 18590 {}
C {devices/lab_pin.sym} 700 18590 0 1 {name=l80 lab=t26}
C {devices/lab_pin.sym} 500 18520 0 1 {name=l81 lab=r27}
N 500 18520 560 18520 {}
C {devices/lab_pin.sym} 560 18500 0 0 {name=l82 lab=vs}
C {comparator.sym} 600 18510 0 0 {name=Bc27 vhigh=1.8 gain=1e5}
N 640 18510 700 18510 {}
C {devices/lab_pin.sym} 700 18510 0 1 {name=l83 lab=t27}
C {devices/lab_pin.sym} 500 18440 0 1 {name=l84 lab=r28}
N 500 18440 560 18440 {}
C {devices/lab_pin.sym} 560 18420 0 0 {name=l85 lab=vs}
C {comparator.sym} 600 18430 0 0 {name=Bc28 vhigh=1.8 gain=1e5}
N 640 18430 700 18430 {}
C {devices/lab_pin.sym} 700 18430 0 1 {name=l86 lab=t28}
C {devices/lab_pin.sym} 500 18360 0 1 {name=l87 lab=r29}
N 500 18360 560 18360 {}
C {devices/lab_pin.sym} 560 18340 0 0 {name=l88 lab=vs}
C {comparator.sym} 600 18350 0 0 {name=Bc29 vhigh=1.8 gain=1e5}
N 640 18350 700 18350 {}
C {devices/lab_pin.sym} 700 18350 0 1 {name=l89 lab=t29}
C {devices/lab_pin.sym} 500 18280 0 1 {name=l90 lab=r30}
N 500 18280 560 18280 {}
C {devices/lab_pin.sym} 560 18260 0 0 {name=l91 lab=vs}
C {comparator.sym} 600 18270 0 0 {name=Bc30 vhigh=1.8 gain=1e5}
N 640 18270 700 18270 {}
C {devices/lab_pin.sym} 700 18270 0 1 {name=l92 lab=t30}
C {devices/lab_pin.sym} 500 18200 0 1 {name=l93 lab=r31}
N 500 18200 560 18200 {}
C {devices/lab_pin.sym} 560 18180 0 0 {name=l94 lab=vs}
C {comparator.sym} 600 18190 0 0 {name=Bc31 vhigh=1.8 gain=1e5}
N 640 18190 700 18190 {}
C {devices/lab_pin.sym} 700 18190 0 1 {name=l95 lab=t31}
C {devices/lab_pin.sym} 500 18120 0 1 {name=l96 lab=r32}
N 500 18120 560 18120 {}
C {devices/lab_pin.sym} 560 18100 0 0 {name=l97 lab=vs}
C {comparator.sym} 600 18110 0 0 {name=Bc32 vhigh=1.8 gain=1e5}
N 640 18110 700 18110 {}
C {devices/lab_pin.sym} 700 18110 0 1 {name=l98 lab=t32}
C {devices/lab_pin.sym} 500 18040 0 1 {name=l99 lab=r33}
N 500 18040 560 18040 {}
C {devices/lab_pin.sym} 560 18020 0 0 {name=l100 lab=vs}
C {comparator.sym} 600 18030 0 0 {name=Bc33 vhigh=1.8 gain=1e5}
N 640 18030 700 18030 {}
C {devices/lab_pin.sym} 700 18030 0 1 {name=l101 lab=t33}
C {devices/lab_pin.sym} 500 17960 0 1 {name=l102 lab=r34}
N 500 17960 560 17960 {}
C {devices/lab_pin.sym} 560 17940 0 0 {name=l103 lab=vs}
C {comparator.sym} 600 17950 0 0 {name=Bc34 vhigh=1.8 gain=1e5}
N 640 17950 700 17950 {}
C {devices/lab_pin.sym} 700 17950 0 1 {name=l104 lab=t34}
C {devices/lab_pin.sym} 500 17880 0 1 {name=l105 lab=r35}
N 500 17880 560 17880 {}
C {devices/lab_pin.sym} 560 17860 0 0 {name=l106 lab=vs}
C {comparator.sym} 600 17870 0 0 {name=Bc35 vhigh=1.8 gain=1e5}
N 640 17870 700 17870 {}
C {devices/lab_pin.sym} 700 17870 0 1 {name=l107 lab=t35}
C {devices/lab_pin.sym} 500 17800 0 1 {name=l108 lab=r36}
N 500 17800 560 17800 {}
C {devices/lab_pin.sym} 560 17780 0 0 {name=l109 lab=vs}
C {comparator.sym} 600 17790 0 0 {name=Bc36 vhigh=1.8 gain=1e5}
N 640 17790 700 17790 {}
C {devices/lab_pin.sym} 700 17790 0 1 {name=l110 lab=t36}
C {devices/lab_pin.sym} 500 17720 0 1 {name=l111 lab=r37}
N 500 17720 560 17720 {}
C {devices/lab_pin.sym} 560 17700 0 0 {name=l112 lab=vs}
C {comparator.sym} 600 17710 0 0 {name=Bc37 vhigh=1.8 gain=1e5}
N 640 17710 700 17710 {}
C {devices/lab_pin.sym} 700 17710 0 1 {name=l113 lab=t37}
C {devices/lab_pin.sym} 500 17640 0 1 {name=l114 lab=r38}
N 500 17640 560 17640 {}
C {devices/lab_pin.sym} 560 17620 0 0 {name=l115 lab=vs}
C {comparator.sym} 600 17630 0 0 {name=Bc38 vhigh=1.8 gain=1e5}
N 640 17630 700 17630 {}
C {devices/lab_pin.sym} 700 17630 0 1 {name=l116 lab=t38}
C {devices/lab_pin.sym} 500 17560 0 1 {name=l117 lab=r39}
N 500 17560 560 17560 {}
C {devices/lab_pin.sym} 560 17540 0 0 {name=l118 lab=vs}
C {comparator.sym} 600 17550 0 0 {name=Bc39 vhigh=1.8 gain=1e5}
N 640 17550 700 17550 {}
C {devices/lab_pin.sym} 700 17550 0 1 {name=l119 lab=t39}
C {devices/lab_pin.sym} 500 17480 0 1 {name=l120 lab=r40}
N 500 17480 560 17480 {}
C {devices/lab_pin.sym} 560 17460 0 0 {name=l121 lab=vs}
C {comparator.sym} 600 17470 0 0 {name=Bc40 vhigh=1.8 gain=1e5}
N 640 17470 700 17470 {}
C {devices/lab_pin.sym} 700 17470 0 1 {name=l122 lab=t40}
C {devices/lab_pin.sym} 500 17400 0 1 {name=l123 lab=r41}
N 500 17400 560 17400 {}
C {devices/lab_pin.sym} 560 17380 0 0 {name=l124 lab=vs}
C {comparator.sym} 600 17390 0 0 {name=Bc41 vhigh=1.8 gain=1e5}
N 640 17390 700 17390 {}
C {devices/lab_pin.sym} 700 17390 0 1 {name=l125 lab=t41}
C {devices/lab_pin.sym} 500 17320 0 1 {name=l126 lab=r42}
N 500 17320 560 17320 {}
C {devices/lab_pin.sym} 560 17300 0 0 {name=l127 lab=vs}
C {comparator.sym} 600 17310 0 0 {name=Bc42 vhigh=1.8 gain=1e5}
N 640 17310 700 17310 {}
C {devices/lab_pin.sym} 700 17310 0 1 {name=l128 lab=t42}
C {devices/lab_pin.sym} 500 17240 0 1 {name=l129 lab=r43}
N 500 17240 560 17240 {}
C {devices/lab_pin.sym} 560 17220 0 0 {name=l130 lab=vs}
C {comparator.sym} 600 17230 0 0 {name=Bc43 vhigh=1.8 gain=1e5}
N 640 17230 700 17230 {}
C {devices/lab_pin.sym} 700 17230 0 1 {name=l131 lab=t43}
C {devices/lab_pin.sym} 500 17160 0 1 {name=l132 lab=r44}
N 500 17160 560 17160 {}
C {devices/lab_pin.sym} 560 17140 0 0 {name=l133 lab=vs}
C {comparator.sym} 600 17150 0 0 {name=Bc44 vhigh=1.8 gain=1e5}
N 640 17150 700 17150 {}
C {devices/lab_pin.sym} 700 17150 0 1 {name=l134 lab=t44}
C {devices/lab_pin.sym} 500 17080 0 1 {name=l135 lab=r45}
N 500 17080 560 17080 {}
C {devices/lab_pin.sym} 560 17060 0 0 {name=l136 lab=vs}
C {comparator.sym} 600 17070 0 0 {name=Bc45 vhigh=1.8 gain=1e5}
N 640 17070 700 17070 {}
C {devices/lab_pin.sym} 700 17070 0 1 {name=l137 lab=t45}
C {devices/lab_pin.sym} 500 17000 0 1 {name=l138 lab=r46}
N 500 17000 560 17000 {}
C {devices/lab_pin.sym} 560 16980 0 0 {name=l139 lab=vs}
C {comparator.sym} 600 16990 0 0 {name=Bc46 vhigh=1.8 gain=1e5}
N 640 16990 700 16990 {}
C {devices/lab_pin.sym} 700 16990 0 1 {name=l140 lab=t46}
C {devices/lab_pin.sym} 500 16920 0 1 {name=l141 lab=r47}
N 500 16920 560 16920 {}
C {devices/lab_pin.sym} 560 16900 0 0 {name=l142 lab=vs}
C {comparator.sym} 600 16910 0 0 {name=Bc47 vhigh=1.8 gain=1e5}
N 640 16910 700 16910 {}
C {devices/lab_pin.sym} 700 16910 0 1 {name=l143 lab=t47}
C {devices/lab_pin.sym} 500 16840 0 1 {name=l144 lab=r48}
N 500 16840 560 16840 {}
C {devices/lab_pin.sym} 560 16820 0 0 {name=l145 lab=vs}
C {comparator.sym} 600 16830 0 0 {name=Bc48 vhigh=1.8 gain=1e5}
N 640 16830 700 16830 {}
C {devices/lab_pin.sym} 700 16830 0 1 {name=l146 lab=t48}
C {devices/lab_pin.sym} 500 16760 0 1 {name=l147 lab=r49}
N 500 16760 560 16760 {}
C {devices/lab_pin.sym} 560 16740 0 0 {name=l148 lab=vs}
C {comparator.sym} 600 16750 0 0 {name=Bc49 vhigh=1.8 gain=1e5}
N 640 16750 700 16750 {}
C {devices/lab_pin.sym} 700 16750 0 1 {name=l149 lab=t49}
C {devices/lab_pin.sym} 500 16680 0 1 {name=l150 lab=r50}
N 500 16680 560 16680 {}
C {devices/lab_pin.sym} 560 16660 0 0 {name=l151 lab=vs}
C {comparator.sym} 600 16670 0 0 {name=Bc50 vhigh=1.8 gain=1e5}
N 640 16670 700 16670 {}
C {devices/lab_pin.sym} 700 16670 0 1 {name=l152 lab=t50}
C {devices/lab_pin.sym} 500 16600 0 1 {name=l153 lab=r51}
N 500 16600 560 16600 {}
C {devices/lab_pin.sym} 560 16580 0 0 {name=l154 lab=vs}
C {comparator.sym} 600 16590 0 0 {name=Bc51 vhigh=1.8 gain=1e5}
N 640 16590 700 16590 {}
C {devices/lab_pin.sym} 700 16590 0 1 {name=l155 lab=t51}
C {devices/lab_pin.sym} 500 16520 0 1 {name=l156 lab=r52}
N 500 16520 560 16520 {}
C {devices/lab_pin.sym} 560 16500 0 0 {name=l157 lab=vs}
C {comparator.sym} 600 16510 0 0 {name=Bc52 vhigh=1.8 gain=1e5}
N 640 16510 700 16510 {}
C {devices/lab_pin.sym} 700 16510 0 1 {name=l158 lab=t52}
C {devices/lab_pin.sym} 500 16440 0 1 {name=l159 lab=r53}
N 500 16440 560 16440 {}
C {devices/lab_pin.sym} 560 16420 0 0 {name=l160 lab=vs}
C {comparator.sym} 600 16430 0 0 {name=Bc53 vhigh=1.8 gain=1e5}
N 640 16430 700 16430 {}
C {devices/lab_pin.sym} 700 16430 0 1 {name=l161 lab=t53}
C {devices/lab_pin.sym} 500 16360 0 1 {name=l162 lab=r54}
N 500 16360 560 16360 {}
C {devices/lab_pin.sym} 560 16340 0 0 {name=l163 lab=vs}
C {comparator.sym} 600 16350 0 0 {name=Bc54 vhigh=1.8 gain=1e5}
N 640 16350 700 16350 {}
C {devices/lab_pin.sym} 700 16350 0 1 {name=l164 lab=t54}
C {devices/lab_pin.sym} 500 16280 0 1 {name=l165 lab=r55}
N 500 16280 560 16280 {}
C {devices/lab_pin.sym} 560 16260 0 0 {name=l166 lab=vs}
C {comparator.sym} 600 16270 0 0 {name=Bc55 vhigh=1.8 gain=1e5}
N 640 16270 700 16270 {}
C {devices/lab_pin.sym} 700 16270 0 1 {name=l167 lab=t55}
C {devices/lab_pin.sym} 500 16200 0 1 {name=l168 lab=r56}
N 500 16200 560 16200 {}
C {devices/lab_pin.sym} 560 16180 0 0 {name=l169 lab=vs}
C {comparator.sym} 600 16190 0 0 {name=Bc56 vhigh=1.8 gain=1e5}
N 640 16190 700 16190 {}
C {devices/lab_pin.sym} 700 16190 0 1 {name=l170 lab=t56}
C {devices/lab_pin.sym} 500 16120 0 1 {name=l171 lab=r57}
N 500 16120 560 16120 {}
C {devices/lab_pin.sym} 560 16100 0 0 {name=l172 lab=vs}
C {comparator.sym} 600 16110 0 0 {name=Bc57 vhigh=1.8 gain=1e5}
N 640 16110 700 16110 {}
C {devices/lab_pin.sym} 700 16110 0 1 {name=l173 lab=t57}
C {devices/lab_pin.sym} 500 16040 0 1 {name=l174 lab=r58}
N 500 16040 560 16040 {}
C {devices/lab_pin.sym} 560 16020 0 0 {name=l175 lab=vs}
C {comparator.sym} 600 16030 0 0 {name=Bc58 vhigh=1.8 gain=1e5}
N 640 16030 700 16030 {}
C {devices/lab_pin.sym} 700 16030 0 1 {name=l176 lab=t58}
C {devices/lab_pin.sym} 500 15960 0 1 {name=l177 lab=r59}
N 500 15960 560 15960 {}
C {devices/lab_pin.sym} 560 15940 0 0 {name=l178 lab=vs}
C {comparator.sym} 600 15950 0 0 {name=Bc59 vhigh=1.8 gain=1e5}
N 640 15950 700 15950 {}
C {devices/lab_pin.sym} 700 15950 0 1 {name=l179 lab=t59}
C {devices/lab_pin.sym} 500 15880 0 1 {name=l180 lab=r60}
N 500 15880 560 15880 {}
C {devices/lab_pin.sym} 560 15860 0 0 {name=l181 lab=vs}
C {comparator.sym} 600 15870 0 0 {name=Bc60 vhigh=1.8 gain=1e5}
N 640 15870 700 15870 {}
C {devices/lab_pin.sym} 700 15870 0 1 {name=l182 lab=t60}
C {devices/lab_pin.sym} 500 15800 0 1 {name=l183 lab=r61}
N 500 15800 560 15800 {}
C {devices/lab_pin.sym} 560 15780 0 0 {name=l184 lab=vs}
C {comparator.sym} 600 15790 0 0 {name=Bc61 vhigh=1.8 gain=1e5}
N 640 15790 700 15790 {}
C {devices/lab_pin.sym} 700 15790 0 1 {name=l185 lab=t61}
C {devices/lab_pin.sym} 500 15720 0 1 {name=l186 lab=r62}
N 500 15720 560 15720 {}
C {devices/lab_pin.sym} 560 15700 0 0 {name=l187 lab=vs}
C {comparator.sym} 600 15710 0 0 {name=Bc62 vhigh=1.8 gain=1e5}
N 640 15710 700 15710 {}
C {devices/lab_pin.sym} 700 15710 0 1 {name=l188 lab=t62}
C {devices/lab_pin.sym} 500 15640 0 1 {name=l189 lab=r63}
N 500 15640 560 15640 {}
C {devices/lab_pin.sym} 560 15620 0 0 {name=l190 lab=vs}
C {comparator.sym} 600 15630 0 0 {name=Bc63 vhigh=1.8 gain=1e5}
N 640 15630 700 15630 {}
C {devices/lab_pin.sym} 700 15630 0 1 {name=l191 lab=t63}
C {devices/lab_pin.sym} 500 15560 0 1 {name=l192 lab=r64}
N 500 15560 560 15560 {}
C {devices/lab_pin.sym} 560 15540 0 0 {name=l193 lab=vs}
C {comparator.sym} 600 15550 0 0 {name=Bc64 vhigh=1.8 gain=1e5}
N 640 15550 700 15550 {}
C {devices/lab_pin.sym} 700 15550 0 1 {name=l194 lab=t64}
C {devices/lab_pin.sym} 500 15480 0 1 {name=l195 lab=r65}
N 500 15480 560 15480 {}
C {devices/lab_pin.sym} 560 15460 0 0 {name=l196 lab=vs}
C {comparator.sym} 600 15470 0 0 {name=Bc65 vhigh=1.8 gain=1e5}
N 640 15470 700 15470 {}
C {devices/lab_pin.sym} 700 15470 0 1 {name=l197 lab=t65}
C {devices/lab_pin.sym} 500 15400 0 1 {name=l198 lab=r66}
N 500 15400 560 15400 {}
C {devices/lab_pin.sym} 560 15380 0 0 {name=l199 lab=vs}
C {comparator.sym} 600 15390 0 0 {name=Bc66 vhigh=1.8 gain=1e5}
N 640 15390 700 15390 {}
C {devices/lab_pin.sym} 700 15390 0 1 {name=l200 lab=t66}
C {devices/lab_pin.sym} 500 15320 0 1 {name=l201 lab=r67}
N 500 15320 560 15320 {}
C {devices/lab_pin.sym} 560 15300 0 0 {name=l202 lab=vs}
C {comparator.sym} 600 15310 0 0 {name=Bc67 vhigh=1.8 gain=1e5}
N 640 15310 700 15310 {}
C {devices/lab_pin.sym} 700 15310 0 1 {name=l203 lab=t67}
C {devices/lab_pin.sym} 500 15240 0 1 {name=l204 lab=r68}
N 500 15240 560 15240 {}
C {devices/lab_pin.sym} 560 15220 0 0 {name=l205 lab=vs}
C {comparator.sym} 600 15230 0 0 {name=Bc68 vhigh=1.8 gain=1e5}
N 640 15230 700 15230 {}
C {devices/lab_pin.sym} 700 15230 0 1 {name=l206 lab=t68}
C {devices/lab_pin.sym} 500 15160 0 1 {name=l207 lab=r69}
N 500 15160 560 15160 {}
C {devices/lab_pin.sym} 560 15140 0 0 {name=l208 lab=vs}
C {comparator.sym} 600 15150 0 0 {name=Bc69 vhigh=1.8 gain=1e5}
N 640 15150 700 15150 {}
C {devices/lab_pin.sym} 700 15150 0 1 {name=l209 lab=t69}
C {devices/lab_pin.sym} 500 15080 0 1 {name=l210 lab=r70}
N 500 15080 560 15080 {}
C {devices/lab_pin.sym} 560 15060 0 0 {name=l211 lab=vs}
C {comparator.sym} 600 15070 0 0 {name=Bc70 vhigh=1.8 gain=1e5}
N 640 15070 700 15070 {}
C {devices/lab_pin.sym} 700 15070 0 1 {name=l212 lab=t70}
C {devices/lab_pin.sym} 500 15000 0 1 {name=l213 lab=r71}
N 500 15000 560 15000 {}
C {devices/lab_pin.sym} 560 14980 0 0 {name=l214 lab=vs}
C {comparator.sym} 600 14990 0 0 {name=Bc71 vhigh=1.8 gain=1e5}
N 640 14990 700 14990 {}
C {devices/lab_pin.sym} 700 14990 0 1 {name=l215 lab=t71}
C {devices/lab_pin.sym} 500 14920 0 1 {name=l216 lab=r72}
N 500 14920 560 14920 {}
C {devices/lab_pin.sym} 560 14900 0 0 {name=l217 lab=vs}
C {comparator.sym} 600 14910 0 0 {name=Bc72 vhigh=1.8 gain=1e5}
N 640 14910 700 14910 {}
C {devices/lab_pin.sym} 700 14910 0 1 {name=l218 lab=t72}
C {devices/lab_pin.sym} 500 14840 0 1 {name=l219 lab=r73}
N 500 14840 560 14840 {}
C {devices/lab_pin.sym} 560 14820 0 0 {name=l220 lab=vs}
C {comparator.sym} 600 14830 0 0 {name=Bc73 vhigh=1.8 gain=1e5}
N 640 14830 700 14830 {}
C {devices/lab_pin.sym} 700 14830 0 1 {name=l221 lab=t73}
C {devices/lab_pin.sym} 500 14760 0 1 {name=l222 lab=r74}
N 500 14760 560 14760 {}
C {devices/lab_pin.sym} 560 14740 0 0 {name=l223 lab=vs}
C {comparator.sym} 600 14750 0 0 {name=Bc74 vhigh=1.8 gain=1e5}
N 640 14750 700 14750 {}
C {devices/lab_pin.sym} 700 14750 0 1 {name=l224 lab=t74}
C {devices/lab_pin.sym} 500 14680 0 1 {name=l225 lab=r75}
N 500 14680 560 14680 {}
C {devices/lab_pin.sym} 560 14660 0 0 {name=l226 lab=vs}
C {comparator.sym} 600 14670 0 0 {name=Bc75 vhigh=1.8 gain=1e5}
N 640 14670 700 14670 {}
C {devices/lab_pin.sym} 700 14670 0 1 {name=l227 lab=t75}
C {devices/lab_pin.sym} 500 14600 0 1 {name=l228 lab=r76}
N 500 14600 560 14600 {}
C {devices/lab_pin.sym} 560 14580 0 0 {name=l229 lab=vs}
C {comparator.sym} 600 14590 0 0 {name=Bc76 vhigh=1.8 gain=1e5}
N 640 14590 700 14590 {}
C {devices/lab_pin.sym} 700 14590 0 1 {name=l230 lab=t76}
C {devices/lab_pin.sym} 500 14520 0 1 {name=l231 lab=r77}
N 500 14520 560 14520 {}
C {devices/lab_pin.sym} 560 14500 0 0 {name=l232 lab=vs}
C {comparator.sym} 600 14510 0 0 {name=Bc77 vhigh=1.8 gain=1e5}
N 640 14510 700 14510 {}
C {devices/lab_pin.sym} 700 14510 0 1 {name=l233 lab=t77}
C {devices/lab_pin.sym} 500 14440 0 1 {name=l234 lab=r78}
N 500 14440 560 14440 {}
C {devices/lab_pin.sym} 560 14420 0 0 {name=l235 lab=vs}
C {comparator.sym} 600 14430 0 0 {name=Bc78 vhigh=1.8 gain=1e5}
N 640 14430 700 14430 {}
C {devices/lab_pin.sym} 700 14430 0 1 {name=l236 lab=t78}
C {devices/lab_pin.sym} 500 14360 0 1 {name=l237 lab=r79}
N 500 14360 560 14360 {}
C {devices/lab_pin.sym} 560 14340 0 0 {name=l238 lab=vs}
C {comparator.sym} 600 14350 0 0 {name=Bc79 vhigh=1.8 gain=1e5}
N 640 14350 700 14350 {}
C {devices/lab_pin.sym} 700 14350 0 1 {name=l239 lab=t79}
C {devices/lab_pin.sym} 500 14280 0 1 {name=l240 lab=r80}
N 500 14280 560 14280 {}
C {devices/lab_pin.sym} 560 14260 0 0 {name=l241 lab=vs}
C {comparator.sym} 600 14270 0 0 {name=Bc80 vhigh=1.8 gain=1e5}
N 640 14270 700 14270 {}
C {devices/lab_pin.sym} 700 14270 0 1 {name=l242 lab=t80}
C {devices/lab_pin.sym} 500 14200 0 1 {name=l243 lab=r81}
N 500 14200 560 14200 {}
C {devices/lab_pin.sym} 560 14180 0 0 {name=l244 lab=vs}
C {comparator.sym} 600 14190 0 0 {name=Bc81 vhigh=1.8 gain=1e5}
N 640 14190 700 14190 {}
C {devices/lab_pin.sym} 700 14190 0 1 {name=l245 lab=t81}
C {devices/lab_pin.sym} 500 14120 0 1 {name=l246 lab=r82}
N 500 14120 560 14120 {}
C {devices/lab_pin.sym} 560 14100 0 0 {name=l247 lab=vs}
C {comparator.sym} 600 14110 0 0 {name=Bc82 vhigh=1.8 gain=1e5}
N 640 14110 700 14110 {}
C {devices/lab_pin.sym} 700 14110 0 1 {name=l248 lab=t82}
C {devices/lab_pin.sym} 500 14040 0 1 {name=l249 lab=r83}
N 500 14040 560 14040 {}
C {devices/lab_pin.sym} 560 14020 0 0 {name=l250 lab=vs}
C {comparator.sym} 600 14030 0 0 {name=Bc83 vhigh=1.8 gain=1e5}
N 640 14030 700 14030 {}
C {devices/lab_pin.sym} 700 14030 0 1 {name=l251 lab=t83}
C {devices/lab_pin.sym} 500 13960 0 1 {name=l252 lab=r84}
N 500 13960 560 13960 {}
C {devices/lab_pin.sym} 560 13940 0 0 {name=l253 lab=vs}
C {comparator.sym} 600 13950 0 0 {name=Bc84 vhigh=1.8 gain=1e5}
N 640 13950 700 13950 {}
C {devices/lab_pin.sym} 700 13950 0 1 {name=l254 lab=t84}
C {devices/lab_pin.sym} 500 13880 0 1 {name=l255 lab=r85}
N 500 13880 560 13880 {}
C {devices/lab_pin.sym} 560 13860 0 0 {name=l256 lab=vs}
C {comparator.sym} 600 13870 0 0 {name=Bc85 vhigh=1.8 gain=1e5}
N 640 13870 700 13870 {}
C {devices/lab_pin.sym} 700 13870 0 1 {name=l257 lab=t85}
C {devices/lab_pin.sym} 500 13800 0 1 {name=l258 lab=r86}
N 500 13800 560 13800 {}
C {devices/lab_pin.sym} 560 13780 0 0 {name=l259 lab=vs}
C {comparator.sym} 600 13790 0 0 {name=Bc86 vhigh=1.8 gain=1e5}
N 640 13790 700 13790 {}
C {devices/lab_pin.sym} 700 13790 0 1 {name=l260 lab=t86}
C {devices/lab_pin.sym} 500 13720 0 1 {name=l261 lab=r87}
N 500 13720 560 13720 {}
C {devices/lab_pin.sym} 560 13700 0 0 {name=l262 lab=vs}
C {comparator.sym} 600 13710 0 0 {name=Bc87 vhigh=1.8 gain=1e5}
N 640 13710 700 13710 {}
C {devices/lab_pin.sym} 700 13710 0 1 {name=l263 lab=t87}
C {devices/lab_pin.sym} 500 13640 0 1 {name=l264 lab=r88}
N 500 13640 560 13640 {}
C {devices/lab_pin.sym} 560 13620 0 0 {name=l265 lab=vs}
C {comparator.sym} 600 13630 0 0 {name=Bc88 vhigh=1.8 gain=1e5}
N 640 13630 700 13630 {}
C {devices/lab_pin.sym} 700 13630 0 1 {name=l266 lab=t88}
C {devices/lab_pin.sym} 500 13560 0 1 {name=l267 lab=r89}
N 500 13560 560 13560 {}
C {devices/lab_pin.sym} 560 13540 0 0 {name=l268 lab=vs}
C {comparator.sym} 600 13550 0 0 {name=Bc89 vhigh=1.8 gain=1e5}
N 640 13550 700 13550 {}
C {devices/lab_pin.sym} 700 13550 0 1 {name=l269 lab=t89}
C {devices/lab_pin.sym} 500 13480 0 1 {name=l270 lab=r90}
N 500 13480 560 13480 {}
C {devices/lab_pin.sym} 560 13460 0 0 {name=l271 lab=vs}
C {comparator.sym} 600 13470 0 0 {name=Bc90 vhigh=1.8 gain=1e5}
N 640 13470 700 13470 {}
C {devices/lab_pin.sym} 700 13470 0 1 {name=l272 lab=t90}
C {devices/lab_pin.sym} 500 13400 0 1 {name=l273 lab=r91}
N 500 13400 560 13400 {}
C {devices/lab_pin.sym} 560 13380 0 0 {name=l274 lab=vs}
C {comparator.sym} 600 13390 0 0 {name=Bc91 vhigh=1.8 gain=1e5}
N 640 13390 700 13390 {}
C {devices/lab_pin.sym} 700 13390 0 1 {name=l275 lab=t91}
C {devices/lab_pin.sym} 500 13320 0 1 {name=l276 lab=r92}
N 500 13320 560 13320 {}
C {devices/lab_pin.sym} 560 13300 0 0 {name=l277 lab=vs}
C {comparator.sym} 600 13310 0 0 {name=Bc92 vhigh=1.8 gain=1e5}
N 640 13310 700 13310 {}
C {devices/lab_pin.sym} 700 13310 0 1 {name=l278 lab=t92}
C {devices/lab_pin.sym} 500 13240 0 1 {name=l279 lab=r93}
N 500 13240 560 13240 {}
C {devices/lab_pin.sym} 560 13220 0 0 {name=l280 lab=vs}
C {comparator.sym} 600 13230 0 0 {name=Bc93 vhigh=1.8 gain=1e5}
N 640 13230 700 13230 {}
C {devices/lab_pin.sym} 700 13230 0 1 {name=l281 lab=t93}
C {devices/lab_pin.sym} 500 13160 0 1 {name=l282 lab=r94}
N 500 13160 560 13160 {}
C {devices/lab_pin.sym} 560 13140 0 0 {name=l283 lab=vs}
C {comparator.sym} 600 13150 0 0 {name=Bc94 vhigh=1.8 gain=1e5}
N 640 13150 700 13150 {}
C {devices/lab_pin.sym} 700 13150 0 1 {name=l284 lab=t94}
C {devices/lab_pin.sym} 500 13080 0 1 {name=l285 lab=r95}
N 500 13080 560 13080 {}
C {devices/lab_pin.sym} 560 13060 0 0 {name=l286 lab=vs}
C {comparator.sym} 600 13070 0 0 {name=Bc95 vhigh=1.8 gain=1e5}
N 640 13070 700 13070 {}
C {devices/lab_pin.sym} 700 13070 0 1 {name=l287 lab=t95}
C {devices/lab_pin.sym} 500 13000 0 1 {name=l288 lab=r96}
N 500 13000 560 13000 {}
C {devices/lab_pin.sym} 560 12980 0 0 {name=l289 lab=vs}
C {comparator.sym} 600 12990 0 0 {name=Bc96 vhigh=1.8 gain=1e5}
N 640 12990 700 12990 {}
C {devices/lab_pin.sym} 700 12990 0 1 {name=l290 lab=t96}
C {devices/lab_pin.sym} 500 12920 0 1 {name=l291 lab=r97}
N 500 12920 560 12920 {}
C {devices/lab_pin.sym} 560 12900 0 0 {name=l292 lab=vs}
C {comparator.sym} 600 12910 0 0 {name=Bc97 vhigh=1.8 gain=1e5}
N 640 12910 700 12910 {}
C {devices/lab_pin.sym} 700 12910 0 1 {name=l293 lab=t97}
C {devices/lab_pin.sym} 500 12840 0 1 {name=l294 lab=r98}
N 500 12840 560 12840 {}
C {devices/lab_pin.sym} 560 12820 0 0 {name=l295 lab=vs}
C {comparator.sym} 600 12830 0 0 {name=Bc98 vhigh=1.8 gain=1e5}
N 640 12830 700 12830 {}
C {devices/lab_pin.sym} 700 12830 0 1 {name=l296 lab=t98}
C {devices/lab_pin.sym} 500 12760 0 1 {name=l297 lab=r99}
N 500 12760 560 12760 {}
C {devices/lab_pin.sym} 560 12740 0 0 {name=l298 lab=vs}
C {comparator.sym} 600 12750 0 0 {name=Bc99 vhigh=1.8 gain=1e5}
N 640 12750 700 12750 {}
C {devices/lab_pin.sym} 700 12750 0 1 {name=l299 lab=t99}
C {devices/lab_pin.sym} 500 12680 0 1 {name=l300 lab=r100}
N 500 12680 560 12680 {}
C {devices/lab_pin.sym} 560 12660 0 0 {name=l301 lab=vs}
C {comparator.sym} 600 12670 0 0 {name=Bc100 vhigh=1.8 gain=1e5}
N 640 12670 700 12670 {}
C {devices/lab_pin.sym} 700 12670 0 1 {name=l302 lab=t100}
C {devices/lab_pin.sym} 500 12600 0 1 {name=l303 lab=r101}
N 500 12600 560 12600 {}
C {devices/lab_pin.sym} 560 12580 0 0 {name=l304 lab=vs}
C {comparator.sym} 600 12590 0 0 {name=Bc101 vhigh=1.8 gain=1e5}
N 640 12590 700 12590 {}
C {devices/lab_pin.sym} 700 12590 0 1 {name=l305 lab=t101}
C {devices/lab_pin.sym} 500 12520 0 1 {name=l306 lab=r102}
N 500 12520 560 12520 {}
C {devices/lab_pin.sym} 560 12500 0 0 {name=l307 lab=vs}
C {comparator.sym} 600 12510 0 0 {name=Bc102 vhigh=1.8 gain=1e5}
N 640 12510 700 12510 {}
C {devices/lab_pin.sym} 700 12510 0 1 {name=l308 lab=t102}
C {devices/lab_pin.sym} 500 12440 0 1 {name=l309 lab=r103}
N 500 12440 560 12440 {}
C {devices/lab_pin.sym} 560 12420 0 0 {name=l310 lab=vs}
C {comparator.sym} 600 12430 0 0 {name=Bc103 vhigh=1.8 gain=1e5}
N 640 12430 700 12430 {}
C {devices/lab_pin.sym} 700 12430 0 1 {name=l311 lab=t103}
C {devices/lab_pin.sym} 500 12360 0 1 {name=l312 lab=r104}
N 500 12360 560 12360 {}
C {devices/lab_pin.sym} 560 12340 0 0 {name=l313 lab=vs}
C {comparator.sym} 600 12350 0 0 {name=Bc104 vhigh=1.8 gain=1e5}
N 640 12350 700 12350 {}
C {devices/lab_pin.sym} 700 12350 0 1 {name=l314 lab=t104}
C {devices/lab_pin.sym} 500 12280 0 1 {name=l315 lab=r105}
N 500 12280 560 12280 {}
C {devices/lab_pin.sym} 560 12260 0 0 {name=l316 lab=vs}
C {comparator.sym} 600 12270 0 0 {name=Bc105 vhigh=1.8 gain=1e5}
N 640 12270 700 12270 {}
C {devices/lab_pin.sym} 700 12270 0 1 {name=l317 lab=t105}
C {devices/lab_pin.sym} 500 12200 0 1 {name=l318 lab=r106}
N 500 12200 560 12200 {}
C {devices/lab_pin.sym} 560 12180 0 0 {name=l319 lab=vs}
C {comparator.sym} 600 12190 0 0 {name=Bc106 vhigh=1.8 gain=1e5}
N 640 12190 700 12190 {}
C {devices/lab_pin.sym} 700 12190 0 1 {name=l320 lab=t106}
C {devices/lab_pin.sym} 500 12120 0 1 {name=l321 lab=r107}
N 500 12120 560 12120 {}
C {devices/lab_pin.sym} 560 12100 0 0 {name=l322 lab=vs}
C {comparator.sym} 600 12110 0 0 {name=Bc107 vhigh=1.8 gain=1e5}
N 640 12110 700 12110 {}
C {devices/lab_pin.sym} 700 12110 0 1 {name=l323 lab=t107}
C {devices/lab_pin.sym} 500 12040 0 1 {name=l324 lab=r108}
N 500 12040 560 12040 {}
C {devices/lab_pin.sym} 560 12020 0 0 {name=l325 lab=vs}
C {comparator.sym} 600 12030 0 0 {name=Bc108 vhigh=1.8 gain=1e5}
N 640 12030 700 12030 {}
C {devices/lab_pin.sym} 700 12030 0 1 {name=l326 lab=t108}
C {devices/lab_pin.sym} 500 11960 0 1 {name=l327 lab=r109}
N 500 11960 560 11960 {}
C {devices/lab_pin.sym} 560 11940 0 0 {name=l328 lab=vs}
C {comparator.sym} 600 11950 0 0 {name=Bc109 vhigh=1.8 gain=1e5}
N 640 11950 700 11950 {}
C {devices/lab_pin.sym} 700 11950 0 1 {name=l329 lab=t109}
C {devices/lab_pin.sym} 500 11880 0 1 {name=l330 lab=r110}
N 500 11880 560 11880 {}
C {devices/lab_pin.sym} 560 11860 0 0 {name=l331 lab=vs}
C {comparator.sym} 600 11870 0 0 {name=Bc110 vhigh=1.8 gain=1e5}
N 640 11870 700 11870 {}
C {devices/lab_pin.sym} 700 11870 0 1 {name=l332 lab=t110}
C {devices/lab_pin.sym} 500 11800 0 1 {name=l333 lab=r111}
N 500 11800 560 11800 {}
C {devices/lab_pin.sym} 560 11780 0 0 {name=l334 lab=vs}
C {comparator.sym} 600 11790 0 0 {name=Bc111 vhigh=1.8 gain=1e5}
N 640 11790 700 11790 {}
C {devices/lab_pin.sym} 700 11790 0 1 {name=l335 lab=t111}
C {devices/lab_pin.sym} 500 11720 0 1 {name=l336 lab=r112}
N 500 11720 560 11720 {}
C {devices/lab_pin.sym} 560 11700 0 0 {name=l337 lab=vs}
C {comparator.sym} 600 11710 0 0 {name=Bc112 vhigh=1.8 gain=1e5}
N 640 11710 700 11710 {}
C {devices/lab_pin.sym} 700 11710 0 1 {name=l338 lab=t112}
C {devices/lab_pin.sym} 500 11640 0 1 {name=l339 lab=r113}
N 500 11640 560 11640 {}
C {devices/lab_pin.sym} 560 11620 0 0 {name=l340 lab=vs}
C {comparator.sym} 600 11630 0 0 {name=Bc113 vhigh=1.8 gain=1e5}
N 640 11630 700 11630 {}
C {devices/lab_pin.sym} 700 11630 0 1 {name=l341 lab=t113}
C {devices/lab_pin.sym} 500 11560 0 1 {name=l342 lab=r114}
N 500 11560 560 11560 {}
C {devices/lab_pin.sym} 560 11540 0 0 {name=l343 lab=vs}
C {comparator.sym} 600 11550 0 0 {name=Bc114 vhigh=1.8 gain=1e5}
N 640 11550 700 11550 {}
C {devices/lab_pin.sym} 700 11550 0 1 {name=l344 lab=t114}
C {devices/lab_pin.sym} 500 11480 0 1 {name=l345 lab=r115}
N 500 11480 560 11480 {}
C {devices/lab_pin.sym} 560 11460 0 0 {name=l346 lab=vs}
C {comparator.sym} 600 11470 0 0 {name=Bc115 vhigh=1.8 gain=1e5}
N 640 11470 700 11470 {}
C {devices/lab_pin.sym} 700 11470 0 1 {name=l347 lab=t115}
C {devices/lab_pin.sym} 500 11400 0 1 {name=l348 lab=r116}
N 500 11400 560 11400 {}
C {devices/lab_pin.sym} 560 11380 0 0 {name=l349 lab=vs}
C {comparator.sym} 600 11390 0 0 {name=Bc116 vhigh=1.8 gain=1e5}
N 640 11390 700 11390 {}
C {devices/lab_pin.sym} 700 11390 0 1 {name=l350 lab=t116}
C {devices/lab_pin.sym} 500 11320 0 1 {name=l351 lab=r117}
N 500 11320 560 11320 {}
C {devices/lab_pin.sym} 560 11300 0 0 {name=l352 lab=vs}
C {comparator.sym} 600 11310 0 0 {name=Bc117 vhigh=1.8 gain=1e5}
N 640 11310 700 11310 {}
C {devices/lab_pin.sym} 700 11310 0 1 {name=l353 lab=t117}
C {devices/lab_pin.sym} 500 11240 0 1 {name=l354 lab=r118}
N 500 11240 560 11240 {}
C {devices/lab_pin.sym} 560 11220 0 0 {name=l355 lab=vs}
C {comparator.sym} 600 11230 0 0 {name=Bc118 vhigh=1.8 gain=1e5}
N 640 11230 700 11230 {}
C {devices/lab_pin.sym} 700 11230 0 1 {name=l356 lab=t118}
C {devices/lab_pin.sym} 500 11160 0 1 {name=l357 lab=r119}
N 500 11160 560 11160 {}
C {devices/lab_pin.sym} 560 11140 0 0 {name=l358 lab=vs}
C {comparator.sym} 600 11150 0 0 {name=Bc119 vhigh=1.8 gain=1e5}
N 640 11150 700 11150 {}
C {devices/lab_pin.sym} 700 11150 0 1 {name=l359 lab=t119}
C {devices/lab_pin.sym} 500 11080 0 1 {name=l360 lab=r120}
N 500 11080 560 11080 {}
C {devices/lab_pin.sym} 560 11060 0 0 {name=l361 lab=vs}
C {comparator.sym} 600 11070 0 0 {name=Bc120 vhigh=1.8 gain=1e5}
N 640 11070 700 11070 {}
C {devices/lab_pin.sym} 700 11070 0 1 {name=l362 lab=t120}
C {devices/lab_pin.sym} 500 11000 0 1 {name=l363 lab=r121}
N 500 11000 560 11000 {}
C {devices/lab_pin.sym} 560 10980 0 0 {name=l364 lab=vs}
C {comparator.sym} 600 10990 0 0 {name=Bc121 vhigh=1.8 gain=1e5}
N 640 10990 700 10990 {}
C {devices/lab_pin.sym} 700 10990 0 1 {name=l365 lab=t121}
C {devices/lab_pin.sym} 500 10920 0 1 {name=l366 lab=r122}
N 500 10920 560 10920 {}
C {devices/lab_pin.sym} 560 10900 0 0 {name=l367 lab=vs}
C {comparator.sym} 600 10910 0 0 {name=Bc122 vhigh=1.8 gain=1e5}
N 640 10910 700 10910 {}
C {devices/lab_pin.sym} 700 10910 0 1 {name=l368 lab=t122}
C {devices/lab_pin.sym} 500 10840 0 1 {name=l369 lab=r123}
N 500 10840 560 10840 {}
C {devices/lab_pin.sym} 560 10820 0 0 {name=l370 lab=vs}
C {comparator.sym} 600 10830 0 0 {name=Bc123 vhigh=1.8 gain=1e5}
N 640 10830 700 10830 {}
C {devices/lab_pin.sym} 700 10830 0 1 {name=l371 lab=t123}
C {devices/lab_pin.sym} 500 10760 0 1 {name=l372 lab=r124}
N 500 10760 560 10760 {}
C {devices/lab_pin.sym} 560 10740 0 0 {name=l373 lab=vs}
C {comparator.sym} 600 10750 0 0 {name=Bc124 vhigh=1.8 gain=1e5}
N 640 10750 700 10750 {}
C {devices/lab_pin.sym} 700 10750 0 1 {name=l374 lab=t124}
C {devices/lab_pin.sym} 500 10680 0 1 {name=l375 lab=r125}
N 500 10680 560 10680 {}
C {devices/lab_pin.sym} 560 10660 0 0 {name=l376 lab=vs}
C {comparator.sym} 600 10670 0 0 {name=Bc125 vhigh=1.8 gain=1e5}
N 640 10670 700 10670 {}
C {devices/lab_pin.sym} 700 10670 0 1 {name=l377 lab=t125}
C {devices/lab_pin.sym} 500 10600 0 1 {name=l378 lab=r126}
N 500 10600 560 10600 {}
C {devices/lab_pin.sym} 560 10580 0 0 {name=l379 lab=vs}
C {comparator.sym} 600 10590 0 0 {name=Bc126 vhigh=1.8 gain=1e5}
N 640 10590 700 10590 {}
C {devices/lab_pin.sym} 700 10590 0 1 {name=l380 lab=t126}
C {devices/lab_pin.sym} 500 10520 0 1 {name=l381 lab=r127}
N 500 10520 560 10520 {}
C {devices/lab_pin.sym} 560 10500 0 0 {name=l382 lab=vs}
C {comparator.sym} 600 10510 0 0 {name=Bc127 vhigh=1.8 gain=1e5}
N 640 10510 700 10510 {}
C {devices/lab_pin.sym} 700 10510 0 1 {name=l383 lab=t127}
C {devices/lab_pin.sym} 500 10440 0 1 {name=l384 lab=r128}
N 500 10440 560 10440 {}
C {devices/lab_pin.sym} 560 10420 0 0 {name=l385 lab=vs}
C {comparator.sym} 600 10430 0 0 {name=Bc128 vhigh=1.8 gain=1e5}
N 640 10430 700 10430 {}
C {devices/lab_pin.sym} 700 10430 0 1 {name=l386 lab=t128}
C {devices/lab_pin.sym} 500 10360 0 1 {name=l387 lab=r129}
N 500 10360 560 10360 {}
C {devices/lab_pin.sym} 560 10340 0 0 {name=l388 lab=vs}
C {comparator.sym} 600 10350 0 0 {name=Bc129 vhigh=1.8 gain=1e5}
N 640 10350 700 10350 {}
C {devices/lab_pin.sym} 700 10350 0 1 {name=l389 lab=t129}
C {devices/lab_pin.sym} 500 10280 0 1 {name=l390 lab=r130}
N 500 10280 560 10280 {}
C {devices/lab_pin.sym} 560 10260 0 0 {name=l391 lab=vs}
C {comparator.sym} 600 10270 0 0 {name=Bc130 vhigh=1.8 gain=1e5}
N 640 10270 700 10270 {}
C {devices/lab_pin.sym} 700 10270 0 1 {name=l392 lab=t130}
C {devices/lab_pin.sym} 500 10200 0 1 {name=l393 lab=r131}
N 500 10200 560 10200 {}
C {devices/lab_pin.sym} 560 10180 0 0 {name=l394 lab=vs}
C {comparator.sym} 600 10190 0 0 {name=Bc131 vhigh=1.8 gain=1e5}
N 640 10190 700 10190 {}
C {devices/lab_pin.sym} 700 10190 0 1 {name=l395 lab=t131}
C {devices/lab_pin.sym} 500 10120 0 1 {name=l396 lab=r132}
N 500 10120 560 10120 {}
C {devices/lab_pin.sym} 560 10100 0 0 {name=l397 lab=vs}
C {comparator.sym} 600 10110 0 0 {name=Bc132 vhigh=1.8 gain=1e5}
N 640 10110 700 10110 {}
C {devices/lab_pin.sym} 700 10110 0 1 {name=l398 lab=t132}
C {devices/lab_pin.sym} 500 10040 0 1 {name=l399 lab=r133}
N 500 10040 560 10040 {}
C {devices/lab_pin.sym} 560 10020 0 0 {name=l400 lab=vs}
C {comparator.sym} 600 10030 0 0 {name=Bc133 vhigh=1.8 gain=1e5}
N 640 10030 700 10030 {}
C {devices/lab_pin.sym} 700 10030 0 1 {name=l401 lab=t133}
C {devices/lab_pin.sym} 500 9960 0 1 {name=l402 lab=r134}
N 500 9960 560 9960 {}
C {devices/lab_pin.sym} 560 9940 0 0 {name=l403 lab=vs}
C {comparator.sym} 600 9950 0 0 {name=Bc134 vhigh=1.8 gain=1e5}
N 640 9950 700 9950 {}
C {devices/lab_pin.sym} 700 9950 0 1 {name=l404 lab=t134}
C {devices/lab_pin.sym} 500 9880 0 1 {name=l405 lab=r135}
N 500 9880 560 9880 {}
C {devices/lab_pin.sym} 560 9860 0 0 {name=l406 lab=vs}
C {comparator.sym} 600 9870 0 0 {name=Bc135 vhigh=1.8 gain=1e5}
N 640 9870 700 9870 {}
C {devices/lab_pin.sym} 700 9870 0 1 {name=l407 lab=t135}
C {devices/lab_pin.sym} 500 9800 0 1 {name=l408 lab=r136}
N 500 9800 560 9800 {}
C {devices/lab_pin.sym} 560 9780 0 0 {name=l409 lab=vs}
C {comparator.sym} 600 9790 0 0 {name=Bc136 vhigh=1.8 gain=1e5}
N 640 9790 700 9790 {}
C {devices/lab_pin.sym} 700 9790 0 1 {name=l410 lab=t136}
C {devices/lab_pin.sym} 500 9720 0 1 {name=l411 lab=r137}
N 500 9720 560 9720 {}
C {devices/lab_pin.sym} 560 9700 0 0 {name=l412 lab=vs}
C {comparator.sym} 600 9710 0 0 {name=Bc137 vhigh=1.8 gain=1e5}
N 640 9710 700 9710 {}
C {devices/lab_pin.sym} 700 9710 0 1 {name=l413 lab=t137}
C {devices/lab_pin.sym} 500 9640 0 1 {name=l414 lab=r138}
N 500 9640 560 9640 {}
C {devices/lab_pin.sym} 560 9620 0 0 {name=l415 lab=vs}
C {comparator.sym} 600 9630 0 0 {name=Bc138 vhigh=1.8 gain=1e5}
N 640 9630 700 9630 {}
C {devices/lab_pin.sym} 700 9630 0 1 {name=l416 lab=t138}
C {devices/lab_pin.sym} 500 9560 0 1 {name=l417 lab=r139}
N 500 9560 560 9560 {}
C {devices/lab_pin.sym} 560 9540 0 0 {name=l418 lab=vs}
C {comparator.sym} 600 9550 0 0 {name=Bc139 vhigh=1.8 gain=1e5}
N 640 9550 700 9550 {}
C {devices/lab_pin.sym} 700 9550 0 1 {name=l419 lab=t139}
C {devices/lab_pin.sym} 500 9480 0 1 {name=l420 lab=r140}
N 500 9480 560 9480 {}
C {devices/lab_pin.sym} 560 9460 0 0 {name=l421 lab=vs}
C {comparator.sym} 600 9470 0 0 {name=Bc140 vhigh=1.8 gain=1e5}
N 640 9470 700 9470 {}
C {devices/lab_pin.sym} 700 9470 0 1 {name=l422 lab=t140}
C {devices/lab_pin.sym} 500 9400 0 1 {name=l423 lab=r141}
N 500 9400 560 9400 {}
C {devices/lab_pin.sym} 560 9380 0 0 {name=l424 lab=vs}
C {comparator.sym} 600 9390 0 0 {name=Bc141 vhigh=1.8 gain=1e5}
N 640 9390 700 9390 {}
C {devices/lab_pin.sym} 700 9390 0 1 {name=l425 lab=t141}
C {devices/lab_pin.sym} 500 9320 0 1 {name=l426 lab=r142}
N 500 9320 560 9320 {}
C {devices/lab_pin.sym} 560 9300 0 0 {name=l427 lab=vs}
C {comparator.sym} 600 9310 0 0 {name=Bc142 vhigh=1.8 gain=1e5}
N 640 9310 700 9310 {}
C {devices/lab_pin.sym} 700 9310 0 1 {name=l428 lab=t142}
C {devices/lab_pin.sym} 500 9240 0 1 {name=l429 lab=r143}
N 500 9240 560 9240 {}
C {devices/lab_pin.sym} 560 9220 0 0 {name=l430 lab=vs}
C {comparator.sym} 600 9230 0 0 {name=Bc143 vhigh=1.8 gain=1e5}
N 640 9230 700 9230 {}
C {devices/lab_pin.sym} 700 9230 0 1 {name=l431 lab=t143}
C {devices/lab_pin.sym} 500 9160 0 1 {name=l432 lab=r144}
N 500 9160 560 9160 {}
C {devices/lab_pin.sym} 560 9140 0 0 {name=l433 lab=vs}
C {comparator.sym} 600 9150 0 0 {name=Bc144 vhigh=1.8 gain=1e5}
N 640 9150 700 9150 {}
C {devices/lab_pin.sym} 700 9150 0 1 {name=l434 lab=t144}
C {devices/lab_pin.sym} 500 9080 0 1 {name=l435 lab=r145}
N 500 9080 560 9080 {}
C {devices/lab_pin.sym} 560 9060 0 0 {name=l436 lab=vs}
C {comparator.sym} 600 9070 0 0 {name=Bc145 vhigh=1.8 gain=1e5}
N 640 9070 700 9070 {}
C {devices/lab_pin.sym} 700 9070 0 1 {name=l437 lab=t145}
C {devices/lab_pin.sym} 500 9000 0 1 {name=l438 lab=r146}
N 500 9000 560 9000 {}
C {devices/lab_pin.sym} 560 8980 0 0 {name=l439 lab=vs}
C {comparator.sym} 600 8990 0 0 {name=Bc146 vhigh=1.8 gain=1e5}
N 640 8990 700 8990 {}
C {devices/lab_pin.sym} 700 8990 0 1 {name=l440 lab=t146}
C {devices/lab_pin.sym} 500 8920 0 1 {name=l441 lab=r147}
N 500 8920 560 8920 {}
C {devices/lab_pin.sym} 560 8900 0 0 {name=l442 lab=vs}
C {comparator.sym} 600 8910 0 0 {name=Bc147 vhigh=1.8 gain=1e5}
N 640 8910 700 8910 {}
C {devices/lab_pin.sym} 700 8910 0 1 {name=l443 lab=t147}
C {devices/lab_pin.sym} 500 8840 0 1 {name=l444 lab=r148}
N 500 8840 560 8840 {}
C {devices/lab_pin.sym} 560 8820 0 0 {name=l445 lab=vs}
C {comparator.sym} 600 8830 0 0 {name=Bc148 vhigh=1.8 gain=1e5}
N 640 8830 700 8830 {}
C {devices/lab_pin.sym} 700 8830 0 1 {name=l446 lab=t148}
C {devices/lab_pin.sym} 500 8760 0 1 {name=l447 lab=r149}
N 500 8760 560 8760 {}
C {devices/lab_pin.sym} 560 8740 0 0 {name=l448 lab=vs}
C {comparator.sym} 600 8750 0 0 {name=Bc149 vhigh=1.8 gain=1e5}
N 640 8750 700 8750 {}
C {devices/lab_pin.sym} 700 8750 0 1 {name=l449 lab=t149}
C {devices/lab_pin.sym} 500 8680 0 1 {name=l450 lab=r150}
N 500 8680 560 8680 {}
C {devices/lab_pin.sym} 560 8660 0 0 {name=l451 lab=vs}
C {comparator.sym} 600 8670 0 0 {name=Bc150 vhigh=1.8 gain=1e5}
N 640 8670 700 8670 {}
C {devices/lab_pin.sym} 700 8670 0 1 {name=l452 lab=t150}
C {devices/lab_pin.sym} 500 8600 0 1 {name=l453 lab=r151}
N 500 8600 560 8600 {}
C {devices/lab_pin.sym} 560 8580 0 0 {name=l454 lab=vs}
C {comparator.sym} 600 8590 0 0 {name=Bc151 vhigh=1.8 gain=1e5}
N 640 8590 700 8590 {}
C {devices/lab_pin.sym} 700 8590 0 1 {name=l455 lab=t151}
C {devices/lab_pin.sym} 500 8520 0 1 {name=l456 lab=r152}
N 500 8520 560 8520 {}
C {devices/lab_pin.sym} 560 8500 0 0 {name=l457 lab=vs}
C {comparator.sym} 600 8510 0 0 {name=Bc152 vhigh=1.8 gain=1e5}
N 640 8510 700 8510 {}
C {devices/lab_pin.sym} 700 8510 0 1 {name=l458 lab=t152}
C {devices/lab_pin.sym} 500 8440 0 1 {name=l459 lab=r153}
N 500 8440 560 8440 {}
C {devices/lab_pin.sym} 560 8420 0 0 {name=l460 lab=vs}
C {comparator.sym} 600 8430 0 0 {name=Bc153 vhigh=1.8 gain=1e5}
N 640 8430 700 8430 {}
C {devices/lab_pin.sym} 700 8430 0 1 {name=l461 lab=t153}
C {devices/lab_pin.sym} 500 8360 0 1 {name=l462 lab=r154}
N 500 8360 560 8360 {}
C {devices/lab_pin.sym} 560 8340 0 0 {name=l463 lab=vs}
C {comparator.sym} 600 8350 0 0 {name=Bc154 vhigh=1.8 gain=1e5}
N 640 8350 700 8350 {}
C {devices/lab_pin.sym} 700 8350 0 1 {name=l464 lab=t154}
C {devices/lab_pin.sym} 500 8280 0 1 {name=l465 lab=r155}
N 500 8280 560 8280 {}
C {devices/lab_pin.sym} 560 8260 0 0 {name=l466 lab=vs}
C {comparator.sym} 600 8270 0 0 {name=Bc155 vhigh=1.8 gain=1e5}
N 640 8270 700 8270 {}
C {devices/lab_pin.sym} 700 8270 0 1 {name=l467 lab=t155}
C {devices/lab_pin.sym} 500 8200 0 1 {name=l468 lab=r156}
N 500 8200 560 8200 {}
C {devices/lab_pin.sym} 560 8180 0 0 {name=l469 lab=vs}
C {comparator.sym} 600 8190 0 0 {name=Bc156 vhigh=1.8 gain=1e5}
N 640 8190 700 8190 {}
C {devices/lab_pin.sym} 700 8190 0 1 {name=l470 lab=t156}
C {devices/lab_pin.sym} 500 8120 0 1 {name=l471 lab=r157}
N 500 8120 560 8120 {}
C {devices/lab_pin.sym} 560 8100 0 0 {name=l472 lab=vs}
C {comparator.sym} 600 8110 0 0 {name=Bc157 vhigh=1.8 gain=1e5}
N 640 8110 700 8110 {}
C {devices/lab_pin.sym} 700 8110 0 1 {name=l473 lab=t157}
C {devices/lab_pin.sym} 500 8040 0 1 {name=l474 lab=r158}
N 500 8040 560 8040 {}
C {devices/lab_pin.sym} 560 8020 0 0 {name=l475 lab=vs}
C {comparator.sym} 600 8030 0 0 {name=Bc158 vhigh=1.8 gain=1e5}
N 640 8030 700 8030 {}
C {devices/lab_pin.sym} 700 8030 0 1 {name=l476 lab=t158}
C {devices/lab_pin.sym} 500 7960 0 1 {name=l477 lab=r159}
N 500 7960 560 7960 {}
C {devices/lab_pin.sym} 560 7940 0 0 {name=l478 lab=vs}
C {comparator.sym} 600 7950 0 0 {name=Bc159 vhigh=1.8 gain=1e5}
N 640 7950 700 7950 {}
C {devices/lab_pin.sym} 700 7950 0 1 {name=l479 lab=t159}
C {devices/lab_pin.sym} 500 7880 0 1 {name=l480 lab=r160}
N 500 7880 560 7880 {}
C {devices/lab_pin.sym} 560 7860 0 0 {name=l481 lab=vs}
C {comparator.sym} 600 7870 0 0 {name=Bc160 vhigh=1.8 gain=1e5}
N 640 7870 700 7870 {}
C {devices/lab_pin.sym} 700 7870 0 1 {name=l482 lab=t160}
C {devices/lab_pin.sym} 500 7800 0 1 {name=l483 lab=r161}
N 500 7800 560 7800 {}
C {devices/lab_pin.sym} 560 7780 0 0 {name=l484 lab=vs}
C {comparator.sym} 600 7790 0 0 {name=Bc161 vhigh=1.8 gain=1e5}
N 640 7790 700 7790 {}
C {devices/lab_pin.sym} 700 7790 0 1 {name=l485 lab=t161}
C {devices/lab_pin.sym} 500 7720 0 1 {name=l486 lab=r162}
N 500 7720 560 7720 {}
C {devices/lab_pin.sym} 560 7700 0 0 {name=l487 lab=vs}
C {comparator.sym} 600 7710 0 0 {name=Bc162 vhigh=1.8 gain=1e5}
N 640 7710 700 7710 {}
C {devices/lab_pin.sym} 700 7710 0 1 {name=l488 lab=t162}
C {devices/lab_pin.sym} 500 7640 0 1 {name=l489 lab=r163}
N 500 7640 560 7640 {}
C {devices/lab_pin.sym} 560 7620 0 0 {name=l490 lab=vs}
C {comparator.sym} 600 7630 0 0 {name=Bc163 vhigh=1.8 gain=1e5}
N 640 7630 700 7630 {}
C {devices/lab_pin.sym} 700 7630 0 1 {name=l491 lab=t163}
C {devices/lab_pin.sym} 500 7560 0 1 {name=l492 lab=r164}
N 500 7560 560 7560 {}
C {devices/lab_pin.sym} 560 7540 0 0 {name=l493 lab=vs}
C {comparator.sym} 600 7550 0 0 {name=Bc164 vhigh=1.8 gain=1e5}
N 640 7550 700 7550 {}
C {devices/lab_pin.sym} 700 7550 0 1 {name=l494 lab=t164}
C {devices/lab_pin.sym} 500 7480 0 1 {name=l495 lab=r165}
N 500 7480 560 7480 {}
C {devices/lab_pin.sym} 560 7460 0 0 {name=l496 lab=vs}
C {comparator.sym} 600 7470 0 0 {name=Bc165 vhigh=1.8 gain=1e5}
N 640 7470 700 7470 {}
C {devices/lab_pin.sym} 700 7470 0 1 {name=l497 lab=t165}
C {devices/lab_pin.sym} 500 7400 0 1 {name=l498 lab=r166}
N 500 7400 560 7400 {}
C {devices/lab_pin.sym} 560 7380 0 0 {name=l499 lab=vs}
C {comparator.sym} 600 7390 0 0 {name=Bc166 vhigh=1.8 gain=1e5}
N 640 7390 700 7390 {}
C {devices/lab_pin.sym} 700 7390 0 1 {name=l500 lab=t166}
C {devices/lab_pin.sym} 500 7320 0 1 {name=l501 lab=r167}
N 500 7320 560 7320 {}
C {devices/lab_pin.sym} 560 7300 0 0 {name=l502 lab=vs}
C {comparator.sym} 600 7310 0 0 {name=Bc167 vhigh=1.8 gain=1e5}
N 640 7310 700 7310 {}
C {devices/lab_pin.sym} 700 7310 0 1 {name=l503 lab=t167}
C {devices/lab_pin.sym} 500 7240 0 1 {name=l504 lab=r168}
N 500 7240 560 7240 {}
C {devices/lab_pin.sym} 560 7220 0 0 {name=l505 lab=vs}
C {comparator.sym} 600 7230 0 0 {name=Bc168 vhigh=1.8 gain=1e5}
N 640 7230 700 7230 {}
C {devices/lab_pin.sym} 700 7230 0 1 {name=l506 lab=t168}
C {devices/lab_pin.sym} 500 7160 0 1 {name=l507 lab=r169}
N 500 7160 560 7160 {}
C {devices/lab_pin.sym} 560 7140 0 0 {name=l508 lab=vs}
C {comparator.sym} 600 7150 0 0 {name=Bc169 vhigh=1.8 gain=1e5}
N 640 7150 700 7150 {}
C {devices/lab_pin.sym} 700 7150 0 1 {name=l509 lab=t169}
C {devices/lab_pin.sym} 500 7080 0 1 {name=l510 lab=r170}
N 500 7080 560 7080 {}
C {devices/lab_pin.sym} 560 7060 0 0 {name=l511 lab=vs}
C {comparator.sym} 600 7070 0 0 {name=Bc170 vhigh=1.8 gain=1e5}
N 640 7070 700 7070 {}
C {devices/lab_pin.sym} 700 7070 0 1 {name=l512 lab=t170}
C {devices/lab_pin.sym} 500 7000 0 1 {name=l513 lab=r171}
N 500 7000 560 7000 {}
C {devices/lab_pin.sym} 560 6980 0 0 {name=l514 lab=vs}
C {comparator.sym} 600 6990 0 0 {name=Bc171 vhigh=1.8 gain=1e5}
N 640 6990 700 6990 {}
C {devices/lab_pin.sym} 700 6990 0 1 {name=l515 lab=t171}
C {devices/lab_pin.sym} 500 6920 0 1 {name=l516 lab=r172}
N 500 6920 560 6920 {}
C {devices/lab_pin.sym} 560 6900 0 0 {name=l517 lab=vs}
C {comparator.sym} 600 6910 0 0 {name=Bc172 vhigh=1.8 gain=1e5}
N 640 6910 700 6910 {}
C {devices/lab_pin.sym} 700 6910 0 1 {name=l518 lab=t172}
C {devices/lab_pin.sym} 500 6840 0 1 {name=l519 lab=r173}
N 500 6840 560 6840 {}
C {devices/lab_pin.sym} 560 6820 0 0 {name=l520 lab=vs}
C {comparator.sym} 600 6830 0 0 {name=Bc173 vhigh=1.8 gain=1e5}
N 640 6830 700 6830 {}
C {devices/lab_pin.sym} 700 6830 0 1 {name=l521 lab=t173}
C {devices/lab_pin.sym} 500 6760 0 1 {name=l522 lab=r174}
N 500 6760 560 6760 {}
C {devices/lab_pin.sym} 560 6740 0 0 {name=l523 lab=vs}
C {comparator.sym} 600 6750 0 0 {name=Bc174 vhigh=1.8 gain=1e5}
N 640 6750 700 6750 {}
C {devices/lab_pin.sym} 700 6750 0 1 {name=l524 lab=t174}
C {devices/lab_pin.sym} 500 6680 0 1 {name=l525 lab=r175}
N 500 6680 560 6680 {}
C {devices/lab_pin.sym} 560 6660 0 0 {name=l526 lab=vs}
C {comparator.sym} 600 6670 0 0 {name=Bc175 vhigh=1.8 gain=1e5}
N 640 6670 700 6670 {}
C {devices/lab_pin.sym} 700 6670 0 1 {name=l527 lab=t175}
C {devices/lab_pin.sym} 500 6600 0 1 {name=l528 lab=r176}
N 500 6600 560 6600 {}
C {devices/lab_pin.sym} 560 6580 0 0 {name=l529 lab=vs}
C {comparator.sym} 600 6590 0 0 {name=Bc176 vhigh=1.8 gain=1e5}
N 640 6590 700 6590 {}
C {devices/lab_pin.sym} 700 6590 0 1 {name=l530 lab=t176}
C {devices/lab_pin.sym} 500 6520 0 1 {name=l531 lab=r177}
N 500 6520 560 6520 {}
C {devices/lab_pin.sym} 560 6500 0 0 {name=l532 lab=vs}
C {comparator.sym} 600 6510 0 0 {name=Bc177 vhigh=1.8 gain=1e5}
N 640 6510 700 6510 {}
C {devices/lab_pin.sym} 700 6510 0 1 {name=l533 lab=t177}
C {devices/lab_pin.sym} 500 6440 0 1 {name=l534 lab=r178}
N 500 6440 560 6440 {}
C {devices/lab_pin.sym} 560 6420 0 0 {name=l535 lab=vs}
C {comparator.sym} 600 6430 0 0 {name=Bc178 vhigh=1.8 gain=1e5}
N 640 6430 700 6430 {}
C {devices/lab_pin.sym} 700 6430 0 1 {name=l536 lab=t178}
C {devices/lab_pin.sym} 500 6360 0 1 {name=l537 lab=r179}
N 500 6360 560 6360 {}
C {devices/lab_pin.sym} 560 6340 0 0 {name=l538 lab=vs}
C {comparator.sym} 600 6350 0 0 {name=Bc179 vhigh=1.8 gain=1e5}
N 640 6350 700 6350 {}
C {devices/lab_pin.sym} 700 6350 0 1 {name=l539 lab=t179}
C {devices/lab_pin.sym} 500 6280 0 1 {name=l540 lab=r180}
N 500 6280 560 6280 {}
C {devices/lab_pin.sym} 560 6260 0 0 {name=l541 lab=vs}
C {comparator.sym} 600 6270 0 0 {name=Bc180 vhigh=1.8 gain=1e5}
N 640 6270 700 6270 {}
C {devices/lab_pin.sym} 700 6270 0 1 {name=l542 lab=t180}
C {devices/lab_pin.sym} 500 6200 0 1 {name=l543 lab=r181}
N 500 6200 560 6200 {}
C {devices/lab_pin.sym} 560 6180 0 0 {name=l544 lab=vs}
C {comparator.sym} 600 6190 0 0 {name=Bc181 vhigh=1.8 gain=1e5}
N 640 6190 700 6190 {}
C {devices/lab_pin.sym} 700 6190 0 1 {name=l545 lab=t181}
C {devices/lab_pin.sym} 500 6120 0 1 {name=l546 lab=r182}
N 500 6120 560 6120 {}
C {devices/lab_pin.sym} 560 6100 0 0 {name=l547 lab=vs}
C {comparator.sym} 600 6110 0 0 {name=Bc182 vhigh=1.8 gain=1e5}
N 640 6110 700 6110 {}
C {devices/lab_pin.sym} 700 6110 0 1 {name=l548 lab=t182}
C {devices/lab_pin.sym} 500 6040 0 1 {name=l549 lab=r183}
N 500 6040 560 6040 {}
C {devices/lab_pin.sym} 560 6020 0 0 {name=l550 lab=vs}
C {comparator.sym} 600 6030 0 0 {name=Bc183 vhigh=1.8 gain=1e5}
N 640 6030 700 6030 {}
C {devices/lab_pin.sym} 700 6030 0 1 {name=l551 lab=t183}
C {devices/lab_pin.sym} 500 5960 0 1 {name=l552 lab=r184}
N 500 5960 560 5960 {}
C {devices/lab_pin.sym} 560 5940 0 0 {name=l553 lab=vs}
C {comparator.sym} 600 5950 0 0 {name=Bc184 vhigh=1.8 gain=1e5}
N 640 5950 700 5950 {}
C {devices/lab_pin.sym} 700 5950 0 1 {name=l554 lab=t184}
C {devices/lab_pin.sym} 500 5880 0 1 {name=l555 lab=r185}
N 500 5880 560 5880 {}
C {devices/lab_pin.sym} 560 5860 0 0 {name=l556 lab=vs}
C {comparator.sym} 600 5870 0 0 {name=Bc185 vhigh=1.8 gain=1e5}
N 640 5870 700 5870 {}
C {devices/lab_pin.sym} 700 5870 0 1 {name=l557 lab=t185}
C {devices/lab_pin.sym} 500 5800 0 1 {name=l558 lab=r186}
N 500 5800 560 5800 {}
C {devices/lab_pin.sym} 560 5780 0 0 {name=l559 lab=vs}
C {comparator.sym} 600 5790 0 0 {name=Bc186 vhigh=1.8 gain=1e5}
N 640 5790 700 5790 {}
C {devices/lab_pin.sym} 700 5790 0 1 {name=l560 lab=t186}
C {devices/lab_pin.sym} 500 5720 0 1 {name=l561 lab=r187}
N 500 5720 560 5720 {}
C {devices/lab_pin.sym} 560 5700 0 0 {name=l562 lab=vs}
C {comparator.sym} 600 5710 0 0 {name=Bc187 vhigh=1.8 gain=1e5}
N 640 5710 700 5710 {}
C {devices/lab_pin.sym} 700 5710 0 1 {name=l563 lab=t187}
C {devices/lab_pin.sym} 500 5640 0 1 {name=l564 lab=r188}
N 500 5640 560 5640 {}
C {devices/lab_pin.sym} 560 5620 0 0 {name=l565 lab=vs}
C {comparator.sym} 600 5630 0 0 {name=Bc188 vhigh=1.8 gain=1e5}
N 640 5630 700 5630 {}
C {devices/lab_pin.sym} 700 5630 0 1 {name=l566 lab=t188}
C {devices/lab_pin.sym} 500 5560 0 1 {name=l567 lab=r189}
N 500 5560 560 5560 {}
C {devices/lab_pin.sym} 560 5540 0 0 {name=l568 lab=vs}
C {comparator.sym} 600 5550 0 0 {name=Bc189 vhigh=1.8 gain=1e5}
N 640 5550 700 5550 {}
C {devices/lab_pin.sym} 700 5550 0 1 {name=l569 lab=t189}
C {devices/lab_pin.sym} 500 5480 0 1 {name=l570 lab=r190}
N 500 5480 560 5480 {}
C {devices/lab_pin.sym} 560 5460 0 0 {name=l571 lab=vs}
C {comparator.sym} 600 5470 0 0 {name=Bc190 vhigh=1.8 gain=1e5}
N 640 5470 700 5470 {}
C {devices/lab_pin.sym} 700 5470 0 1 {name=l572 lab=t190}
C {devices/lab_pin.sym} 500 5400 0 1 {name=l573 lab=r191}
N 500 5400 560 5400 {}
C {devices/lab_pin.sym} 560 5380 0 0 {name=l574 lab=vs}
C {comparator.sym} 600 5390 0 0 {name=Bc191 vhigh=1.8 gain=1e5}
N 640 5390 700 5390 {}
C {devices/lab_pin.sym} 700 5390 0 1 {name=l575 lab=t191}
C {devices/lab_pin.sym} 500 5320 0 1 {name=l576 lab=r192}
N 500 5320 560 5320 {}
C {devices/lab_pin.sym} 560 5300 0 0 {name=l577 lab=vs}
C {comparator.sym} 600 5310 0 0 {name=Bc192 vhigh=1.8 gain=1e5}
N 640 5310 700 5310 {}
C {devices/lab_pin.sym} 700 5310 0 1 {name=l578 lab=t192}
C {devices/lab_pin.sym} 500 5240 0 1 {name=l579 lab=r193}
N 500 5240 560 5240 {}
C {devices/lab_pin.sym} 560 5220 0 0 {name=l580 lab=vs}
C {comparator.sym} 600 5230 0 0 {name=Bc193 vhigh=1.8 gain=1e5}
N 640 5230 700 5230 {}
C {devices/lab_pin.sym} 700 5230 0 1 {name=l581 lab=t193}
C {devices/lab_pin.sym} 500 5160 0 1 {name=l582 lab=r194}
N 500 5160 560 5160 {}
C {devices/lab_pin.sym} 560 5140 0 0 {name=l583 lab=vs}
C {comparator.sym} 600 5150 0 0 {name=Bc194 vhigh=1.8 gain=1e5}
N 640 5150 700 5150 {}
C {devices/lab_pin.sym} 700 5150 0 1 {name=l584 lab=t194}
C {devices/lab_pin.sym} 500 5080 0 1 {name=l585 lab=r195}
N 500 5080 560 5080 {}
C {devices/lab_pin.sym} 560 5060 0 0 {name=l586 lab=vs}
C {comparator.sym} 600 5070 0 0 {name=Bc195 vhigh=1.8 gain=1e5}
N 640 5070 700 5070 {}
C {devices/lab_pin.sym} 700 5070 0 1 {name=l587 lab=t195}
C {devices/lab_pin.sym} 500 5000 0 1 {name=l588 lab=r196}
N 500 5000 560 5000 {}
C {devices/lab_pin.sym} 560 4980 0 0 {name=l589 lab=vs}
C {comparator.sym} 600 4990 0 0 {name=Bc196 vhigh=1.8 gain=1e5}
N 640 4990 700 4990 {}
C {devices/lab_pin.sym} 700 4990 0 1 {name=l590 lab=t196}
C {devices/lab_pin.sym} 500 4920 0 1 {name=l591 lab=r197}
N 500 4920 560 4920 {}
C {devices/lab_pin.sym} 560 4900 0 0 {name=l592 lab=vs}
C {comparator.sym} 600 4910 0 0 {name=Bc197 vhigh=1.8 gain=1e5}
N 640 4910 700 4910 {}
C {devices/lab_pin.sym} 700 4910 0 1 {name=l593 lab=t197}
C {devices/lab_pin.sym} 500 4840 0 1 {name=l594 lab=r198}
N 500 4840 560 4840 {}
C {devices/lab_pin.sym} 560 4820 0 0 {name=l595 lab=vs}
C {comparator.sym} 600 4830 0 0 {name=Bc198 vhigh=1.8 gain=1e5}
N 640 4830 700 4830 {}
C {devices/lab_pin.sym} 700 4830 0 1 {name=l596 lab=t198}
C {devices/lab_pin.sym} 500 4760 0 1 {name=l597 lab=r199}
N 500 4760 560 4760 {}
C {devices/lab_pin.sym} 560 4740 0 0 {name=l598 lab=vs}
C {comparator.sym} 600 4750 0 0 {name=Bc199 vhigh=1.8 gain=1e5}
N 640 4750 700 4750 {}
C {devices/lab_pin.sym} 700 4750 0 1 {name=l599 lab=t199}
C {devices/lab_pin.sym} 500 4680 0 1 {name=l600 lab=r200}
N 500 4680 560 4680 {}
C {devices/lab_pin.sym} 560 4660 0 0 {name=l601 lab=vs}
C {comparator.sym} 600 4670 0 0 {name=Bc200 vhigh=1.8 gain=1e5}
N 640 4670 700 4670 {}
C {devices/lab_pin.sym} 700 4670 0 1 {name=l602 lab=t200}
C {devices/lab_pin.sym} 500 4600 0 1 {name=l603 lab=r201}
N 500 4600 560 4600 {}
C {devices/lab_pin.sym} 560 4580 0 0 {name=l604 lab=vs}
C {comparator.sym} 600 4590 0 0 {name=Bc201 vhigh=1.8 gain=1e5}
N 640 4590 700 4590 {}
C {devices/lab_pin.sym} 700 4590 0 1 {name=l605 lab=t201}
C {devices/lab_pin.sym} 500 4520 0 1 {name=l606 lab=r202}
N 500 4520 560 4520 {}
C {devices/lab_pin.sym} 560 4500 0 0 {name=l607 lab=vs}
C {comparator.sym} 600 4510 0 0 {name=Bc202 vhigh=1.8 gain=1e5}
N 640 4510 700 4510 {}
C {devices/lab_pin.sym} 700 4510 0 1 {name=l608 lab=t202}
C {devices/lab_pin.sym} 500 4440 0 1 {name=l609 lab=r203}
N 500 4440 560 4440 {}
C {devices/lab_pin.sym} 560 4420 0 0 {name=l610 lab=vs}
C {comparator.sym} 600 4430 0 0 {name=Bc203 vhigh=1.8 gain=1e5}
N 640 4430 700 4430 {}
C {devices/lab_pin.sym} 700 4430 0 1 {name=l611 lab=t203}
C {devices/lab_pin.sym} 500 4360 0 1 {name=l612 lab=r204}
N 500 4360 560 4360 {}
C {devices/lab_pin.sym} 560 4340 0 0 {name=l613 lab=vs}
C {comparator.sym} 600 4350 0 0 {name=Bc204 vhigh=1.8 gain=1e5}
N 640 4350 700 4350 {}
C {devices/lab_pin.sym} 700 4350 0 1 {name=l614 lab=t204}
C {devices/lab_pin.sym} 500 4280 0 1 {name=l615 lab=r205}
N 500 4280 560 4280 {}
C {devices/lab_pin.sym} 560 4260 0 0 {name=l616 lab=vs}
C {comparator.sym} 600 4270 0 0 {name=Bc205 vhigh=1.8 gain=1e5}
N 640 4270 700 4270 {}
C {devices/lab_pin.sym} 700 4270 0 1 {name=l617 lab=t205}
C {devices/lab_pin.sym} 500 4200 0 1 {name=l618 lab=r206}
N 500 4200 560 4200 {}
C {devices/lab_pin.sym} 560 4180 0 0 {name=l619 lab=vs}
C {comparator.sym} 600 4190 0 0 {name=Bc206 vhigh=1.8 gain=1e5}
N 640 4190 700 4190 {}
C {devices/lab_pin.sym} 700 4190 0 1 {name=l620 lab=t206}
C {devices/lab_pin.sym} 500 4120 0 1 {name=l621 lab=r207}
N 500 4120 560 4120 {}
C {devices/lab_pin.sym} 560 4100 0 0 {name=l622 lab=vs}
C {comparator.sym} 600 4110 0 0 {name=Bc207 vhigh=1.8 gain=1e5}
N 640 4110 700 4110 {}
C {devices/lab_pin.sym} 700 4110 0 1 {name=l623 lab=t207}
C {devices/lab_pin.sym} 500 4040 0 1 {name=l624 lab=r208}
N 500 4040 560 4040 {}
C {devices/lab_pin.sym} 560 4020 0 0 {name=l625 lab=vs}
C {comparator.sym} 600 4030 0 0 {name=Bc208 vhigh=1.8 gain=1e5}
N 640 4030 700 4030 {}
C {devices/lab_pin.sym} 700 4030 0 1 {name=l626 lab=t208}
C {devices/lab_pin.sym} 500 3960 0 1 {name=l627 lab=r209}
N 500 3960 560 3960 {}
C {devices/lab_pin.sym} 560 3940 0 0 {name=l628 lab=vs}
C {comparator.sym} 600 3950 0 0 {name=Bc209 vhigh=1.8 gain=1e5}
N 640 3950 700 3950 {}
C {devices/lab_pin.sym} 700 3950 0 1 {name=l629 lab=t209}
C {devices/lab_pin.sym} 500 3880 0 1 {name=l630 lab=r210}
N 500 3880 560 3880 {}
C {devices/lab_pin.sym} 560 3860 0 0 {name=l631 lab=vs}
C {comparator.sym} 600 3870 0 0 {name=Bc210 vhigh=1.8 gain=1e5}
N 640 3870 700 3870 {}
C {devices/lab_pin.sym} 700 3870 0 1 {name=l632 lab=t210}
C {devices/lab_pin.sym} 500 3800 0 1 {name=l633 lab=r211}
N 500 3800 560 3800 {}
C {devices/lab_pin.sym} 560 3780 0 0 {name=l634 lab=vs}
C {comparator.sym} 600 3790 0 0 {name=Bc211 vhigh=1.8 gain=1e5}
N 640 3790 700 3790 {}
C {devices/lab_pin.sym} 700 3790 0 1 {name=l635 lab=t211}
C {devices/lab_pin.sym} 500 3720 0 1 {name=l636 lab=r212}
N 500 3720 560 3720 {}
C {devices/lab_pin.sym} 560 3700 0 0 {name=l637 lab=vs}
C {comparator.sym} 600 3710 0 0 {name=Bc212 vhigh=1.8 gain=1e5}
N 640 3710 700 3710 {}
C {devices/lab_pin.sym} 700 3710 0 1 {name=l638 lab=t212}
C {devices/lab_pin.sym} 500 3640 0 1 {name=l639 lab=r213}
N 500 3640 560 3640 {}
C {devices/lab_pin.sym} 560 3620 0 0 {name=l640 lab=vs}
C {comparator.sym} 600 3630 0 0 {name=Bc213 vhigh=1.8 gain=1e5}
N 640 3630 700 3630 {}
C {devices/lab_pin.sym} 700 3630 0 1 {name=l641 lab=t213}
C {devices/lab_pin.sym} 500 3560 0 1 {name=l642 lab=r214}
N 500 3560 560 3560 {}
C {devices/lab_pin.sym} 560 3540 0 0 {name=l643 lab=vs}
C {comparator.sym} 600 3550 0 0 {name=Bc214 vhigh=1.8 gain=1e5}
N 640 3550 700 3550 {}
C {devices/lab_pin.sym} 700 3550 0 1 {name=l644 lab=t214}
C {devices/lab_pin.sym} 500 3480 0 1 {name=l645 lab=r215}
N 500 3480 560 3480 {}
C {devices/lab_pin.sym} 560 3460 0 0 {name=l646 lab=vs}
C {comparator.sym} 600 3470 0 0 {name=Bc215 vhigh=1.8 gain=1e5}
N 640 3470 700 3470 {}
C {devices/lab_pin.sym} 700 3470 0 1 {name=l647 lab=t215}
C {devices/lab_pin.sym} 500 3400 0 1 {name=l648 lab=r216}
N 500 3400 560 3400 {}
C {devices/lab_pin.sym} 560 3380 0 0 {name=l649 lab=vs}
C {comparator.sym} 600 3390 0 0 {name=Bc216 vhigh=1.8 gain=1e5}
N 640 3390 700 3390 {}
C {devices/lab_pin.sym} 700 3390 0 1 {name=l650 lab=t216}
C {devices/lab_pin.sym} 500 3320 0 1 {name=l651 lab=r217}
N 500 3320 560 3320 {}
C {devices/lab_pin.sym} 560 3300 0 0 {name=l652 lab=vs}
C {comparator.sym} 600 3310 0 0 {name=Bc217 vhigh=1.8 gain=1e5}
N 640 3310 700 3310 {}
C {devices/lab_pin.sym} 700 3310 0 1 {name=l653 lab=t217}
C {devices/lab_pin.sym} 500 3240 0 1 {name=l654 lab=r218}
N 500 3240 560 3240 {}
C {devices/lab_pin.sym} 560 3220 0 0 {name=l655 lab=vs}
C {comparator.sym} 600 3230 0 0 {name=Bc218 vhigh=1.8 gain=1e5}
N 640 3230 700 3230 {}
C {devices/lab_pin.sym} 700 3230 0 1 {name=l656 lab=t218}
C {devices/lab_pin.sym} 500 3160 0 1 {name=l657 lab=r219}
N 500 3160 560 3160 {}
C {devices/lab_pin.sym} 560 3140 0 0 {name=l658 lab=vs}
C {comparator.sym} 600 3150 0 0 {name=Bc219 vhigh=1.8 gain=1e5}
N 640 3150 700 3150 {}
C {devices/lab_pin.sym} 700 3150 0 1 {name=l659 lab=t219}
C {devices/lab_pin.sym} 500 3080 0 1 {name=l660 lab=r220}
N 500 3080 560 3080 {}
C {devices/lab_pin.sym} 560 3060 0 0 {name=l661 lab=vs}
C {comparator.sym} 600 3070 0 0 {name=Bc220 vhigh=1.8 gain=1e5}
N 640 3070 700 3070 {}
C {devices/lab_pin.sym} 700 3070 0 1 {name=l662 lab=t220}
C {devices/lab_pin.sym} 500 3000 0 1 {name=l663 lab=r221}
N 500 3000 560 3000 {}
C {devices/lab_pin.sym} 560 2980 0 0 {name=l664 lab=vs}
C {comparator.sym} 600 2990 0 0 {name=Bc221 vhigh=1.8 gain=1e5}
N 640 2990 700 2990 {}
C {devices/lab_pin.sym} 700 2990 0 1 {name=l665 lab=t221}
C {devices/lab_pin.sym} 500 2920 0 1 {name=l666 lab=r222}
N 500 2920 560 2920 {}
C {devices/lab_pin.sym} 560 2900 0 0 {name=l667 lab=vs}
C {comparator.sym} 600 2910 0 0 {name=Bc222 vhigh=1.8 gain=1e5}
N 640 2910 700 2910 {}
C {devices/lab_pin.sym} 700 2910 0 1 {name=l668 lab=t222}
C {devices/lab_pin.sym} 500 2840 0 1 {name=l669 lab=r223}
N 500 2840 560 2840 {}
C {devices/lab_pin.sym} 560 2820 0 0 {name=l670 lab=vs}
C {comparator.sym} 600 2830 0 0 {name=Bc223 vhigh=1.8 gain=1e5}
N 640 2830 700 2830 {}
C {devices/lab_pin.sym} 700 2830 0 1 {name=l671 lab=t223}
C {devices/lab_pin.sym} 500 2760 0 1 {name=l672 lab=r224}
N 500 2760 560 2760 {}
C {devices/lab_pin.sym} 560 2740 0 0 {name=l673 lab=vs}
C {comparator.sym} 600 2750 0 0 {name=Bc224 vhigh=1.8 gain=1e5}
N 640 2750 700 2750 {}
C {devices/lab_pin.sym} 700 2750 0 1 {name=l674 lab=t224}
C {devices/lab_pin.sym} 500 2680 0 1 {name=l675 lab=r225}
N 500 2680 560 2680 {}
C {devices/lab_pin.sym} 560 2660 0 0 {name=l676 lab=vs}
C {comparator.sym} 600 2670 0 0 {name=Bc225 vhigh=1.8 gain=1e5}
N 640 2670 700 2670 {}
C {devices/lab_pin.sym} 700 2670 0 1 {name=l677 lab=t225}
C {devices/lab_pin.sym} 500 2600 0 1 {name=l678 lab=r226}
N 500 2600 560 2600 {}
C {devices/lab_pin.sym} 560 2580 0 0 {name=l679 lab=vs}
C {comparator.sym} 600 2590 0 0 {name=Bc226 vhigh=1.8 gain=1e5}
N 640 2590 700 2590 {}
C {devices/lab_pin.sym} 700 2590 0 1 {name=l680 lab=t226}
C {devices/lab_pin.sym} 500 2520 0 1 {name=l681 lab=r227}
N 500 2520 560 2520 {}
C {devices/lab_pin.sym} 560 2500 0 0 {name=l682 lab=vs}
C {comparator.sym} 600 2510 0 0 {name=Bc227 vhigh=1.8 gain=1e5}
N 640 2510 700 2510 {}
C {devices/lab_pin.sym} 700 2510 0 1 {name=l683 lab=t227}
C {devices/lab_pin.sym} 500 2440 0 1 {name=l684 lab=r228}
N 500 2440 560 2440 {}
C {devices/lab_pin.sym} 560 2420 0 0 {name=l685 lab=vs}
C {comparator.sym} 600 2430 0 0 {name=Bc228 vhigh=1.8 gain=1e5}
N 640 2430 700 2430 {}
C {devices/lab_pin.sym} 700 2430 0 1 {name=l686 lab=t228}
C {devices/lab_pin.sym} 500 2360 0 1 {name=l687 lab=r229}
N 500 2360 560 2360 {}
C {devices/lab_pin.sym} 560 2340 0 0 {name=l688 lab=vs}
C {comparator.sym} 600 2350 0 0 {name=Bc229 vhigh=1.8 gain=1e5}
N 640 2350 700 2350 {}
C {devices/lab_pin.sym} 700 2350 0 1 {name=l689 lab=t229}
C {devices/lab_pin.sym} 500 2280 0 1 {name=l690 lab=r230}
N 500 2280 560 2280 {}
C {devices/lab_pin.sym} 560 2260 0 0 {name=l691 lab=vs}
C {comparator.sym} 600 2270 0 0 {name=Bc230 vhigh=1.8 gain=1e5}
N 640 2270 700 2270 {}
C {devices/lab_pin.sym} 700 2270 0 1 {name=l692 lab=t230}
C {devices/lab_pin.sym} 500 2200 0 1 {name=l693 lab=r231}
N 500 2200 560 2200 {}
C {devices/lab_pin.sym} 560 2180 0 0 {name=l694 lab=vs}
C {comparator.sym} 600 2190 0 0 {name=Bc231 vhigh=1.8 gain=1e5}
N 640 2190 700 2190 {}
C {devices/lab_pin.sym} 700 2190 0 1 {name=l695 lab=t231}
C {devices/lab_pin.sym} 500 2120 0 1 {name=l696 lab=r232}
N 500 2120 560 2120 {}
C {devices/lab_pin.sym} 560 2100 0 0 {name=l697 lab=vs}
C {comparator.sym} 600 2110 0 0 {name=Bc232 vhigh=1.8 gain=1e5}
N 640 2110 700 2110 {}
C {devices/lab_pin.sym} 700 2110 0 1 {name=l698 lab=t232}
C {devices/lab_pin.sym} 500 2040 0 1 {name=l699 lab=r233}
N 500 2040 560 2040 {}
C {devices/lab_pin.sym} 560 2020 0 0 {name=l700 lab=vs}
C {comparator.sym} 600 2030 0 0 {name=Bc233 vhigh=1.8 gain=1e5}
N 640 2030 700 2030 {}
C {devices/lab_pin.sym} 700 2030 0 1 {name=l701 lab=t233}
C {devices/lab_pin.sym} 500 1960 0 1 {name=l702 lab=r234}
N 500 1960 560 1960 {}
C {devices/lab_pin.sym} 560 1940 0 0 {name=l703 lab=vs}
C {comparator.sym} 600 1950 0 0 {name=Bc234 vhigh=1.8 gain=1e5}
N 640 1950 700 1950 {}
C {devices/lab_pin.sym} 700 1950 0 1 {name=l704 lab=t234}
C {devices/lab_pin.sym} 500 1880 0 1 {name=l705 lab=r235}
N 500 1880 560 1880 {}
C {devices/lab_pin.sym} 560 1860 0 0 {name=l706 lab=vs}
C {comparator.sym} 600 1870 0 0 {name=Bc235 vhigh=1.8 gain=1e5}
N 640 1870 700 1870 {}
C {devices/lab_pin.sym} 700 1870 0 1 {name=l707 lab=t235}
C {devices/lab_pin.sym} 500 1800 0 1 {name=l708 lab=r236}
N 500 1800 560 1800 {}
C {devices/lab_pin.sym} 560 1780 0 0 {name=l709 lab=vs}
C {comparator.sym} 600 1790 0 0 {name=Bc236 vhigh=1.8 gain=1e5}
N 640 1790 700 1790 {}
C {devices/lab_pin.sym} 700 1790 0 1 {name=l710 lab=t236}
C {devices/lab_pin.sym} 500 1720 0 1 {name=l711 lab=r237}
N 500 1720 560 1720 {}
C {devices/lab_pin.sym} 560 1700 0 0 {name=l712 lab=vs}
C {comparator.sym} 600 1710 0 0 {name=Bc237 vhigh=1.8 gain=1e5}
N 640 1710 700 1710 {}
C {devices/lab_pin.sym} 700 1710 0 1 {name=l713 lab=t237}
C {devices/lab_pin.sym} 500 1640 0 1 {name=l714 lab=r238}
N 500 1640 560 1640 {}
C {devices/lab_pin.sym} 560 1620 0 0 {name=l715 lab=vs}
C {comparator.sym} 600 1630 0 0 {name=Bc238 vhigh=1.8 gain=1e5}
N 640 1630 700 1630 {}
C {devices/lab_pin.sym} 700 1630 0 1 {name=l716 lab=t238}
C {devices/lab_pin.sym} 500 1560 0 1 {name=l717 lab=r239}
N 500 1560 560 1560 {}
C {devices/lab_pin.sym} 560 1540 0 0 {name=l718 lab=vs}
C {comparator.sym} 600 1550 0 0 {name=Bc239 vhigh=1.8 gain=1e5}
N 640 1550 700 1550 {}
C {devices/lab_pin.sym} 700 1550 0 1 {name=l719 lab=t239}
C {devices/lab_pin.sym} 500 1480 0 1 {name=l720 lab=r240}
N 500 1480 560 1480 {}
C {devices/lab_pin.sym} 560 1460 0 0 {name=l721 lab=vs}
C {comparator.sym} 600 1470 0 0 {name=Bc240 vhigh=1.8 gain=1e5}
N 640 1470 700 1470 {}
C {devices/lab_pin.sym} 700 1470 0 1 {name=l722 lab=t240}
C {devices/lab_pin.sym} 500 1400 0 1 {name=l723 lab=r241}
N 500 1400 560 1400 {}
C {devices/lab_pin.sym} 560 1380 0 0 {name=l724 lab=vs}
C {comparator.sym} 600 1390 0 0 {name=Bc241 vhigh=1.8 gain=1e5}
N 640 1390 700 1390 {}
C {devices/lab_pin.sym} 700 1390 0 1 {name=l725 lab=t241}
C {devices/lab_pin.sym} 500 1320 0 1 {name=l726 lab=r242}
N 500 1320 560 1320 {}
C {devices/lab_pin.sym} 560 1300 0 0 {name=l727 lab=vs}
C {comparator.sym} 600 1310 0 0 {name=Bc242 vhigh=1.8 gain=1e5}
N 640 1310 700 1310 {}
C {devices/lab_pin.sym} 700 1310 0 1 {name=l728 lab=t242}
C {devices/lab_pin.sym} 500 1240 0 1 {name=l729 lab=r243}
N 500 1240 560 1240 {}
C {devices/lab_pin.sym} 560 1220 0 0 {name=l730 lab=vs}
C {comparator.sym} 600 1230 0 0 {name=Bc243 vhigh=1.8 gain=1e5}
N 640 1230 700 1230 {}
C {devices/lab_pin.sym} 700 1230 0 1 {name=l731 lab=t243}
C {devices/lab_pin.sym} 500 1160 0 1 {name=l732 lab=r244}
N 500 1160 560 1160 {}
C {devices/lab_pin.sym} 560 1140 0 0 {name=l733 lab=vs}
C {comparator.sym} 600 1150 0 0 {name=Bc244 vhigh=1.8 gain=1e5}
N 640 1150 700 1150 {}
C {devices/lab_pin.sym} 700 1150 0 1 {name=l734 lab=t244}
C {devices/lab_pin.sym} 500 1080 0 1 {name=l735 lab=r245}
N 500 1080 560 1080 {}
C {devices/lab_pin.sym} 560 1060 0 0 {name=l736 lab=vs}
C {comparator.sym} 600 1070 0 0 {name=Bc245 vhigh=1.8 gain=1e5}
N 640 1070 700 1070 {}
C {devices/lab_pin.sym} 700 1070 0 1 {name=l737 lab=t245}
C {devices/lab_pin.sym} 500 1000 0 1 {name=l738 lab=r246}
N 500 1000 560 1000 {}
C {devices/lab_pin.sym} 560 980 0 0 {name=l739 lab=vs}
C {comparator.sym} 600 990 0 0 {name=Bc246 vhigh=1.8 gain=1e5}
N 640 990 700 990 {}
C {devices/lab_pin.sym} 700 990 0 1 {name=l740 lab=t246}
C {devices/lab_pin.sym} 500 920 0 1 {name=l741 lab=r247}
N 500 920 560 920 {}
C {devices/lab_pin.sym} 560 900 0 0 {name=l742 lab=vs}
C {comparator.sym} 600 910 0 0 {name=Bc247 vhigh=1.8 gain=1e5}
N 640 910 700 910 {}
C {devices/lab_pin.sym} 700 910 0 1 {name=l743 lab=t247}
C {devices/lab_pin.sym} 500 840 0 1 {name=l744 lab=r248}
N 500 840 560 840 {}
C {devices/lab_pin.sym} 560 820 0 0 {name=l745 lab=vs}
C {comparator.sym} 600 830 0 0 {name=Bc248 vhigh=1.8 gain=1e5}
N 640 830 700 830 {}
C {devices/lab_pin.sym} 700 830 0 1 {name=l746 lab=t248}
C {devices/lab_pin.sym} 500 760 0 1 {name=l747 lab=r249}
N 500 760 560 760 {}
C {devices/lab_pin.sym} 560 740 0 0 {name=l748 lab=vs}
C {comparator.sym} 600 750 0 0 {name=Bc249 vhigh=1.8 gain=1e5}
N 640 750 700 750 {}
C {devices/lab_pin.sym} 700 750 0 1 {name=l749 lab=t249}
C {devices/lab_pin.sym} 500 680 0 1 {name=l750 lab=r250}
N 500 680 560 680 {}
C {devices/lab_pin.sym} 560 660 0 0 {name=l751 lab=vs}
C {comparator.sym} 600 670 0 0 {name=Bc250 vhigh=1.8 gain=1e5}
N 640 670 700 670 {}
C {devices/lab_pin.sym} 700 670 0 1 {name=l752 lab=t250}
C {devices/lab_pin.sym} 500 600 0 1 {name=l753 lab=r251}
N 500 600 560 600 {}
C {devices/lab_pin.sym} 560 580 0 0 {name=l754 lab=vs}
C {comparator.sym} 600 590 0 0 {name=Bc251 vhigh=1.8 gain=1e5}
N 640 590 700 590 {}
C {devices/lab_pin.sym} 700 590 0 1 {name=l755 lab=t251}
C {devices/lab_pin.sym} 500 520 0 1 {name=l756 lab=r252}
N 500 520 560 520 {}
C {devices/lab_pin.sym} 560 500 0 0 {name=l757 lab=vs}
C {comparator.sym} 600 510 0 0 {name=Bc252 vhigh=1.8 gain=1e5}
N 640 510 700 510 {}
C {devices/lab_pin.sym} 700 510 0 1 {name=l758 lab=t252}
C {devices/lab_pin.sym} 500 440 0 1 {name=l759 lab=r253}
N 500 440 560 440 {}
C {devices/lab_pin.sym} 560 420 0 0 {name=l760 lab=vs}
C {comparator.sym} 600 430 0 0 {name=Bc253 vhigh=1.8 gain=1e5}
N 640 430 700 430 {}
C {devices/lab_pin.sym} 700 430 0 1 {name=l761 lab=t253}
C {devices/lab_pin.sym} 500 360 0 1 {name=l762 lab=r254}
N 500 360 560 360 {}
C {devices/lab_pin.sym} 560 340 0 0 {name=l763 lab=vs}
C {comparator.sym} 600 350 0 0 {name=Bc254 vhigh=1.8 gain=1e5}
N 640 350 700 350 {}
C {devices/lab_pin.sym} 700 350 0 1 {name=l764 lab=t254}
C {devices/lab_pin.sym} 500 280 0 1 {name=l765 lab=r255}
N 500 280 560 280 {}
C {devices/lab_pin.sym} 560 260 0 0 {name=l766 lab=vs}
C {comparator.sym} 600 270 0 0 {name=Bc255 vhigh=1.8 gain=1e5}
N 640 270 700 270 {}
C {devices/lab_pin.sym} 700 270 0 1 {name=l767 lab=t255}
C {devices/bsource.sym} 900 270 0 0 {name=Bcount VAR=V FUNC="u(V(t1)-0.9)+u(V(t2)-0.9)+u(V(t3)-0.9)+u(V(t4)-0.9)+u(V(t5)-0.9)+u(V(t6)-0.9)+u(V(t7)-0.9)+u(V(t8)-0.9)+u(V(t9)-0.9)+u(V(t10)-0.9)+u(V(t11)-0.9)+u(V(t12)-0.9)+u(V(t13)-0.9)+u(V(t14)-0.9)+u(V(t15)-0.9)+u(V(t16)-0.9)+u(V(t17)-0.9)+u(V(t18)-0.9)+u(V(t19)-0.9)+u(V(t20)-0.9)+u(V(t21)-0.9)+u(V(t22)-0.9)+u(V(t23)-0.9)+u(V(t24)-0.9)+u(V(t25)-0.9)+u(V(t26)-0.9)+u(V(t27)-0.9)+u(V(t28)-0.9)+u(V(t29)-0.9)+u(V(t30)-0.9)+u(V(t31)-0.9)+u(V(t32)-0.9)+u(V(t33)-0.9)+u(V(t34)-0.9)+u(V(t35)-0.9)+u(V(t36)-0.9)+u(V(t37)-0.9)+u(V(t38)-0.9)+u(V(t39)-0.9)+u(V(t40)-0.9)+u(V(t41)-0.9)+u(V(t42)-0.9)+u(V(t43)-0.9)+u(V(t44)-0.9)+u(V(t45)-0.9)+u(V(t46)-0.9)+u(V(t47)-0.9)+u(V(t48)-0.9)+u(V(t49)-0.9)+u(V(t50)-0.9)+u(V(t51)-0.9)+u(V(t52)-0.9)+u(V(t53)-0.9)+u(V(t54)-0.9)+u(V(t55)-0.9)+u(V(t56)-0.9)+u(V(t57)-0.9)+u(V(t58)-0.9)+u(V(t59)-0.9)+u(V(t60)-0.9)+u(V(t61)-0.9)+u(V(t62)-0.9)+u(V(t63)-0.9)+u(V(t64)-0.9)+u(V(t65)-0.9)+u(V(t66)-0.9)+u(V(t67)-0.9)+u(V(t68)-0.9)+u(V(t69)-0.9)+u(V(t70)-0.9)+u(V(t71)-0.9)+u(V(t72)-0.9)+u(V(t73)-0.9)+u(V(t74)-0.9)+u(V(t75)-0.9)+u(V(t76)-0.9)+u(V(t77)-0.9)+u(V(t78)-0.9)+u(V(t79)-0.9)+u(V(t80)-0.9)+u(V(t81)-0.9)+u(V(t82)-0.9)+u(V(t83)-0.9)+u(V(t84)-0.9)+u(V(t85)-0.9)+u(V(t86)-0.9)+u(V(t87)-0.9)+u(V(t88)-0.9)+u(V(t89)-0.9)+u(V(t90)-0.9)+u(V(t91)-0.9)+u(V(t92)-0.9)+u(V(t93)-0.9)+u(V(t94)-0.9)+u(V(t95)-0.9)+u(V(t96)-0.9)+u(V(t97)-0.9)+u(V(t98)-0.9)+u(V(t99)-0.9)+u(V(t100)-0.9)+u(V(t101)-0.9)+u(V(t102)-0.9)+u(V(t103)-0.9)+u(V(t104)-0.9)+u(V(t105)-0.9)+u(V(t106)-0.9)+u(V(t107)-0.9)+u(V(t108)-0.9)+u(V(t109)-0.9)+u(V(t110)-0.9)+u(V(t111)-0.9)+u(V(t112)-0.9)+u(V(t113)-0.9)+u(V(t114)-0.9)+u(V(t115)-0.9)+u(V(t116)-0.9)+u(V(t117)-0.9)+u(V(t118)-0.9)+u(V(t119)-0.9)+u(V(t120)-0.9)+u(V(t121)-0.9)+u(V(t122)-0.9)+u(V(t123)-0.9)+u(V(t124)-0.9)+u(V(t125)-0.9)+u(V(t126)-0.9)+u(V(t127)-0.9)+u(V(t128)-0.9)+u(V(t129)-0.9)+u(V(t130)-0.9)+u(V(t131)-0.9)+u(V(t132)-0.9)+u(V(t133)-0.9)+u(V(t134)-0.9)+u(V(t135)-0.9)+u(V(t136)-0.9)+u(V(t137)-0.9)+u(V(t138)-0.9)+u(V(t139)-0.9)+u(V(t140)-0.9)+u(V(t141)-0.9)+u(V(t142)-0.9)+u(V(t143)-0.9)+u(V(t144)-0.9)+u(V(t145)-0.9)+u(V(t146)-0.9)+u(V(t147)-0.9)+u(V(t148)-0.9)+u(V(t149)-0.9)+u(V(t150)-0.9)+u(V(t151)-0.9)+u(V(t152)-0.9)+u(V(t153)-0.9)+u(V(t154)-0.9)+u(V(t155)-0.9)+u(V(t156)-0.9)+u(V(t157)-0.9)+u(V(t158)-0.9)+u(V(t159)-0.9)+u(V(t160)-0.9)+u(V(t161)-0.9)+u(V(t162)-0.9)+u(V(t163)-0.9)+u(V(t164)-0.9)+u(V(t165)-0.9)+u(V(t166)-0.9)+u(V(t167)-0.9)+u(V(t168)-0.9)+u(V(t169)-0.9)+u(V(t170)-0.9)+u(V(t171)-0.9)+u(V(t172)-0.9)+u(V(t173)-0.9)+u(V(t174)-0.9)+u(V(t175)-0.9)+u(V(t176)-0.9)+u(V(t177)-0.9)+u(V(t178)-0.9)+u(V(t179)-0.9)+u(V(t180)-0.9)+u(V(t181)-0.9)+u(V(t182)-0.9)+u(V(t183)-0.9)+u(V(t184)-0.9)+u(V(t185)-0.9)+u(V(t186)-0.9)+u(V(t187)-0.9)+u(V(t188)-0.9)+u(V(t189)-0.9)+u(V(t190)-0.9)+u(V(t191)-0.9)+u(V(t192)-0.9)+u(V(t193)-0.9)+u(V(t194)-0.9)+u(V(t195)-0.9)+u(V(t196)-0.9)+u(V(t197)-0.9)+u(V(t198)-0.9)+u(V(t199)-0.9)+u(V(t200)-0.9)+u(V(t201)-0.9)+u(V(t202)-0.9)+u(V(t203)-0.9)+u(V(t204)-0.9)+u(V(t205)-0.9)+u(V(t206)-0.9)+u(V(t207)-0.9)+u(V(t208)-0.9)+u(V(t209)-0.9)+u(V(t210)-0.9)+u(V(t211)-0.9)+u(V(t212)-0.9)+u(V(t213)-0.9)+u(V(t214)-0.9)+u(V(t215)-0.9)+u(V(t216)-0.9)+u(V(t217)-0.9)+u(V(t218)-0.9)+u(V(t219)-0.9)+u(V(t220)-0.9)+u(V(t221)-0.9)+u(V(t222)-0.9)+u(V(t223)-0.9)+u(V(t224)-0.9)+u(V(t225)-0.9)+u(V(t226)-0.9)+u(V(t227)-0.9)+u(V(t228)-0.9)+u(V(t229)-0.9)+u(V(t230)-0.9)+u(V(t231)-0.9)+u(V(t232)-0.9)+u(V(t233)-0.9)+u(V(t234)-0.9)+u(V(t235)-0.9)+u(V(t236)-0.9)+u(V(t237)-0.9)+u(V(t238)-0.9)+u(V(t239)-0.9)+u(V(t240)-0.9)+u(V(t241)-0.9)+u(V(t242)-0.9)+u(V(t243)-0.9)+u(V(t244)-0.9)+u(V(t245)-0.9)+u(V(t246)-0.9)+u(V(t247)-0.9)+u(V(t248)-0.9)+u(V(t249)-0.9)+u(V(t250)-0.9)+u(V(t251)-0.9)+u(V(t252)-0.9)+u(V(t253)-0.9)+u(V(t254)-0.9)+u(V(t255)-0.9)"}
C {devices/gnd.sym} 900 300 0 0 {name=g6 lab=GND}
N 900 240 900 220 {}
N 900 220 980 220 {}
C {devices/opin.sym} 980 220 0 0 {name=p4 lab=code}
T {ones counter: code = sum of t1..t255
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
C {devices/bsource.sym} 1900 500 0 0 {name=Bd3 VAR=V FUNC="1.8*(floor((V(code)+0.25)/8)-2*floor((V(code)+0.25)/16))"}
C {devices/gnd.sym} 1900 530 0 0 {name=g10 lab=GND}
N 1900 470 1900 440 {}
C {devices/opin.sym} 1900 440 3 0 {name=p8 lab=d3}
C {devices/bsource.sym} 2220 500 0 0 {name=Bd4 VAR=V FUNC="1.8*(floor((V(code)+0.25)/16)-2*floor((V(code)+0.25)/32))"}
C {devices/gnd.sym} 2220 530 0 0 {name=g11 lab=GND}
N 2220 470 2220 440 {}
C {devices/opin.sym} 2220 440 3 0 {name=p9 lab=d4}
C {devices/bsource.sym} 2540 500 0 0 {name=Bd5 VAR=V FUNC="1.8*(floor((V(code)+0.25)/32)-2*floor((V(code)+0.25)/64))"}
C {devices/gnd.sym} 2540 530 0 0 {name=g12 lab=GND}
N 2540 470 2540 440 {}
C {devices/opin.sym} 2540 440 3 0 {name=p10 lab=d5}
C {devices/bsource.sym} 2860 500 0 0 {name=Bd6 VAR=V FUNC="1.8*(floor((V(code)+0.25)/64)-2*floor((V(code)+0.25)/128))"}
C {devices/gnd.sym} 2860 530 0 0 {name=g13 lab=GND}
N 2860 470 2860 440 {}
C {devices/opin.sym} 2860 440 3 0 {name=p11 lab=d6}
C {devices/bsource.sym} 3180 500 0 0 {name=Bd7 VAR=V FUNC="1.8*(floor((V(code)+0.25)/128)-2*floor((V(code)+0.25)/256))"}
C {devices/gnd.sym} 3180 530 0 0 {name=g14 lab=GND}
N 3180 470 3180 440 {}
C {devices/opin.sym} 3180 440 3 0 {name=p12 lab=d7}
