`timescale 1ns/1ps

module tb_skew_buffer;

    parameter DATA_WIDTH = 8;

    reg clk;
    reg rst_n;

    // Input data untuk 4 baris matriks
    reg [DATA_WIDTH-1:0] d_in0;
    reg [DATA_WIDTH-1:0] d_in1;
    reg [DATA_WIDTH-1:0] d_in2;
    reg [DATA_WIDTH-1:0] d_in3;

    // Output data ter-skew
    wire [DATA_WIDTH-1:0] d_out0;
    wire [DATA_WIDTH-1:0] d_out1;
    wire [DATA_WIDTH-1:0] d_out2;
    wire [DATA_WIDTH-1:0] d_out3;

    // -------------------------------------------------------------
    // Instansiasi 4 modul skew_buffer sesuai DEPTH masing-masing
    // -------------------------------------------------------------
    // Baris 0: Bypass / Tanpa delay
    skew_buffer #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(0)) sb0 (
        .clk(clk), .rst_n(rst_n), .d_in(d_in0), .d_out(d_out0)
    );

    // Baris 1: Delay 1 siklus
    skew_buffer #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(1)) sb1 (
        .clk(clk), .rst_n(rst_n), .d_in(d_in1), .d_out(d_out1)
    );

    // Baris 2: Delay 2 siklus
    skew_buffer #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(2)) sb2 (
        .clk(clk), .rst_n(rst_n), .d_in(d_in2), .d_out(d_out2)
    );

    // Baris 3: Delay 3 siklus
    skew_buffer #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(3)) sb3 (
        .clk(clk), .rst_n(rst_n), .d_in(d_in3), .d_out(d_out3)
    );

    // Clock Generator (100 MHz, Periode = 10ns)
    always #5 clk = ~clk;

    initial begin
        // Setup GTKWave dump
        $dumpfile("sim/sim_skew.vcd");
        $dumpvars(0, tb_skew_buffer);

        // Inisialisasi Sinyal
        clk   = 0;
        rst_n = 0;
        d_in0 = 0;
        d_in1 = 0;
        d_in2 = 0;
        d_in3 = 0;

        // Reset pulsa selama 15ns
        #15;
        rst_n = 1;

        // -------------------------------------------------------------
        // Nembak data matriks 4x4 secara bersamaan per siklus
        // -------------------------------------------------------------
        
        // Siklus 1: Masukkan data Kolom 0 -> [11, 21, 31, 41]
        @(posedge clk);
        d_in0 = 8'd11;
        d_in1 = 8'd21;
        d_in2 = 8'd31;
        d_in3 = 8'd41;

        // Siklus 2: Masukkan data Kolom 1 -> [12, 22, 32, 42]
        @(posedge clk);
        d_in0 = 8'd12;
        d_in1 = 8'd22;
        d_in2 = 8'd32;
        d_in3 = 8'd42;

        // Siklus 3: Masukkan data Kolom 2 -> [13, 23, 33, 43]
        @(posedge clk);
        d_in0 = 8'd13;
        d_in1 = 8'd23;
        d_in2 = 8'd33;
        d_in3 = 8'd43;

        // Siklus 4: Masukkan data Kolom 3 -> [14, 24, 34, 44]
        @(posedge clk);
        d_in0 = 8'd14;
        d_in1 = 8'd24;
        d_in2 = 8'd34;
        d_in3 = 8'd44;

        // Selesai input, kosongkan data (set 0)
        @(posedge clk);
        d_in0 = 8'd0;
        d_in1 = 8'd0;
        d_in2 = 8'd0;
        d_in3 = 8'd0;

        // Tunggu sisa data terdorong keluar dari pipeline buffer
        repeat (5) @(posedge clk);

        $display("Simulasi Skew Buffer Selesai!");
        $finish;
    end

endmodule