--Alba García de la Camacha Selgas.

with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Lower_Layer_UDP;

package Chat_Messages is
       
        package ASU renames Ada.Strings.Unbounded;
       	package TIO renames Ada.Text_IO;
       	package LLU renames Lower_Layer_UDP;
       	
        type Message_Type is (Init, Reject, Confirm, Writer,Logout);
 
end Chat_Messages;
