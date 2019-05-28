// FSM Design Verilog
// DMA/TDSP Bus Arbiter
// Asynchronous reset, active high
//

module arb_v (
	reset,
	clk,
	dma_breq,
	dma_grant,
	tdsp_breq,
	tdsp_grant
	);
  
  input
  	reset,
  	clk,
  	dma_breq,
  	tdsp_breq;
  
  output reg
  	dma_grant,
  	tdsp_grant;

  
  // include state encodings defined in arb.h
  `include "arb.h"
  
  // STATE REGISTERS
  reg [2:0] state; // current state
  reg [2:0] next_state;
  
  always@(posedge clk or posedge reset)
    begin
      if(reset)
        begin
          state <= `IDLE;
        end
      else
        state <= next_state;
    end
  
  // Compute next state based on present state: combinational logic
  always@(state or tdsp_breq or dma_breq)
    begin
      case (state)
        `IDLE:
          begin
          	if(tdsp_breq)
            	next_state = `GRANT_TDSP;
          	else if(dma_breq)
            	next_state = `GRANT_DMA;
				else next_state = `IDLE;
        	end
        `GRANT_TDSP:
          begin
            if(tdsp_breq == 1'b0)
              next_state = `CLEAR;
				 else next_state = `GRANT_TDSP;
          end
        `GRANT_DMA:
          begin
            if(dma_breq == 1'b0)
              next_state = `CLEAR;
				else next_state = `GRANT_DMA;
          end
        `DMA_PRI:
          begin
            if(tdsp_breq)
              next_state = `GRANT_TDSP;
            else if(dma_breq)
              next_state = `GRANT_DMA;
            else if(!tdsp_breq && !dma_breq)
              next_state = `IDLE;
				else next_state = `DMA_PRI;
          end
        `CLEAR:
          begin
            if(tdsp_breq == 1'b1)
              next_state = `GRANT_TDSP;
            else if(dma_breq)
              next_state = `DMA_PRI;
				else next_state = `CLEAR;
          end
         default: next_state = `IDLE;
      endcase
    end
  
  // output at clock edge based on next state: Registered output, glitch free
  always@(posedge clk or posedge reset)
    begin
		if(reset)
			begin
				dma_grant <= 1'b0;
				tdsp_grant <= 1'b0;
			end
		else
			begin
				case(next_state) // based on next state assign the output

				  `IDLE:
					 begin
						dma_grant = 1'b0;
						tdsp_grant = 1'b0;
					 end
				  `GRANT_TDSP:
					 begin
						dma_grant = 1'b0;
						tdsp_grant = 1'b1;
					 end
				  `GRANT_DMA:
					 begin
						dma_grant = 1'b1;
						tdsp_grant = 1'b0;
					 end
				  `DMA_PRI:
					 begin
						dma_grant = 1'b0;
						tdsp_grant = 1'b0;
					 end
				  `CLEAR:
					 begin
						dma_grant = 1'b0;
						tdsp_grant = 1'b1;
					 end
				  default:
					 begin
						dma_grant = 1'b0;
						tdsp_grant = 1'b0;
					 end
				endcase
		end
        
    end
  
 endmodule