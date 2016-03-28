module crc16(
	rst,     /*async reset,active low*/
   clk,     /*clock input*/
	crc_en,
	crc_clr,
   data_in, /*parallel data input pins */
   crc
);

input            rst;     /*async reset,active low*/
input            clk;     /*clock input*/
input 			  crc_en;
input 			  crc_clr;
input     [7:0]  data_in; /*parallel data input pins */
output    [15:0] crc;

wire [15:0] crc;
reg [15:0] crc_out_temp;

always @(posedge clk or negedge rst)
begin
    if(!rst) 
		begin
        //crc_back <= 16'Hffff;          //触发器中的初始值十分重要
		  crc_out_temp <= 16'Hffff;
		end
    else if(crc_en)
        crc_out_temp <= nextCRC16_D8({data_in[0],data_in[1],data_in[2],data_in[3],data_in[4],data_in[5],data_in[6],data_in[7]}, crc_out_temp);
	else if(crc_clr)
		crc_out_temp <= 16'Hffff;
end

assign crc = {crc_out_temp[0],crc_out_temp[1],crc_out_temp[2],crc_out_temp[3],crc_out_temp[4],crc_out_temp[5],crc_out_temp[6]
				 ,crc_out_temp[7],crc_out_temp[8],crc_out_temp[9],crc_out_temp[10],crc_out_temp[11],crc_out_temp[12],crc_out_temp[13]
				 ,crc_out_temp[14],crc_out_temp[15]};
////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 1999-2008 Easics NV.
// This source file may be used and distributed without restriction
// provided that this copyright statement is not removed from the file
// and that any derivative work contains the original copyright notice
// and the associated disclaimer.
//
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// Purpose : synthesizable CRC function
//   * polynomial: (0 2 15 16)
//   * data width: 8
//
// Info : tools@easics.be
//        http://www.easics.com
////////////////////////////////////////////////////////////////////////////////

  // polynomial: (0 2 15 16)
  // data width: 8
  // convention: the first serial bit is D[7]
  function [15:0] nextCRC16_D8;

    input [7:0] Data;
    input [15:0] crc_temp;
    reg [7:0] d;
    reg [15:0] c;
    reg [15:0] newcrc;
  begin
    d = Data;
    c = crc_temp;

    newcrc[0] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
    newcrc[1] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
    newcrc[2] = d[1] ^ d[0] ^ c[8] ^ c[9];
    newcrc[3] = d[2] ^ d[1] ^ c[9] ^ c[10];
    newcrc[4] = d[3] ^ d[2] ^ c[10] ^ c[11];
    newcrc[5] = d[4] ^ d[3] ^ c[11] ^ c[12];
    newcrc[6] = d[5] ^ d[4] ^ c[12] ^ c[13];
    newcrc[7] = d[6] ^ d[5] ^ c[13] ^ c[14];
    newcrc[8] = d[7] ^ d[6] ^ c[0] ^ c[14] ^ c[15];
    newcrc[9] = d[7] ^ c[1] ^ c[15];
    newcrc[10] = c[2];
    newcrc[11] = c[3];
    newcrc[12] = c[4];
    newcrc[13] = c[5];
    newcrc[14] = c[6];
    newcrc[15] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[7] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
    nextCRC16_D8 = newcrc;
  end
  endfunction
  
endmodule
