module inCache
  #(
    parameter TIMESTEPS=2048,
    parameter DATAW=16,
    parameter NUMVALUES=32,
    parameter NUMFIFO=3
   )
   (
    input en, rst_n, FFTReady,
    output done, rdy,
    input [DATAW-1:0] dataIn [NUMVALUES-1:0],
    output [DATAW-1:0] dataOut [TIMESTEPS-1:0]
   );

    

end module