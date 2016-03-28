module my_uart_tx_top(
				clk,rst_n,tx_data,tx_int,
				rs232_tx,tx_end
				);

input clk;			// 50MHz��ʱ��
input rst_n;		//�͵�ƽ��λ�ź�

input [7:0] tx_data;	//�������ݼĴ������ֱ����һ���������
input tx_int;
output rs232_tx;		// RS232���������ź�
output tx_end;
wire bps_start2;	//���յ����ݺ󣬲�����ʱ�������ź���λ
wire clk_bps2;		// clk_bps_r�ߵ�ƽΪ��������λ���м�������,ͬʱҲ��Ϊ�������ݵ����ݸı��� 

speed_select		speed_tx(	
							.clk(clk),	//������ѡ��ģ��
							.rst_n(rst_n),
							.bps_start(bps_start2),
							.clk_bps(clk_bps2)
						);

my_uart_tx			my_uart_tx(		
							.clk(clk),	//��������ģ��
							.rst_n(rst_n),
							.tx_data(tx_data),
							.tx_int(tx_int),
							.rs232_tx(rs232_tx),
							.clk_bps(clk_bps2),
							.bps_start(bps_start2),
							.tx_end(tx_end)
						);

endmodule
						