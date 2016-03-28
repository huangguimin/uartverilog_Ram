`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    17:11:32 08/28/08
// Design Name:    
// Module Name:    my_uart_rx
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
module my_uart_rx(
				clk,rst_n,
				rs232_rx,rx_data,rx_int,
				clk_bps,bps_start
			);

input clk;		// 50MHz��ʱ��
input rst_n;	//�͵�ƽ��λ�ź�
input rs232_rx;	// RS232���������ź�
input clk_bps;	// clk_bps�ĸߵ�ƽΪ���ջ��߷�������λ���м�������
output bps_start;		//���յ����ݺ󣬲�����ʱ�������ź���λ
output[7:0] rx_data;	//�������ݼĴ������ֱ����һ��������� 
output rx_int;	//���������ж��ź�,���յ������ڼ�ʼ��Ϊ�ߵ�ƽ

//----------------------------------------------------------------
reg rs232_rx0,rs232_rx1,rs232_rx2,rs232_rx3;	//�������ݼĴ������˲���
wire neg_rs232_rx;	//��ʾ�����߽��յ��½���

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			rs232_rx0 <= 1'b0;
			rs232_rx1 <= 1'b0;
			rs232_rx2 <= 1'b0;
			rs232_rx3 <= 1'b0;
		end
	else begin
			rs232_rx0 <= rs232_rx;
			rs232_rx1 <= rs232_rx0;
			rs232_rx2 <= rs232_rx1;
			rs232_rx3 <= rs232_rx2;
		end
end
	//�������½��ؼ��������˵�<20ns-40ns��ë��(����������͵�����ë��)��
	//������������Դ���ȶ���ǰ�������Ƕ�ʱ��Ҫ��������ô��̣���Ϊ�����źŴ��˺ü��ģ� 
	//����Ȼ���ǵ���Ч�������źſ϶���ԶԶ����40ns�ģ�
assign neg_rs232_rx = rs232_rx3 & rs232_rx2 & ~rs232_rx1 & ~rs232_rx0;	//���յ��½��غ�neg_rs232_rx�ø�һ��ʱ������

//----------------------------------------------------------------
reg bps_start_r;
reg[3:0] num;	//��λ����
reg rx_int;		//���������ж��ź�,���յ������ڼ�ʼ��Ϊ�ߵ�ƽ

always @ (posedge clk or negedge rst_n)
	if(!rst_n) begin
			bps_start_r <= 1'b0;
			rx_int <= 1'b0;
		end
	else if(neg_rs232_rx) begin		//���յ����ڽ�����rs232_rx���½��ر�־�ź�
			bps_start_r <= 1'b1;	//�����׼�����ݽ���
			rx_int <= 1'b1;			//���������ж��ź�ʹ��
		end
	else if(num==4'd10) begin		//����������������Ϣ
			bps_start_r <= 1'b0;	//���ݽ������ϣ��ͷŲ����������ź�
			rx_int <= 1'b0;			//���������ж��źŹر�
		end

assign bps_start = bps_start_r;

//----------------------------------------------------------------
reg[7:0] rx_data_r;		//���ڽ������ݼĴ������ֱ����һ���������
//----------------------------------------------------------------

reg[7:0] rx_temp_data;	//��ǰ�������ݼĴ���

always @ (posedge clk or negedge rst_n)
	if(!rst_n) begin
			rx_temp_data <= 8'd0;
			num <= 4'd0;
			rx_data_r <= 8'd0;
		end
	else if(rx_int) begin	//�������ݴ���
		if(clk_bps) begin	//��ȡ����������,��������Ϊһ����ʼλ��8bit���ݣ�1��2������λ		
				num <= num + 1'b1;
				case (num)
						4'd1: rx_temp_data[0] <= rs232_rx;	//������0bit
						4'd2: rx_temp_data[1] <= rs232_rx;	//������1bit
						4'd3: rx_temp_data[2] <= rs232_rx;	//������2bit
						4'd4: rx_temp_data[3] <= rs232_rx;	//������3bit
						4'd5: rx_temp_data[4] <= rs232_rx;	//������4bit
						4'd6: rx_temp_data[5] <= rs232_rx;	//������5bit
						4'd7: rx_temp_data[6] <= rs232_rx;	//������6bit
						4'd8: rx_temp_data[7] <= rs232_rx;	//������7bit
						default:;
					endcase
			end
		else if(num == 4'd10) begin		//���ǵı�׼����ģʽ��ֻ��1+8+1(2)=11bit����Ч����
				num <= 4'd0;			//���յ�STOPλ������,num����
				rx_data_r <= rx_temp_data;	//���������浽���ݼĴ���rx_data��
			end
		end

assign rx_data = rx_data_r;	

endmodule
