# Formal verification

System verilog assertion (SVA) is normally used as checkers during dynamic simulation, it can be put in either RTL code, test-bench, UVM component or even test cases.

SVA can be also used in formal verification, similar as PSL and other language. In this scenario, SVA describes the RTL behaviour in another layer of abstraction and EDA tools, like IFV or JasperGold, will generate stimulus automatically and inject to both RTL design and SVA, then the tool compare both output result to check if design is expected.

There are two kinds of formal verification:

1. Connection check for combination logic like GPIO MUX and Debug MUX.
2. Temporal assertion. it can also check sequential logic with provided temporal/timing assertion.

## Connection check

The most common use case for connection is check GPIO MUX and Debug MUX combinational logic in complex SoC design. Say we have a simple MUX as DUT:

dut.v
```
module mux(a, b, s, y);
input a, b, s;
output y;

assign y = s ? a : b;

endmodule
```

### Traditional test in dynamic simulation

Traditionally, we can force the source signal one by one, and then check the destination signal values in dynamic simulation. It's simple and works fine. But in many cases, the test case may become very complex and difficult to maintain. 

Test example:
```
always@(*)
    if(s == 1) assert(y == a);
    else assert(y == b);
    
initial begin
    s = 0;
    a = 0; b = 0;
    #1ns;
    a = 0; b = 1;
    #1ns;
    a = 1; b = 0;
    #1ns;
    a = 1; b = 1;
    #1ns;
    
    s = 1;
    a = 0; b = 0;
    #1ns;
    a = 0; b = 1;
    #1ns;
    a = 1; b = 0;
    #1ns;
    a = 1; b = 1;
    #1ns;
end
```

In real case, since there are normally many signals from different blocks, above sequence will become very long and hard to maintain.

In order to resolve the maintenance issue in this traditional connection test, a simple and standard connection test framework has been defined.

<img width="862" alt="Screenshot 2022-01-04 at 10 56 34 AM" src="https://user-images.githubusercontent.com/35386741/148003609-78c14307-6481-429d-ba3f-01edc1bed6d3.png">

Test example in new framework:

```
`VC_CONNECTION_BEGIN(test0)
    `VC_CONNECTION(conn_s0, a, y)
    `VC_COND_EXPR((s==1))
    `VC_CONNECTION(conn_s1, b, y)
    `VC_COND_EXPR((s==0))
    `VC_CONN_COND(s)
`VC_CONNECTION_END

initial begin
    vc_conn_assert_all();
end
```

### Formal verification using JasperGold

The Perl script will generate CSV file which represents the connection in different format and this file would be input for JasperGold connection App.

dut.csv
```
CONNECTION,conn_wrp_dbg_m0_b0,,a,,y
COND_EXPR,(s==1)

CONNECTION,conn_wrp_dbg_m0_b1,,b,,y
COND_EXPR,(s==0)
```

dut.tcl
```
analyze -verilog dut.v
elaborate -top mux

clock -none
reset -none

check_conn -load ./dut.csv 
check_conn -generate_toggle_checks {}

check_conn -prove
```

Makefile:
```
jg:
	-rm -fr jgproject
	jaspergold -fpv dut.tcl -no_gui

jg_gui:
	-rm -fr jgproject
	jaspergold -fpv dut.tcl
```

Output:
```
==============================================================
SUMMARY
==============================================================
           Properties Considered              : 8
                 assertions                   : 2
                  - proven                    : 2 (100%)
                  - bounded_proven (user)     : 0 (0%)
                  - bounded_proven (auto)     : 0 (0%)
                  - marked_proven             : 0 (0%)
                  - cex                       : 0 (0%)
                  - ar_cex                    : 0 (0%)
                  - undetermined              : 0 (0%)
                  - unknown                   : 0 (0%)
                  - error                     : 0 (0%)
                 covers                       : 6
                  - unreachable               : 0 (0%)
                  - bounded_unreachable (user): 0 (0%)
                  - covered                   : 6 (100%)
                  - ar_covered                : 0 (0%)
                  - undetermined              : 0 (0%)
                  - unknown                   : 0 (0%)
                  - error                     : 0 (0%)
determined
```


## Temporal assertion

Temporal assertion is to check timing and other behaviour in sequential design. The assertion can be used in traditional dynamic simulation, running the check in background. Newly some formal verification engine, like JasperGold, can use the temporal assertion to check the design without dynamic simulation. 

There are different languanges which support temporal assertion, like VHDL, PSL, and System verilog. OVL provides us a language indepedent method to write temporal assertion which is also easier to understand in terms of syntax.

### Open Verification Library(OVL)

- Introduction: https://www.accellera.org/activities/working-groups/ovl
- Download: https://www.accellera.org/images/downloads/standards/ovl/std_ovl_v2p8.1_Apr2014.tgz

#### Quick start

RTL code:
```
`timescale 1ns/1ns
`include "std_ovl_defines.h"

module tb();

logic rstn;
initial begin
    rstn = 0;
    #100ns;
    rstn = 1;
    #10us;
    $finish(0);
end

logic clk;
initial begin
    clk = 0;
    forever begin
       #1ns clk =~ clk;
    end
end

logic [7:0] cnt;
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        cnt <= '0;
    end else begin
        if(cnt >= 8) begin
            cnt <= '0;
        end else begin
            cnt ++;
        end
    end
end

ovl_never #(
/* severity_level */  `OVL_ERROR,       // raise error when violation occurs, other value: OVL_FATAL
/* property_type */   `OVL_ASSERT,      // other value: OVL_ASSUME. both are the same in dynamic simulation.
/* msg */             "cnt > 1",        // error message
/* coverage_level */  `OVL_COVER_ALL)   // enable coverage for this assertion. can be turned off globally by OVL_COVER_ON
                      valid_checker_inst(
/* clock */           .clock    (clk    ),
/* reset */           .reset    (rstn   ),
/* enable */          .enable   (1'b1   ),
/* test_expr */       .test_expr(cnt > 1));

endmodule
```

Makefile:
```
XRUN_OPTS   = +access+wrc tb.sv
XRUN_OPTS  += -SV +incdir+$(std_ovl)
XRUN_OPTS  += -y $(std_ovl) +libext+.v
# Specify language, by default is OVL_VERILOG
XRUN_OPTS  += +define+OVL_SVA
# Switch to turn on assertion, coverage and xcheck.
XRUN_OPTS  += +define+OVL_ASSERT_ON+OVL_COVER_ON+OVL_XCHECK_OFF

run:
	xrun $(XRUN_OPTS)

clean:
	rm -fr xrun.*  *.log
```

Output:
```
xmsim: *E,ASRTST (./tb.sv,42): (time 105 NS) Assertion tb.valid_checker_inst.ovl_assert.A_ASSERT_NEVER_P has failed 
105 NS + 4 (Assertion output stop: tb.valid_checker_inst.ovl_assert.A_ASSERT_NEVER_P = failed)
       OVL_ERROR : OVL_NEVER : cnt > 1 : Test expression is not FALSE : severity 1 : time 105 : tb.valid_checker_inst.ovl_error_t
```

#### Another example
```
logic pulse;
logic [7:0] cnt;
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        cnt <= '0;
        pulse <= '0;
    end else begin
        if(cnt >= 8) begin
            cnt <= '0;
            pulse <= '1;
        end else begin
            cnt ++;
            pulse <= '0;
        end
    end
end
```

<img width="1211" alt="Screenshot 2021-11-02 at 5 00 12 PM" src="https://user-images.githubusercontent.com/35386741/139816580-874c2368-9831-4f92-9e19-4e0626fdd0de.png">

```
ovl_next #(
    `OVL_ERROR,
    1,
    1,
    0,
    `OVL_ASSERT,
    "error:",
    `OVL_COVER_DEFAULT,
    `OVL_POSEDGE,
    `OVL_ACTIVE_LOW,
    `OVL_GATE_CLOCK)
    ovl_next_inst_pulse (
       clk,
       rstn,
       1'b1,
       cnt == 8,
       pulse == 1);
```

### Jasper Gold and OVL

tb.tcl
```
clear -all
analyze \
    -y $std_ovl +libext+.v \
    -sv +incdir+$std_ovl \
    +define+OVL_SVA \
    +define+OVL_ASSERT_ON+OVL_COVER_ON+OVL_XCHECK_OFF \
    tb.sv

elaborate -top tb
clock clk
reset !rstn
prove -all
exit
```
Makefile:
```
formal:
	rm -fr jgproject
	jaspergold -fpv -no_gui tb.tcl
```
Output:
```
==============================================================
SUMMARY
==============================================================
           Properties Considered              : 4
                 assertions                   : 2
                  - proven                    : 2 (100%)
                  - bounded_proven (user)     : 0 (0%)
                  - bounded_proven (auto)     : 0 (0%)
                  - marked_proven             : 0 (0%)
                  - cex                       : 0 (0%)
                  - ar_cex                    : 0 (0%)
                  - undetermined              : 0 (0%)
                  - unknown                   : 0 (0%)
                  - error                     : 0 (0%)
                 covers                       : 2
                  - unreachable               : 0 (0%)
                  - bounded_unreachable (user): 0 (0%)
                  - covered                   : 2 (100%)
                  - ar_covered                : 0 (0%)
                  - undetermined              : 0 (0%)
                  - unknown                   : 0 (0%)
                  - error                     : 0 (0%)
determined
```

