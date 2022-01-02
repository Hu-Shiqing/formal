// ===============================================================================
// Date: 01/02/2022
// Creator: Hu, Shiqing
// E-mail: ryderhu512@gmail.com
// Description: 
// ===============================================================================

`ifndef VC_FORMAL_SV
`define VC_FORMAL_SV

`define VC_CONNECTION_BEGIN \
    int unsigned vc_conn_runs; \
    int unsigned vc_conn_errs; \
    int unsigned vc_conn_runs_s[string]; \
    int unsigned vc_conn_errs_s[string]; \
    string vc_conn_src_path[string]; \
    string vc_conn_dst_path[string];

`define VC_CONNECTION(NAME, SRC_SIG, DST_SIG) \
    `ifdef VC_CONN_NAME \
        `undef VC_CONN_NAME \
    `endif \
    `define VC_CONN_NAME NAME \
    `ifdef VC_CONN_SRC_PATH \
        `undef VC_CONN_SRC_PATH \
    `endif \
    `ifdef VC_CONN_DST_PATH \
        `undef VC_CONN_DST_PATH \
    `endif \
    `ifdef VC_CONN_PREFIX \
        `define VC_CONN_SRC_PATH `VC_CONN_PREFIX.SRC_SIG \
    `else \
        `define VC_CONN_SRC_PATH SRC_SIG \
    `endif \
    `ifdef VC_CONN_PREFIX \
        `define VC_CONN_DST_PATH `VC_CONN_PREFIX.DST_SIG \
    `else \
        `define VC_CONN_DST_PATH DST_SIG \
    `endif \
    initial begin \
        `ifdef VC_CONN_DBG \
            $display("Adding %s to vc_conn_src_path", `"`VC_CONN_SRC_PATH`"); \
        `endif \
        vc_conn_src_path[`"`VC_CONN_NAME`"] = `"`VC_CONN_SRC_PATH`"; \
        `ifdef VC_CONN_DBG \
            $display("Adding %s to vc_conn_dst_path", `"`VC_CONN_DST_PATH`"); \
        `endif \
        vc_conn_dst_path[`"`VC_CONN_NAME`"] = `"`VC_CONN_DST_PATH`"; \
        if(!vc_conn_runs_s.exists(`"`VC_CONN_NAME`")) vc_conn_runs_s[`"`VC_CONN_NAME`"] = 0; \
        if(!vc_conn_errs_s.exists(`"`VC_CONN_NAME`")) vc_conn_errs_s[`"`VC_CONN_NAME`"] = 0; \
    end


`define VC_COND_EXPR(EXPR) \
    always @ (`VC_CONN_SRC_PATH or `VC_CONN_DST_PATH) begin \
        if(EXPR) begin \
            `ifdef VC_DELAY \
                #(`VC_CONN_DELAY); \
            `else \
                #1ns; \
            `endif \
            VC_CONN_```VC_CONN_NAME:assert(`VC_CONN_SRC_PATH === `VC_CONN_DST_PATH) begin \
                vc_conn_runs ++; \
                vc_conn_runs_s[`"`VC_CONN_NAME`"] ++; \
                `ifdef VC_CONN_DBG \
                    $display("source signal: %s\nsource value : %b\ndestin signal: %s\ndestin value : %b\n", \
                        `"`VC_CONN_SRC_PATH`", `VC_CONN_SRC_PATH, `"`VC_CONN_DST_PATH`", `VC_CONN_DST_PATH); \
                `endif \
            end else begin \
                vc_conn_errs ++; \
                vc_conn_errs_s[`"`VC_CONN_NAME`"] ++; \
                $display("source signal: %s\nsource value : %b\ndestin signal: %s\ndestin value : %b\n", \
                   `"`VC_CONN_SRC_PATH`", `VC_CONN_SRC_PATH, `"`VC_CONN_DST_PATH`", `VC_CONN_DST_PATH); \
            end \
        end \
    end


`define VC_CONNECTION_END \
task vc_conn_assert(); \
    int unsigned errors; \
    $display("[VC_CONNECTION][%0t] walking ones test", $time); \
    errors = vc_conn_errs; \
    foreach(vc_conn_src_path[k]) begin \
        `ifdef VC_CONN_DBG \
            $display("[%0t] force source signal #%s: %s = 1", $time, k, vc_conn_src_path[k]) ; \
        `endif \
        $xm_force(vc_conn_src_path[k], "1", ""); \
        `ifdef VC_CONN_FORCE_TIME \
            #(`VC_CONN_FORCE_TIME); \
        `else \
            #2ns; \
        `endif \
    end \
    if(vc_conn_errs > errors) $display("[VC_CONNECTION][%0t] %0d errors found in walking ones test!", $time, vc_conn_errs - errors); \
    $display("[VC_CONNECTION][%0t] walking zeros test", $time); \
    errors = vc_conn_errs; \
    foreach(vc_conn_src_path[k]) begin \
        `ifdef VC_CONN_DBG \
            $display("[%0t] force source signal #%s: %s = 0", $time, k, vc_conn_src_path[k]) ; \
        `endif \
        $xm_force(vc_conn_src_path[k], "0", ""); \
        `ifdef VC_CONN_FORCE_TIME \
            #(`VC_CONN_FORCE_TIME); \
        `else \
            #2ns; \
        `endif \
    end \
    if(vc_conn_errs > errors) $display("[VC_CONNECTION][%0t] %0d errors found in walking zeros test!", $time, vc_conn_errs - errors); \
    $display("[VC_CONNECTION][%0t] set all ones test", $time); \
    errors = vc_conn_errs; \
    foreach(vc_conn_src_path[k]) begin \
        `ifdef VC_CONN_DBG \
            $display("[%0t] force source signal #%s: %s = 1", $time, k, vc_conn_src_path[k]) ; \
        `endif \
        $xm_force(vc_conn_src_path[k], "1", ""); \
    end \
    `ifdef VC_CONN_FORCE_TIME \
        #(`VC_CONN_FORCE_TIME); \
    `else \
        #2ns; \
    `endif \
    if(vc_conn_errs > errors) $display("[VC_CONNECTION][%0t] %0d errors found in set all ones test!", $time, vc_conn_errs - errors); \
    $display("[VC_CONNECTION][%0t] set all zeros test", $time); \
    errors = vc_conn_errs; \
    foreach(vc_conn_src_path[k]) begin \
        `ifdef VC_CONN_DBG \
            $display("[%0t] force source signal #%s: %s = 0", $time, k, vc_conn_src_path[k]) ; \
        `endif \
        $xm_force(vc_conn_src_path[k], "0", ""); \
    end \
    `ifdef VC_CONN_FORCE_TIME \
        #(`VC_CONN_FORCE_TIME); \
    `else \
        #2ns; \
    `endif \
    if(vc_conn_errs > errors) $display("[VC_CONNECTION][%0t] %0d errors found in set all zeros test!", $time, vc_conn_errs - errors); \
    $display("[VC_CONNECTION][%0t] random test", $time); \
    errors = vc_conn_errs; \
    repeat(5) begin \
        foreach(vc_conn_src_path[k]) begin \
            bit value; \
            value = $urandom_range(0,1); \
            `ifdef VC_CONN_DBG \
                $display("[%0t] force source signal #%s: %s = %b", $time, k, vc_conn_src_path[k], value) ; \
            `endif \
            $xm_force(vc_conn_src_path[k], $sformatf("%b", value), ""); \
            `ifdef VC_CONN_FORCE_TIME \
                #(`VC_CONN_FORCE_TIME); \
            `else \
                #2ns; \
            `endif \
        end \
    end \
    if(vc_conn_errs > errors) $display("[VC_CONNECTION][%0t] %0d errors found in random test!", $time, vc_conn_errs - errors); \
endtask \
\
function void vc_conn_report(); \
    $display("[VC_CONNECTION][%0t] --------------------", $time); \
    $display("[VC_CONNECTION][%0t] Report", $time); \
    $display("[VC_CONNECTION][%0t] --------------------", $time); \
    $display("[VC_CONNECTION][%0t] vc_conn_runs: %0d", $time, vc_conn_runs); \
    $display("[VC_CONNECTION][%0t] vc_conn_errs: %0d", $time, vc_conn_errs); \
    assert(vc_conn_runs > 0) else \
        $display("No connection asserted!"); \
    foreach(vc_conn_runs_s[k]) begin \
        // $display("%s asserted %0d times", k, vc_conn_runs_s[k]); \
        assert(vc_conn_runs_s[k] != 0) else  \
            $display("%s is not asserted", k); \
    end \
endfunction


`endif // VC_FORMAL_SV
