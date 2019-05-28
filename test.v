module test();
    reg
  	reset,
  	clk,
  	dma_breq,
  	tdsp_breq;
  
  wire
  	dma_grant,
  	tdsp_grant;
  
  
  arb_v top (
	reset,
	clk,
	dma_breq,
	dma_grant,
	tdsp_breq,
	tdsp_grant
	);
  
  
  // $timeformat[(units_number,precision_number,suffix_string,minimum_field_width)] ;
  initial 
    begin
      clk = 1'b0;
      reset = 1'b0;
      dma_breq = 1'b0;
      tdsp_breq = 1'b0;
      @(negedge clk)
      reset = 1'b1;
      repeat(2)
        @(negedge clk);
      @(negedge clk)
      reset = 1'b0;
      repeat(2)
        @(posedge clk);
      
      dma_breq = 1'b1;
      tdsp_breq = 1'b0;
      @(posedge clk)
      @(posedge clk)
      
      dma_breq = 1'b1;
      tdsp_breq = 1'b0;
      @(posedge clk)
      @(posedge clk)
      
      dma_breq = 1'b0;
      tdsp_breq = 1'b0;

      
      //repeat(256)
      //  begin
         // dma_request;
         // tdsp_request;
        //end
    end
  
  always #20 clk = ~clk;
  
  initial begin
    #2000 $finish;
  end

  
endmodule