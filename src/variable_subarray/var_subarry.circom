pragma circom 2.1.2;

include "circomlib/comparators.circom";
include "../utils/CalculateTotal.circom";
include "../utils/QuinSelector.circom";

template VarSubarray() {
    // input signals
    signal input start;
    signal input end;
    signal input in[1000];

    // output signal
    signal output out[1000];

    // components
    component isLessThan1[1000];
    component isLessThan2[1000];
    component isLessThan3[1000];
    component calcTotal[1000];
    component quinSel[1000];
    
    var start_index = 0; // this will store the starting index
    var end_index = 0;   // this will store the ending index
    for (var i = 0; i < 1000; i++) {
        // Checking whether i < end
        isLessThan1[i] = LessThan(252);
        isLessThan1[i].in[0] <== i;
        isLessThan1[i].in[1] <== end;
        end_index = end_index + isLessThan1[i].out;
        
        // Checkinf whether i < start
        isLessThan2[i] = LessThan(252);
        isLessThan2[i].in[0] <== i;
        isLessThan2[i].in[1] <== start;
        start_index = start_index + isLessThan2[i].out;
    }

    // Now we assign:
    // out[i] = out[i+start_index] if (i+start_index < end_index)
    // out[i] = 0                   otherwise
    for(var i=0;i<1000;i++){
        // Finding the signal value (i+start_index)
        calcTotal[i] = CalculateTotal(2);
        calcTotal[i].in[0] <== i;
        calcTotal[i].in[1] <== start_index;

        // Checking whether i+start_index < end_index
        isLessThan3[i] = LessThan(252);
        isLessThan3[i].in[0] <== calcTotal[i].out;
        isLessThan3[i].in[1] <== end_index;

        // Using quin selector to get the value of signal at in[i+start_index]
        quinSel[i] = QuinSelector(1000);
        quinSel[i].in <== in;

        // index = i+start_index if (i+start_index<end_index)
        // index = 999             otherwise
        quinSel[i].index <== calcTotal[i].out + (999-calcTotal[i].out)*(1-isLessThan3[i].out);

        // out[i] = out[i+start_index] if (i+start_index < end_index)
        // out[i] = 0                   otherwise
        out[i] <== quinSel[i].out * isLessThan3[i].out;
    }

}

component main = VarSubarray();

/* INPUT = {
    "in": ["5","8","9","3","2","1"],
    "start": "0",
    "end": "6"
} */