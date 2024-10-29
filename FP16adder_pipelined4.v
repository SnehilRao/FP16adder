
//////////////////////////////////////////////////////////////////////////////////

module GenProp(GP, A, B);
    output reg [1:0] GP;
    input A, B;
    
    always @(*)
        begin
        GP[1] = A & B;  //G
        GP[0] = A ^ B;  //P
        end
        
endmodule

//////////////////////////////////////////////////////////////////////////////////

module Dot(GPab, GPa, GPb);
output reg [1:0] GPab;                          //Ga:b Pa:b
input [1:0] GPa, GPb;                           //Ga Pa; Gb Pb

always @(*)
    begin
        GPab[1] = GPb[1] | (GPa[1] & GPb[0]) ;  //Ga:b
        GPab[0] = GPa[0] & GPb[0];              //Pa:b
    end
      
endmodule

//////////////////////////////////////////////////////////////////////////////////


module BKA(X, Y, Cin, S);
output [16:0] S;
input Cin;
input [15:0] X, Y;
    
    wire [1:0] GP[15:0];
    // Generate block to instantiate 16 GenProp modules
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) 
            begin : GenProp_Instances
        // Instantiate the GenProp module for each bit of X and Y
            GenProp GP_instance (
                .GP(GP[i]),   // Connect output GP to GP[i] wire
                .A(X[i]),     // Connect input A to X[i]
                .B(Y[i]) );      // Connect input B to Y[i]
            end
    endgenerate
    
    wire [1:0] GPab1[7:0];
    //Dot(GPab, GPa, GPb);
    //Stage 1
    Dot Dot10(.GPab(GPab1[0]), .GPa(GP[0]), .GPb(GP[1]));  //stage 1's 0tht Dot
    Dot Dot11(.GPab(GPab1[1]), .GPa(GP[2]), .GPb(GP[3]));  //stage 1's 1st Dot
    Dot Dot12(.GPab(GPab1[2]), .GPa(GP[4]), .GPb(GP[5]));  //stage 1's 2nd Dot
    Dot Dot13(.GPab(GPab1[3]), .GPa(GP[6]), .GPb(GP[7]));  //stage 1's 3rd Dot
    Dot Dot14(.GPab(GPab1[4]), .GPa(GP[8]), .GPb(GP[9]));  //stage 1's 4th Dot
    Dot Dot15(.GPab(GPab1[5]), .GPa(GP[10]), .GPb(GP[11]));  //stage 1's 5th Dot
    Dot Dot16(.GPab(GPab1[6]), .GPa(GP[12]), .GPb(GP[13]));  //stage 1's 6th Dot
    Dot Dot17(.GPab(GPab1[7]), .GPa(GP[14]), .GPb(GP[15]));  //stage 1's 7th Dot  
    
    //Stage 2 
    wire [1:0] GPab2[3:0];
    Dot Dot20(.GPab(GPab2[0]), .GPa(GPab1[0]), .GPb(GPab1[1]));  //stage 2's 0tht Dot
    Dot Dot21(.GPab(GPab2[1]), .GPa(GPab1[2]), .GPb(GPab1[3]));  //stage 2's 1st Dot
    Dot Dot22(.GPab(GPab2[2]), .GPa(GPab1[4]), .GPb(GPab1[5]));  //stage 2's 2nd Dot
    Dot Dot23(.GPab(GPab2[3]), .GPa(GPab1[6]), .GPb(GPab1[7]));  //stage 2's 3rd Dot
    
    //Stage 3 
    wire [1:0] GPab3[1:0];
    Dot Dot30(.GPab(GPab3[0]), .GPa(GPab2[0]), .GPb(GPab2[1]));  //stage 3's 0tht Dot
    Dot Dot31(.GPab(GPab3[1]), .GPa(GPab2[2]), .GPb(GPab2[3]));  //stage 3's 1st Dot
    
    //Stage 4
    wire [1:0] GPab4[1:0];
    Dot Dot40(.GPab(GPab4[0]), .GPa(GPab3[0]), .GPb(GPab2[2]));  //stage 4's 0tht Dot
    Dot Dot41(.GPab(GPab4[1]), .GPa(GPab3[0]), .GPb(GPab3[1]));  //stage 4's 1st Dot
    
    //Stage 5 
    wire [1:0] GPab5[2:0];
    Dot Dot50(.GPab(GPab5[0]), .GPa(GPab2[0]), .GPb(GPab1[2]));  //stage 5's 0tht Dot
    Dot Dot51(.GPab(GPab5[1]), .GPa(GPab3[0]), .GPb(GPab1[4]));  //stage 5's 1st Dot
    Dot Dot52(.GPab(GPab5[2]), .GPa(GPab4[0]), .GPb(GPab1[6]));  //stage 5's 2nd Dot

    //Stage 6
    wire [1:0] GPab6[6:0];
    Dot Dot60(.GPab(GPab6[0]), .GPa(GPab1[0]), .GPb(GP[2]));  //stage 6's 0tht Dot
    Dot Dot61(.GPab(GPab6[1]), .GPa(GPab2[0]), .GPb(GP[4]));  //stage 6's 1st Dot
    Dot Dot62(.GPab(GPab6[2]), .GPa(GPab5[0]), .GPb(GP[6]));  //stage 6's 2nd Dot
    Dot Dot63(.GPab(GPab6[3]), .GPa(GPab3[0]), .GPb(GP[8]));  //stage 6's 3rd Dot
    Dot Dot64(.GPab(GPab6[4]), .GPa(GPab5[1]), .GPb(GP[10]));  //stage 6's 4th Dot
    Dot Dot65(.GPab(GPab6[5]), .GPa(GPab4[0]), .GPb(GP[12]));  //stage 6's 5th Dot
    Dot Dot66(.GPab(GPab6[6]), .GPa(GPab5[2]), .GPb(GP[14]));  //stage 6's 6th Dot
    
    //carry bits
    wire [15:0] carry;
    assign carry = {(GPab4[1][1] | (GPab4[1][0] & Cin)),    (GPab6[6][1] | (GPab6[6][0]& Cin)),               //  
                    (GPab5[2][1] | (GPab5[2][0] & Cin)),    (GPab6[5][1] | (GPab6[5][0] & Cin)),
                    (GPab4[0][1] | (GPab4[0][0] & Cin)),    (GPab6[4][1] | (GPab6[4][0] & Cin)),
                    (GPab5[1][1] | (GPab5[1][0] & Cin)),    (GPab6[3][1] | (GPab6[3][0] & Cin)),
                    (GPab3[0][1] | (GPab3[0][0] & Cin)),    (GPab6[2][1] | (GPab6[2][0] & Cin)),
                    (GPab5[0][1] | (GPab5[0][0] & Cin)),    (GPab6[1][1] | (GPab6[1][0] & Cin)),
                    (GPab2[0][1] | (GPab2[0][0] & Cin)),    (GPab6[0][1] | (GPab6[0][0] & Cin)),
                    (GPab1[0][1] | (GPab1[0][0] & Cin)),    (GP[0][1] | (GP[0][0] & Cin))};
     
    wire [16:0] sum;
    assign sum = {  carry[15],
                    (GP[15][0] ^ carry[14]),    (GP[14][0] ^ carry[13]),    (GP[13][0] ^ carry[12]),
                    (GP[12][0] ^ carry[11]),    (GP[11][0] ^ carry[10]),    (GP[10][0] ^ carry[9]),
                    (GP[9][0] ^ carry[8]),      (GP[8][0] ^ carry[7]),      (GP[7][0] ^ carry[6]),
                    (GP[6][0] ^ carry[5]),      (GP[5][0] ^ carry[4]),      (GP[4][0] ^ carry[3]),
                    (GP[3][0] ^ carry[2]),      (GP[2][0] ^ carry[1]),      (GP[1][0] ^ carry[0]),
                    (GP[0][0] ^ Cin)    };
                    
    assign S = sum;
    
    //$display (GPab6[6][1]);
    
endmodule

//////////////////////////////////////////////////////////////////////////////////

module Rounding2(Mout, Min);

    input [14:0] Min;
    output reg [10:0] Mout;
 
    
    wire [16:0] Saux;
    wire ms, mp1;
    assign ms = |Min[2:0];    //sticky bit
    assign mp = Min[3];        //rounding bit
    assign mp1= Min[4];        //initial lsb       
    
    BKA adder32(.X({1'b0,Min}), .Y(16'd0), .Cin(1'b1), .S(Saux));
    
    always @(*)
        begin
            //Implementing round ties to even.
            if (mp==1'b0)    begin Mout = Min[14:4]; end   
            else 
                begin
                if(ms == 1'b1)  begin Mout = Saux[14:4];  end        
                else
                    begin if (mp1 == 1'b1)  begin Mout = Saux[14:4];  end
                    else begin Mout = Min[14:4]; end
                    end
                end
                
        end
        
endmodule

//////////////////////////////////////////////////////////////////////////////////


module Mux21(Z, A, B, S);
    input A, B, S;
    output Z;

    assign Z = S ? B : A;  // If S is 1, Z = B; otherwise, Z = A

endmodule


//////////////////////////////////////////////////////////////////////////////////


module LogShifter(  output [14:0] Out, 
                    input [14:0] In, 
                    input [3:0] S);
    
    wire [14:0] stage1, stage2, stage3, stage4;

    // Stage 0: Shift Left by 1 if S[0] is set
    generate
        genvar i;
        for (i = 1; i < 15; i = i + 1) begin : stage0_loop
            Mux21 mux1(stage1[i], In[i], In[i-1], S[0]);
        end
        Mux21 mux1_last(stage1[0], In[0], 1'b0, S[0]); // For the lsb
    endgenerate

    // Stage 1: Shift Left by 2 if S[1] is set
    generate
        for (i = 2; i < 15; i = i + 1) begin : stage1_loop
            Mux21 mux2(stage2[i], stage1[i], stage1[i-2], S[1]);
        end
        Mux21 mux2_last1(stage2[1], stage1[1], 1'b0, S[1]); // for bit 1
        Mux21 mux2_last2(stage2[0], stage1[0], 1'b0, S[1]); // for lsb
    endgenerate

    // Stage 2: Shift Left by 4 if S[2] is set
    generate
        for (i = 4; i < 15; i = i + 1) begin : stage2_loop
            Mux21 mux3(stage3[i], stage2[i], stage2[i-4], S[2]);
        end
        Mux21 mux3_last1(stage3[3], stage2[3], 1'b0, S[2]); // Bit position 3
        Mux21 mux3_last2(stage3[2], stage2[2], 1'b0, S[2]); // Bit position 2
        Mux21 mux3_last3(stage3[1], stage2[1], 1'b0, S[2]); // for bit 1
        Mux21 mux3_last4(stage3[0], stage2[0], 1'b0, S[2]); // for lsb
    endgenerate

    // Stage 3: Shift Left by 8 if S[3] is set
    generate
        for (i = 8; i < 15; i = i + 1) begin : stage3_loop
            Mux21 mux4(stage4[i], stage3[i], stage3[i-8], S[3]);
        end
        Mux21 mux4_last1(stage4[7], stage3[7], 1'b0, S[3]);  // Bit position 7
        Mux21 mux4_last2(stage4[6], stage3[6], 1'b0, S[3]);  // Bit position 6
        Mux21 mux4_last3(stage4[5], stage3[5], 1'b0, S[3]);  // Bit position 5
        Mux21 mux4_last4(stage4[4], stage3[4], 1'b0, S[3]); // Bit position 4
        Mux21 mux4_last5(stage4[3], stage3[3], 1'b0, S[3]); // Bit position 3
        Mux21 mux4_last6(stage4[2], stage3[2], 1'b0, S[3]); // Bit position 2
        Mux21 mux4_last7(stage4[1], stage3[1], 1'b0, S[3]); // Bit position 1
        Mux21 mux4_last8(stage4[0], stage3[0], 1'b0, S[3]); // for lsb
    endgenerate

    // Final output is the result from the last stage
    assign Out = stage4;

endmodule


//////////////////////////////////////////////////////////////////////////////////

module ZerosCount2(Zcount, SubMan);
input [14:0] SubMan;        //Mantissa, with implicit bit
output reg [3:0] Zcount;        // to save no. of leading zeros in start of Mantissa of Bsubnorm.. 

always @(*)
    begin
        Zcount = 4'd0;
        if (SubMan[14] == 1'b1) 
            Zcount = 5'd0;  // 0 leading zero
        else if (SubMan[13] == 1'b1) 
            Zcount = 5'd1;  // 1 leading zero
        else if (SubMan[12] == 1'b1) 
            Zcount = 5'd2;  // 2 leading zero
        else if (SubMan[11] == 1'b1)
            Zcount = 5'd3;  // 3 leading zeros
        else if (SubMan[10] == 1'b1)
            Zcount = 5'd4;  // 4 leading zeros
        else if (SubMan[9] == 1'b1)
            Zcount = 5'd5;  // 5 leading zeros
        else if (SubMan[8] == 1'b1)
            Zcount = 5'd6;  // 6 leading zeros
        else if (SubMan[7] == 1'b1)
            Zcount = 5'd7;  // 7 leading zeros
        else if (SubMan[6] == 1'b1)
            Zcount = 5'd8;  // 8 leading zeros
        else if (SubMan[5] == 1'b1)
            Zcount = 5'd9;  // 9 leading zeros
        else if (SubMan[4] == 1'b1)
            Zcount = 5'd10; // 10 leading zeros
        else if (SubMan[3] == 1'b1)
            Zcount = 5'd11; // 11 leading zeros
        else if (SubMan[2] == 1'b1)
            Zcount = 5'd12; // 12 leading zeros
        else if (SubMan[1] == 1'b1)
            Zcount = 5'd13; // 13 leading zeros
        else if (SubMan[0] == 1'b1)
            Zcount = 5'd14; // 14 leading zeros
        else if (SubMan == 15'd0)
            Zcount = 5'd15; // 15 leading zeros
        else
            Zcount = 4'd0;
            
end

endmodule

//////////////////////////////////////////////////////////////////////////////////
module Normalize2(
    Eo, Moo, So,         //op
    Ei, Mi, Co, Si      //ip
    );
    
    //Mantissa in form say: ZX.YYYYYYYYYYYYYY   Z=Co; X=1/0
    
    input [4:0] Ei;
    input [14:0] Mi;
    input Co, Si;
    output reg [4:0] Eo;
    output wire [9:0] Moo;
    output wire So;
    
    reg [14:0] Maux;   //for storing the complete form of mantissa
    wire [10:0] Mround; //rounded mantissa
    wire [3:0] zeros;
    wire [14:0] M1, M2; // for shifer
    
    ZerosCount2 zc2(.Zcount(zeros), .SubMan(Mi));
    LogShifter left1 (.In(Mi), .S(Ei[3:0]), .Out(M1));
    LogShifter left2 (.In(Mi), .S(zeros), .Out(M2));
    Rounding2 round2(.Mout(Mround), .Min(Maux));
    
    // ZX.YYYYYYYYYYYYYY   Z=Co; X=1/0
    always @(*)
    begin
        if (Co == 1)        //Z==1?
        begin
            Eo = Ei + 1;
            Maux = {1'b1, Mi[14:1]};
        end
        else 
        begin
        if (Mi[14] == 1)// Z==0 & X==1?
            begin
            Maux = Mi;    //1.YYYYY..
                Eo = Ei;
            end
        else                    // when subtraction happens
            begin
            if(zeros>=Ei || zeros == 5'd15)      //There is no exponent left to handle the zeros     // 
                begin
                Eo = 5'd0;
                Maux = M1;      //shifting left till exponent zero
                end
            else                //There is few exponent to encorporate the zeros
                begin
                Eo = Ei - zeros;
                Maux = M2;      //shift left till 1 appears on MSB
                end
            end
    
        
    end 
end
        assign Moo = Mround[9:0];
        assign So = Si;              
            
endmodule       
       

//////////////////////////////////////////////////////////////////////////////////

module Sign2(
    output reg SOut, AorS,     // outputs
    output reg [14:0] MAa, MBb, 
    input SA, SB, C,           // inputs
    input [14:0] MA, MB
);

    always @(*) begin
        // Default assignments
        MAa = MA;
        MBb = MB;

        // Determine whether to add or subtract based on the sign comparison
        AorS = (SA != SB) ? 1'b1 : 1'b0;

        // Set the output sign based on the comparison result
        SOut = C ? SA : SB;
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
module Adder2(
    output reg [14:0] M,          // Mantissa output
    output reg COut, SOut,        // Carry Out and Sign Out
    input SA, SB, /*op,*/ C,      // Inputs for signs, and carry
    input [14:0] MA, MB           // Input mantissas
);
    
    wire [14:0] ma, mb;
    wire AorS, so;
    wire [14:0] as;
    wire [16:0] Saux1;     // 16-bit BKA output (with carry)
    
    assign as = {15{AorS}};       // Replicate AorS to form 15-bit mask for 1's complement

    // Instantiate the Sign module
    Sign2 signOut2(
        .SOut(so),              // Assign so to the output from the Sign module
        .AorS(AorS), 
        .MAa(ma), 
        .MBb(mb),              // Outputs
        .SA(SA), 
        .SB(SB), 
        //.op(op), 
        .C(C), 
        .MA(MA), 
        .MB(MB)                // Inputs
    );

    // Calculate B as mb XOR as (1's complement if AorS = 1)
    wire [14:0] B = mb ^ as;
    
    // 16-bit BKA for initial addition
    BKA adder12(
        .X({1'b0, ma}), 
        .Y({1'b0, B}),  // Use B here
        .Cin(AorS),      // Carry-in based on AorS
        .S(Saux1)        // Sum output, 17 bits
    );
    
    // Prepare a2 for potential 2's complement correction
    // assign a2 = Saux1[14:0] ^ as;

    always @(*) begin
        M = Saux1[14:0];
        if(AorS)    COut = 1'b0;
        else        COut = Saux1[15];
        
        // Assign SOut based on the sign logic
        SOut = so;
    end
endmodule


//////////////////////////////////////////////////////////////////////////////////


//module RightShifter (   
//    input [14:0] MMin,      
//    input [3:0] ShiftAmount, // number of right shift
//    output [14:0] ShiftedMMin 
//);
//
//    wire [14:0] reversedIn, reversedOut;
//
//    // reversed input bits 
//    assign reversedIn = {MMin[0], MMin[1], MMin[2], MMin[3], MMin[4], 
//                         MMin[5], MMin[6], MMin[7], MMin[8], MMin[9], 
//                         MMin[10], MMin[11], MMin[12], MMin[13], MMin[14]};
//    
//    //logshifter with rev input
//    LogShifter ShiftR (
//        .Out(reversedOut),    // Shifted (reversed) output
//        .In(reversedIn),      // Reversed input
//        .S(ShiftAmount)       // Shift amount
//    );
//    
//    // Reverse the output bits to get the right-shifted result
//    assign ShiftedMMin = {reversedOut[0], reversedOut[1], reversedOut[2], reversedOut[3], reversedOut[4], 
//                          reversedOut[5], reversedOut[6], reversedOut[7], reversedOut[8], reversedOut[9], 
//                          reversedOut[10], reversedOut[11], reversedOut[12], reversedOut[13], reversedOut[14]};
//    
//endmodule


//////////////////////////////////////////////////////////////////////////////////


//module ExpoCompare3(
//    output wire SA, SB,               // Sign of A and B
//    output reg [4:0] EMax,            // Max exponent out of A and B
//    output reg [14:0] MMax, MMin,     // Min and max mantissa
//    output reg [3:0] ShiftControl,    // # Shift required to equalize exponents
//    output wire Comp,                 // 1 if EA>EB; 0 if EA<EB; else compares mantissas when exponents are equal
//    input [20:0] NA, NB               // Inputs
//);
//
//    // Extract components from input numbers
//    wire [4:0] EA = NA[19:15];
//    wire [4:0] EB = NB[19:15];
//    wire [14:0] MA = NA[14:0];
//    wire [14:0] MB = NB[14:0];
//    wire [4:0] diff;
//
//    // Sign assignments
//    assign SA = NA[20];
//    assign SB = NB[20];
//
//    // Compute Comp and exponent difference
//    assign Comp = (EA > EB) || ((EA == EB) && (MA >= MB));
//    assign diff = (EA > EB) ? (EA - EB) : (EB - EA);
//
//    // Set outputs based on Comp result
//    always @(*) begin
//        // Determine EMax based on Comp result
//        EMax = (Comp) ? EA : EB;
//
//        // Set ShiftControl limited to 15
//        ShiftControl = (diff <= 5'd15) ? diff[3:0] : 4'd15;
//
//        // Mantissa comparison: Assign max and min mantissa
//        if (Comp) begin
//            MMax = MA;
//            MMin = MB;
//        end else begin
//            MMax = MB;
//            MMin = MA;
//        end
//    end
//    
//endmodule


//////////////////////////////////////////////////////////////////////////////////

//module Preperation(
//    output reg SA, SB,
//    output reg [4:0] EMax,
//    output reg [14:0] MA, MB,
//    output reg Comp,
//    input [20:0] NA, NB
//    );
//    
//    wire [14:0] MiniMan, ma, mb;
//    wire [3:0] Sh;
//    wire sa, sb, c;
//    wire [4:0] em;
//    
//    ExpoCompare3 exp3(.NA(NA), .NB(NB), .SA(sa), .SB(sb), .EMax(em), .MMax(ma), .MMin(MiniMan), .ShiftControl(Sh), .Comp(c));
//    RightShifter RS3(.MMin(MiniMan), .ShiftAmount(Sh), .ShiftedMMin(mb));
//    
//    
//    always @(*)
//    begin
//    SA = sa;
//    SB = sb;
//    EMax = em;
//    MA = ma;
//    MB = mb;
//    Comp = c;
//    end
//endmodule


//////////////////////////////////////////////////////////////////////////////////


module PreProcesssorV21 (
    input [15:0] A, B,
    output SA, SB, C,
    output reg [4:0] Ex,
    output reg [14:0] MA, MB
);

    // Extract exponent and mantissa components from inputs A and B
    wire [4:0] EA = A[14:10];
    wire [4:0] EB = B[14:10];
    wire [14:0] Ma = {1'b1, A[9:0], 4'b0};  // Normalized mantissa for A with implicit 1
    wire [14:0] Mb = {1'b1, B[9:0], 4'b0};  // Normalized mantissa for B with implicit 1

    // Calculate the difference between exponents and compare values
    wire [4:0] diff = (EA > EB) ? (EA - EB) : (EB - EA); 
    reg [3:0] ShiftControl;
    reg [14:0] Mmin;  // Temporary register for the minimum mantissa

    // Sign assignments from MSB of input values
    assign SA = A[15];
    assign SB = B[15];

    // Compute comparison result C: 1 if EA > EB or (EA == EB and Ma >= Mb)
    assign C = (EA > EB) || ((EA == EB) && (Ma >= Mb));

    always @(*) begin
        // Determine the shift amount, limiting to a max of 15
        ShiftControl = (diff <= 5'd15) ? diff[3:0] : 4'd15;
        
        // Assign EMax (Ex) based on which exponent is larger
        Ex = C ? EA : EB;
        
        // Assign the larger mantissa to MA and the smaller one to Mmin
        MA = C ? Ma : Mb;
        Mmin = C ? Mb : Ma;
        
        // Right shift the minimum mantissa by ShiftControl to align with MA
        MB = Mmin >> ShiftControl;
    end

endmodule



//////////////////////////////////////////////////////////////////////////////////

module ExceptionsV2(
S, en, A, B, 
infA, nanA, norA, zerA,
infB, nanB, norB, zerB/*, op*/);

input infA, infB, nanA, nanB, norA, norB, zerA, zerB;
input [15:0] A, B;

//input op;
output reg [15:0] S;
output reg en;
reg  [1:0] outA, outB;
reg  SA, SB;
reg [4:0] EA, EB;
reg [9:0] MA, MB;
reg SAB;
    
always @(*)
begin   
        SA = A[15];
        SB = B[15];
        EA = A[14:10];
        EB = B[14:10];
        MA = A[9:0];
        MB = B[9:0];
        SAB = (~(SA ^ SB));
        

    // Generate outputs based on the coded inputs from multiplier.
    //Case1
    if (zerA == 1'b1) begin
        S[15] = SB;
        S[14:10] = EB;
        S[9:0] = MB;
        en = 0;  // Disable en when operated with zero
    end 
    //Case2
    else if (zerB == 1'b1) begin
        S[15] = SA;
        S[14:10] = EA;
        S[9:0] = MA;
        en = 0;  // Disable en when operated with zero
    end 
    //Case3
    else if (norA && infB) begin
        S[15] = SB;
        S[14:10] = 5'b11111;
        S[9:0] = 10'd0;  
        en = 0;     // Disable en when S is Inf
    end 
    //Case4
    else if (infA && norB) begin
        S[15] = SA;
        S[14:10] = 5'b11111;
        S[9:0] = 10'd0;  
        en = 0;     // Disable en when S is Inf
    end
    //Case5
    else if (infB && infA) begin
        S[15] = (SAB) ? SA : 1'b1;   
        S[14:10] = 5'b11111;
        S[9:0] = (SAB) ? 10'd0 : {1'b1,9'd0};  
        en = 0;     // Disable en when S is Inf or qNAN
    end
    //Case 6 and 7
    else if (nanA || nanB) begin
        S[15] = 1'b1; 
        S[14:10] = 5'b11111;
        S[9:0] = {1'b1,9'd0};
        en = 0;     // Disable en when S is qNaN
    end
    //case 8
    else begin
        S = 16'd0;  // Default value for S
        en = 1;     // Enable signal for other cases
    end
    
end
endmodule


//////////////////////////////////////////////////////////////////////////////////


//module FP16_Adder_NoSubnormal(



////////////////////FP16adder_pipelined/////////////////////



module FP16adder_pipelined4(
    input clk,
    input rst,
    input [15:0] A,
    input [15:0] B,
    input infA, nanA, norA, zerA,
    infB, nanB, norB, zerB,
    output [15:0] Sum
);

// Pipeline Stage 1: Exception and Preparation Processing
reg [15:0] A_reg, B_reg;
reg infA_reg, nanA_reg, norA_reg, zerA_reg;
reg infB_reg, nanB_reg, norB_reg, zerB_reg;

wire [15:0] S1_wire;
wire enable, sa1, sb1, c1;
wire [4:0] ex1;
wire [14:0] ma1, mb1;

// Instantiate ExceptionsV2 module with registered inputs
ExceptionsV2 excepttt(
    .S(S1_wire),
    .en(enable),
    .A(A_reg),
    .B(B_reg), 
    .infA(infA_reg), .nanA(nanA_reg), .norA(norA_reg), .zerA(zerA_reg),
    .infB(infB_reg), .nanB(nanB_reg), .norB(norB_reg), .zerB(zerB_reg)
);

// Instantiate PreProcesssorV21 module
PreProcesssorV21 AddPreperation(
    .A(A_reg),
    .B(B_reg),
    .SA(sa1),
    .SB(sb1),
    .C(c1),
    .Ex(ex1),
    .MA(ma1),
    .MB(mb1)
);

// Register Inputs: Capture inputs and exception flags on clock edge
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        A_reg <= 16'b0;
        B_reg <= 16'b0;
        infA_reg <= 1'b0;
        nanA_reg <= 1'b0;
        norA_reg <= 1'b0;
        zerA_reg <= 1'b0;
        infB_reg <= 1'b0;
        nanB_reg <= 1'b0;
        norB_reg <= 1'b0;
        zerB_reg <= 1'b0;
    end else begin
        A_reg <= A;
        B_reg <= B;
        infA_reg <= infA;
        nanA_reg <= nanA;
        norA_reg <= norA;
        zerA_reg <= zerA;
        infB_reg <= infB;
        nanB_reg <= nanB;
        norB_reg <= norB;
        zerB_reg <= zerB;
    end
end

// Pipeline Stage 2 Registers
reg [15:0] S1_reg;
reg [14:0] ma1_reg, mb1_reg;
reg [4:0] ex1_reg;
reg sa1_reg, sb1_reg, c1_reg, enable_reg;
reg infA_stage2, nanA_stage2, norA_stage2, zerA_stage2;
reg infB_stage2, nanB_stage2, norB_stage2, zerB_stage2;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        S1_reg <= 16'b0;
        ma1_reg <= 15'b0;
        mb1_reg <= 15'b0;
        ex1_reg <= 5'b0;
        enable_reg <= 1'b0;
        c1_reg <= 1'b0;
        sa1_reg <= 1'b0;
        sb1_reg <= 1'b0;
        infA_stage2 <= 1'b0;
        nanA_stage2 <= 1'b0;
        norA_stage2 <= 1'b0;
        zerA_stage2 <= 1'b0;
        infB_stage2 <= 1'b0;
        nanB_stage2 <= 1'b0;
        norB_stage2 <= 1'b0;
        zerB_stage2 <= 1'b0;
    end else begin
        S1_reg <= S1_wire;
        ma1_reg <= ma1;
        mb1_reg <= mb1;
        ex1_reg <= ex1;
        enable_reg <= enable;
        c1_reg <= c1;
        sa1_reg <= sa1;
        sb1_reg <= sb1;
        infA_stage2 <= infA_reg;
        nanA_stage2 <= nanA_reg;
        norA_stage2 <= norA_reg;
        zerA_stage2 <= zerA_reg;
        infB_stage2 <= infB_reg;
        nanB_stage2 <= nanB_reg;
        norB_stage2 <= norB_reg;
        zerB_stage2 <= zerB_reg;
    end
end

// Pipeline Stage 2: Adder Stage
wire [14:0] m2;
wire co1, so1;

Adder2 addd3(
    .M(m2),
    .COut(co1),
    .SOut(so1),
    .SA(sa1_reg),
    .SB(sb1_reg),
    .MA(ma1_reg),
    .MB(mb1_reg),
    .C(c1_reg)
);

// Pipeline Stage 3: Normalize Stage
wire [4:0] Eo;
wire [9:0] mo;
wire Soo;

Normalize2 normalisse3(
    .Eo(Eo),
    .Moo(mo),
    .So(Soo),
    .Ei(ex1_reg),
    .Mi(m2),
    .Co(co1),
    .Si(so1)
);

// Final Stage Output Registers
reg [9:0] Mo_reg;
reg [4:0] Eo_reg;
reg So_reg;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        So_reg <= 1'b0;
        Mo_reg <= 10'b0;
        Eo_reg <= 5'b0;
    end else begin
        if (enable_reg) begin
            So_reg <= Soo;
            Mo_reg <= mo;
            Eo_reg <= Eo;
        end else begin
            So_reg <= S1_reg[15];
            Mo_reg <= S1_reg[9:0];
            Eo_reg <= S1_reg[14:10];
        end
    end
end

assign Sum = {So_reg, Eo_reg, Mo_reg};

endmodule
	

////////////////////FP16adder2/////////////////////

//module FP16adder2 (
   
