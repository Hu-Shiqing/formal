// ===============================================================================
// Date: 01/03/2022
// Creator: Hu, Shiqing
// E-mail: ryderhu512@gmail.com
// Description: 
// ===============================================================================


`include "dut.v"

module tb();

logic a, b, s, y;

mux u_mux(a, b, s, y);

`VC_CONNECTION_BEGIN(test0)

    `VC_CONNECTION(conn_wrp_dbg_m0_b0, a, y)
    `VC_COND_EXPR((s==1))
    `VC_CONNECTION(conn_wrp_dbg_m0_b1, b, y)
    `VC_COND_EXPR((s==0))

    `VC_CONN_COND(s)

`VC_CONNECTION_END

`VC_CONNECTION_BEGIN(test1)

    `VC_CONNECTION(conn_wrp_dbg_m1_b0, a, y)
    `VC_COND_EXPR((s==1))
    `VC_CONNECTION(conn_wrp_dbg_m1_b1, b, y)
    `VC_COND_EXPR((s==0))

    `VC_CONN_COND(s)

`VC_CONNECTION_END


initial begin
    vc_conn_assert_all();
end

endmodule

