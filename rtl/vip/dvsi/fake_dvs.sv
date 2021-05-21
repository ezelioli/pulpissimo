timeunit 1ns;
timeprecision 1ps;

module fake_dvs
#(
  parameter bit PULP_TB = 1'b0
  )
(
  input logic     rst_ni,

  input  logic		saer_asa_i,
  input  logic        saer_are_i,
  input  logic        saer_asy_i,
  input  logic        saer_ynrst_i,
  input  logic        saer_yclk_i,
  input  logic        saer_sxy_i,
  input  logic        saer_xclk_i,
  input  logic        saer_xnrst_i,
  output logic [3:0]  saer_on_o,
  output logic [3:0]  saer_off_o,
  output logic [7:0]  saer_xydata_o,
  input  string       tb_cmd_i,
  input  logic         tb_cmd_vld_i
);

typedef struct packed {
  logic [3:0]  on;
  logic [3:0]  off;
  logic [7:0]  y;
  logic [7:0]  x;
  logic        last;   // indicates that the event is the last of a row
} dvs_evt_t;

  // first dimension:  frames
  // second dimension: events
  dvs_evt_t frames [][];
  int          frame_lens [];
// ------------------------
// SIGNAL DECLARATION
// ------------------------

logic     clk_i;
localparam XDIM = 52;
localparam YDIM = 66;

typedef enum {WAIT_4_YCLK, WAIT_LAST_YCLK,  YDATA, YDATA_LAST, WAIT_4_XCLK, XDATA, XDATA_LAST} state_type;
state_type state_d, state_q;

logic output_enable;

logic [7:0] index;
logic       xlast_out, ylast_out;
logic [7:0] address_d, address_q;

logic [3:0] ON_s, OFF_s;

logic     startup_d, startup_q;

logic XCLK_prev, YCLK_prev, SXY_prev;
logic enable;

int frame_cnt_d, frame_cnt_q, evt_cnt_d, evt_cnt_q;


// fill the event arrays
initial begin
  string evt_file;
  string line;
  automatic int    fgets_res, sscanf_res;
  automatic int    evt_idx;
  dvs_evt_t cur_evt;
  automatic int    cur_frame = -1;
  automatic int    cur_frame_events;
  automatic int    evt_fh;
  enable = 0;

  if (!$test$plusargs("FAKEDVS_IN"))
    $info("FakeDVS requires the FAKEDVS_IN plusarg: Pass it to the simulator with +FAKEDVS_IN='<file path>'. FakeDVS will not do anything!");
  else begin
    if (!$value$plusargs("FAKEDVS_IN=%s", evt_file))
      $fatal("ultra weird stuff going on...");
    evt_fh     = $fopen(evt_file, "r");
    if (evt_fh == 0)
      $fatal("FakeDVS could not open input file %s - aborting...", evt_file);

    while (!$feof(evt_fh)) begin
      fgets_res     = $fgets(line, evt_fh);
      if (fgets_res == 0)
        break;
      // skip comments
      if (line[0] == "#")
        continue;
      // new frame (hopefully)
      if (line[0] == "-") begin
        if (cur_frame >= 0 && evt_idx > 0) begin
          frames[cur_frame][evt_idx-1].last = 1'b1;
          frame_lens[cur_frame] = evt_idx;
        end
        evt_idx                           = 0;
        cur_frame++;
        sscanf_res     = $sscanf(line, "--FRAME--%d_evts", cur_frame_events);
        if (sscanf_res == 0)
          $fatal("Invalid line encountered: %s", line);
        frames            = new[cur_frame+1](frames);
        frames[cur_frame] = new[cur_frame_events];
        frame_lens = new[cur_frame+1](frame_lens);
        continue;
      end
      sscanf_res = $sscanf(line, "y=%x,x=%x,on=%x,off=%x", cur_evt.y, cur_evt.x, cur_evt.on, cur_evt.off);
      cur_evt.last = 1'b0;
      if (evt_idx > 0 && cur_evt.y != frames[cur_frame][evt_idx-1].y)
        frames[cur_frame][evt_idx-1].last = 1'b1;
      frames[cur_frame][evt_idx] = cur_evt;
      evt_idx++;
    end // while (!$feof(evt_fh))
    frames[cur_frame][evt_idx-1].last = 1'b1;
    frame_lens[cur_frame] = evt_idx;
    $info("Successfully read %d frames!", cur_frame+1);
    enable = 1;
  end // else: !if(!$test$plusargs("FAKEDVS_IN"))
end // initial begin

always #0.5ns clk_i = ~clk_i;

initial begin
  clk_i = 0;
end
// ------------------------
// Output Enable FSM
// ------------------------

// Combinational Logic
always_comb begin
  output_enable = 1'b0;
  state_d       = state_q;
  ylast_out     = 1'b0;
  xlast_out     = 1'b0;
  frame_cnt_d   = frame_cnt_q;
  evt_cnt_d     = evt_cnt_q;
  startup_d     = startup_q;

  if (enable) begin
    case(state_q)

      WAIT_4_YCLK : begin
        if(YCLK_prev==1'b1 && saer_yclk_i==1'b0) begin
          //output_enable = 1;
          if (evt_cnt_q == frame_lens[frame_cnt_q]-1) begin
            state_d       = YDATA_LAST;
            //ylast_out     = 1'b1;
          end else begin
            if (~startup_q)
              evt_cnt_d = evt_cnt_q + 1;
            startup_d   = 1'b0;
            state_d     = YDATA;
          end
        end
      end

      YDATA : begin
        output_enable = 1;
        if(saer_sxy_i==1'b1) begin
          state_d = WAIT_4_XCLK;
          //state_d = XDATA;
          output_enable = 0;
        end
      end

      YDATA_LAST : begin
        output_enable = 1;
        ylast_out     = 1'b1;
        if (~saer_ynrst_i) begin
          state_d = WAIT_LAST_YCLK;
        end
      end

      WAIT_LAST_YCLK : begin
        // see page 11 of datasheet: we need to wait for a last YCLK
        if (YCLK_prev && ~saer_yclk_i) begin
          state_d   = WAIT_4_YCLK;
          evt_cnt_d = 0;
          startup_d = 1'b1;
          if (frame_cnt_q == frames.size()-1)
            frame_cnt_d = 0;
          else
            frame_cnt_d = frame_cnt_q + 1;
        end
      end

      WAIT_4_XCLK : begin
        output_enable = 0;
        if(XCLK_prev==1'b1 && saer_xclk_i==1'b0) begin
          begin
            state_d = XDATA;
          end
        end // if (XCLK_prev==1'b1 && saer_xclk_i==1'b0)
      end

      XDATA : begin
        output_enable = 1;
        if (XCLK_prev==1'b1 && saer_xclk_i==1'b0) begin
          if (frames[frame_cnt_q][evt_cnt_q].last) begin
            state_d = XDATA_LAST;
          end else begin
            evt_cnt_d = evt_cnt_q + 1;
          end
        end
      end

      XDATA_LAST : begin
        output_enable = 1'b1;
        xlast_out     = 1'b1;
        if (saer_sxy_i==1'b0) begin
          state_d = WAIT_4_YCLK;
        end
      end
      default: output_enable = 0;
    endcase // case (state_q)
  end // if (enable)
end

// Registers
always_ff @(posedge clk_i or negedge rst_ni) begin
  if(~rst_ni) begin
    state_q <= WAIT_4_YCLK;
  end else begin
    state_q <= state_d;
  end
end

// ------------------------
// Next index logic (Phase 1)
// ------------------------

// Combinational logic
// always_comb begin

//   x_index_d = x_index_q;
//   y_index_d = y_index_q;

// //  x_index_cnt_d = x_index_cnt_q;

//   if(saer_xnrst_i == 1'b0) begin
//     x_index_d = 0;

//   end else begin
//     if(XCLK_prev==1'b1 && saer_xclk_i==1'b0) begin
//       if (

  //     case(x_index_cnt_q)

  //       0 : begin // in this case, x_index is y_index mod XDIM-1 (why?)
  // //        x_index_cnt_d = x_index_cnt_q + 1;
  //         if(y_index_q < XDIM-1) begin
  //           x_index_d = y_index_q;
  //         end else begin
  //           x_index_d = y_index_q - (XDIM-1);
  //         end
  //       end

  //       1 : begin // in this case, x_index is set to XDIM-1-y_index mod XDIM-1
  //         x_index_cnt_d = x_index_cnt_q + 1;
  //         if(y_index_q < XDIM-1) begin
  //           x_index_d = (XDIM-1) - y_index_q;
  //         end else begin
  //           x_index_d = 2*(XDIM-1) - y_index_q;
  //         end
  //       end

  //       default : begin
  //         x_index_cnt_d = x_index_cnt_q;
  //         x_index_d = 52;	// XEND
  //       end
  //     endcase
  //   end
  //  end // if (XCLK_prev==1'b1 && saer_xclk_i==1'b0)
  //end

  // if(saer_ynrst_i == 1'b0) begin
//     y_index_d = 0;

//   end else begin
//     if(SXY_prev==1'b1 && saer_sxy_i==1'b0) begin
//       if(y_index_q < YDIM) begin // all Y indices are traversed, 2 events per
//                                 // line (plus an XEND event - see X index logic above)
//         y_index_d = y_index_q + 1;
//         x_index_cnt_d = 0;
//       end else begin
//         y_index_d = 66;		// YEND
//       end
//     end
//   end
// end

// Registers
always_ff @(posedge clk_i or negedge rst_ni) begin
  if(~rst_ni) begin
    YCLK_prev <= 0;
    XCLK_prev <= 0;
    SXY_prev <= 0;
//    x_index_cnt_q <= 0;
  end else begin
    YCLK_prev <= saer_yclk_i;
    XCLK_prev <= saer_xclk_i;
    SXY_prev <= saer_sxy_i;
    //x_index_cnt_q <= x_index_cnt_d;
  end
end

// always_ff @(posedge clk_i or negedge rst_ni) begin
//   if(~rst_ni) begin
//     x_index_q <= 0;
//   end else begin
//     x_index_q <= x_index_d;
//   end
// end

// always_ff @(posedge clk_i or negedge rst_ni) begin
//   if(~rst_ni) begin
//     y_index_q <= 0;
//   end else begin
//     y_index_q <= y_index_d;
//   end
// end

// ------------------------
// Index selection
// ------------------------

// Combinational logic
always_comb begin

  index = 67;
  ON_s  = '0;
  OFF_s = '0;

  if (enable) begin
    if(saer_sxy_i==1'b1) begin
      index = (~xlast_out) ? frames[frame_cnt_q][evt_cnt_q].x : 52;
      ON_s  = frames[frame_cnt_q][evt_cnt_q].on;
      OFF_s = frames[frame_cnt_q][evt_cnt_q].off;
    end else begin
      index = (~ylast_out) ? frames[frame_cnt_q][evt_cnt_q].y : 66;
      ON_s  = 4'd0;
      OFF_s = 4'd0;
    end
  end // if (enable)
end

// -----------------------------
// ON/OFF data (2 possible values)
// -----------------------------

// Combinational logic
// always_comb begin

//   ON_d = ON_q1;
//   OFF_d = OFF_q1;

//   if (saer_are_i) begin
//     ON_d  = 4'b1010;
//     OFF_d = 4'b0101;
//   end else if(saer_sxy_i==1'b1) begin
//     if(XCLK_prev==1'b1 && saer_xclk_i==1'b0 && x_index_cnt_q<2) begin
//       ON_d = ON_q1 + 7;
//       //OFF_d = OFF_q1 - 5;
//       OFF_d = ~ON_d;
//     end
//   end
// end

// // Registers
// always_ff @(posedge clk_i or negedge rst_ni) begin
//   if(~rst_ni) begin
//     ON_q1 <= 4'b1010;
//     OFF_q1 <= 4'b0101;
//   end else begin
//     // Phase 1
//     ON_q1 <= ON_d;
//     OFF_q1 <= OFF_d;
//   end
// end

// ------------------------
// Output Enable Logic
// ------------------------

// if in PULP testbench, we only want to assign outputs if we get the
// appropriate tb_cmd
time output_del;
if (~PULP_TB) begin : out_assign_notb
assign #output_del saer_xydata_o = output_enable ? address_q : 8'b0;
assign #output_del saer_on_o  = output_enable ? ON_s : 4'b0;
assign #output_del saer_off_o   = output_enable ? OFF_s : 4'b0;
end else begin : out_assign_tb
  logic assign_out = 1'b0;
  always_comb begin : assign_outputs
    if (tb_cmd_vld_i) begin
      if (tb_cmd_i[6:15] == "FAKEDVS_ON")
        assign_out = 1'b1;
      else if (tb_cmd_i[6:16] == "FAKEDVS_OFF")
        assign_out = 1'b0;
    end
  end
  assign #output_del saer_xydata_o = assign_out ? (output_enable ? address_q : 8'b0) : 'Z;
  assign #output_del saer_on_o  = assign_out ? (output_enable ? ON_s : 4'b0) : 'Z;
  assign #output_del saer_off_o   = assign_out ? (output_enable ? OFF_s : 4'b0) : 'Z;
end // block: out_assign_tb

// ------------------------
// Address Register (Phase 2)
// ------------------------

always_ff @(posedge clk_i or negedge rst_ni) begin
  if(~rst_ni) begin
    address_q   <= 0;
    evt_cnt_q   <= 0;
    frame_cnt_q <= 0;
    startup_q   <= 1;
    output_del  <= $urandom_range(0.2,10);
  end else begin
    address_q   <= address_d;
    frame_cnt_q <= frame_cnt_d;
    evt_cnt_q   <= evt_cnt_d;
    startup_q   <= startup_d;
    output_del  <= $urandom_range(0.2,10);
  end
end

// ------------------------
// Address LUT
// ------------------------

always_comb begin
  case(index)
    00 : address_d =  8'b11110000;
    01 : address_d =  8'b11101000;
    02 : address_d =  8'b11100100;
    03 : address_d =  8'b11100010;
    04 : address_d =  8'b11100001;
    05 : address_d =  8'b11011000;
    06 : address_d =  8'b11010100;
    07 : address_d =  8'b11010010;
    08 : address_d =  8'b11010001;
    09 : address_d =  8'b11001100;
    10 : address_d =  8'b11001010;
    11 : address_d =  8'b11001001;
    12 : address_d =  8'b11000110;
    13 : address_d =  8'b11000101;
    14 : address_d =  8'b11000011;
    15 : address_d =  8'b10111000;
    16 : address_d =  8'b10110100;
    17 : address_d =  8'b10110010;
    18 : address_d =  8'b10110001;
    19 : address_d =  8'b10101100;
    20 : address_d =  8'b10101010;
    21 : address_d =  8'b10101001;
    22 : address_d =  8'b10100110;
    23 : address_d =  8'b10100101;
    24 : address_d =  8'b10100011;
    25 : address_d =  8'b10011100;
    26 : address_d =  8'b10011010;
    27 : address_d =  8'b10011001;
    28 : address_d =  8'b10010110;
    29 : address_d =  8'b10010101;
    30 : address_d =  8'b10010011;
    31 : address_d =  8'b10001110;
    32 : address_d =  8'b10001101;
    33 : address_d =  8'b10001011;
    34 : address_d =  8'b10000111;
    35 : address_d =  8'b01111000;
    36 : address_d =  8'b01110100;
    37 : address_d =  8'b01110010;
    38 : address_d =  8'b01110001;
    39 : address_d =  8'b01101100;
    40 : address_d =  8'b01101010;
    41 : address_d =  8'b01101001;
    42 : address_d =  8'b01100110;
    43 : address_d =  8'b01100101;
    44 : address_d =  8'b01100011;
    45 : address_d =  8'b01011100;
    46 : address_d =  8'b01011010;
    47 : address_d =  8'b01011001;
    48 : address_d =  8'b01010110;
    49 : address_d =  8'b01010101;
    50 : address_d =  8'b01010011;
    51 : address_d =  8'b01001110;
    52 : address_d =  8'b01001101;		//XEND
    53 : address_d =  8'b01001011;
    54 : address_d =  8'b01000111;
    55 : address_d =  8'b00111100;
    56 : address_d =  8'b00111010;
    57 : address_d =  8'b00111001;
    58 : address_d =  8'b00110110;
    59 : address_d =  8'b00110101;
    60 : address_d =  8'b00110011;
    61 : address_d =  8'b00101110;
    62 : address_d =  8'b00101101;
    63 : address_d =  8'b00101011;
    64 : address_d =  8'b00100111;
    65 : address_d =  8'b00011110;
    66 : address_d =  8'b00011101;		//YEND
    default : address_d =  0;
  endcase
end

endmodule : fake_dvs
