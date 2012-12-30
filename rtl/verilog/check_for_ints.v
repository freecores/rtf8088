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
// Check for interrupts during string instructions.
//
        if (pe_nmi & checkForInts) begin
            rst_nmi <= 1'b1;
            int_num <= 8'h02;
            ir <= `NOP;
            state <= INT2;
        end
        else if (irq_i & ie & checkForInts) begin
            ir <= `NOP;
            state <= INTA0;
        end
