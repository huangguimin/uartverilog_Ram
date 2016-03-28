module my_uart_rx_top(
				clk,rst_n,rx_data,
				rs232_rx,rx_int
				);

input clk;			// 50MHz��ʱ��
input rst_n;		//�͵�ƽ��λ�ź�

input rs232_rx;		// RS232���������ź�
output [7:0] rx_data;	//�������ݼĴ������ֱ����һ���������
output rx_int;

wire bps_start1;	//���յ����ݺ󣬲�����ʱ�������ź���λ
wire clk_bps1;		// clk_bps_r�ߵ�ƽΪ��������λ���м�������,ͬʱҲ��Ϊ�������ݵ����ݸı��� 

//----------------------------------------------------
//�������ĸ�ģ���У�speed_rx��speed_tx�������ȫ�����Ӳ��ģ�飬�ɳ�֮Ϊ�߼�����
//��������Դ�����������е�ͬһ���ӳ������ò��ܻ�Ϊһ̸��
////////////////////////////////////////////
speed_select		speed_rx(	
							.clk(clk),	//������ѡ��ģ��
							.rst_n(rst_n),
							.bps_start(bps_start1),
							.clk_bps(clk_bps1)
						);

my_uart_rx			my_uart_rx(		
							.clk(clk),	//��������ģ��
							.rst_n(rst_n),
							.rs232_rx(rs232_rx),
							.rx_data(rx_data),
							.rx_int(rx_int),
							.clk_bps(clk_bps1),
							.bps_start(bps_start1)
						);
						
endmodule						
						