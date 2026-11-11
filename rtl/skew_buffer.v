module skew_buffer #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 0
)(
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] d_in,
    output [DATA_WIDTH-1:0] d_out
);

    generate 
        if (DEPTH == 0) begin : g_bypass
            assign d_out = d_in;
        end
        else begin: g_delay
            reg [DATA_WIDTH-1:0] shift_reg [0:DEPTH-1];
            integer i;

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    for (i = 0; i < DEPTH; i = i + 1) begin
                        shift_reg[i] <= {DATA_WIDTH{1'b0}};
                    end
                end
                else begin
                    shift_reg[0] <= d_in;
                    for (i = 1; i < DEPTH; i = i + 1) begin
                        shift_reg[i] <= shift_reg[i-1];
                    end
                end
            end

            assign d_out = shift_reg[DEPTH-1];
        
        end

    endgenerate



endmodule


