--Alba García de la Camacha Selgas.

with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Maps_G;
with Ordered_Maps_G;
with Ordered_Maps_Protector_G;
with Maps_Protector_G;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Debug;
with Pantalla;

package Chat_Handlers is
	package LLU renames Lower_Layer_UDP;
	package C_IO renames Gnat.Calendar.Time_IO;
	package ASU renames Ada.Strings.Unbounded;
   
	type Seq_N_T is mod Integer'Last;
    
	MaxNodos : Natural := 10;
	MaxMsgs  : Natural := 50;
    
    ----------------------KEY DE LA TABLA SENDER_DESTS--------------------------
    
	type Mess_Id_T is record
		EP: LLU.End_Point_Type;
		Seq: Seq_N_T;
	end record;
    
	type Destination_T is record
		EP: LLU.End_Point_Type := null;
		Retries : Natural := 0;
	end record;

	 ------------------VALUE DE LA TABLA SENDER_DESTS----------------------------
	 
	type Destinations_T is array (1..10) of Destination_T;
    
    --------------¿ QUÉ ES EXACTAMENTE?-----------------------------------------
    
	type Buffer_A_T is access LLU.Buffer_Type;

    -------------------VALUE DE TABLA SENDER_BUFFERING--------------------------
    
	type Value_T is record
		EP_H_Creat : LLU.End_Point_Type;
		Seq_N : Seq_N_T;
		P_Buffer : Buffer_A_T;
	end record;

    
	function Image_3 (T: Ada.Calendar.Time) return String;
	function Igual_Mess_Id_T (Id1: Mess_Id_T; Id2: Mess_Id_T) return Boolean;
	function Mayor_Mess_Id_T (Id1: Mess_Id_T; Id2: Mess_Id_T) return Boolean;
	function Menor_Mess_Id_T (Id1: Mess_Id_T; Id2: Mess_Id_T) return Boolean;
	function End_Point_Image(EP: LLU.End_Point_Type) return String;
	function Id_Image(Id : Mess_Id_T) return String;
	function Destination_Image( D: Destinations_T) return String;
	function Value_T_Image(V: Value_T) return String;
    
	package NP_Neighbors is new Maps_G (Key_Type   => LLU.End_Point_Type,
										Value_Type => Ada.Calendar.Time,
                              Null_Key => null,
                              Null_Value => Ada.Calendar.Time_Of(2000,1,1),
                              Max_Length => MaxNodos,
                              "="        => LLU."=",
                              Key_To_String  => LLU.Image,
                              Value_To_String  => Image_3);
                               
	package NP_Latest_Msgs is new Maps_G (Key_Type   => LLU.End_Point_Type,
                              Value_Type => Seq_N_T,
                              Null_Key => null,
                              Null_Value => 2000,
                              Max_Length => MaxMsgs,
                              "="        => LLU."=",
                              Key_To_String  => LLU.Image,
                              Value_To_String  => Seq_N_T'Image);
                             
	package NP_Sender_Dests is new Ordered_Maps_G (Key_Type   => Mess_Id_T,
                              Value_Type => Destinations_T,
                              "="        => Igual_Mess_Id_T,
                              "<" => Menor_Mess_Id_T,
                              ">" => Mayor_Mess_Id_T,
                              Key_To_String  => Id_Image,
                              Value_To_String  => Destination_Image);
                               
	package NP_Sender_Buffering is new Ordered_Maps_G (Key_Type   => Ada.Calendar.Time,
                              Value_Type => Value_T,
                              "="        => Ada.Calendar."=" ,
                              "<" => Ada.Calendar."<",
                              ">" => Ada.Calendar.">",
                              Key_To_String  => Image_3,
                              Value_To_String  => Value_T_Image);


	package Neighbors is new Maps_Protector_G (NP_Neighbors);
  
	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);
   
	package Sender_Dests is new Ordered_Maps_Protector_G (NP_Sender_Dests);
   
	package Sender_Buffering is new Ordered_Maps_Protector_G (NP_Sender_Buffering);

   
	My_Neighbors : Neighbors.Prot_Map;
	Messages : Latest_Msgs.Prot_Map;
	My_Nick : ASU.Unbounded_String;
	Dest : Sender_Dests.Prot_Map;
	Buffering : Sender_Buffering.Prot_Map;
	Plazo_Retransmision : Duration;
   
	procedure Update_Neighbors(Neigh :in out Neighbors.Prot_Map; EP_H_Creat: LLU.End_Point_Type);
	procedure Delete_Neighbors(Neigh :in out Neighbors.Prot_Map; EP_H_Creat: LLU.End_Point_Type);
	procedure Retransmission(Time: in Ada.Calendar.Time);
	procedure Resend_Init(EP_H_Creat : LLU.End_Point_Type; EP_H_Rsnd : LLU.End_Point_Type; 
                         Seq_N: Seq_N_T; Nick : ASU.Unbounded_String; EP_Rsnd1: LLU.End_Point_Type;
                         EP_R_Creat: LLU.End_Point_Type);
	procedure Resend_Confirm(EP_H_Creat : LLU.End_Point_Type; Seq_N: Seq_N_T; 
  		  						 Nick : ASU.Unbounded_String;EP_H_Rsnd: LLU.End_Point_Type; 
  		  						 EP_Rsnd1: LLU.End_Point_Type);
  		  						 
	procedure Send_Ack(EP_H_Acker: LLU.End_Point_Type; EP_H_Creat: LLU.End_Point_Type;
   							EP_H_Rsnd: LLU.End_Point_Type; Seq_N: Seq_N_T);
	procedure Receive_Ack(EP_H_Acker: LLU.End_Point_Type; EP_H_Creat: LLU.End_Point_Type;
	                   Seq_N: Seq_N_T);
	procedure Send_Reject(EP_H_To : LLU.End_Point_Type; Nick : ASU.Unbounded_String;
   							 EP_R_Creat: LLU.End_Point_Type);
	procedure Resend_Logout(EP_H_Creat : LLU.End_Point_Type; Seq_N: Seq_N_T; 
  		  						 Nick : ASU.Unbounded_String;EP_H_Rsnd: LLU.End_Point_Type; 
  		  						 EP_Rsnd1: LLU.End_Point_Type; Confirm_Sent: Boolean);
	procedure Resend_Writer(EP_H_Creat : LLU.End_Point_Type; EP_H_Rsnd : LLU.End_Point_Type; 
                         Seq_N: Seq_N_T; Nick : ASU.Unbounded_String; EP_Rsnd1: LLU.End_Point_Type;
                         Comentario: ASU.Unbounded_String);

   -- Handler para utilizar como parámetro en LLU.Bind en el cliente
   -- Muestra en pantalla las cadenas de texto recibidas
   -- Este procedimiento NO debe llamarse explícitamente
   procedure Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type);


end Chat_Handlers;
