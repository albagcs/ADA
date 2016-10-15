--Alba García de la Camacha Selgas
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Lower_Layer_UDP;

package Chat_Messages is
       
        package ASU renames Ada.Strings.Unbounded;
       	package TIO renames Ada.Text_IO;
       	package LLU renames Lower_Layer_UDP;
       	
        type Message_Type is (Init, Writer, Server);
        type Message is record 
                EP: LLU.End_Point_Type;
                Comentario: ASU.Unbounded_String;
                Nick: ASU.Unbounded_String;
        end record;
 
end Chat_Messages;
