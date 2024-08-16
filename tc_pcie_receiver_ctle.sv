module tc_pcie_receiver_ctle
(
 input        real  RXDP_PAD,
 input        real  RXDN_PAD,
 output       real  RXDP_OUT,
 input  [2:0] logic rate_i,
 input              rxclk
);
`timescale 1ps/1fs 

// CLOCK parameter 
parameter RX_CLK_DELAY_GEN1 = 400.00 ; //ps
parameter RX_CLK_DELAY_GEN2 = 200.00 ; //ps
parameter RX_CLK_DELAY_GEN3 = 125.00 ; //ps
parameter RX_CLK_DELAY_GEN4 =  62.50 ; //ps
parameter RX_CLK_DELAY_GEN5 =  31.25 ; //ps

parameter SAMPLES_PER_BIT   = 8 ;

logic rx_sampling_clk;
real sample_values[SAMPLES_PER_BIT];
real sample_avg;

real RX_SAMPLING_CLK_DELAY;
real RX_SHIFT_CLK_DELAY;

assign RX_SAMPLING_CLK_DELAY = ( rate_i == 3'd0 ) ? RX_CLK_DELAY_GEN1 / ( 2 * SAMPLES_PER_BIT ) :
                               ( rate_i == 3'd1 ) ? RX_CLK_DELAY_GEN2 / ( 2 * SAMPLES_PER_BIT ) :
							   ( rate_i == 3'd2 ) ? RX_CLK_DELAY_GEN3 / ( 2 * SAMPLES_PER_BIT ) :
							   ( rate_i == 3'd3 ) ? RX_CLK_DELAY_GEN4 / ( 2 * SAMPLES_PER_BIT ) : RX_CLK_DELAY_GEN5 / ( 2 * SAMPLES_PER_BIT );
							   
//sampling clock generation 
initial begin 
rx_sampling_clk <= 1'b0;
forever begin
 #RX_SAMPLING_CLK_DELAY;
 #RX_SHIFT_CLK_DELAY;
 rx_sampling_clk <= ~ rx_sampling_clk;
end
end 

//sampling voltage valuesfor each samples
genvar i;
generate 
for ( i = 0 ; i < SAMPLES_PER_BIT; i++ )
begin
always @ ( posedge rx_sampling_clk )
begin
  if ( i == 0 ) sample_values[i] <= RXDP_PAD - RXDN_PAD; 
  else sample_values[i] <= sample_values[i-1];
end 
end 
endgenerate

//average voltage value calculation
always @(posedge rxclk )
begin
 // avg sum of sampled voltage values
 sample_avg = 0 ;
 for ( i = 0 ; i < SAMPLES_PER_BIT ; i++ )
 begin
    sample_avg += sample_values[i];
 end 
 RXDP_OUT <= sample_avg / SAMPLES_PER_BIT ; 
end

endmodule