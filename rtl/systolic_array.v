module systolic_array #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32,
    parameter ARRAY_SIZE = 4
)(
    input  wire                                       clk,
    input  wire                                       rst_n,
    input  wire                                       clr_acc,
    input  wire [ARRAY_SIZE*DATA_WIDTH-1:0]           a_in,   // 4 baris input dari kiri (32-bit)
    input  wire [ARRAY_SIZE*DATA_WIDTH-1:0]           b_in,   // 4 kolom input dari atas (32-bit)
    output wire [ARRAY_SIZE*ARRAY_SIZE*ACC_WIDTH-1:0] c_out   // 16 hasil akumulasi (512-bit)
);

    // Kabel internal estafet horizontal (A) dan vertikal (B)
    // Ukuran dilebihkan +1 untuk menampung tepi input (indeks 0) dan tepi ujung (indeks ARRAY_SIZE)
    wire [DATA_WIDTH-1:0] a_wire [0:ARRAY_SIZE-1][0:ARRAY_SIZE];
    wire [DATA_WIDTH-1:0] b_wire [0:ARRAY_SIZE][0:ARRAY_SIZE-1];
    wire [ACC_WIDTH-1:0]  c_wire [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];

    genvar r, c;
    generate
        // 1. Sambungkan port input luar ke tepi paling kiri (A) dan paling atas (B)
        for (r = 0; r < ARRAY_SIZE; r = r + 1) begin : INPUT_A_EDGE
            assign a_wire[r][0] = a_in[r*DATA_WIDTH +: DATA_WIDTH];
        end

        for (c = 0; c < ARRAY_SIZE; c = c + 1) begin : INPUT_B_EDGE
            assign b_wire[0][c] = b_in[c*DATA_WIDTH +: DATA_WIDTH];
        end

        // 2. Instansiasi Grid 4x4 PE & hubungkan kabel antar-sel
        for (r = 0; r < ARRAY_SIZE; r = r + 1) begin : ROW
            for (c = 0; c < ARRAY_SIZE; c = c + 1) begin : COL
                pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACC_WIDTH(ACC_WIDTH)
                ) pe_inst (
                    .clk     (clk),
                    .rst_n   (rst_n),
                    .clr_acc (clr_acc),
                    .in_a    (a_wire[r][c]),     // Terima data A dari PE kiri
                    .in_b    (b_wire[r][c]),     // Terima data B dari PE atas
                    .out_a   (a_wire[r][c+1]),   // Oper data A ke PE kanan
                    .out_b   (b_wire[r+1][c]),   // Oper data B ke PE bawah
                    .out_acc (c_wire[r][c])      // Hasil lokal PE(r,c)
                );

                // Gabungkan kembali output 2D ke port flattened c_out
                assign c_out[(r*ARRAY_SIZE + c)*ACC_WIDTH +: ACC_WIDTH] = c_wire[r][c];
            end
        end
    endgenerate

endmodule