//=============================================================================
//  CALL NEAR
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
CALL:
	begin
		`INITIATE_STACK_WRITE
		lock_o <= 1'b1;
		dat_o <= ip[15:8];
		state <= CALL1;
	end
CALL1:
	if (ack_i) begin
		state <= CALL2;
		`PAUSE_STACK_WRITE
	end
CALL2:
	begin
		state <= CALL3;
		`INITIATE_STACK_WRITE
		dat_o <= ip[7:0];
	end
CALL3:
	if (ack_i) begin
		`TERMINATE_CYCLE
		lock_o <= 1'b0;
		ip <= ip + disp16;
		state <= IFETCH;
	end
