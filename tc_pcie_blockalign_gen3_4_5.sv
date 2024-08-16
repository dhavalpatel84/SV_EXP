module tc_pcie_block_align_gen3_4_5
(
input         rxclk_i,
input         reset_n_i,
input  [9:0]  rxdata_pma_i,
input         blockalign_enable_i,
input  [2:0]  rate_i,
output [9:0]  aligned_rxdata_o,
output        rxdata_valid_o 
);

// register value for storing of I/O signals
logic  [9:0]  rxdata_pma_r;
logic         blockalign_enable_r;
logic  [9:0]  aligned_rxdata_r;
logic         rxdata_valid_r; 
logic  [2:0]  rate_r;

// parameter defination for COM symbol 
parameter TC_PCIE_EIEOS_GEN3 = 16'hFF_00;
parameter TC_PCIE_EIEOS_GEN4 = 32'hFFFF_0000;        
parameter TC_PCIE_EIEOS_GEN5 = 64'hFFFFFFFF_00000000; // this is assumption

// local combinational signal declaration 
logic   [39:0] shifted_rxdata_40bit_c;
logic   [59:0] shifted_rxdata_60bit_c;
logic   [89:0] shifted_rxdata_90bit_c;
logic   [09:0] aligned_rxdata_c;
logic          rxdata_valid_c; 
logic   [09:0] eieos_detected_c;
logic   [03:0] index_value_c;

//local sequenctial register variable 
logic   [39:0] shifted_rxdata_40bit_r;
logic   [59:0] shifted_rxdata_60bit_r;
logic   [89:0] shifted_rxdata_90bit_r;
logic   [09:0] eieos_detected_r;
logic   [03:0] index_value_r;

// local combinational logic 
assign shifted_rxdata_40bit_c = {rxdata_pma_r,shifted_rxdata_40bit_r[39:10]}; //shifting data by 10bit
assign shifted_rxdata_60bit_c = {rxdata_pma_r,shifted_rxdata_60bit_r[49:10]}; //shifting data by 10bit
assign shifted_rxdata_90bit_c = {rxdata_pma_r,shifted_rxdata_90bit_r[79:10]}; //shifting data by 10bit

// finding the index for COM symbol detection
genvar i; 
generate 
   for ( i = 0; i < 10 ; i++ )
   begin :EIEOS_DETECT
        assign eieos_detected_c[i] = ( ( shifted_rxdata_40bit_r[i+10 +:16] == TC_PCIE_EIEOS_GEN3 ) && ( rate_r == 3'd2 )) ? 1'b1 : 
		                             ( ( shifted_rxdata_60bit_r[i+10 +:32] == TC_PCIE_EIEOS_GEN4 ) && ( rate_r == 3'd3 )) ? 1'b1 : 
									 ( ( shifted_rxdata_90bit_r[i+10 +:64] == TC_PCIE_EIEOS_GEN5 ) && ( rate_r == 3'd4 )) ? 1'b1 :1'b0;
   end :EIEOS_DETECT 
endgenerate                 

// index assignment
assign index_value_c = eieos_detected_r[0] ? 4'd0 :
                       eieos_detected_r[1] ? 4'd1 :
					   eieos_detected_r[2] ? 4'd2 :
					   eieos_detected_r[3] ? 4'd3 :
                       eieos_detected_r[4] ? 4'd4 :
					   eieos_detected_r[5] ? 4'd5 :
					   eieos_detected_r[6] ? 4'd6 :
					   eieos_detected_r[7] ? 4'd7 :
					   eieos_detected_r[8] ? 4'd8 :
					   eieos_detected_r[9] ? 4'd9 : index_value_r ;
					   
// rxdata valid assignment 
assign  rxdata_valid_c = ( (|eieos_detected_r) & blockalign_enable_r ) ? 1'b1 : rxdata_valid_r;
					
// aligned rxdata assignment 
assign  aligned_rxdata_c = shifted_rxdata_40bit_r[index_value_r+:10];
					
// input registered value 
always @( posedge rxclk_i or negedge reset_n_i )
begin
    if ( ~reset_n_i) 
    begin 
	   rxdata_pma_r           <= 10'b0;
       blockalign_enable_r    <= 1'b0;
       shifted_rxdata_40bit_r <= 40'b0; 	   
	   shifted_rxdata_60bit_r <= 60'b0; 	   
	   shifted_rxdata_90bit_r <= 90'b0; 	   
	   aligned_rxdata_r       <= 10'b0;
	   rxdata_valid_r         <= 1'b0;
	   eieos_detected_r       <= 1'b0;
	   index_value_r          <= 4'b0;
	   rate_r                 <= 3'b0;
    end 
    else 
    begin
	   rxdata_pma_r           <= rxdata_pma_i;
       blockalign_enable_r    <= blockalign_enable_i; 
	   shifted_rxdata_40bit_r <= shifted_rxdata_40bit_c;
	   shifted_rxdata_60bit_r <= shifted_rxdata_60bit_c;
	   shifted_rxdata_90bit_r <= shifted_rxdata_90bit_c;
	   aligned_rxdata_r       <= aligned_rxdata_c;
	   rxdata_valid_r         <= rxdata_valid_c;
	   eieos_detected_r       <= eieos_detected_c;
	   index_value_r          <= index_value_c;
	   rate_r                 <= rate_i;
    end 	
end 


// output assignment from sequential register block 
assign aligned_rxdata_o = aligned_rxdata_r;
assign rxdata_valid_o   = rxdata_valid_r;

endmodule : tc_pcie_block_align_gen3_4_5
