module tx_driver 
(
input               vdd,
input               vss,
input   wire        bit_clk,
input   wire        reset,

input   logic       select_reduced_swing,
input   logic [5:0] FS,
input   logic [5:0] LF,

input   logic [5:0] C0, 
input   logic [5:0] C1_plus,
input   logic [5:0] C1_minus,
input   logic       bit_in_tx_dp,
input   logic       bit_in_tx_dn,

output  real       tx_dp,
output  real       tx_dn 
);

`include "Custom_DAC.sv"


parameter TXD_PAD_MAX_VOLTAGE_IN_MV =   0.250000; // this can be from 200-300 mv  for GEN1/2  and is 200-325 mv for GEN3
parameter TXD_PAD_MIN_VOLTAGE_IN_MV =  -0.250000;   // inverted of max positive peak voltage of single pad pin

parameter C1_MINUS_ANALOG_MAX_VALUE =  1.000000;  
parameter C1_MINUS_ANALOG_MIN_VALUE =  0.000000;  

parameter C1_PLUS_ANALOG_MAX_VALUE  =  1.000000;  
parameter C1_PLUS_ANALOG_MIN_VALUE  =  0.000000;  

real txdp_pad ;
real txdn_pad ;

// volatage level represented in mv
real txd_pad_max ;
real txd_pad_min ;

assign txd_pad_max = real'(FS) * real'(TXD_PAD_MAX_VOLTAGE_IN_MV/63);
assign txd_pad_min = real'(LF/FS) * real'(TXD_PAD_MIN_VOLTAGE_IN_MV/63);


assign tx_dp = txdp_pad ;
assign tx_dn = txdn_pad ;


////////////////////////////////////////////////////////
// bit buffering 
real bit_in_txdp_1_minus;
real bit_in_txdp_1_plus ;
real bit_in_txdp_0      ;

assign bit_in_txdp_1_minus = bit_in_tx_dp ? txd_pad_max : txd_pad_min ;

always @ ( posedge bit_clk or negedge reset ) 
begin
  if (~reset ) 
  begin
    bit_in_txdp_1_plus  <= 1'b0 ;
    bit_in_txdp_0       <= 1'b0 ;
  end 
  else 
  begin
    bit_in_txdp_0       <= bit_in_txdp_1_minus;
    bit_in_txdp_1_plus  <= bit_in_txdp_0      ;
  end
end 

////////////////////////////////////////////////////////

////////////////////////////////////////////////////////
//DAC for Coefficient digital to analog converter 
////////////////////////////////////////////////////////
real C0_analog ;
real C1_minus_analog;
real C1_plus_analog;

Custom_DAC #(.DIGITAL_INPUT_WIDTH(6)) C1_minus_DAC = new(.name("C1_minus_DAC"), .analog_out_max_value_in(C1_MINUS_ANALOG_MAX_VALUE), .analog_out_min_value_in(C1_MINUS_ANALOG_MIN_VALUE));
Custom_DAC #(.DIGITAL_INPUT_WIDTH(6)) C1_plus_DAC  = new(.name("C1_plus_DAC"), .analog_out_max_value_in(C1_PLUS_ANALOG_MAX_VALUE), .analog_out_min_value_in(C1_PLUS_ANALOG_MIN_VALUE));


always @ ( posedge bit_clk ) 
begin
 C1_minus_analog = C1_minus_DAC.dac_out(C1_minus);  
 C1_plus_analog  = C1_plus_DAC.dac_out(C1_plus);
 C0_analog       = 1 - C1_plus_analog - C1_minus_analog;
end 

////////////////////////////////////////////////////////


assign txdp_pad = - bit_in_txdp_1_minus * C1_minus_analog + bit_in_txdp_0 * C0_analog - bit_in_txdp_1_plus * C1_plus_analog ;
assign txdn_pad = - txdp_pad ;


endmodule 
