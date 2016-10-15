--Alba García de la Camacha Selgas.

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Maps_G;
with Maps_Protector_G;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;


package body Chat_Handlers is

   --package ASU renames Ada.Strings.Unbounded;
   --package CM renames Chat_Messages;
   package TIO renames Ada.Text_IO;
   package AC renames Ada.Calendar;
   use type CM.Message_Type;
   use type LLU.End_Point_Type;
   use type ASU.Unbounded_String;
   
    function Image_3 (T: Ada.Calendar.Time) return String is
    begin
      return C_IO.Image(T, "%T.%i");
    end Image_3;
   
  
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
   
   --PROCEDURE QUE ACTUALIZA MI TABLA DE VECINOS.
   procedure Update_Neighbors(Neigh :in out Neighbors.Prot_Map; EP_H_Creat: LLU.End_Point_Type) is
   Success : Boolean;
   Value: AC.Time;
   begin
		-- vemos si tenemos a este ep_H_creat en nuestra tabla.
   	Neighbors.Get(Neigh, EP_H_Creat, Value, Success);
   	-- si no estaba, lo añadimos	
   	if Success = False then
   	   Neighbors.Put(Neigh, EP_H_Creat, AC.Clock, Success);
   	end if;
 	end Update_Neighbors;
 	
 	procedure Delete_Neighbors(Neigh :in out Neighbors.Prot_Map; EP_H_Creat: LLU.End_Point_Type) is
   Success : Boolean;
   Value: AC.Time;
   begin
		-- vemos si tenemos a este ep_H_creat en nuestra tabla.
   	Neighbors.Get(Neigh, EP_H_Creat, Value, Success);	
   	if Success = True then
   	 	Neighbors.Delete(My_Neighbors, EP_H_Creat, Success);
   	 	Debug.Put_Line("    Borramos de neighbors a " & End_Point_Image(EP_H_Creat));
   	end if;
 	end Delete_Neighbors;
 	
 	--PROCEDURE QUE REENVÍA EL INIT AL RESTO DE NODOS.
 	procedure Resend_Init(EP_H_Creat : LLU.End_Point_Type; EP_H_Rsnd : LLU.End_Point_Type; 
                       Seq_N: Seq_N_T; Nick : ASU.Unbounded_String; EP_Rsnd1: LLU.End_Point_Type;
                        Tipo: CM.Message_Type; EP_R_Creat: LLU.End_Point_Type) is
                       
   Buffer: aliased LLU.Buffer_Type(1024);
   Vecinos_Array : Neighbors.Keys_Array_Type := Neighbors.Get_Keys(My_Neighbors);
   NumC : Natural := Neighbors.Map_Length(My_Neighbors);

   begin
         LLU.Reset(Buffer);
         CM.Message_Type'Output(Buffer'Access, Tipo);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
         Seq_N_T'Output(Buffer'Access, Seq_N);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
         LLU.End_Point_Type'Output(Buffer'Access, EP_R_Creat);
         ASU.Unbounded_String'Output(Buffer'Access, Nick);
         for K in 1..NumC loop
         	if Vecinos_Array(K) /= EP_Rsnd1 then	
         		LLU.Send(Vecinos_Array(K), Buffer'Access);
         		Debug.Put_Line("          send to: " & End_Point_Image(Vecinos_Array(K)));
         	end if;
         end loop;
    end Resend_Init;
    
    --PROCEDURE QUE REENVÍA EL CONFIRM AL RESTO DE NODOS.
    procedure Resend_Confirm(EP_H_Creat : LLU.End_Point_Type; Seq_N: Seq_N_T; 
  		  			Nick : ASU.Unbounded_String;EP_H_Rsnd: LLU.End_Point_Type; Tipo : CM.Message_Type;
  		  			EP_Rsnd1: LLU.End_Point_Type) is
                       
 		Buffer: aliased LLU.Buffer_Type(1024);
   	Vecinos_Array : Neighbors.Keys_Array_Type := Neighbors.Get_Keys(My_Neighbors);
   	NumC : Natural := Neighbors.Map_Length(My_Neighbors);
   begin
         LLU.Reset(Buffer);
         CM.Message_Type'Output(Buffer'Access, Tipo);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
         Seq_N_T'Output(Buffer'Access, Seq_N);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
         ASU.Unbounded_String'Output(Buffer'Access, Nick);
         for K in 1..NumC loop
         	if Vecinos_Array(K) /= EP_Rsnd1 then	
         		LLU.Send(Vecinos_Array(K), Buffer'Access);
         		Debug.Put_Line("        send to: " & End_Point_Image(Vecinos_Array(K)));
         	end if;
         end loop;
    end Resend_Confirm;
   
   --PROCEDURE QUE ENVÍA EL REJECT.
   procedure Send_Reject(EP_H_To : LLU.End_Point_Type; Nick : ASU.Unbounded_String;
    				 EP_R_Creat: LLU.End_Point_Type) is
                       
   Tipo : CM.Message_Type := CM.Reject;
   Buffer: aliased LLU.Buffer_Type(1024);
    
   begin
         LLU.Reset(Buffer);
         CM.Message_Type'Output(Buffer'Access, Tipo);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_To);
         ASU.Unbounded_String'Output(Buffer'Access, Nick);
         LLU.Send(EP_R_Creat, Buffer'Access);
    end Send_Reject;
    
    --PROCEDURE QUE ENVÍA EL LOGOUT.
    procedure Resend_Logout(EP_H_Creat : LLU.End_Point_Type; Seq_N: Seq_N_T; 
  		  			Nick : ASU.Unbounded_String;EP_H_Rsnd: LLU.End_Point_Type; Tipo : CM.Message_Type;
  		  			EP_Rsnd1: LLU.End_Point_Type; Confirm_Sent: Boolean) is
                       
 		Buffer: aliased LLU.Buffer_Type(1024);
   	Vecinos_Array : Neighbors.Keys_Array_Type := Neighbors.Get_Keys(My_Neighbors);
   	NumC : Natural := Neighbors.Map_Length(My_Neighbors);
   begin
         LLU.Reset(Buffer);
         CM.Message_Type'Output(Buffer'Access, Tipo);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
         Seq_N_T'Output(Buffer'Access, Seq_N);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
         ASU.Unbounded_String'Output(Buffer'Access, Nick);
         Boolean'Output(Buffer'Access, Confirm_Sent);
         for K in 1..NumC loop
         	if Vecinos_Array(K) /= EP_Rsnd1 then	
         		LLU.Send(Vecinos_Array(K), Buffer'Access);
         		Debug.Put_Line("        send to: " & End_Point_Image(Vecinos_Array(K)));
         	end if;
         end loop;
    end Resend_Logout;
    
    --PROCEDURE QUE REENVÍA EL WRITER.
    procedure Resend_Writer(EP_H_Creat : LLU.End_Point_Type; EP_H_Rsnd : LLU.End_Point_Type; 
                       Seq_N: Seq_N_T; Nick : ASU.Unbounded_String; EP_Rsnd1: LLU.End_Point_Type;
                        Tipo: CM.Message_Type; Comentario: ASU.Unbounded_String) is
                       
   Buffer: aliased LLU.Buffer_Type(1024);
   Vecinos_Array : Neighbors.Keys_Array_Type := Neighbors.Get_Keys(My_Neighbors);
   NumC : Natural := Neighbors.Map_Length(My_Neighbors);

   begin
         LLU.Reset(Buffer);
         CM.Message_Type'Output(Buffer'Access, Tipo);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
         Seq_N_T'Output(Buffer'Access, Seq_N);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
         ASU.Unbounded_String'Output(Buffer'Access, Nick);
         ASU.Unbounded_String'Output(Buffer'Access, Comentario);
         for K in 1..NumC loop
         	if Vecinos_Array(K) /= EP_Rsnd1 then	
         		LLU.Send(Vecinos_Array(K), Buffer'Access);
         		Debug.Put_Line("          send to: " & End_Point_Image(Vecinos_Array(K)));
         	end if;
         end loop;
    end Resend_Writer;
 
   procedure Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type) is   
   Tipo : CM.Message_Type;
   EP_H_Creat: LLU.End_Point_Type;
   Seq_N: Seq_N_T;
   EP_H_Rsnd: LLU.End_Point_Type;
   EP_R_Creat: LLU.End_Point_Type;
   Nick : ASU.Unbounded_String;
   Success : Boolean;
   Old_Seq: Seq_N_T;
   EP_Rsnd1: LLU.End_Point_Type;
   Confirm_Sent: Boolean;
   Comentario : ASU.Unbounded_String;
   
   begin
   	Tipo := CM.Message_Type'Input(P_Buffer);
   	EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer);
   	Seq_N := Seq_N_T'Input(P_Buffer); 
   	EP_H_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
   	if EP_H_Creat = EP_H_Rsnd then
   		Update_Neighbors(My_Neighbors, EP_H_Creat);
   	end if;
   	
   	-- vemos si el num sec que hemos recibido ya estaba
   	--Neighbors.Print_Map(My_Neighbors);
   	Latest_Msgs.Get(Messages, EP_H_Creat, Old_Seq, Success);
   	
   	if Tipo = CM.Logout and Success = False then
   	   Nick := ASU.Unbounded_String'Input(P_Buffer);
   	   Confirm_Sent:= Boolean'Input(P_Buffer);
       	Debug.Put("RCV Logout ", Pantalla.Amarillo);
         Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
           				&  End_Point_Image(EP_H_Rsnd) & " ... " & ASU.To_String(Nick)& " "& Boolean'Image(Confirm_Sent));
         Debug.Put("    NOFLOOD Logout ", Pantalla.Amarillo);
         Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
             		 &  End_Point_Image(EP_H_Rsnd)  & ASU.To_String(Nick) & " "& Boolean'Image(Confirm_Sent));
         TIO.Put_Line("");
   	elsif Success = False or Old_Seq < Seq_N then
   	   Latest_Msgs.Put(Messages, EP_H_Creat, Seq_N, Success);
   	   -- Si no estaba, lo añadimos, si old_seq < seq actualizamos.
   	   --Latest_Msgs.Print_Map(Messages);
   	  
         if Tipo = CM.Init then
       	   EP_R_Creat := LLU.End_Point_Type'Input(P_Buffer); 
            Nick := ASU.Unbounded_String'Input(P_Buffer);
            Debug.Put("RCV Init ", Pantalla.Amarillo);
            Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              	&  End_Point_Image(EP_H_Rsnd) & " ... " & ASU.To_String(Nick));
            if Nick = My_Nick then
            	Send_Reject(To, My_Nick, EP_R_Creat);
            	Debug.Put("    SEND Reject ", Pantalla.Amarillo);
            	Debug.Put_Line(End_Point_Image(To) & ASU.To_String(My_Nick));
            end if;
            if Nick /= My_Nick and EP_H_Creat = EP_H_Rsnd then
               Debug.Put_Line("    Añadimos a neighbors " & End_Point_Image(EP_H_Creat));
            end if;
            Debug.Put_line("    Añadimos a latest_messages " & End_Point_Image(EP_H_Creat) 
         			& Seq_N_T'Image(Seq_N));
         	--EL NUEVO EP_H_RSND SERÁ EL DE ESTE NODO HANDLER, Y EL QUE VENÍA EN EL 
         	--BUFFER SERÁ AL QUE NO HAYA QUE ENVIARLE NADA POR INUNDACIÓN.
            EP_Rsnd1:= EP_H_Rsnd;
            EP_H_Rsnd := To;
            Debug.Put("    FLOOD Init ", Pantalla.Amarillo);
            Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              &  End_Point_Image(EP_H_Rsnd) & " ... " & ASU.To_String(Nick));
            --REENVIAMOS EL INIT.
            Resend_Init(EP_H_Creat, EP_H_Rsnd,Seq_N,Nick,EP_Rsnd1,Tipo,EP_R_Creat);
            TIO.Put_Line("");
                        
      	 elsif Tipo = CM.Confirm then
      	     Nick := ASU.Unbounded_String'Input(P_Buffer);
      	     Debug.Put("RCV Confirm ", Pantalla.Amarillo);
              Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              		&  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick));
              Debug.Put(ASU.To_String(Nick), Pantalla.Blanco);
              Debug.Put_Line(" ha entrado en el chat", Pantalla.Blanco);
              Debug.Put_line("    Añadimos a latest_messages " & End_Point_Image(EP_H_Creat) 
         			& Seq_N_T'Image(Seq_N));
         	  --EL NUEVO EP_H_RSND SERÁ EL DE ESTE NODO HANDLER, Y EL QUE VENÍA EN EL 
         	  --BUFFER SERÁ AL QUE NO HAYA QUE ENVIARLE NADA POR INUNDACIÓN.
              EP_Rsnd1:= EP_H_Rsnd;
              EP_H_Rsnd := To;
         	  Debug.Put("    FLOOD Confirm ", Pantalla.Amarillo);
              Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              		&  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick));
              --REENVIAMOS EL CONFIRM.
              Resend_Confirm(EP_H_Creat, Seq_N,Nick,EP_H_Rsnd,Tipo,EP_Rsnd1);
              TIO.Put_Line("");
          elsif Tipo = CM.Logout then
          	  Nick := ASU.Unbounded_String'Input(P_Buffer);
          	  Confirm_Sent:= Boolean'Input(P_Buffer);
          	  Debug.Put("RCV Logout ", Pantalla.Amarillo);
              Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              		&  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick)& " " &
              		Boolean'Image(Confirm_Sent));
              Debug.Put_Line("    Borramos de latest_messages a " & End_Point_Image(EP_H_Creat));
              --SI ERA VECINO NUESTRO, LO BORRAMOS
              Delete_Neighbors(My_Neighbors, EP_H_Creat);
              --EL NUEVO EP_H_RSND SERÁ EL DE ESTE NODO HANDLER, Y EL QUE VENÍA EN EL 
         	  --BUFFER SERÁ AL QUE NO HAYA QUE ENVIARLE NADA POR INUNDACIÓN.
         	  if Confirm_Sent = True then
         	     Debug.Put_Line(ASU.To_String(Nick) & " ha abandonado el chat", Pantalla.Blanco);
         	  end if;
              EP_Rsnd1:= EP_H_Rsnd;
              EP_H_Rsnd := To;
              Debug.Put("    FLOOD Logout ", Pantalla.Amarillo);
              Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              		&  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick)&" " &
              		Boolean'Image(Confirm_Sent));
              Resend_Logout(EP_H_Creat, Seq_N,Nick,EP_H_Rsnd,Tipo,EP_Rsnd1, Confirm_Sent);
              Latest_Msgs.Delete(Messages, EP_H_Creat, Success);
              --Neighbors.Delete(My_Neighbors, EP_H_Creat, Success);
              TIO.Put_Line("");
          elsif Tipo = CM.Writer then
          	  Nick := ASU.Unbounded_String'Input(P_Buffer);
          	  Comentario := ASU.Unbounded_String'Input(P_Buffer);
          	  Debug.Put("RCV Writer ", Pantalla.Amarillo);
              Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              		&  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick)
              			&" " & ASU.To_String(Comentario));
              Debug.Put_Line(ASU.To_String(Nick) & ": " & ASU.To_String(Comentario), Pantalla.Blanco);
              Debug.Put_line("    Añadimos a latest_messages " & End_Point_Image(EP_H_Creat) 
         			& Seq_N_T'Image(Seq_N));
         	  EP_Rsnd1:= EP_H_Rsnd;
              EP_H_Rsnd := To;
              Debug.Put("    FLOOD Writer ", Pantalla.Amarillo);
              Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              &  End_Point_Image(EP_H_Rsnd) & ASU.To_String(Nick)& " " & ASU.To_String(Comentario));
              --REENVIAMOS EL WRITER.
              Resend_Writer(EP_H_Creat, EP_H_Rsnd, Seq_N, Nick, EP_Rsnd1,
              						Tipo, Comentario);
              TIO.Put_Line("");
              
          end if;
       elsif Old_Seq = Seq_N then
       		 if Tipo = CM.Init then
       		 	 EP_R_Creat := LLU.End_Point_Type'Input(P_Buffer);
       		 	 Nick := ASU.Unbounded_String'Input(P_Buffer);
       		 	 Debug.Put("RCV Init ", Pantalla.Amarillo);
            	 Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              				&  End_Point_Image(EP_H_Rsnd) & " ... " & ASU.To_String(Nick));
              	 EP_H_Rsnd := To;
              	 Debug.Put("    NOFLOOD Init ", Pantalla.Amarillo);
            	 Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
             		 &  End_Point_Image(EP_H_Rsnd)  & ASU.To_String(Nick));
             	 TIO.Put_Line("");
             elsif Tipo = CM.Confirm then
             	 Nick := ASU.Unbounded_String'Input(P_Buffer);
       		 	 Debug.Put("RCV Confirm ", Pantalla.Amarillo);
            	 Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              				&  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick));
              	 Debug.Put("    NOFLOOD Confirm ", Pantalla.Amarillo);
            	 Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
             		 &  End_Point_Image(EP_H_Rsnd)  & ASU.To_String(Nick));
             	 TIO.Put_Line("");
             elsif Tipo = CM.Writer then
                Nick := ASU.Unbounded_String'Input(P_Buffer);
                Comentario := ASU.Unbounded_String'Input(P_Buffer);
       		 	 Debug.Put("RCV Writer ", Pantalla.Amarillo);
            	 Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              				&  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick)
              				&" " & ASU.To_String(Comentario));
              	 Debug.Put("    NOFLOOD Writer ", Pantalla.Amarillo);
            	 Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
             		 &  End_Point_Image(EP_H_Rsnd)  & ASU.To_String(Nick));
             	 TIO.Put_Line("");
               
             end if;
       		 	 
       end if;
      
   end Handler;

end Chat_Handlers;
