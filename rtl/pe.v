module pe #(
parameter DATA_WIDTH = 8,
parameter ACC_WIDTH = 32 
)(
    input clk,
    input rst_n,
    input clr_acc,

    input [DATA_WIDTH-1:0] in_a,
    input [DATA_WIDTH-1:0] in_b,

    output reg [DATA_WIDTH-1:0] out_a,
    output reg [DATA_WIDTH-1:0] out_b,
    output reg [ACC_WIDTH-1:0] out_acc


    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_a <= {DATA_WIDTH{1'b0}};
            out_b <= {DATA_WIDTH{1'b0}};
            out_acc <= {ACC_WIDTH{1'b0}};
        end
        else begin
            out_a <= in_a;
            out_b <= in_b;
           
            if (clr_acc) begin
                out_acc <= in_a * in_b;
            
            end
            else begin
                out_acc <= out_acc + (in_a*in_b);
            end
        end
    end
    

endmodule