module LEDBlink(
	input wire in_clk, 
	input wire [9:0] in_switch, 
	input wire [3:0] in_button,
	output wire [9:0] out_led, 
	output wire [6:0] seven_segment_0, 
	output wire [6:0] seven_segment_1, 
	output wire [6:0] seven_segment_2, 
	output wire [6:0] seven_segment_3, 
	output wire [6:0] seven_segment_4, 
	output wire [6:0] seven_segment_5);
	//
	wire reset = ~in_button[0];
	//
	// clock divder for 1 sec
	//
	reg [25:0] _26bit_counter;
	wire _26bit_counter_expired;
	assign _26bit_counter_expired = (_26bit_counter == 26'd49_999_999)? 1'b1: 1'b0;
	//
	always @(posedge in_clk or posedge reset)
	begin
		if (reset)
			_26bit_counter <= 26'd0;
		else
		begin
			if (_26bit_counter_expired)
				_26bit_counter <= 26'd0;
			else
				_26bit_counter <= _26bit_counter + 26'd1;
		end
	end
	//
	// LED blink latch
	//
	reg led_latch;
	//
	always @(posedge in_clk or posedge reset)
	begin
		if (reset)
			led_latch <= 1'd0;
		else
			if (_26bit_counter_expired)
				led_latch <= ~led_latch;
	end
	//
	// counter for 7 segment LED 
	//
	reg [3:0] _4bit_counter;
	//
	always @(posedge in_clk or posedge reset)
	begin
		if (reset)
			_4bit_counter <= 4'd0;
		else
			if (_26bit_counter_expired)
				_4bit_counter  <= _4bit_counter + 4'd1;
	end
	
	//assign LEDs
	seven_segment_decoder seven_segment_decoder_0(
	.in_4bit(_4bit_counter + 4'd5), 
	.out_seven_segment(seven_segment_0));
	seven_segment_decoder seven_segment_decoder_1(
	.in_4bit(_4bit_counter + 4'd4), 
	.out_seven_segment(seven_segment_1));
	seven_segment_decoder seven_segment_decoder_2(
	.in_4bit(_4bit_counter + 4'd3), 
	.out_seven_segment(seven_segment_2));
	seven_segment_decoder seven_segment_decoder_3(
	.in_4bit(_4bit_counter + 4'd2),
	.out_seven_segment(seven_segment_3));
	seven_segment_decoder seven_segment_decoder_4(
	.in_4bit(_4bit_counter + 4'd1), 
	.out_seven_segment(seven_segment_4));
	seven_segment_decoder seven_segment_decoder_5(
	.in_4bit(_4bit_counter), 
	.out_seven_segment(seven_segment_5));
	//
	assign out_led = (led_latch)? 10'b11_1111_1111: 10'b00_0000_0000;
endmodule