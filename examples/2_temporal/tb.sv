// ===============================================================================
// Date: 01/02/2022
// Creator: Hu, Shiqing
// E-mail: ryderhu512@gmail.com
// Description: 
// ===============================================================================

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

ovl_never #(
/* severity_level */  `OVL_ERROR,       // raise error when violation occurs, other value: OVL_FATAL
/* property_type */   `OVL_ASSERT,      // other value: OVL_ASSUME. both are the same in dynamic simulation.
/* msg */             "cnt > 1",        // error message
/* coverage_level */  `OVL_COVER_ALL)   // enable coverage for this assertion. can be turned off globally by OVL_COVER_ON
                      ovl_never_inst(
/* clock */           .clock    (clk    ),
/* reset */           .reset    (rstn   ),
/* enable */          .enable   (1'b1   ),
/* test_expr */       .test_expr(cnt > 8));


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
    valid_next_a_b (
       clk,
       rstn,
       1'b1,
       cnt == 8,
       pulse == 1);


endmodule

