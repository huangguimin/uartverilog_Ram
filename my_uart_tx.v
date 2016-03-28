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
module my_uart_tx(
				clk,rst_n,
				tx_data,tx_int,rs232_tx,
				clk_bps,bps_start,tx_end
			);

input clk;			// 50MHz��ʱ��
input rst_n;		//�͵�ƽ��λ�ź�
input clk_bps;		// clk_bps_r�ߵ�ƽΪ��������λ���м�������,ͬʱҲ��Ϊ�������ݵ����ݸı���
input [7:0] tx_data;	//�������ݼĴ���
input tx_int;		//���������ж��ź�,���յ������ڼ�ʼ��Ϊ�ߵ�ƽ,�ڸ�ģ�������������½��������ڷ�������
output rs232_tx;	// RS232���������ź�
output bps_start;	//���ջ���Ҫ�������ݣ�������ʱ�������ź���λ
output tx_end;
//---------------------------------------------------------
reg tx_int0;	//rx_int�źżĴ����׽�½����˲���
wire neg_tx_int;	// rx_int�½��ر�־λ

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			tx_int0 <= 1'b0;
		end
	else begin
			tx_int0 <= tx_int;
		end
end

assign neg_tx_int =  tx_int & ~tx_int0;	//��׽���½��غ���neg_rx_int��߱���һ����ʱ������

//---------------------------------------------------------
reg[7:0] tx_data_temp;	//���������ݵļĴ���
//---------------------------------------------------------
reg bps_start_r;
reg tx_en;	//��������ʹ���źţ�����Ч
reg[3:0] num;
reg tx_end;
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			bps_start_r <= 1'b0;
			tx_en <= 1'b0;
			tx_data_temp <= 8'd0;
			tx_end <= 1'b0;
		end
	else if(neg_tx_int) begin	//�����������ϣ�׼���ѽ��յ������ݷ���ȥ
			bps_start_r <= 1'b1;
			tx_data_temp <= tx_data;	//�ѽ��յ������ݴ��뷢�����ݼĴ���
			tx_en <= 1'b1;		//���뷢������״̬��
			tx_end <= 1'b1;
		end
	else if(num==4'd10) begin	//���ݷ������ɣ���λ
			bps_start_r <= 1'b0;
			tx_en <= 1'b0;
			tx_end <= 1'b0;
		end
end

assign bps_start = bps_start_r;

//---------------------------------------------------------
reg rs232_tx_r;

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			num <= 4'd0;
			rs232_tx_r <= 1'b1;
		end
	else if(tx_en) begin
			if(clk_bps)	begin
					num <= num+1'b1;
					case (num)
						4'd0: rs232_tx_r <= 1'b0; 	//������ʼλ
						4'd1: rs232_tx_r <= tx_data_temp[0];	//����bit0
						4'd2: rs232_tx_r <= tx_data_temp[1];	//����bit1
						4'd3: rs232_tx_r <= tx_data_temp[2];	//����bit2
						4'd4: rs232_tx_r <= tx_data_temp[3];	//����bit3
						4'd5: rs232_tx_r <= tx_data_temp[4];	//����bit4
						4'd6: rs232_tx_r <= tx_data_temp[5];	//����bit5
						4'd7: rs232_tx_r <= tx_data_temp[6];	//����bit6
						4'd8: rs232_tx_r <= tx_data_temp[7];	//����bit7
						4'd9: rs232_tx_r <= 1'b1;	//���ͽ���λ
					 	default: rs232_tx_r <= 1'b1;
						endcase
				end
			else if(num==4'd10) num <= 4'd0;	//��λ
		end
end

assign rs232_tx = rs232_tx_r;

endmodule


