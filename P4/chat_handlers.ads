--Alba García de la Camacha Selgas.

with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Maps_G;
with Maps_Protector_G;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Debug;
with Pantalla;

package Chat_Handlers is
   package LLU renames Lower_Layer_UDP;
   package C_IO renames Gnat.Calendar.Time_IO;
   package ASU renames Ada.Strings.Unbounded;
   package CM renames Chat_Messages;
   
    type Seq_N_T is mod Integer'Last;
    
    MaxNodos : Natural := 10;
    MaxMsgs  : Natural := 50;
    
    function Image_3 (T: Ada.Calendar.Time) return String;
    function End_Point_Image(EP: LLU.End_Point_Type) return String;
    
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


   package Neighbors is new Maps_Protector_G (NP_Neighbors);
   
   package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);
   
   My_Neighbors : Neighbors.Prot_Map;
   Messages : Latest_Msgs.Prot_Map;
   My_Nick : ASU.Unbounded_String;
   
   procedure Update_Neighbors(Neigh :in out Neighbors.Prot_Map; EP_H_Creat: LLU.End_Point_Type);
   procedure Delete_Neighbors(Neigh :in out Neighbors.Prot_Map; EP_H_Creat: LLU.End_Point_Type);
   procedure Resend_Init(EP_H_Creat : LLU.End_Point_Type; EP_H_Rsnd : LLU.End_Point_Type; 
                       Seq_N: Seq_N_T; Nick : ASU.Unbounded_String; EP_Rsnd1: LLU.End_Point_Type;
                        Tipo: CM.Message_Type; EP_R_Creat: LLU.End_Point_Type);
   procedure Resend_Confirm(EP_H_Creat : LLU.End_Point_Type; Seq_N: Seq_N_T; 
  		  			Nick : ASU.Unbounded_String;EP_H_Rsnd: LLU.End_Point_Type; Tipo : CM.Message_Type;
  		  			EP_Rsnd1: LLU.End_Point_Type);
   procedure Send_Reject(EP_H_To : LLU.End_Point_Type; Nick : ASU.Unbounded_String;
    				 EP_R_Creat: LLU.End_Point_Type);
   procedure Resend_Logout(EP_H_Creat : LLU.End_Point_Type; Seq_N: Seq_N_T; 
  		  			Nick : ASU.Unbounded_String;EP_H_Rsnd: LLU.End_Point_Type; Tipo : CM.Message_Type;
  		  			EP_Rsnd1: LLU.End_Point_Type; Confirm_Sent: Boolean);
   procedure Resend_Writer(EP_H_Creat : LLU.End_Point_Type; EP_H_Rsnd : LLU.End_Point_Type; 
                       Seq_N: Seq_N_T; Nick : ASU.Unbounded_String; EP_Rsnd1: LLU.End_Point_Type;
                        Tipo: CM.Message_Type; Comentario: ASU.Unbounded_String);

   -- Handler para utilizar como parámetro en LLU.Bind en el cliente
   -- Muestra en pantalla las cadenas de texto recibidas
   -- Este procedimiento NO debe llamarse explícitamente
   procedure Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type);


end Chat_Handlers;
