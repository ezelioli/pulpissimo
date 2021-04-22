module fpga_generic_ram
  #(
    parameter ADDR_WIDTH=12
    ) (
       input logic                  clk_i,
       input logic                  rst_ni,
       input logic                  csn_i,
       input logic                  wen_i,
       input logic [31:0]           be_i,
       input logic [ADDR_WIDTH-1:0] addr_i,
       input logic [31:0]           wdata_i,
       output logic [31:0]          rdata_o
   );

  logic [3:0]                       wea;

  always_comb begin
    if (wen_i == 1'b0) begin
      wea = be_i;
    end else begin
      wea = '0;
    end
  end

  xilinx_generic_ram i_xilinx_generic_ram
    (
     .clka(clk_i),
     .ena(~csn_i),
     .wea(wea),
     .addra(addr_i),
     .dina(wdata_i),
     .douta(rdata_o)
     );

endmodule : fpga_generic_ram