## ===============================================================================
## Date: 01/02/2022
## Creator: Hu, Shiqing
## E-mail: ryderhu512@gmail.com
## Description: 
## ===============================================================================

clear -all
analyze \
    -y $::env(trunk)/acm_gnss/tb/common/lib/std_ovl +libext+.v \
    -sv +incdir+$::env(trunk)/acm_gnss/tb/common/lib/std_ovl \
    +define+OVL_SVA \
    +define+OVL_ASSERT_ON+OVL_COVER_ON+OVL_XCHECK_OFF \
    tb.sv

elaborate -top tb
clock clk
reset !rstn
prove -all
exit
