--Alba García de la Camacha Selgas

with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Lower_Layer_UDP;
with Chat_Messages;
with Ada.Calendar;
with Ada.Unchecked_Deallocation;

package Users is
        
        package ASU renames Ada.Strings.Unbounded;
       	package TIO renames Ada.Text_IO;
       	package LLU renames Lower_Layer_UDP;
       	package CM renames Chat_Messages;
       	package AC renames Ada.Calendar;
       	use type LLU.End_Point_Type;
       	
       	type Clients_List is private; 
       	
       	procedure Add(Cliente: in out Clients_List; EP : LLU.End_Point_Type; Nick: ASU.Unbounded_String; Max : Natural);
       	procedure Expulsar(Cliente: in out Clients_List; Max: Natural; Nick_Fuera: out ASU.Unbounded_String);
       	procedure Buscar_Esta(Cliente:in out Clients_List; Nick:ASU.Unbounded_String; Max : Natural; Esta: out Boolean);
       	procedure Buscar_Nick(Cliente: Clients_List; EP: LLU.End_Point_Type; Nick: out ASU.Unbounded_String; Max : Natural);
       	procedure Buscar_y_Envia(Cliente : Clients_List; Nick: ASU.Unbounded_String; Max : Natural;
        		P_Buffer: access LLU.Buffer_Type);
        procedure Delete(Cliente: in out Clients_List; EP_Handler: LLU.End_Point_Type; Max: Natural);
       	
       private
       
       type Client;
       type Clients_List is access Client;
       
       type Client is record
       	        EP : LLU.End_Point_Type;
       	        Nick : ASU.Unbounded_String;
       	        Next : Clients_List;
       	        Time : AC.Time;
       	end record;
       	
end Users;
