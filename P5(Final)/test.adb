with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ordered_Maps_G;
with Ordered_Maps_Protector_G;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Lower_Layer_UDP;

procedure Test is 

   package LLU renames Lower_Layer_UDP;
   package C_IO renames Gnat.Calendar.Time_IO;
   package ASU renames Ada.Strings.Unbounded;
   use type LLU.End_Point_Type;
   use type ASU.Unbounded_String;
   
   
   type Seq_N_T is mod Integer'Last;
    
    MaxNodos : Natural := 10;
    MaxMsgs  : Natural := 50;
    
    --Sender_Dests
    type Mess_Id_T is record
	 EP: LLU.End_Point_Type;
	 Seq: Seq_N_T:=0;
    end record;
    
    type Destination_T is record
	 EP: LLU.End_Point_Type := null;
	 Retries : Natural := 0;
    end record;

    type Destinations_T is array (1..10) of Destination_T;
    
    --Sender_Buffering
    
    type Buffer_A_T is access LLU.Buffer_Type;

    type Value_T is record
	EP_H_Creat : LLU.End_Point_Type;
	Seq_N : Seq_N_T;
	P_Buffer : Buffer_A_T;
    end record;
    
    
      function Image_3 (T: Ada.Calendar.Time) return String is
    begin
      return C_IO.Image(T, "%T.%i");
    end Image_3;
   
   function Igual_Mess_Id_T (Id1: Mess_Id_T; Id2: Mess_Id_T) return Boolean is
   begin
        return Id1.EP = Id2.EP and Id1.Seq = Id2.Seq;
   end Igual_Mess_Id_T;
   
   function Mayor_Mess_Id_T (Id1: Mess_Id_T; Id2: Mess_Id_T) return Boolean is
   begin
        return Id1.EP = Id2.EP and Id1.Seq > Id2.Seq;
   end Mayor_Mess_Id_T;
   
   function Menor_Mess_Id_T (Id1: Mess_Id_T; Id2: Mess_Id_T) return Boolean is
   begin
        return Id1.EP = Id2.EP and Id1.Seq < Id2.Seq;
   end Menor_Mess_Id_T;
  
   function End_Point_Image(EP: LLU.End_Point_Type) return String is
     IP: ASU.Unbounded_String;
     Puerto: ASU.Unbounded_String;
     Pos : Natural := 1;
     Frase: ASU.Unbounded_String := ASU.To_Unbounded_String(LLU.Image(EP));
     begin
      Pos := ASU.Index(Frase, "1");
      Frase := ASU.Tail(Frase, ASU.Length(Frase) - Pos + 1);
      Pos := ASU.Index(Frase, ",");
      IP := ASU.Head(Frase, Pos -1);
      Pos := ASU.Index(Frase, ":");
      Frase := ASU.Tail(Frase, ASU.Length(Frase) - Pos);
      Puerto := ASU.Head(Frase, Pos - 8);
     return ASU.To_String(IP) & ":" & ASU.To_String(Puerto);
   end End_Point_Image;
   
   function Id_Image(Id : Mess_Id_T) return String is 
   begin
        return End_Point_Image(Id.EP) & " " & Seq_N_T'Image(Id.Seq);
   end Id_Image;
   
   function Destination_Image( D: Destination_T) return String is
   begin
   	return End_Point_Image(D.EP) & " " & Natural'Image(D.Retries);
   end Destination_Image;
   
   function Value_T_Image(V: Value_T) return String is
   begin
        return End_Point_Image(V.EP_H_Creat) & " " & Seq_N_T'Image(V.Seq_N);
   end Value_T_Image;
   
   
   package NP_Sender_Dests is new Ordered_Maps_G (Key_Type   => Mess_Id_T,
                               Value_Type => Destination_T,
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
                               
                               
   package Sender_Dests is new Ordered_Maps_Protector_G (NP_Sender_Dests);
   
   package Sender_Buffering is new Ordered_Maps_Protector_G (NP_Sender_Buffering);
   
   Dest : Sender_Dests.Prot_Map;
   Buffering : Sender_Buffering.Prot_Map;
   EP_1: LLU.End_Point_Type;
   EP_2: LLU.End_Point_Type;
   EP_3: LLU.End_Point_Type;
   Mensaje: Mess_Id_T;
   Mensaje2: Mess_Id_T;
   Mensaje3: Mess_Id_T;
   Destino: Destination_T;
   Destino2: Destination_T;
   Destino3: Destination_T;
	begin
   
   LLU.Bind_Any(EP_1);   
   LLU.Bind_Any(EP_2);
   LLU.Bind_Any(EP_3);    
   Mensaje.EP := EP_1;
   Mensaje2.EP:= EP_2;
   Mensaje3.EP := EP_3;
   Destino.EP := EP_1;
   Destino2.EP := EP_2;
   Destino3.EP := EP_3;
   Sender_Dests.Put(Dest, Mensaje, Destino);
   Sender_Dests.Print_Map(Dest);
   Sender_Dests.Put(Dest, Mensaje2, Destino2);
   Sender_Dests.Print_Map(Dest);
   Sender_Dests.Put(Dest, Mensaje3, Destino3);
   Sender_Dests.Print_Map(Dest);
   
   end Test;
    
    
    
                               
                               
                               
                               
                               
                               
                               
                               
                               
                               
                               
                               
