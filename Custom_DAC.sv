/////////////////////////////////////////////////////
// Custom DAC 
// - to convert digital value to analog 
//
//
/////////////////////////////////////////////////////

class Custom_DAC #( parameter DIGITAL_INPUT_WIDTH=6 ); //, ANALOG_OUT_MAX_VALUE=250, ANALOG_OUT_MIN_VALUE=0);

real analog_out_max_value = 250 ;
real analog_out_min_value = 0   ;

string dac_name ;

// constructor 
function new ( string name =  "CUSTOM_ADC", real analog_out_max_value_in, real analog_out_min_value_in);
    this.dac_name             = name ;
    this.analog_out_max_value = analog_out_max_value_in;
    this.analog_out_min_value = analog_out_min_value_in;
endfunction :new 


//value out 
function real dac_out (bit [DIGITAL_INPUT_WIDTH-1 :0] digital_in);
       $display("in dac_out function for : %s",dac_name); 
       $display("in DIGITAL INPUT WIDTH  : %d : power value : %d ",DIGITAL_INPUT_WIDTH,2**DIGITAL_INPUT_WIDTH); 
       dac_out = analog_out_min_value + ((real'(( analog_out_max_value - analog_out_min_value ))) /  real'( (2**DIGITAL_INPUT_WIDTH) - 1)) * real'(digital_in) ;
       $display("in DAC out value : %f ",dac_out);                                      
       $display("in DAC min value : %f ",analog_out_min_value);                                      
       $display("in DAC max value : %f ",analog_out_max_value);                                      
       $display("in DAC div value : %f ",((real'(( analog_out_max_value - analog_out_min_value ))) /  real'( (2**DIGITAL_INPUT_WIDTH) - 1)));                                      
endfunction : dac_out 

endclass : Custom_DAC 
