///////////////////////////////////////////////////////////
// n-tap Filter Design
// customizable coefficient selection
// Functoin for output generation
///////////////////////////////////////////////////////////

class FIR_filter ;

// No of taps in filter 
int no_of_taps = 1;

// Coefficient values as per taps  
real coefficient_value[int];
real delayed_value_for_taps[int];

string FIR_filter_name ;

// constructor call 
function new (string name = "FIR_Filter",int no_of_taps_in);
   int i = 0 ;

   FIR_filter_name = name ;
   no_of_taps      = no_of_taps_in ;
   
   repeat(no_of_taps)
   begin
      coefficient_value[i]      = 0.0;
      delayed_value_for_taps[i] = 0.0;
      i++;
   end 

endfunction :new


// Coefficient value initialization  
function init_coefficients(real coefficient_value_in[*]);
    int i = 0;
    repeat(no_of_taps)
    begin
         if( coefficient_value_in.exists(i) && coefficient_value.exists(i))
	 begin
         coefficient_value[i] = coefficient_value_in[i];
	 end
	 else 
	 begin
	   $error("Coefficient ( coefficient no: %d) does not exists and trying to initialize",i);
	 end 
	 i++;
    end 
endfunction : init_coefficients 


// delayed value for taps intialization 
function init_delayed_value_for_taps(real delayed_value_for_taps_in[*]);
    int i=0;
    foreach(delayed_value_for_taps[i])
    begin
         if ( delayed_value_for_taps_in.exists(i) && delayed_value_for_taps.exists(i))
	 begin
         delayed_value_for_taps[i] = delayed_value_for_taps_in[i];
	 end 
	 else 
	 begin
	   $error("Tap ( tap no: %d) does not exists and trying to initialize delayed value",i);
	 end 
	 i++;
    end 
endfunction : init_delayed_value_for_taps 


// Function to calculate FIR output accoding to coefficient and input delayed value 
function real FIR_filter_out ( real input_bit_value);
    int i=0 ;

    FIR_filter_out = 0.0;
    
    repeat(no_of_taps)
    begin
         
	 if ( i < no_of_taps - 1 ) 
	 begin
	     delayed_value_for_taps[i+1]   = delayed_value_for_taps[i]; 
	 end

	 if ( i == 0 ) 
         begin 
             delayed_value_for_taps[i] = input_bit_value;
         end


         FIR_filter_out = FIR_filter_out + coefficient_value[i] * delayed_value_for_taps[i]; 
    end 

endfunction : FIR_filter_out


endclass : FIR_filter
