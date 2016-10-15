--Alba García de la Camacha Selgas

with Chat_Handlers;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Debug;
with Pantalla;
with Ada.Calendar;

procedure Chat_Peer is
   package TIO renames Ada.Text_IO;
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package CM renames Chat_Messages;
   package CH renames Chat_Handlers;
   package AC renames Ada.Calendar;
   use type CM.Message_Type;
   use type ASU.Unbounded_String;
   use type CH.Seq_N_T;
   use type LLU.End_Point_Type;
   
   --PROCEDURE QUE ENVÍA EL MENSAJE INICIAL.
   procedure Send_Init(EP_R : LLU.End_Point_Type; EP_H : LLU.End_Point_Type; 
                       Seq_N: in out CH.Seq_N_T; Nick : ASU.Unbounded_String; VecinoEP: LLU.End_Point_Type;
                        Buffer: in out LLU.Buffer_Type) is
                       
   Tipo : CM.Message_Type := CM.Init;
   EP_H_Creat: LLU.End_Point_Type := EP_H;
   EP_H_Rsnd: LLU.End_Point_Type := EP_H;
   EP_R_Creat: LLU.End_Point_Type := EP_R;

   begin
         LLU.Reset(Buffer);
         CM.Message_Type'Output(Buffer'Access, Tipo);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
         CH.Seq_N_T'Output(Buffer'Access, Seq_N);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
         LLU.End_Point_Type'Output(Buffer'Access, EP_R_Creat);
         ASU.Unbounded_String'Output(Buffer'Access, Nick);
         LLU.Send(VecinoEP, Buffer'Access);
    end Send_Init;
    
    --PROCEDURE QUE ENVÍA EL CONFIRM.
    procedure Send_Confirm(EP_H : LLU.End_Point_Type; Seq_N: in out CH.Seq_N_T; 
  		  Nick : ASU.Unbounded_String; VecinoEP: LLU.End_Point_Type;
  		  Buffer: in out LLU.Buffer_Type) is
                       
   Tipo : CM.Message_Type := CM.Confirm;
   EP_H_Creat: LLU.End_Point_Type := EP_H;
   EP_H_Rsnd: LLU.End_Point_Type := EP_H;

   begin
         LLU.Reset(Buffer);
         CM.Message_Type'Output(Buffer'Access, Tipo);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
         CH.Seq_N_T'Output(Buffer'Access, Seq_N);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
         ASU.Unbounded_String'Output(Buffer'Access, Nick);
         LLU.Send(VecinoEP, Buffer'Access);
    end Send_Confirm;
       
    --PROCEDURE QUE ENVÍA EL LOGOUT.  
    procedure Send_Logout(EP_H : LLU.End_Point_Type; Seq_N: in out CH.Seq_N_T; 
  		   Nick : ASU.Unbounded_String; Confirm_Sent: Boolean; Buffer: in out LLU.Buffer_Type) is
                       
   Tipo : CM.Message_Type := CM.Logout;
   EP_H_Creat: LLU.End_Point_Type := EP_H;
   EP_H_Rsnd: LLU.End_Point_Type := EP_H;
   Vecinos_Array : CH.Neighbors.Keys_Array_Type := CH.Neighbors.Get_Keys(CH.My_Neighbors);
   NumC : Natural := CH.Neighbors.Map_Length(CH.My_Neighbors);

   begin
         LLU.Reset(Buffer);
         CM.Message_Type'Output(Buffer'Access, Tipo);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
         CH.Seq_N_T'Output(Buffer'Access, Seq_N);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
         ASU.Unbounded_String'Output(Buffer'Access, Nick);
         Boolean'Output(Buffer'Access, Confirm_Sent);
         for K in 1..NumC loop
         	 LLU.Send(Vecinos_Array(K), Buffer'Access);
         	 Debug.Put_Line("        send to: " & CH.End_Point_Image(Vecinos_Array(K)));
         end loop;
    end Send_Logout;
    
    --PROCEDURE QUE ENVÍA EL WRITER.
    procedure Send_Writer(EP_H : LLU.End_Point_Type; Seq_N: in out CH.Seq_N_T; 
  		   Nick : ASU.Unbounded_String; Comentario: ASU.Unbounded_String; Buffer: in out LLU.Buffer_Type) is
  		    
   Tipo : CM.Message_Type := CM.Writer;
   EP_H_Creat: LLU.End_Point_Type := EP_H;
   EP_H_Rsnd: LLU.End_Point_Type := EP_H; 
   Vecinos_Array : CH.Neighbors.Keys_Array_Type := CH.Neighbors.Get_Keys(CH.My_Neighbors);
   NumC : Natural := CH.Neighbors.Map_Length(CH.My_Neighbors);
   
   begin  
   		LLU.Reset(Buffer);
         CM.Message_Type'Output(Buffer'Access, Tipo);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
         CH.Seq_N_T'Output(Buffer'Access, Seq_N);
         LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
         ASU.Unbounded_String'Output(Buffer'Access, Nick);
         ASU.Unbounded_String'Output(Buffer'Access, Comentario);
         for K in 1..NumC loop
         	 LLU.Send(Vecinos_Array(K), Buffer'Access);
         	 Debug.Put_Line("        send to: " & CH.End_Point_Image(Vecinos_Array(K)));
         end loop;
   end Send_Writer;
   
   
   EP_R: LLU.End_Point_Type;
   EP_H: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Expired : Boolean;
   Usage_Error : exception;
   Mi_Vecino1EP : LLU.End_Point_Type;
   Mi_Vecino2EP : LLU.End_Point_Type;
   Success : Boolean;
   Tipo : CM.Message_Type;
   Seq_N: CH.Seq_N_T := 0;
   Confirm_Sent: Boolean;
   EP_H_Reject : LLU.End_Point_Type;
   Nick : ASU.Unbounded_String;
   Comentario : ASU.Unbounded_String;
   Message_Keys : CH.Latest_Msgs.Keys_Array_Type := CH.Latest_Msgs.Get_Keys(CH.Messages);
   Message_Seq :  CH.Latest_Msgs.Values_Array_Type := CH.Latest_Msgs.Get_Values(CH.Messages);
   NumC : Natural := CH.Latest_Msgs.Map_Length(CH.Messages);
   
   
begin

  if ACL.Argument_Count < 2 or ACL.Argument_Count = 3 or ACL.Argument_Count = 5 or ACL.Argument_Count > 6 then
 	   raise Usage_Error;
  end if;
  --Esto soy yo, mis end points
  CH.My_Nick := ASU.To_Unbounded_String(ACL.Argument(2));
  EP_H := LLU.Build(LLU.To_IP(LLU.Get_Host_Name), Natural'Value(ACL.Argument(1)));
  LLU.Bind(EP_H, CH.Handler'Access);
  LLU.Bind_Any(EP_R);
 
   if ACL.Argument_Count = 2 then
      Debug.Put_Line("No hacemos protocolos de admisión porque no tenemos contactos iniciales...");
      Debug.Put_Line("Peer-Chat v1.0", Pantalla.Blanco);
      Debug.Put_Line("===============", Pantalla.Blanco);
      TIO.Put_Line("");
      Debug.Put("Entramos en el chat con Nick : ", Pantalla.Blanco);
      Debug.Put_Line(ASU.To_String(CH.My_Nick), Pantalla.Blanco);
      Debug.Put_Line(".h para help", Pantalla.Blanco);
      --Cuando tenemos dos argumentos no enviamos Init, somos los primeros.
   else
		 --mi vecino 1 está formado por los argumentos 3 y 4, lo añado a mi tabla
		 Mi_Vecino1EP := LLU.Build(LLU.To_IP(ACL.Argument(3)), Natural'Value(ACL.Argument(4)));
		 CH.Neighbors.Put(CH.My_Neighbors, Mi_Vecino1EP, Ada.Calendar.Clock, Success);
		 Debug.Put_Line("Añadimos a neighbors " & CH.End_Point_Image(Mi_Vecino1EP));
		 Seq_N := Seq_N + 1;
		 if ACL.Argument_Count = 6 then
		    Mi_Vecino2EP := LLU.Build(LLU.To_IP(ACL.Argument(5)), Natural'Value(ACL.Argument(6)));
		    CH.Neighbors.Put(CH.My_Neighbors, Mi_Vecino2EP, Ada.Calendar.Clock, Success);
		    Debug.Put_Line("Añadimos a neighbors " & CH.End_Point_Image(Mi_Vecino2EP));
		 end if;
		 Debug.Put_Line("");
		 Debug.Put_Line("Iniciando protocolo de admisión ...");
		 Send_Init(EP_R, EP_H, Seq_N, CH.My_Nick, Mi_Vecino1EP, Buffer);
		 --añado mi mensaje inicial a mi tabla de últimos mensajes
		 CH.Latest_Msgs.Put(CH.Messages, EP_H, Seq_N, Success);
		 Debug.Put_line("Añadimos a latest_messages " & CH.End_Point_Image(EP_H) 
		      			& CH.Seq_N_T'Image(Seq_N));
		 Debug.Put("FLOOD Init  ", Pantalla.Amarillo);
		 Debug.Put(CH.End_Point_Image(EP_H) &  CH.Seq_N_T'Image(Seq_N) & " " &  CH.End_Point_Image(EP_H));
		 Debug.Put_Line( "..." & ASU.To_String(CH.My_Nick)); 		 
		 Debug.Put_Line("          send to: " &  CH.End_Point_Image(Mi_Vecino1EP));
		 if ACL.Argument_Count = 6 then
		    Send_Init(EP_R, EP_H, Seq_N, CH.My_Nick, Mi_Vecino2EP, Buffer);
		    Debug.Put_Line("          send to: " &  CH.End_Point_Image(Mi_Vecino2EP));
		 end if;
		 TIO.Put_Line("");
		      			
		
		LLU.Reset(Buffer);    			
		LLU.Receive (EP_R, Buffer'Access, 2.0, Expired);  
		if Expired then
		   -- Si pasan dos segundos y no recibí un Reject, envío el Confirm.
		   Seq_N := Seq_N + 1;
		   Send_Confirm(EP_H, Seq_N, CH.My_Nick, Mi_Vecino1EP, Buffer);
		   if ACL.Argument_Count = 6 then
		      Send_Confirm(EP_H, Seq_N, CH.My_Nick, Mi_Vecino2EP, Buffer);
		   end if;
		   CH.Latest_Msgs.Put(CH.Messages, EP_H, Seq_N, Success);
		   TIO.Put_Line("");
		   Debug.Put_line("Añadimos a latest_messages " & CH.End_Point_Image(EP_H) 
		      			& CH.Seq_N_T'Image(Seq_N));  
		   Debug.Put("FLOOD Confirm ", Pantalla.Amarillo);
		   Debug.Put_Line(CH.End_Point_Image(EP_H) &  CH.Seq_N_T'Image(Seq_N) & " " & CH.End_Point_Image(EP_H) &
		   			"  " &ASU.To_String(CH.My_Nick));
		   Debug.Put_Line("          send to: " &  CH.End_Point_Image(Mi_Vecino1EP));
		   if ACL.Argument_Count = 6 then
		   Debug.Put_Line("          send to: " &  CH.End_Point_Image(Mi_Vecino2EP));     
		   end if;
		   
		   TIO.Put_Line("");
		   Debug.Put_line("Fin del protocolo de admisión");
		   TIO.Put_Line("");
		   Debug.Put_Line("Peer-Chat v1.0", Pantalla.Blanco);
		   Debug.Put_Line("===============", Pantalla.Blanco);
		   TIO.Put_Line("");
		   Debug.Put("Entramos en el chat con Nick : ", Pantalla.Blanco);
		   Debug.Put_Line(ASU.To_String(CH.My_Nick), Pantalla.Blanco);
		   Debug.Put_Line(".h para help", Pantalla.Blanco);
		   
		else 
			Tipo := CM.Message_Type'Input(Buffer'Access);
			EP_H_Reject := LLU.End_Point_Type'Input(Buffer'Access);
			Nick := ASU.Unbounded_String'Input(Buffer'Access);
			Debug.Put("RCV Reject");
			Debug.Put_Line(CH.End_Point_Image(EP_H_Reject) & ASU.To_String(Nick));
			Debug.Put("Usuario rechazado porque ", Pantalla.Blanco);
			Debug.Put(CH.End_Point_Image(EP_H_Reject), Pantalla.Blanco);
			Debug.Put_Line(" está usando el mismo nick", Pantalla.Blanco);
		   --Si he recibido el Reject tengo que enviar el Logout.
		   Confirm_Sent := False;
		   Seq_N := Seq_N + 1;
		   Send_Logout(EP_H, Seq_N, CH.My_Nick, Confirm_Sent, Buffer);
		   Debug.Put("FLOOD Logout ", Pantalla.Amarillo);
		   Debug.Put_Line(CH.End_Point_Image(EP_H) &  CH.Seq_N_T'Image(Seq_N) & " " & CH.End_Point_Image(EP_H) &
		   			"  " &ASU.To_String(CH.My_Nick) & " " & Boolean'Image(Confirm_Sent));
		   TIO.Put_Line("");
		   Debug.Put_line("Fin del protocolo de admisión");
		   LLU.Finalize;
		 end if;
	end if; 
      
   loop 	
      Comentario := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
      if Comentario = ".salir" then
        Seq_N := Seq_N + 1;
        Confirm_Sent := True;
        Debug.Put("FLOOD Logout ", Pantalla.Amarillo);
		  Debug.Put_Line(CH.End_Point_Image(EP_H) &  CH.Seq_N_T'Image(Seq_N) & " " & CH.End_Point_Image(EP_H) &
		   			"  " &ASU.To_String(CH.My_Nick) & " " & Boolean'Image(Confirm_Sent));
        Send_Logout(EP_H, Seq_N, CH.My_Nick, Confirm_Sent, Buffer);
        LLU.Finalize;
     elsif Comentario = ".h" then
         Debug.Put_Line("              Comandos             Efectos", Pantalla.Rojo);
         Debug.Put_Line("              =================    =======", Pantalla.Rojo);
         Debug.Put_Line("              .nb .neihbors        lista de vecinos", Pantalla.Rojo);
         Debug.Put_Line("              .lm .latest_msgs    lista de últimos mensajes recibidos", Pantalla.Rojo);
         Debug.Put_Line("              .debug              toggle para info de debug", Pantalla.Rojo);
         Debug.Put_Line("              .wai .whoami        Muestra en pantalla: nick | EP_H | EP_R", Pantalla.Rojo);
         Debug.Put_Line("              .prompt             toggle para mostrar prompt", Pantalla.Rojo);
         Debug.Put_Line("              .h .help            muestra esta información de ayuda", Pantalla.Rojo);
         Debug.Put_Line("              .salir              termina el programa", Pantalla.Rojo); 
     elsif Comentario = ".nb" or Comentario = ".neighbors" then
     		TIO.Put_Line("");
     elsif Comentario = ".lm" or Comentario = ".latest_msgs" then
     		Debug.Put_Line("                      Latest_Msgs", Pantalla.Rojo);
     		Debug.Put_Line("                      --------------------", Pantalla.Rojo);
     		for K in 1..NumC loop
     			Debug.Put_Line("                      [ (" & CH.End_Point_Image(Message_Keys(K)) &"),  " &  
     			CH.Seq_N_T'Image(Message_Seq) &" ]", Pantalla.Rojo);
     		end loop;
     elsif Comentario = ".debug" then
     		TIO.Put_Line("");
     elsif Comentario = ".wai" or Comentario = ".whoami" then
     		TIO.Put_Line("");
     elsif Comentario = ".prompt" then
     		TIO.Put_Line("");
     else
     		Seq_N := Seq_N + 1;
     		Debug.Put_line("Añadimos a latest_messages " & CH.End_Point_Image(EP_H) 
		      			& CH.Seq_N_T'Image(Seq_N));
		   Debug.Put("FLOOD Writer ", Pantalla.Amarillo);
		   Debug.Put_Line(CH.End_Point_Image(EP_H) &  CH.Seq_N_T'Image(Seq_N) & " " & CH.End_Point_Image(EP_H) &
		   			"  " &ASU.To_String(CH.My_Nick)& " " & ASU.To_String(Comentario));
     		Send_Writer(EP_H, Seq_N, CH.My_Nick, Comentario, Buffer);
     		TIO.Put_Line("");
  		   
  		   
     end if;
     exit when Comentario = ".salir";
    end loop;			
   
     
exception
   when Usage_Error =>
      TIO.Put_Line("Argumentos incorrectos");
      
      LLU.Finalize;
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Peer;
