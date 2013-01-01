//=============================================================================
//  Fetch instruction
//
//
//  (C) 2009,2010,2012 Robert Finch, Stratford
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
// - All of the state control flags are reset.
//
// - If the current instruction is a prefix then we want to shift it
//   into the prefix buffer before fetching the instruction. Also
//   interrupts are blocked if the previous instruction is a prefix.
//
// - two bytes are fetched at once if the instruction is aligned on
//   an even address. This saves a bus cycle most of the time.
//
// ToDo:
// - add an exception if more than two prefixes are present.
//
//=============================================================================
//
IFETCH:
	begin
		// Reset all instruction processing flags at instruction fetch
		cyc_type <= `CT_PASSIVE;
		mod <= 2'd0;
		rrr <= 3'd0;
		rm <= 3'd0;
		sxi <= 1'b0;
		hasFetchedModrm <= 1'b0;
		hasFetchedDisp8 <= 1'b0;
		hasFetchedDisp16 <= 1'b0;
		hasFetchedVector <= 1'b0;
		hasStoredData <= 1'b0;
		hasFetchedData <= 1'b0;
		data16 <= 16'h0000;
		cnt <= 7'd0;
//		if (prefix1!=8'h00 && prefix2 !=8'h00 && is_prefix)
//			state <= TRIPLE_PREFIX;
		if (is_prefix) begin
			prefix1 <= ir;
			prefix2 <= prefix1;
		end
		else begin
			prefix1 <= 8'h00;
			prefix2 <= 8'h00;
		end

        if (pe_nmi & checkForInts) begin
            state <= INT2;
            rst_nmi <= 1'b1;
            int_num <= 8'h02;
            ir <= `NOP;
        end
        else if (irq_i & ie & checkForInts) begin
            state <= INTA0;
            ir <= `NOP;
        end
        else if (ir==`HLT) begin
			state <= IFETCH;
        	cyc_type <= `CT_HALT;
        end
        else begin
			state <= IFETCH_ACK;
			`INITIATE_CODE_READ
			inta_o <= 1'b0;
			mio_o <= 1'b1;
			lock_o <= bus_locked;
		end
	end

IFETCH_ACK:
	if (ack_i) begin
		`TERMINATE_CODE_READ
		ir <= dat_i;
		$display("IR: %h",dat_i);
		if (!hasPrefix)
			ir_ip <= ip;
//		ir_ip <= dat_i;
		w <= dat_i[0];
		d <= dat_i[1];
		v <= dat_i[1];
		sxi <= dat_i[1];
		sreg2 <= dat_i[4:3];
		sreg3 <= {1'b0,dat_i[4:3]};
		ir2 <= 8'h00;
		state <= DECODE;
	end

// Fetch extended opcode
//
XI_FETCH:
	begin
		`INITIATE_CODE_READ
		state <= XI_FETCH_ACK;
	end

XI_FETCH_ACK:
	if (ack_i) begin
		`TERMINATE_CODE_READ
		ir2 <= dat_i;
		state <= DECODER2;
	end
