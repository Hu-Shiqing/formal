# Formal verification

System verilog assertion (SVA) is normally used as checkers during dynamic simulation, it can be put in either RTL code, test-bench, UVM component or even test cases.

SVA can be also used in formal verification, similar as PSL and other language. In this scenario, SVA describes the RTL behaviour in another layer of abstraction and EDA tools, like IFV or JasperGold, will generate stimulus automatically and inject to both RTL design and SVA, then the tool compare both output result to check if design is expected.

There are two kinds of formal verification:

1. Connectivity check for combination logic like GPIO MUX and Debug MUX.
2. Termporal assertion. it can also check sequential logic with provided temporal/timing assertion.


## Open Verification Library(OVL)
- Introduction: https://www.accellera.org/activities/working-groups/ovl
- Download: https://www.accellera.org/images/downloads/standards/ovl/std_ovl_v2p8.1_Apr2014.tgz

## Jasper Gold

