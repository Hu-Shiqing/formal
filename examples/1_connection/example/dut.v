// ===============================================================================
// Date: 01/03/2022
// Creator: Hu, Shiqing
// E-mail: ryderhu512@gmail.com
// Description: 
// ===============================================================================

module mux(a, b, s, y);
input a, b, s;
output y;

assign y = s ? a : b;

endmodule
