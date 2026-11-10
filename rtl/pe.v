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

    //internal pipeline registers
    reg [DATA_WIDTH-1:0] in_a_reg;
    reg [DATA_WIDTH-1:0] in_b_reg;
    reg [(DATA_WIDTH*2)-1:0] mult_reg; //menyimpan hasil in_a * in_b
    reg clr_acc_reg;

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_a_reg    <= {DATA_WIDTH{1'b0}};
            in_b_reg    <= {DATA_WIDTH{1'b0}};
            mult_reg    <= {(DATA_WIDTH*2){1'b0}};
            clr_acc_reg <= 1'b0;

            out_a <= {DATA_WIDTH{1'b0}};
            out_b <= {DATA_WIDTH{1'b0}};
            out_acc <= {ACC_WIDTH{1'b0}};
        end
        else begin
            //stage 1 pipeline
            in_a_reg <= in_a;
            in_b_reg <= in_b;
            mult_reg <= in_a * in_b;
            clr_acc_reg <= clr_acc;



            //stage 2 pipeline
            out_a <= in_a_reg;
            out_b <= in_b_reg;
           
            if (clr_acc_reg) begin
                out_acc <= mult_reg;
            
            end
            else begin
                out_acc <= out_acc + mult_reg;
            end
        end
    end
    

endmodule