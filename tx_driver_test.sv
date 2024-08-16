`include "tx_driver.sv"

module tx_driver_test();

logic bit_in ;
logic bit_clk, reset;
logic       select_reduced_swing;
logic [5:0] FS        = 6'd63; // complete full swing 
logic [5:0] LF        = 0 ;
logic [5:0] C0        = 6'd63;
logic [5:0] C1_plus   = 0 ;
logic [5:0] C1_minus  = 0 ;

real  tx_dp_out;
real  tx_dn_out;

bit  [9:0] bit_pattern = 12'b10_100_11111_01_;
int i=0;

tx_driver TX_DRIVER (
                      .vdd(),
                      .vss(),
                      .bit_clk(bit_clk),
                      .reset(reset),
                      .select_reduced_swing(1'b0),
                      .FS(FS),
                      .LF(LF),
                      .C0(C0), 
                      .C1_plus(C1_plus),
                      .C1_minus(C1_minus),
                      .bit_in_tx_dp(bit_in  ),
                      .bit_in_tx_dn(~bit_in ),
                     
                      .tx_dp(tx_dp_out),
                      .tx_dn(tx_dn_out) 
                     );

initial 
begin

FS       = $urandom_range(24,63);
reset <= 1'b1 ;
#10 ;
reset <= 1'b0 ;
#20 ;
reset <= 1'b1 ;
 

repeat(100)
begin
 //bit_in   <= $random;
 bit_in   <= bit_pattern[11-i] ;    
 i++;
 //C0       <= C0 +1'b1;
 //C1_plus  <= C1_plus + 1'b1 ;
 // as per mindshare example 
 //C1_plus  = 6'd13;                              
 //C1_plus  = 6'd08;          
 //C1_minus = 6'd07;                             
 
 // mindshare table C-1 max value 
 //C1_minus = 6'd16;               
 //C1_plus  = 6'd5;  
 
 // mindshare table C+1 max value 
 //C1_minus = 6'd5;               
 //C1_plus  = 6'd16; 
 
 // table line middle value 
 C1_minus = 6'd10;               
 C1_plus  = 6'd10;



 C0       = 6'd63 - C1_plus - C1_minus ;
 //C1_minus <= C1_plus + 1'b1 ;
 if ( i == 12 ) i = 0;
 @(posedge bit_clk)
 $display("bit_in = %d",bit_in);
end
 $finish();
end 

initial begin 
bit_clk <= 1'b0;

forever begin  
 #5 
 bit_clk <= ~bit_clk ;
end 
end 


endmodule 
