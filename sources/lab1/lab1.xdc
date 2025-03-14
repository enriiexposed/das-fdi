#####################################################################
##
##  Fichero:
##    lab1.xdc  07/09/2023
##
##    (c) J.M. Mendias
##    Dise�o Autom�tico de Sistemas
##    Facultad de Inform�tica. Universidad Complutense de Madrid
##
##  Prop�sito:
##    Configuraci�n del laboratorio 1
##
##  Notas de dise�o:
##
#####################################################################

#
# Voltaje del interfaz de configuraci�n de la FPGA
#
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];

#
# Pines conectados al array de switches
#
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {sws[0]}];
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {sws[1]}];
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports {sws[2]}];
set_property -dict { PACKAGE_PIN W17 IOSTANDARD LVCMOS33 } [get_ports {sws[3]}];
set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33 } [get_ports {sws[4]}];
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports {sws[5]}];
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports {sws[6]}];
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports {sws[7]}];
set_property -dict { PACKAGE_PIN V2  IOSTANDARD LVCMOS33 } [get_ports {sws[8]}];
set_property -dict { PACKAGE_PIN T3  IOSTANDARD LVCMOS33 } [get_ports {sws[9]}];
set_property -dict { PACKAGE_PIN T2  IOSTANDARD LVCMOS33 } [get_ports {sws[10]}];
set_property -dict { PACKAGE_PIN R3  IOSTANDARD LVCMOS33 } [get_ports {sws[11]}];
set_property -dict { PACKAGE_PIN W2  IOSTANDARD LVCMOS33 } [get_ports {sws[12]}];
set_property -dict { PACKAGE_PIN U1  IOSTANDARD LVCMOS33 } [get_ports {sws[13]}];
set_property -dict { PACKAGE_PIN T1  IOSTANDARD LVCMOS33 } [get_ports {sws[14]}];
set_property -dict { PACKAGE_PIN R2  IOSTANDARD LVCMOS33 } [get_ports {sws[15]}];

#
# Pines conectados al array de leds
#
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {leds[0]}];
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {leds[1]}];
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports {leds[2]}];
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports {leds[3]}];
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports {leds[4]}];
set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports {leds[5]}];
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports {leds[6]}];
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports {leds[7]}];
set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } [get_ports {leds[8]}];
set_property -dict { PACKAGE_PIN V3  IOSTANDARD LVCMOS33 } [get_ports {leds[9]}];
set_property -dict { PACKAGE_PIN W3  IOSTANDARD LVCMOS33 } [get_ports {leds[10]}];
set_property -dict { PACKAGE_PIN U3  IOSTANDARD LVCMOS33 } [get_ports {leds[11]}];
set_property -dict { PACKAGE_PIN P3  IOSTANDARD LVCMOS33 } [get_ports {leds[12]}];
set_property -dict { PACKAGE_PIN N3  IOSTANDARD LVCMOS33 } [get_ports {leds[13]}];
set_property -dict { PACKAGE_PIN P1  IOSTANDARD LVCMOS33 } [get_ports {leds[14]}];
set_property -dict { PACKAGE_PIN L1  IOSTANDARD LVCMOS33 } [get_ports {leds[15]}];

#
# Pines conectados a los pulsadores
#
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports btnL];
set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVCMOS33 } [get_ports btnR];

#
# Pines conectados al display 7 segmentos
#
set_property -dict { PACKAGE_PIN W7 IOSTANDARD LVCMOS33 } [get_ports {segs_n[6]}];
set_property -dict { PACKAGE_PIN W6 IOSTANDARD LVCMOS33 } [get_ports {segs_n[5]}];
set_property -dict { PACKAGE_PIN U8 IOSTANDARD LVCMOS33 } [get_ports {segs_n[4]}];
set_property -dict { PACKAGE_PIN V8 IOSTANDARD LVCMOS33 } [get_ports {segs_n[3]}];
set_property -dict { PACKAGE_PIN U5 IOSTANDARD LVCMOS33 } [get_ports {segs_n[2]}];
set_property -dict { PACKAGE_PIN V5 IOSTANDARD LVCMOS33 } [get_ports {segs_n[1]}];
set_property -dict { PACKAGE_PIN U7 IOSTANDARD LVCMOS33 } [get_ports {segs_n[0]}];
set_property -dict { PACKAGE_PIN V7 IOSTANDARD LVCMOS33 } [get_ports {segs_n[7]}];

set_property -dict { PACKAGE_PIN U2 IOSTANDARD LVCMOS33 } [get_ports {an_n[0]}];
set_property -dict { PACKAGE_PIN U4 IOSTANDARD LVCMOS33 } [get_ports {an_n[1]}];
set_property -dict { PACKAGE_PIN V4 IOSTANDARD LVCMOS33 } [get_ports {an_n[2]}];
set_property -dict { PACKAGE_PIN W4 IOSTANDARD LVCMOS33 } [get_ports {an_n[3]}];