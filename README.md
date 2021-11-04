# Formal verification

System verilog assertion (SVA) is normally used as checkers during dynamic simulation, it can be put in either RTL code, test-bench, UVM component or even test cases.

SVA can be also used in formal verification, similar as PSL and other language. In this scenario, SVA describes the RTL behaviour in another layer of abstraction and EDA tools, like IFV or JasperGold, will generate stimulus automatically and inject to both RTL design and SVA, then the tool compare both output result to check if design is expected.

There are two kinds of formal verification:

1. Connectivity check for combination logic like GPIO MUX and Debug MUX.
2. Termporal assertion. it can also check sequential logic with provided temporal/timing assertion.


## Open Verification Library(OVL)
- Introduction: https://www.accellera.org/activities/working-groups/ovl
- Download: https://www.accellera.org/images/downloads/standards/ovl/std_ovl_v2p8.1_Apr2014.tgz

### Quick start

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

### Another example
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







## Jasper Gold

### tb.tcl
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
### Makefile:
```
formal:
	rm -fr jgproject
	jaspergold -fpv -no_gui tb.tcl
```
### Output:
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
