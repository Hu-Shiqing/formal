## ===============================================================================
## Date: 01/02/2022
## Creator: Hu, Shiqing
## E-mail: ryderhu512@gmail.com
## Description: 
## ===============================================================================


analyze -verilog dut.v
elaborate -top mux

clock -none
reset -none

check_conn -load ./dut.csv 
check_conn -generate_toggle_checks {}

check_conn -prove

