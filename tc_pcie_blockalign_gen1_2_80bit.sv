// This will generate block aligned data for 80bit in data
module tc_pcie_block_align_gen1_2_80bit
(
input          rxclk_i,
input          reset_n_i, 
input  [79:0]  rxdata_pma_i,
input          blockalign_enable_i,
output [79:0]  aligned_rxdata_o,
output         rxdata_valid_o 
);

// register value for storing of I/O signals
logic  [79:0]  rxdata_pma_r;
logic          blockalign_enable_r;
logic  [79:0]  aligned_rxdata_r;
logic          rxdata_valid_r; 

// parameter defination for COM symbol 
parameter TC_PCIE_COM = 10'h1bc;


// local combinational signal declaration 
logic   [239:0] shifted_rxdata_240bit_c;
logic   [ 79:0] aligned_rxdata_c;
logic           rxdata_valid_c; 
logic   [ 79:0] com_detected_c;
logic   [ 06:0] index_value_c;

//local sequenctial register variable 
logic   [239:0] shifted_rxdata_240bit_r;
logic   [ 79:0] com_detected_r;
logic   [ 06:0] index_value_r;

// local combinational logic 
assign shifted_rxdata_240bit_c = {rxdata_pma_r,shifted_rxdata_240bit_r[239:80]}; //shifting data by 10bit

// finding the index for COM symbol detection
genvar i;
generate              
   for ( i = 0; i < 80 ; i=i+1)
   begin :COM_DETECT
        assign com_detected_c[i] = ( shifted_rxdata_240bit_r[i+80+:10] == TC_PCIE_COM ) ? 1'b1 : 1'b0;
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
					   com_detected_r[9] ? 4'd9 : 
					   com_detected_r[10] ? 4'd10 :
                       com_detected_r[11] ? 4'd11 :
					   com_detected_r[12] ? 4'd12 :
					   com_detected_r[13] ? 4'd13 :
                       com_detected_r[14] ? 4'd14 :
					   com_detected_r[15] ? 4'd15 :
					   com_detected_r[16] ? 4'd16 :
					   com_detected_r[17] ? 4'd17 :
					   com_detected_r[18] ? 4'd18 :
					   com_detected_r[19] ? 4'd19 : 
					   com_detected_r[20] ? 4'd20 :
                       com_detected_r[21] ? 4'd21 :
					   com_detected_r[22] ? 4'd22 :
					   com_detected_r[23] ? 4'd23 :
                       com_detected_r[24] ? 4'd24 :
					   com_detected_r[25] ? 4'd25 :
					   com_detected_r[26] ? 4'd26 :
					   com_detected_r[27] ? 4'd27 :
					   com_detected_r[28] ? 4'd28 :
					   com_detected_r[29] ? 4'd29 : 
					   com_detected_r[30] ? 4'd30 :
                       com_detected_r[31] ? 4'd31 :
					   com_detected_r[32] ? 4'd32 :
					   com_detected_r[33] ? 4'd33 :
                       com_detected_r[34] ? 4'd34 :
					   com_detected_r[35] ? 4'd35 :
					   com_detected_r[36] ? 4'd36 :
					   com_detected_r[37] ? 4'd37 :
					   com_detected_r[38] ? 4'd38 :
					   com_detected_r[39] ? 4'd39 :
					   com_detected_r[40] ? 4'd40 :
                       com_detected_r[41] ? 4'd41 :
					   com_detected_r[42] ? 4'd42 :
					   com_detected_r[43] ? 4'd43 :
                       com_detected_r[44] ? 4'd44 :
					   com_detected_r[45] ? 4'd45 :
					   com_detected_r[46] ? 4'd46 :
					   com_detected_r[47] ? 4'd47 :
					   com_detected_r[48] ? 4'd48 :
					   com_detected_r[49] ? 4'd49 : 
					   com_detected_r[50] ? 4'd50 :
                       com_detected_r[51] ? 4'd51 :
					   com_detected_r[52] ? 4'd52 :
					   com_detected_r[53] ? 4'd53 :
                       com_detected_r[54] ? 4'd54 :
					   com_detected_r[55] ? 4'd55 :
					   com_detected_r[56] ? 4'd56 :
					   com_detected_r[57] ? 4'd57 :
					   com_detected_r[58] ? 4'd58 :
					   com_detected_r[59] ? 4'd59 : 
					   com_detected_r[60] ? 4'd60 :
                       com_detected_r[61] ? 4'd61 :
					   com_detected_r[62] ? 4'd62 :
					   com_detected_r[63] ? 4'd63 :
                       com_detected_r[64] ? 4'd64 :
					   com_detected_r[65] ? 4'd65 :
					   com_detected_r[66] ? 4'd66 :
					   com_detected_r[67] ? 4'd67 :
					   com_detected_r[68] ? 4'd68 :
					   com_detected_r[69] ? 4'd69 : 
					   com_detected_r[70] ? 4'd70 :
                       com_detected_r[71] ? 4'd71 :
					   com_detected_r[72] ? 4'd72 :
					   com_detected_r[73] ? 4'd73 :
                       com_detected_r[74] ? 4'd74 :
					   com_detected_r[75] ? 4'd75 :
					   com_detected_r[76] ? 4'd76 :
					   com_detected_r[77] ? 4'd77 :
					   com_detected_r[78] ? 4'd78 :
					   com_detected_r[79] ? 4'd79 :index_value_r ;
					   
// rxdata valid assignment 
assign  rxdata_valid_c = ( (|com_detected_r) & blockalign_enable_r ) ? 1'b1 : rxdata_valid_r;
					
// aligned rxdata assignment 
assign  aligned_rxdata_c = shifted_rxdata_240bit_r[index_value_r+:10];
					
// input registered value 
always @( posedge rxclk_i or negedge reset_n_i )
begin
    if ( ~reset_n_i) 
    begin 
	   rxdata_pma_r            <=  80'b0;
       blockalign_enable_r     <=   1'b0;
       shifted_rxdata_240bit_r <= 240'b0; 	   
	   aligned_rxdata_r        <=  80'b0;
	   rxdata_valid_r          <=   1'b0;
	   com_detected_r          <=   1'b0;
	   index_value_r           <=   7'b0;
    end 
    else 
    begin
	   rxdata_pma_r               <= rxdata_pma_i;
       blockalign_enable_r        <= blockalign_enable_i; 
	   shifted_rxdata_240bit_r    <= shifted_rxdata_240bit_c;
	   aligned_rxdata_r           <= aligned_rxdata_c;
	   rxdata_valid_r             <= rxdata_valid_c;
	   com_detected_r             <= com_detected_c;
	   index_value_r              <= index_value_c;
    end 	
end 


// output assignment from sequential register block 
assign aligned_rxdata_o = aligned_rxdata_r;
assign rxdata_valid_o   = rxdata_valid_r;

endmodule : tc_pcie_block_align_gen1_2_80bit
