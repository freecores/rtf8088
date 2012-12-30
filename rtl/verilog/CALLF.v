//=============================================================================
//  CALL FAR and CALL FAR indirect
//
//
//  2009-2012 Robert Finch
//  Stratford
//  robfinch<remove>@opencores.org
//
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//
//=============================================================================
//
CALLF:
	begin
		`INITIATE_STACK_WRITE
		lock_o <= 1'b1;
		dat_o <= cs[15:8];
		state <= CALLF1;
	end
CALLF1:
	if (ack_i) begin
		`PAUSE_STACK_WRITE
		state <= CALLF2;
	end
CALLF2:
	begin
		`INITIATE_STACK_WRITE
		dat_o <= cs[7:0];
		state <= CALLF3;
	end
CALLF3:
	if (ack_i) begin
		`PAUSE_STACK_WRITE
		state <= CALLF4;
	end
CALLF4:
	begin
		`INITIATE_STACK_WRITE
		dat_o <= ip[15:8];
		state <= CALLF5;
	end
CALLF5:
	if (ack_i) begin
		`PAUSE_STACK_WRITE
		state <= CALLF6;
	end
CALLF6:
	begin
		`INITIATE_STACK_WRITE
		dat_o <= ip[7:0];
		state <= CALLF7;
	end
CALLF7:
	if (ack_i) begin
		`TERMINATE_CYCLE
		if (ir==8'hFF && rrr==3'b011)	// CALL FAR indirect
			state <= JUMP_VECTOR1;
		else begin
			cs <= selector;
			ip <= offset;
			state <= IFETCH;
		end
	end
