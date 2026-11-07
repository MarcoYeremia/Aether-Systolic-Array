`timescale 1ns/1ps

module tb_pe;

    //1.Parameters and internal signal declaration
    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH = 32;

    //input uses reg because we determine the value
    reg clk;
    reg rst_n;
    reg clr_acc;
    reg [DATA_WIDTH-1:0] in_a;
    reg [DATA_WIDTH-1:0] in_b;
    
    //output uses wire because the modul determines the value
    wire [DATA_WIDTH-1:0] out_a;
    wire [DATA_WIDTH-1:0] out_b;
    wire [ACC_WIDTH-1:0] out_acc;

    //2.Unit Under Test (UUT) Instantiation
    pe #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .in_a(in_a),
        .in_b(in_b),
        .out_a(out_a),
        .out_b(out_b),
        .out_acc(out_acc)
    );

    //3.Clock generator (10 ns period -> 100 MHz)
    always #5 clk = ~clk;

    //4.Simulation scenario
    initial begin 
        //setup file for GTKWave
        $dumpfile("sim/sim_pe.vcd");
        $dumpvars(0, tb_pe);

        //initialization
        clk = 0;
        rst_n = 0; //active reset
        clr_acc = 0;
        in_a = 0;
        in_b = 0;

        //hold reset for 20 ns
        #20;
        rst_n = 1; //release reset

        //--TEST CASE 1: (clr_acc = 1)--
        //expected output: out_acc = (2*3) = 6
        @(posedge clk);
        clr_acc = 1;
        in_a = 8'd2;
        in_b = 8'd3;

        //--TEST CASE 2: accumulation mode (clr_acc = 0)--
        //expected output: out_acc = 6 + (5 * 8) = 46
        @(posedge clk);
        clr_acc = 0;
        in_a = 8'd5;
        in_b = 8'd8;

        //--TEST CASE 3: accumulation mode (again) (clr_acc = 0)--
        //expected output: out_acc = 46 + (7 * 6) = 88
        @(posedge clk);
        clr_acc = 0;
        in_a = 8'd7;
        in_b = 8'd6;    

        // TEST CASE 4: accumulate with (5 * 6) = 118
        @(posedge clk);
        in_a    = 8'd5;
        in_b    = 8'd6;

        // TEST CASE 5: reset in the middle (output should 0)
        @(posedge clk);
        rst_n   = 0;        // reset active, out_acc = 0
        in_a    = 8'd9;
        in_b    = 8'd9;

        // reset inactive in the next cycle
        @(posedge clk);
        rst_n   = 1;
        in_a    = 8'd2;
        in_b    = 8'd2;    //output should be 4

        //pause for 2 clock cycles, then finish
        @(posedge clk);
        @(posedge clk);
        $display("Simulasi Selesai");
        $finish; 

    end

endmodule