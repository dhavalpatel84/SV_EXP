// BUFFER OR CONVERTER FROM 10/20/40/80 bit to 80bit
module tc_pcie_80bit_converter 
(
input  logic        reset_n_i,
input  logic        rxclk_i,    // this clk depends on rxwidth 
input  logic [ 1:0] rxwidth_i,  
input  logic [79:0] rxdata_i,   // data byte depends on rxwidth  
output logic [79:0] rxdata_o,   // 80bit valid data out 
output logic        rxclk_o,    // 80bit rxclk out 
 );
 
// combinational logic wires declaration 
logic [79:0] rxdata_c ;
logic        rxclk_c  ;
logic [ 2:0] rxclk_count_c;
  
//sequential logic registers declaration
logic [79:0] rxdata_r ;
logic [ 2:0] rxclk_count_r;
logic [ 1:0] rxwidth_r;
logic [79:0] rxdata_in_r;  
  
// combinational logic assignment 
assign rxdata_c = ( rxwidth_r   == 2'd0 ) ? {rxdata_in_r[09:0],rxdata_r[79:09]} : // 10 bit interface 
                  ( rxwidth_r   == 2'd1 ) ? {rxdata_in_r[19:0],rxdata_r[79:19]} : // 20 bit interface 
                  ( rxwidth_r   == 2'd2 ) ? {rxdata_in_r[39:0],rxdata_r[79:39]} : // 40 bit interface 
                                                           {rxdata_in_r[79:00]} ; // 80 bit interface 

assign rxclk_count_c = ( rxwidth_r == 2'd0 )  ? ( ( rxclk_count_r == 3'd7 ) ? 3'd0 : rxclk_count_r + 1'd1 ) :  // 10bit rxwidth defines it will take 8 rxclk to gather 80bit data 
                       ( rxwidth_r == 2'd1 )  ? ( ( rxclk_count_r == 3'd3 ) ? 3'd0 : rxclk_count_r + 1'd1 ) :  // 20bit rxwidth defines it will take 4 rxclk to gather 80bit data 
					   ( rxwidth_r == 2'd2 )  ? ( ( rxclk_count_r == 3'd1 ) ? 3'd0 : rxclk_count_r + 1'd1 ) :  // 40bit rxwidth defines it will take 2 rxclk to gather 80bit data					                                                                                          
					                                                                                   3'd0 ;  // 80bit rxwidth defines it will take 1 rxclk to gather 80bit data			                                                                                        
																									   
assign rxclk_c  = ( rxclk_count_r == 'd0 ) ? ~rxclk_r : rxclk_r;    														   
    
// sequential assignments  
 always @(posedge rxclk_i or negedge reset_n_i)
 begin
    if ( ~reset_n_i)
	begin
	   rxdata_r      <= 80'd0;
	   rxclk_r       <=  1'b0;
	   rxclk_count_r <=  3'd0;
	   rxwidth_r     <=  2'd0;
	   rxdata_in_r   <= 80'd0;
	end 
	else 
	begin
	   rxdata_r      <= rxdata_c;
	   rxclk_r       <= rxclk_c ;
	   rxclk_count_r <= rxclk_count_c;
	   rxwidth_r     <= rxwidth_i;
	   rxdata_in_r   <= rxdata_i;
	end 
 end 

 // output assignments 
assign rxdata_o = rxdata_r ;  
assign rxclk_o  = rxclk_r  ;  
 
endmodule :tc_pcie_80bit_converter