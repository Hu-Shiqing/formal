## ===============================================================================
## Date: 01/03/2022
## Creator: Hu, Shiqing
## E-mail: ryderhu512@gmail.com
## Description: 
## ===============================================================================



xrun:
	xrun ../vc_formal.sv tb.sv -top tb +access+rwc +test0 # +define+VC_CONN_DBG

xrun_gui:
	xrun ../vc_formal.sv tb.sv -top tb +access+rwc +test1 -gui

jg:
	-rm -fr jgproject
	jaspergold -fpv dut.tcl -no_gui

jg_gui:
	-rm -fr jgproject
	jaspergold -fpv dut.tcl


clean:
	-rm -fr waves.shm  xcelium.d  xrun.history  xrun.key  xrun.log
	-rm -fr .simvision jgproject
