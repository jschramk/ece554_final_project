// `include "cci_mpf_if.vh"

module afu (
    input clk,
    input rst,
    dma_if.peripheral dma
);

localparam int CL_ADDR_WIDTH = 32;
localparam pSIZE = 16;
localparam INPUT_SIZE = 512;
localparam SAMPLES = 2048;
localparam COEFF_BITS = 8;
localparam FFT_BUS_SIZE = 44;
localparam IFFT_BUS_SIZE = 56;

// I want to just use dma.count_t, but apparently
// either SV or Modelsim doesn't support that. Similarly, I can't
// just do dma.SIZE_WIDTH without getting errors or warnings about
// "constant expression cannot contain a hierarchical identifier" in
// some tools. Declaring a function within the interface works just fine in
// some tools, but in Quartus I get an error about too many ports in the
// module instantiation.
typedef logic [CL_ADDR_WIDTH:0] count_t;
//count_t size;
logic go;
logic done;

// Software provides 64-bit virtual byte addresses.
// Again, this constant would ideally get read from the DMA interface if
// there was widespread tool support.
localparam int VIRTUAL_BYTE_ADDR_WIDTH = 64;

// Instantiate the memory map, which provides the starting read/write
// 64-bit virtual byte addresses, a transfer size (in cache lines), and a
// go signal. It also sends a done signal back to software.

wire local_dma_re, local_dma_we;

wire [1:0] mem_op;
wire [VIRTUAL_BYTE_ADDR_WIDTH-1:0] cpu_addr;
logic [VIRTUAL_BYTE_ADDR_WIDTH-1:0] final_addr;
logic [VIRTUAL_BYTE_ADDR_WIDTH-1:0] wr_addr_s0;
logic [VIRTUAL_BYTE_ADDR_WIDTH-1:0] wr_addr_s1;
logic [VIRTUAL_BYTE_ADDR_WIDTH-1:0] wr_addr_s2;
logic [VIRTUAL_BYTE_ADDR_WIDTH-1:0] wr_addr_s3;
logic [VIRTUAL_BYTE_ADDR_WIDTH-1:0] cv_value;
wire tx_done;
wire ready;
wire rd_valid;
wire rd_go;
wire wr_go;

wire [31:0] cpu_in;
wire [31:0] cpu_out; // Todo, parameterize

CPU cpu(
    .clk(clk),
    .rst_n(~rst),
    .tx_done(tx_done),
    .rd_valid(rd_valid),
    .dma_ready(ready),
    .instr_write_en(),
    .cache_stall(),
    .mem_write_en(),
    .op(mem_op),
    .io_address(cpu_addr),
    .common_data_bus_in(cpu_in),

    //Outputs
    .audio_out(cpu_out),
    .syn(),
    .set_en(),
    .set_freq(),
    .imm(),
    .mem_address()

    // .audio_valid(), .syn(), .set_en(), .set_freq(),
    // output [IMMW-1:0] imm,
    // output [1:0] op,
    // output [ADDRW-1:0] mem_address,
    // output [INW-1:0] audio_out
);

// Memory Controller module
mem_ctrl memory(
    .clk(clk),
    .rst_n(~rst),
    .host_init(go),
    .host_rd_ready(~dma.empty),
    .host_wr_ready(~dma.full & ~dma.host_wr_completed),
    .op(mem_op), // CPU Defined
    .common_data_bus_read_in(cpu_out), // CPU data word bus, input
    .common_data_bus_write_out(cpu_in),
    .host_data_bus_read_in(dma.rd_data),
    .host_data_bus_write_out(dma.wr_data),
    .ready(ready), // Usable for the host CPU
    .tx_done(tx_done), // Again, notifies CPU when ever a read or write is complete
    .rd_valid(rd_valid), // Notifies CPU whenever the data on the databus is valid
    .host_re(local_dma_re),
    .host_we(local_dma_we),
    .host_rgo(rd_go),
    .host_wgo(wr_go)
);

addr_tr_unit atu
(
    .virtual_addr(cpu_addr),
    .base_address_s0(wr_addr_s0),
    .base_address_s1(wr_addr_s1),
    .base_address_s2(wr_addr_s2),
    .base_address_s3(wr_addr_s3),
    .corrected_address(final_addr)
);

CacheThief thief
(.rd_valid(local_dma_re), .wr_valid(local_dma_we), .en(mem_op !== 0 && tx_done == 0),
    .cpu_addr_top(cpu_addr[ADDR_BITCOUNT-1 -:1]),
    .data_cache_re(data_cache_re), .instr_cache_re(instr_write_en), 
    .data_cache_we(data_cache_we), .stall(cache_stall)
);


AudioProcessor #(
    .SIZE(pSIZE),
    .INPUT_SIZE(INPUT_SIZE),
    .SAMPLES(SAMPLES),
    .COEFF_BITS(COEFF_BITS),
    .FFT_BUS_SIZE(FFT_BUS_SIZE),
    .IFFT_BUS_SIZE(IFFT_BUS_SIZE)
) AudioProc (
    // Inputs
    // control inputs
    .clk(clk), .rst_n(~rst),
    // start processing (SYN instruction)
    .start(),                       // input start,
    // input wave data (LDE instruction)
    .data_wr_en(),                  // input data_wr_en,
    .input_index(),                 // input [$clog2(INPUTS_TO_FILL)-1:0] input_index,
    .data_in(),                     // input [INPUT_SIZE-1:0] data_in,
    // pitch shift (SPM instruction)
    .pitch_shift_wr_en(),           // input pitch_shift_wr_en,
    .pitch_shift_semitones(),       // input [4:0] pitch_shift_semitones,
    // frequency coefficients (SFC instruction)
    .freq_coeff_wr_en(),            // input freq_coeff_wr_en,
    .freq_coeff_index(),            // input [$clog2(SAMPLES)-1:0] freq_coeff_index,
    .freq_coeff_in(),               // input [COEFF_BITS-1:0] freq_coeff_in,
    // overdrive
    .overdrive_enable_wr_en(),      // input overdrive_enable_wr_en, // write enable for OD enable bus
    .overdrive_enable_in(),         // input overdrive_enable_in,
    .overdrive_magnitude_wr_en(),   // input overdrive_magnitude_wr_en,
    .overdrive_magnitude(),         // input [3:0] overdrive_magnitude,
    // tremolo
    .tremelo_enable_wr_en(),        // input tremolo_enable_wr_en,
    .tremelo_enable_in(),           // input tremolo_enable_in,
    // output select
    .output_index(),                // input [$clog2(INPUTS_TO_FILL)-1:0] output_index,

    // Outputs
    // output wave data (STE instruction)
    .data_out(),                // output [INPUT_SIZE-1:0] data_out,
    // flag for when data is ready to be read back out
    .done()                     // output done
);


// Assign the starting addresses from the memory map.
assign dma.rd_addr = cpu_addr;
assign dma.wr_addr = cpu_addr;

// Use the size (# of cache lines) specified by the design.
wire [CL_ADDR_WIDTH:0] size;
assign size = 1; // hardcoded for now

assign dma.rd_size = size;
assign dma.wr_size = size;

// Start both the read and write channels when the MMIO go is received.
// Note that writes don't actually occur until dma.wr_en is asserted.
assign dma.rd_go = rd_go;
assign dma.wr_go = wr_go;

// Read from the DMA when there is data available (!dma.empty) and when
// it is safe to write data (!dma.full).
assign dma.rd_en = local_dma_re;

// Since this is a simple loopback, write to the DMA anytime we read.
// For most applications, write enable would be asserted when there is an
// output from a pipeline. In this case, the "pipeline" is a wire.
assign dma.wr_en = local_dma_we;

// The AFU is done when the DMA is done writing size cache lines.
assign done = dma.wr_done;
 
endmodule