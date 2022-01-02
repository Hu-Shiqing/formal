// ===============================================================================
// Date: 01/02/2022
// Creator: Hu, Shiqing
// E-mail: ryderhu512@gmail.com
// Description: 
// ===============================================================================


`include "dut.v"

module tb();

logic a, b, s, y;

mux u_mux(a, b, s, y);

`VC_CONNECTION_BEGIN
    //`define VC_CONN_PREFIX tb
    `VC_CONNECTION(conn_wrp_dbg_m0_b0, a, y)
    `VC_COND_EXPR((s==1))
    `VC_CONNECTION(conn_wrp_dbg_m0_b1, b, y)
    `VC_COND_EXPR((s==0))
`VC_CONNECTION_END

initial begin
    s = 0;
    vc_conn_assert();
    s = 1;
    vc_conn_assert();

    vc_conn_report();
end

endmodule

