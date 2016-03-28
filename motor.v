module motor(
    		clk,pwm_clk,reset_n,pwm_target,pwm_speed,
			pwm_out,dir_out,pwm_end
    		);

input    clk,pwm_clk,reset_n;
input	signed [23:0] pwm_target;
input [15:0] pwm_speed;    
output	pwm_out,dir_out,pwm_end;


wire [15:0] pwm_speed_temp;
T_data 			T_data(
						.address(pwm_addr),
						.clock(clk),
						.q(pwm_speed_temp)
					);
						
reg [7:0] pwm_addr;
reg [23:0] run_lang;
reg [1:0] pwm_state;
//---------------start_acc_dec----------------
always @ (posedge clk or negedge reset_n)
begin
		if(reset_n == 1'b0)
			begin
				pwm_addr <= 8'd0;
				pwm_state <= 2'd0;
			end
		else
			begin
				if(pwm_count_reg)
				begin
						case(pwm_state)
							2'd0:
								if((pwm_speed_temp > pwm_speed)&&(pwm_addr < 8'd255)&&(pwm_addr < run_lang))
									 pwm_addr <= pwm_addr + 1'b1;
								else
									pwm_state <= 2'd1;
							2'd1:
								if(run_lang <= pwm_addr || (pwm_addr == 8'd0))
									pwm_state <= 2'd2;
								else if(pwm_speed_temp > pwm_speed)
									pwm_state <= 2'd0;
								else if(pwm_speed_temp < pwm_speed)
									pwm_addr <= pwm_addr - 1'b1;
									//pwm_addr <= pwm_speed;
							2'd2:
								if(pwm_addr > 8'd0)
									pwm_addr <= pwm_addr - 1'b1;
								else
									pwm_state <= 2'd0;
						endcase
				end
			end
end						
//--------------------------------------------------------------------
	
//判断方向是否跳变
reg dir_out_reg;
wire dir_chang;
always @ (posedge clk or negedge reset_n)
begin	
		if(reset_n == 1'b0)
			dir_out_reg <= 1'b0;
		else if(pwm_enable)
			dir_out_reg <= dir_chang_action;
end
assign dir_chang = dir_out_reg^dir_chang_action;		
		
reg pwm_enable;
reg pwm_out;
reg dir_out;

always @ (posedge clk or negedge reset_n)
begin	
		if(reset_n == 1'b0)
			dir_out	<= 1'b0;
		else if(!pwm_enable)
			dir_out <= dir_chang_action;
end

//--------------pwm_out------------------
reg [23:0] PWM_speed_counter;			
always @ (posedge pwm_clk or negedge reset_n)
begin
		if(reset_n==1'b0)
			begin
				pwm_out <= 1'b1;
				PWM_speed_counter <= 24'd0;
			end
		else
		begin
			if(pwm_enable)
			begin
				if(PWM_speed_counter < (pwm_speed_temp))
					PWM_speed_counter <= PWM_speed_counter + 1'b1;
				else
				begin	
					PWM_speed_counter <= 24'd0;
					pwm_out <= ~pwm_out;
				end
			end
			else
				pwm_out <= 1'b1;
		end
end
//----------------pwm_target-------------------
reg pwm_out_reg;
wire pwm_count_reg;
always @ (posedge clk or negedge reset_n)
begin
		if(reset_n == 1'b0)
			begin
				pwm_out_reg <= 1'd1;
			end
		else
			begin
				pwm_out_reg <= pwm_out;
			end
end
assign pwm_count_reg = pwm_out & ~pwm_out_reg;

reg signed [23:0] pwm_count_num;
reg signed [23:0] pwm_target_temp;
reg dir_chang_action;
//-------------------pwm_action----------------------
always @ (posedge clk or negedge reset_n)
begin
		if(reset_n == 1'b0)
			begin
				pwm_target_temp <= 0;
				run_lang <= 24'd0;
				dir_chang_action <= 1'b0;
			end
		else 
		begin
			if(pwm_target_temp > pwm_count_num)
				run_lang <= pwm_target_temp - pwm_count_num;
			else
				run_lang <= pwm_count_num - pwm_target_temp;
			if((pwm_speed == 16'd0) || dir_chang)
				begin
					if(dir_out)
						pwm_target_temp <= pwm_count_num + pwm_addr;
					else
						pwm_target_temp <= pwm_count_num - pwm_addr;
				end
			else if(!pwm_enable)
					pwm_target_temp <= pwm_target;
				
			if(pwm_count_num < pwm_target)
				dir_chang_action <= 1'b1;
			else if(pwm_count_num > pwm_target)
				dir_chang_action <= 1'b0;
		end
end

always @ (posedge clk or negedge reset_n)
begin
		if(reset_n==1'b0)
			begin
				pwm_count_num <= 24'd0;
				pwm_enable <= 1'b0;
			end
		else
		begin
			if(pwm_count_num < pwm_target_temp)
				begin
					if(pwm_count_reg)	
						pwm_count_num <= pwm_count_num + 1'b1;
					pwm_enable <= 1'b1;
				end 	
			else if(pwm_count_num > pwm_target_temp)
				begin
					if(pwm_count_reg)	
						pwm_count_num <= pwm_count_num - 1'b1;	
					pwm_enable <= 1'b1;
				end
			else
				pwm_enable <= 1'b0;
		end
end

assign pwm_end = ~pwm_enable;
endmodule