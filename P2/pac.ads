--Alba García de la Camacha Selgas

with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Lower_Layer_UDP;
with Chat_Messages;

package Pac is
        
        package ASU renames Ada.Strings.Unbounded;
       	package TIO renames Ada.Text_IO;
       	package LLU renames Lower_Layer_UDP;
       	package CM renames Chat_Messages;
       	use type LLU.End_Point_Type;
       	
       	type Client is record
       	        EP : LLU.End_Point_Type;
       	        Nick : ASU.Unbounded_String;
       	end record;
       	
       	type Clientes is array(1..50) of Client;
       	
       	procedure Add(Cliente: in out Clientes; Mess : CM.Message; NumC : Natural);
       	procedure Buscar(Cliente:in out Clientes; EP: LLU.End_Point_Type; Nick: out ASU.Unbounded_String; NumC : Natural);
end Pac;
