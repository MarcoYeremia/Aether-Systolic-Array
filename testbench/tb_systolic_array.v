`timescale 1ns/1ps

module tb_systolic_array;

    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH  = 32;
    parameter ARRAY_SIZE = 4;

    reg clk;
    reg rst_n;
    reg clr_acc;

    // Input terpisah per baris (A) dan per kolom (B) biar gampang dibaca
    reg [DATA_WIDTH-1:0] a_row0, a_row1, a_row2, a_row3;
    reg [DATA_WIDTH-1:0] b_col0, b_col1, b_col2, b_col3;

    wire [ARRAY_SIZE*DATA_WIDTH-1:0]           a_in;
    wire [ARRAY_SIZE*DATA_WIDTH-1:0]           b_in;
    wire [ARRAY_SIZE*ARRAY_SIZE*ACC_WIDTH-1:0] c_out;

    // Gabungkan ke bus flattened sesuai mapping systolic_array.v
    assign a_in = {a_row3, a_row2, a_row1, a_row0};
    assign b_in = {b_col3, b_col2, b_col1, b_col0};

    // Pecah c_out jadi 16 sinyal individual biar gampang di-drag ke GTKWave
    wire [ACC_WIDTH-1:0] c00 = c_out[(0*4 + 0)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c01 = c_out[(0*4 + 1)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c02 = c_out[(0*4 + 2)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c03 = c_out[(0*4 + 3)*ACC_WIDTH +: ACC_WIDTH];

    wire [ACC_WIDTH-1:0] c10 = c_out[(1*4 + 0)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c11 = c_out[(1*4 + 1)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c12 = c_out[(1*4 + 2)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c13 = c_out[(1*4 + 3)*ACC_WIDTH +: ACC_WIDTH];

    wire [ACC_WIDTH-1:0] c20 = c_out[(2*4 + 0)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c21 = c_out[(2*4 + 1)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c22 = c_out[(2*4 + 2)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c23 = c_out[(2*4 + 3)*ACC_WIDTH +: ACC_WIDTH];

    wire [ACC_WIDTH-1:0] c30 = c_out[(3*4 + 0)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c31 = c_out[(3*4 + 1)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c32 = c_out[(3*4 + 2)*ACC_WIDTH +: ACC_WIDTH];
    wire [ACC_WIDTH-1:0] c33 = c_out[(3*4 + 3)*ACC_WIDTH +: ACC_WIDTH];

    // Instansiasi Top-Level Systolic Array
    systolic_array #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .clr_acc(clr_acc),
        .a_in(a_in),
        .b_in(b_in),
        .c_out(c_out)
    );

    // Clock Generator (100 MHz, periode 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/sim_array.vcd");
        $dumpvars(0, tb_systolic_array);

        // Inisialisasi
        clk     = 0;
        rst_n   = 0;
        clr_acc = 0;
        {a_row3, a_row2, a_row1, a_row0} = 32'd0;
        {b_col3, b_col2, b_col1, b_col0} = 32'd0;

        // Lepas reset
        #15;
        rst_n = 1;

        // Pulse clr_acc 1 siklus sebelum data masuk
        @(negedge clk);
        clr_acc = 1;
        @(negedge clk);
        clr_acc = 0;

        // =====================================================================
        // STREAMING INPUT MATRIKS A & B (Skew step = 2 siklus per baris/kolom)
        // =====================================================================

        // t = 0: A[0][0], B[0][0]
        a_row0 = 8'd1;  a_row1 = 8'd0;  a_row2 = 8'd0;  a_row3 = 8'd0;
        b_col0 = 8'd1;  b_col1 = 8'd0;  b_col2 = 8'd0;  b_col3 = 8'd0;
        @(negedge clk);

        // t = 1: A[0][1], B[1][0]
        a_row0 = 8'd2;  a_row1 = 8'd0;  a_row2 = 8'd0;  a_row3 = 8'd0;
        b_col0 = 8'd0;  b_col1 = 8'd0;  b_col2 = 8'd0;  b_col3 = 8'd0;
        @(negedge clk);

        // t = 2: A[0][2], A[1][0] | B[2][0], B[0][1]
        a_row0 = 8'd3;  a_row1 = 8'd2;  a_row2 = 8'd0;  a_row3 = 8'd0;
        b_col0 = 8'd1;  b_col1 = 8'd2;  b_col2 = 8'd0;  b_col3 = 8'd0;
        @(negedge clk);

        // t = 3: A[0][3], A[1][1] | B[3][0], B[1][1]
        a_row0 = 8'd4;  a_row1 = 8'd2;  a_row2 = 8'd0;  a_row3 = 8'd0;
        b_col0 = 8'd2;  b_col1 = 8'd1;  b_col2 = 8'd0;  b_col3 = 8'd0;
        @(negedge clk);

        // t = 4: A[1][2], A[2][0] | B[2][1], B[0][2]
        a_row0 = 8'd0;  a_row1 = 8'd2;  a_row2 = 8'd1;  a_row3 = 8'd0;
        b_col0 = 8'd0;  b_col1 = 8'd0;  b_col2 = 8'd0;  b_col3 = 8'd0;
        @(negedge clk);

        // t = 5: A[1][3], A[2][1] | B[3][1], B[1][2]
        a_row0 = 8'd0;  a_row1 = 8'd2;  a_row2 = 8'd0;  a_row3 = 8'd0;
        b_col0 = 8'd0;  b_col1 = 8'd1;  b_col2 = 8'd2;  b_col3 = 8'd0;
        @(negedge clk);

        // t = 6: A[2][2], A[3][0] | B[2][2], B[0][3]
        a_row0 = 8'd0;  a_row1 = 8'd0;  a_row2 = 8'd1;  a_row3 = 8'd0;
        b_col0 = 8'd0;  b_col1 = 8'd0;  b_col2 = 8'd1;  b_col3 = 8'd1;
        @(negedge clk);

        // t = 7: A[2][3], A[3][1] | B[3][2], B[1][3]
        a_row0 = 8'd0;  a_row1 = 8'd0;  a_row2 = 8'd0;  a_row3 = 8'd1;
        b_col0 = 8'd0;  b_col1 = 8'd0;  b_col2 = 8'd0;  b_col3 = 8'd0;
        @(negedge clk);

        // t = 8: A[3][2] | B[2][3]
        a_row0 = 8'd0;  a_row1 = 8'd0;  a_row2 = 8'd0;  a_row3 = 8'd0;
        b_col0 = 8'd0;  b_col1 = 8'd0;  b_col2 = 8'd0;  b_col3 = 8'd2;
        @(negedge clk);

        // t = 9: A[3][3] | B[3][3]
        a_row0 = 8'd0;  a_row1 = 8'd0;  a_row2 = 8'd0;  a_row3 = 8'd1;
        b_col0 = 8'd0;  b_col1 = 8'd0;  b_col2 = 8'd0;  b_col3 = 8'd1;
        @(negedge clk);

        // Kosongkan input & tunggu sisa pipeline mengalir sampai PE(3,3)
        {a_row3, a_row2, a_row1, a_row0} = 32'd0;
        {b_col3, b_col2, b_col1, b_col0} = 32'd0;
        repeat (10) @(posedge clk);

        // Tampilkan hasil matriks 4x4 langsung di terminal
        $display("\n=== HASIL PERKALIAN MATRIKS 4x4 (C = A x B) ===");
        $display("[ %4d  %4d  %4d  %4d ]", c00, c01, c02, c03);
        $display("[ %4d  %4d  %4d  %4d ]", c10, c11, c12, c13);
        $display("[ %4d  %4d  %4d  %4d ]", c20, c21, c22, c23);
        $display("[ %4d  %4d  %4d  %4d ]\n", c30, c31, c32, c33);

        $finish;
    end

endmodule