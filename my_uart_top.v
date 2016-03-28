`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:
// Design Name:    
// Module Name:    my_uart_top
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module my_uart_top(
				clk_int,rst_n,rs232_rx,
				rs232_tx,pwm_pin,pwm_dir,test_pin
				);

input clk_int;			// 50MHz��ʱ��
input rst_n;		//�͵�ƽ��λ�ź�

input rs232_rx;		// RS232���������ź�
output rs232_tx;	//	RS232���������ź�
output pwm_pin,pwm_dir,test_pin;

wire[7:0] rx_data;	//�������ݼĴ������ֱ����һ���������
wire[7:0] tx_data;	//�������ݼĴ������ֱ����һ���������
wire[7:0] calc_data;
wire rx_int;		//���������ж��ź�,���յ������ڼ�ʼ��Ϊ�ߵ�ƽ

wire flen;
wire tx_end;
wire full_rx;
wire empty_rx;

wire clk,pwm_clk;

wire wren_ram;
//wire test_pin;

PLL 			PLL(
						.inclk0(clk_int),
						.c0(clk),
						.c1(pwm_clk)
					);
//----------------------------------------------------
//�������ĸ�ģ���У�speed_rx��speed_tx�������ȫ�����Ӳ��ģ�飬�ɳ�֮Ϊ�߼�����
//��������Դ�����������е�ͬһ���ӳ������ò��ܻ�Ϊһ̸��
////////////////////////////////////////////
my_uart_rx_top			my_uart_rx(		
											.clk(clk),	//��������ģ��
											.rst_n(rst_n),
											
											.rs232_rx(rs232_rx),
											.rx_data(rx_data),
											.rx_int(rx_int)
						);
/*
wire [12:0] fifo_data_num;
wire [23:0] fifo_data_out;
wire [6:0] fifo_data_count;
reg fifo_data_reden;
reg fifo_data_wren;
reg fifo_clr;
reg [23:0] fifo_data_in;
wire fifo_data_empty,fifo_data_full;
fifo_data					fifo_data(
											.sclr(fifo_clr),
											.clock(clk),
											.data(fifo_data_in),
											.rdreq(fifo_data_reden),
											.wrreq(fifo_data_wren),
											.empty(fifo_data_empty),
											.full(fifo_data_full),
											.q(fifo_data_out),
											.usedw(fifo_data_count)
						);					

reg [3:0] stat_fifo;
always @ (posedge clk or negedge rst_n) 
begin
	if(!rst_n) begin
			fifo_data_reden <= 1'b0;
			stat_fifo <= 4'd7;
			//pwm_target1 <= 24'd0;
		end
	else 
			begin
				case (stat_fifo)
					4'd7:
						if(fifo_data_count >= 7'd1)
							stat_fifo <= 4'd0;
					4'd0:
						if(!fifo_data_empty)
						begin 
							fifo_data_reden <= 1'b1;
							stat_fifo <= 4'd1;
						end
						else
							stat_fifo <= 4'd7;
					4'd1:
						begin 
							fifo_data_reden <= 1'b0;
							stat_fifo <= 4'd2;
						end
					4'd2:begin stat_fifo <= 4'd3;pwm_target1 <= $signed(fifo_data_out);end
					4'd3:stat_fifo <= 4'd4;
					4'd4:stat_fifo <= 4'd5;
					4'd3:
						if(pwm_end)
						begin	
							stat_fifo <= 4'd0;
						end
				endcase
			end
end
*/
/*
reg pwm_end_reg;
wire pwm_end_p;
always @ (posedge clk or negedge rst_n) 
begin
	if(!rst_n) begin
		pwm_end_reg <= 1'b0;
		end
	else 
		begin
			pwm_end_reg <= pwm_end;
		end
end
assign pwm_end_p = pwm_end & ~pwm_end_reg;
*/
//---------------------MOTOR----------------------------
wire pwm_end;
reg [15:0] pwm_speed_reg;
motor					motor(
							.clk(clk),
							.pwm_clk(pwm_clk),
							.reset_n(rst_n),
							.pwm_target(pwm_target1),
							.pwm_speed(pwm_speed_reg),
							.pwm_out(pwm_pin),
							.dir_out(pwm_dir),
							.pwm_end(pwm_end)
						);

reg wren1;	//rx_int�źżĴ����׽�½����˲���

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			wren1 <= 1'b0;
		end
	else begin
			wren1 <= rx_int;
		end
end

assign wren_ram =  ~rx_int & wren1;
							
reg wren_tx;
reg [7:0] calc_data_temp;
reg [7:0] calc_data_buf[31:0];

parameter state0 = 4'd0;
parameter state1 = 4'd1;
parameter state2 = 4'd2;
parameter state3 = 4'd3;
parameter state4 = 4'd4;
parameter state5 = 4'd5;
parameter state6 = 4'd6;
parameter state7 = 4'd7;
parameter state8 = 4'd8;
parameter state9 = 4'd9;
parameter state10 = 4'd10;
parameter state11 = 4'd11;

reg [4:0]  addr;
reg [4:0]  crc_num1;
reg [4:0]  crc_num2;
reg [15:0] crc_data_temp;
reg signed [23:0] pwm_target1;

reg [3:0] state;
wire[15:0] crc_data; 
reg crc_clr;
reg crc_en;

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) 
		begin
			state <= state0;
			calc_data_temp <= 8'd0;
			wren_tx <= 1'b0;
			addr <= 5'd0;
			crc_clr <= 1'b0;
			crc_en <= 1'b0;
			crc_num1 <= 5'd0;
			crc_num2 <= 5'd0;
			crc_data_temp <= 16'd0;
			calc_data_buf[0] <= 8'd0;
			calc_data_buf[1] <= 8'd0;
			pwm_target1 <= 24'd0;
		end
	else begin
		case(state)
		state0:
			begin
			if(en_3_5) 
				begin
				state <= state2;
				crc_num1 <= addr - 2'd2;
				crc_num2 <= addr - 2'd1;
				addr <= 5'd0;
				crc_en <= 1'b0;
				end
			else if(wren_ram) 
				begin
				crc_clr <= 1'b0;
				crc_en <= 1'b1;
				addr <= addr + 1'b1;
				calc_data_buf[addr] <= rx_data;
				state <= state3;
				end
			end
			
		state6:
				if(crc_data_temp2 == crc_data_temp)
					begin
						state <= state8;
					end
				else
					begin
						state <= state10;
						crc_clr <= 1'b1;
					end
		state10:
			begin
					calc_data_buf[0] <= 8'hFF;
					calc_data_buf[1] <= 8'hFF;
					calc_data_buf[2] <= 8'hFF;
					calc_data_buf[3] <= 8'hFF;
					calc_data_buf[4] <= 8'hFF;
					calc_data_buf[5] <= 8'hFF;
					crc_num1	<= 6;
					state <= state4;
			end
				
		state8:
				begin
					if(calc_data_buf[0] == 8'h01)
					begin
						pwm_target1 <= {calc_data_buf[1],calc_data_buf[2],calc_data_buf[3]};
					end
					else if(calc_data_buf[0] == 8'h02)
						pwm_speed_reg <= {calc_data_buf[1],calc_data_buf[2]};
					state <= state9;
				end
		state9:
				begin
					state <= state4;
					addr <= 5'd0;
				end
			
		state2:
			begin
				state <= state6;
		 		crc_data_temp <= {calc_data_buf[crc_num1],calc_data_buf[crc_num2]};
			end
		
		state3:
			begin
				crc_en <= 1'b0;
				state  <= state0;
			end

		state4:
				if(addr < crc_num1) 
					begin
						wren_tx <= 1'b1;
						addr <= addr + 1'b1;
						calc_data_temp <= calc_data_buf[addr];
					end
				else begin
						wren_tx <= 1'b0;
						addr <= 5'd0;
						calc_data_temp <= 8'd0;
						state <= state5;
					end
		
		default:
				if(addr < 5'd2) 
				   begin
						wren_tx <= 1'b1;
						addr <= addr + 1'b1;
						crc_clr <= 1'b1;
						if(!addr)
							calc_data_temp <= crc_data_temp2[15:8];
						else
							calc_data_temp <= crc_data_temp2[7:0];
					end 
				else
					begin
						wren_tx <= 1'b0;
						addr <= 5'd0;
						calc_data_temp <= 8'd0;
						state <= state0;
						crc_clr <= 1'b0;
					end
		endcase
		
		end
end


reg [15:0] crc_data_temp1; 
reg [15:0] crc_data_temp2; 

always @ (posedge clk or negedge rst_n)
	if(!rst_n) 
		begin
			crc_data_temp1 <= 16'd0;
			crc_data_temp2 <= 16'd0;
		end
	else if(wren_ram)
		begin
			crc_data_temp1 <= crc_data;
			crc_data_temp2 <= crc_data_temp1;
		end
	else if(state == state10)
		crc_data_temp2 <= 16'h9401;
		
//3.8byte count when 115200bds
`define		BYTE3_5		24'd30380//24'd30380//24'd75950 //21700*3.5
reg [23:0] count3_5;
reg en_3_5;
reg [1:0] state3_5;
always @ (posedge clk or negedge rst_n)
	if(!rst_n) 
		begin
			count3_5 <= 24'd0;
			en_3_5 <= 1'b0;
			state3_5 <= 2'd0;
		end
	else 
		begin
			case(state3_5)	
			2'd0:	
				if(wren_ram)
					state3_5 <= 2'd1;
			2'd1:
				if(wren_ram)
					count3_5 <= 24'd0;
				else if(count3_5 <= `BYTE3_5)
					begin
						count3_5 <= count3_5 + 1'b1;
					end
				else if(count3_5 > `BYTE3_5)
					begin
						en_3_5 <= 1'b1;
						state3_5 <= 2'd2;
						count3_5 <= 24'd0;
					end
			2'd2:
				begin
					state3_5 <= 2'd0;
					en_3_5 <= 1'b0;
				end
			endcase
		end

assign test_pin = wren_ram;

//CRC16
crc16						crc16(
								.rst(rst_n), //async reset,active low
								.clk(clk),     //clock input
								.crc_en(crc_en),
								.crc_clr(crc_clr),
								.data_in(rx_data), 		//parallel data input pins 
								.crc(crc_data)
							);
//assign calc_data = calc_data_temp;
///////////////////////////////////////////	

wire full_tx;
wire empty_tx;
fifo_tx					fifo_tx(
											.clock(clk),
											.data(calc_data_temp),
											.rdreq(reen),
											.wrreq(wren_tx),
											.empty(empty_tx),
											.full(full_tx),
											.q(tx_data)
						);					
my_uart_tx_top			my_uart_tx(		
											.clk(clk),	//��������ģ��
											.rst_n(rst_n),
											.rs232_tx(rs232_tx),							
											.tx_data(tx_data),
											.tx_int(send_bity_en),
											.tx_end(tx_end)
						);
reg [2:0] send_state;
reg reen,send_bity_en;					
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		send_bity_en <= 1'b0;
		reen <= 1'b0;
		send_state = 3'd0;
		end
	else 
		begin
			case (send_state)
				3'd0:
					if(!empty_tx&&!tx_end)
					begin
						reen <= 1'b1;
						send_state <= 3'd1;
					end
				3'd1:
					begin
						reen <= 1'b0;
						send_bity_en <= 1'b1;
						send_state <= 3'd2;
					end
				3'd2:
					begin
						send_bity_en <= 1'b0;
						send_state <= 3'd0;
					end
			endcase
		end
end

endmodule
