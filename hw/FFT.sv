module FFT
  #(
    parameter TIMESTEPS=2048,
    parameter DATAW=16,
    parameter NUMVALUES=32
   )
   (
    input en, rst_n, InCacheDone, EQReady, setEn,
    output done, rdy,
    input [DATAW-1:0] dataIn [TIMESTEPS-1:0],
    output [DATAW-1:0] dataOut [(TIMESTEPS/2)-1:0]
   );



endmodule