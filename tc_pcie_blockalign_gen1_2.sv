module tc_pcie_block_align_gen1_2
(
input         rxclk_i,
input         reset_n_i,
input  [9:0]  rxdata_pma_i,
input         blockalign_enable_i,
output [9:0]  aligned_rxdata_o,
output        rxdata_valid_o 
);

// register value for storing of I/O signals
logic  [9:0]  rxdata_pma_r;
logic         blockalign_enable_r;
logic  [9:0]  aligned_rxdata_r;
logic         rxdata_valid_r; 

// parameter defination for COM symbol 
parameter TC_PCIE_COM = 10'h1bc;


// local combinational signal declaration 
logic   [29:0] shifted_rxdata_30bit_c;
logic   [09:0] aligned_rxdata_c;
logic          rxdata_valid_c; 
logic   [09:0] com_detected_c;
logic   [03:0] index_value_c;

//local sequenctial register variable 
logic   [29:0] shifted_rxdata_30bit_r;
logic   [09:0] com_detected_r;
logic   [03:0] index_value_r;

// local combinational logic 
assign shifted_rxdata_30bit_c = {rxdata_pma_r,shifted_rxdata_30bit_r[29:10]}; //shifting data by 10bit

// finding the index for COM symbol detection
genvar i;
generate              
   for ( i = 0; i < 10 ; i=i+1)
   begin :COM_DETECT
        assign com_detected_c[i] = ( shifted_rxdata_30bit_r[i+10+:10] == TC_PCIE_COM ) ? 1'b1 : 1'b0;
   end :COM_DETECT 
endgenerate                

// index assignment
assign index_value_c = com_detected_r[0] ? 4'd0 :
                       com_detected_r[1] ? 4'd1 :
					   com_detected_r[2] ? 4'd2 :
					   com_detected_r[3] ? 4'd3 :
                       com_detected_r[4] ? 4'd4 :
					   com_detected_r[5] ? 4'd5 :
					   com_detected_r[6] ? 4'd6 :
					   com_detected_r[7] ? 4'd7 :
					   com_detected_r[8] ? 4'd8 :
					   com_detected_r[9] ? 4'd9 : index_value_r ;
					   
// rxdata valid assignment 
assign  rxdata_valid_c = ( (|com_detected_r) & blockalign_enable_r ) ? 1'b1 : rxdata_valid_r;
					
// aligned rxdata assignment 
assign  aligned_rxdata_c = shifted_rxdata_30bit_r[index_value_r+:10];
					
// input registered value 
always @( posedge rxclk_i or negedge reset_n_i )
begin
    if ( ~reset_n_i) 
    begin 
	   rxdata_pma_r           <= 10'b0;
           blockalign_enable_r    <= 1'b0;
           shifted_rxdata_30bit_r <= 20'b0; 	   
	   aligned_rxdata_r       <= 10'b0;
	   rxdata_valid_r         <= 1'b0;
	   com_detected_r         <= 1'b0;
	   index_value_r          <= 4'b0;
    end 
    else 
    begin
	   rxdata_pma_r           <= rxdata_pma_i;
           blockalign_enable_r    <= blockalign_enable_i; 
	   shifted_rxdata_30bit_r <= shifted_rxdata_30bit_c;
	   aligned_rxdata_r       <= aligned_rxdata_c;
	   rxdata_valid_r         <= rxdata_valid_c;
	   com_detected_r         <= com_detected_c;
	   index_value_r          <= index_value_c;
    end 	
end 


// output assignment from sequential register block 
assign aligned_rxdata_o = aligned_rxdata_r;
assign rxdata_valid_o   = rxdata_valid_r;

endmodule : tc_pcie_block_align_gen1_2
