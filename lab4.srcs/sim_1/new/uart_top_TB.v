`timescale 1ns / 1ps

module uart_top_TB;

  parameter CLK_FREQ = 125_000_000;
  parameter BAUD_RATE = 115_200;
  parameter CLK_PERIOD = 8; // 125MHz -> 8ns
  parameter OPERAND_WIDTH = 512;
  parameter NBYTES = OPERAND_WIDTH / 8;

  // UART bit period in ns
  parameter UART_BIT_PERIOD_NS = 1_000_000_000 / BAUD_RATE;

  reg iClk = 0;
  reg iRst = 1;
  reg iRx = 1;
  wire oTx;

  // Instantiate DUT
  uart_top #(
    .OPERAND_WIDTH(OPERAND_WIDTH),
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
  ) DUT (
    .iClk(iClk),
    .iRst(iRst),
    .iRx(iRx),
    .oTx(oTx)
  );

  // Generate 125 MHz clock
  always #(CLK_PERIOD / 2) iClk = ~iClk;

  // UART byte send with accurate timing
  task uart_send_byte(input [7:0] data);
    integer i;
    begin
      iRx = 0; #(UART_BIT_PERIOD_NS); // Start bit
      for (i = 0; i < 8; i = i + 1) begin
        iRx = data[i];
        #(UART_BIT_PERIOD_NS);
      end
      iRx = 1; #(UART_BIT_PERIOD_NS); // Stop bit
    end
  endtask

  // FSM ADD state cycle counter
  integer add_cycles = 0;
  reg in_add_state = 0;

  always @(posedge iClk) begin
    if (DUT.rFSM == 3'b011) begin
      add_cycles <= add_cycles + 1;
      in_add_state <= 1;
    end else if (in_add_state) begin
      $display("FSM ADD state duration: %0d cycles", add_cycles);
      in_add_state <= 0;
    end
  end

  // rStartAdd to wAddDone
  integer real_add_cycles = 0;
  reg counting = 0;

  always @(posedge iClk) begin
    if (DUT.rStartAdd == 1) begin
      counting <= 1;
      real_add_cycles <= 0;
    end else if (counting && DUT.wAddDone == 0) begin
      real_add_cycles <= real_add_cycles + 1;
    end else if (counting && DUT.wAddDone == 1) begin
      $display("Accurate mp_adder duration: %0d cycles", real_add_cycles);
      counting <= 0;
    end
  end

  // Timeout protection
  initial begin
    #60_000_000; // 60ms
    $display("Timeout: FSM did not reach DONE state.");
    $finish;
  end

  // Test sequence
  initial begin
    #100;
    iRst = 0;

    $display("Sending OP_ADD...");
    uart_send_byte(8'h00);

    $display("Sending operand A...");
    repeat (NBYTES) uart_send_byte(8'h11);

    $display("Sending operand B...");
    repeat (NBYTES) uart_send_byte(8'h22);

    wait (DUT.rFSM == 3'b110); // s_DONE
    $display("FSM reached DONE state.");

    #1000;
    $finish;
  end

endmodule
