################################################################################
# Date: 11/4/2021
# Creator: Hu, Shiqing
# E-mail: schinghu@gmail.com
# Description:
################################################################################


XRUN_OPTS   = +access+wrc tb.sv -gui
XRUN_OPTS  += -SV +incdir+$(std_ovl)
XRUN_OPTS  += -y $(std_ovl) +libext+.v
# Specify language, by default is OVL_VERILOG
XRUN_OPTS  += +define+OVL_SVA
# Switch to turn on assertion, coverage and xcheck.
XRUN_OPTS  += +define+OVL_ASSERT_ON+OVL_COVER_ON+OVL_XCHECK_OFF

run:
	xrun $(XRUN_OPTS)

formal:
	rm -fr jgproject
	jaspergold -fpv tb.tcl -no_gui

clean:
	rm -fr xrun.*  *.log
	rm -fr waves.shm  xcelium.d
	rm -fr jgproject
	rm -fr .simvision

# === END ===
