--Alba García de la Camacha Selgas.

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Maps_G;
with Maps_Protector_G;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Timed_Handlers;


package body Chat_Handlers is

   package TIO renames Ada.Text_IO;
   package AC renames Ada.Calendar;
   package CM renames Chat_Messages;
   package TH renames Timed_Handlers;
   use type CM.Message_Type;
   use type LLU.End_Point_Type;
   use type ASU.Unbounded_String;
   use type Ada.Calendar.Time;
   
	----------------------FUNCIONES TABLAS SD Y SB-------------------------------
	
	function Image_3 (T: Ada.Calendar.Time) return String is
	begin
			return C_IO.Image(T, "%T.%i");
	end Image_3;
    
   
	function Igual_Mess_Id_T (Id1: Mess_Id_T; Id2: Mess_Id_T) return Boolean is
	begin
			return (LLU.Image(Id1.EP) = LLU.Image(Id2.EP) and Id1.Seq = Id2.Seq);
	end Igual_Mess_Id_T;
   
   
	function Mayor_Mess_Id_T (Id1: Mess_Id_T; Id2: Mess_Id_T) return Boolean is
	begin
			return (LLU.Image(Id1.EP) = LLU.Image(Id2.EP) and Id1.Seq > Id2.Seq) 
                         or (LLU.Image(Id1.EP) > LLU.Image(Id2.EP));
	end Mayor_Mess_Id_T;
   
 
	function Menor_Mess_Id_T (Id1: Mess_Id_T; Id2: Mess_Id_T) return Boolean is
	begin
			return (LLU.Image(Id1.EP) = LLU.Image(Id2.EP) and Id1.Seq < Id2.Seq)
                                or (LLU.Image(Id1.EP) < LLU.Image(Id2.EP));
	end Menor_Mess_Id_T;
	
   
	function Value_T_Image(V: Value_T) return String is
	begin
		return End_Point_Image(V.EP_H_Creat) & " " & Seq_N_T'Image(V.Seq_N);
	end Value_T_Image;
	

	function Id_Image(Id : Mess_Id_T) return String is 
	begin
		return End_Point_Image(Id.EP) & " " & Seq_N_T'Image(Id.Seq);
	end Id_Image;
   
   --------------------------IMAGEN DE UN END_POINT-----------------------------
   
	function End_Point_Image(EP: LLU.End_Point_Type) return String is
		Cola: ASU.Unbounded_String;
		IP : ASU.Unbounded_String;
		Puerto: ASU.Unbounded_String;
		Pos : Natural;
		Cadena: ASU.Unbounded_String := ASU.To_Unbounded_String(LLU.Image(EP));
	begin
		If Cadena = "null" then
			TIO.Put_Line("Null");
		else
		
			Pos := ASU.Index(Cadena, ":");
			Cadena := ASU.Tail(Cadena, ASU.Length(Cadena) - Pos);
			Pos := ASU.Index(Cadena, ",");
			IP := ASU.Head(Cadena, Pos - 1);
			Cadena := ASU.Tail(Cadena, ASU.Length(Cadena) - Pos + 1);
			Pos := ASU.Index(Cadena, ":");
			Cadena := ASU.Tail(Cadena, ASU.Length(Cadena) - Pos + 1);
				while Pos /= 0 loop 
					Pos := ASU.Index(Cadena, " ");
						if Pos = 0 then
							if ASU.Length(Cadena) = 0 then
		                  -- si la lonitud es 0 significa que no tienes nada 
		                  --que guardar, por tanto no hace nada más
							TIO.New_Line;
							else
								Puerto := ASU.Tail(Cadena, ASU.Length(Cadena) -Pos);
							end if;
		                                    
						elsif Pos = 1 then
							Cadena := ASU.Tail(Cadena, ASU.Length(Cadena) - Pos);
						else            
							Puerto := ASU.Head(Cadena, Pos -1);
							Cadena := ASU.Tail(Cadena, ASU.Length(Cadena) -Pos);
						end if;
		                           
				exit when Pos = 0;
				end loop;
		end if;
			return (ASU.To_String(IP) & ":" & ASU.To_String(Puerto));
	end End_Point_Image;
	
	function Destination_Image( D: Destinations_T) return String is
        Imagen:ASU.Unbounded_String:= ASU.To_Unbounded_String("");      
	begin
		for K in 1..10 loop
			if D(K).EP /= null then
				Imagen := ASU.To_Unbounded_String(ASU.To_String(Imagen)
               & " EP" & End_Point_Image(D(K).EP) & 
               		" Retries " & Natural'Image(D(K).Retries));
          end if;
		end loop;
		return ASU.To_String(Imagen);
	end Destination_Image;
   
   --------------------ACTUALIZA MI TABLA DE VECINOS----------------------------
   
	procedure Update_Neighbors(Neigh :in out Neighbors.Prot_Map; 
                EP_H_Creat: LLU.End_Point_Type) is
	Success : Boolean;
	Value: AC.Time;
	begin
      -- Vemos si tenemos a este EP_H_CREAT en nuestra tabla.
		Neighbors.Get(Neigh, EP_H_Creat, Value, Success);
      -- Si no estaba, lo añadimos.
		if Success = False then
			Neighbors.Put(Neigh, EP_H_Creat, AC.Clock, Success);
		end if;
	end Update_Neighbors;
        
   -----------------------BORRAR VECINOS DE MI TABLA----------------------------
        
	procedure Delete_Neighbors(Neigh :in out Neighbors.Prot_Map; 
                        EP_H_Creat: LLU.End_Point_Type) is
	Success : Boolean;
	Value: AC.Time;
	begin
      -- Vemos si tenemos a este EP_H_CREAT en nuestra tabla.
		Neighbors.Get(Neigh, EP_H_Creat, Value, Success);       
      if Success = True then
			--Si está, lo borramos.
			Neighbors.Delete(My_Neighbors, EP_H_Creat, Success);
			Debug.Put_Line("    Borramos de neighbors a " & End_Point_Image(EP_H_Creat));
		end if;
	end Delete_Neighbors;
        
   -----------------------------------------------------------------------------
   ----------------------MANEJADOR TEMPORIZADO----------------------------------
   -----------------------------------------------------------------------------
        
	procedure Retransmission(Time: in Ada.Calendar.Time) is
		Value : Value_T;
		Mess : Mess_Id_T;
		Destinos : Destinations_T;
		Success : Boolean;
		Tiempo : Ada.Calendar.Time;
		Todos_Nulos: Boolean := True;
	begin
		Sender_Buffering.Get(Buffering, Time, Value, Success);
		Mess.EP := Value.EP_H_Creat;
		Mess.Seq := Value.Seq_N;
		Sender_Dests.Get(Dest, Mess, Destinos, Success);
		---Si la clave se encuentra en sender_dests, entones vemos--------
		---si hay end points no nulos a los que reenviarles el mensaje----
		---y sólo si Retries < 10, ya que 0<Retries<10--------------------
		if Success = True then
			for K in 1..10 loop
				if Destinos(K).Retries < 10 and Destinos(K).EP /= null then
					LLU.Send(Destinos(k).EP, Value.P_Buffer);
					Destinos(K).Retries := Destinos(K).Retries + 1;
					TIO.New_Line;
					Debug.Put("RESENDED", Pantalla.Rojo);
					Debug.Put(" To " & End_Point_Image(Destinos(k).EP), Pantalla.Azul);
					Debug.Put_Line(" De creador " & End_Point_Image(Mess.EP) & 
              		" Seq : "  & Seq_N_T'Image(Mess.Seq), Pantalla.Azul);
					Debug.Put_Line("Retries: " & Natural'Image(Destinos(K).Retries), Pantalla.Azul);
				end if;
			end loop;
         
			for K in 1..10 loop
				if Destinos(K).EP /= null and Destinos(K).Retries < 10 then
					Todos_Nulos := False;
				end if;
			end loop;
      	
			if Todos_Nulos = True then 
				--Si la clave está en sender_dests, pero el array--------
				--destinatons está a null todo, borramos la entrada------
				Sender_Dests.Delete(Dest,Mess, Success);
			else
				--Actualizamos la tabla, para rehacer nuestro nuevo destinations y--
				--Colocamos un nuevo Manej_Tempo, y añadimos una nueva entrada a SB-
				Sender_Dests.Put(Dest, Mess, Destinos); 
				Tiempo := AC.Clock + Plazo_Retransmision;
				Sender_Buffering.Put(Buffering, Tiempo, Value);
				Timed_Handlers.Set_Timed_Handler
					(Tiempo , Retransmission'Access);  
			end if;
              
		end if;
		Sender_Buffering.Delete(Buffering, Time, Success);
	end Retransmission;
                        
   -----------------------------------------------------------------------------
   -------------REENVÍA EL INIT AL RESTO DE NODOS Y AÑADE-----------------------
   --------------------INFORMACIÓN A SD Y SB------------------------------------
   -----------------------------------------------------------------------------
        
	procedure Resend_Init(EP_H_Creat : LLU.End_Point_Type; EP_H_Rsnd : LLU.End_Point_Type; 
       Seq_N: Seq_N_T; Nick : ASU.Unbounded_String; EP_Rsnd1: LLU.End_Point_Type;
                     EP_R_Creat: LLU.End_Point_Type) is
                       
	Vecinos_Array : Neighbors.Keys_Array_Type := Neighbors.Get_Keys(My_Neighbors);
	NumC : Natural := Neighbors.Map_Length(My_Neighbors);
	--Corresponde a Sender Dest
	Mess: Mess_Id_T;
	Destino: Destinations_T;
	--Corresponde a Sender Buffering
	Tiempo: Ada.Calendar.Time;
	Value : Value_T;
   
	begin
		-- este será el buffer que quizá luego sea preciso reenviar
		CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
		CM.Message_Type'Output(CM.P_Buffer_Handler, CM.Init);
		LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
		Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
		LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Rsnd);
		LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_R_Creat);
		ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
		--El Init se reenvía a todos los vecinos menos al que me lo envió a mí.
		for K in 1..NumC loop
			if Vecinos_Array(K) /= EP_Rsnd1 then    
				LLU.Send(Vecinos_Array(K), CM.P_Buffer_Handler);
				Debug.Put_Line("          send to: " & End_Point_Image(Vecinos_Array(K)));
				Destino(K).EP := Vecinos_Array(K);
			end if;
		end loop;
		--Ahora vamos a añadir a las tablas Sender_Dest, según nos vayan asintiendo
		--borraremos a los vecinos de esta tabla(array destinations).
		Mess.EP := EP_H_Creat;
		Mess.Seq := Seq_N;
		Sender_Dests.Put(Dest, Mess, Destino);  
		--Ahora añadimos a la tabla Sender_Buffering el mensaje que enviamos y 
		--está pendiente de ser asentido.
		Tiempo := AC.Clock + Plazo_Retransmision;
		Value.EP_H_Creat := EP_H_Creat;
		Value.Seq_N := Seq_N; 
		Value.P_Buffer:= CM.P_Buffer_Handler;
		Sender_Buffering.Put(Buffering, Tiempo, Value);
		Timed_Handlers.Set_Timed_Handler
				(Tiempo , Retransmission'Access);    
	end Resend_Init;
    
    ----------------------------------------------------------------------------
    ---------------REENVÍA EL CONFIRM AL RESTO DE NODOS Y AÑADE-----------------
    ----------------INFORMACIÓN A TABLAS SD Y SB--------------------------------
    ----------------------------------------------------------------------------
    
	procedure Resend_Confirm(EP_H_Creat : LLU.End_Point_Type; Seq_N: Seq_N_T; 
                    Nick : ASU.Unbounded_String;EP_H_Rsnd: LLU.End_Point_Type;
                    EP_Rsnd1: LLU.End_Point_Type) is
                       
	Vecinos_Array : Neighbors.Keys_Array_Type := Neighbors.Get_Keys(My_Neighbors);
	NumC : Natural := Neighbors.Map_Length(My_Neighbors);
	--Corresponde a Sender Dest
	Mess: Mess_Id_T;
	Destino: Destinations_T;
	--Corresponde a Sender Buffering
	Tiempo: Ada.Calendar.Time;
	Value : Value_T;
        
	begin
		-- este será el buffer que quizá luego sea preciso reenviar
		CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
		CM.Message_Type'Output(CM.P_Buffer_Handler, CM.Confirm);
		LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
		Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
		LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Rsnd);
		ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
		--El Confirm se reenvía a todos los vecinos menos al que me lo envió a mí.
		for K in 1..NumC loop
			if Vecinos_Array(K) /= EP_Rsnd1 then    
				LLU.Send(Vecinos_Array(K), CM.P_Buffer_Handler);
				Debug.Put_Line("        send to: " & End_Point_Image(Vecinos_Array(K)));
				Destino(K).EP := Vecinos_Array(K);
			end if;
		end loop;
		--Ahora vamos a añadir a las tablas Sender_Dest, según nos vayan asintiendo
		--borraremos a los vecinos de esta tabla(array destinations).
		Mess.EP := EP_H_Creat;
		Mess.Seq := Seq_N;
		Sender_Dests.Put(Dest, Mess, Destino);  
		--Ahora añadimos a la tabla Sender_Buffering el mensaje que enviamos y 
		--está pendiente de ser asentido.
		Tiempo := AC.Clock + Plazo_Retransmision;
		Value.EP_H_Creat := EP_H_Creat;
		Value.Seq_N := Seq_N; 
		Value.P_Buffer:= CM.P_Buffer_Handler;
		Sender_Buffering.Put(Buffering, Tiempo, Value); 
		Timed_Handlers.Set_Timed_Handler
					(Tiempo , Retransmission'Access);
	end Resend_Confirm;
   
   ----------------------------ENVÍA ACK----------------------------------------
  
	procedure Send_Ack(EP_H_Acker: LLU.End_Point_Type; EP_H_Creat: LLU.End_Point_Type;
                     EP_H_Rsnd: LLU.End_Point_Type; Seq_N: Seq_N_T) is
        
	Buffer: aliased LLU.Buffer_Type(1024);
                                                   
	begin
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access, CM.Ack);
		LLU.End_Point_Type'Output(Buffer'Access, EP_H_Acker);
		LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
		Seq_N_T'Output(Buffer'Access, Seq_N);
		LLU.Send(EP_H_Rsnd, Buffer'Access);
		Debug.Put("ACK SENT: From ", Pantalla.Rojo);
		Debug.Put(End_Point_Image(EP_H_Acker), Pantalla.Azul);
		Debug.Put(" To ", Pantalla.Rojo);
		Debug.Put(End_Point_Image(EP_H_Rsnd), Pantalla.Azul); 
		Debug.Put_Line(" Seq: " &Seq_N_T'Image(Seq_N), Pantalla.Azul);
	end Send_Ack;
   
   -------------------------RECIBIR ACK-----------------------------------------
  
	procedure Receive_Ack(EP_H_Acker: LLU.End_Point_Type; EP_H_Creat: LLU.End_Point_Type;
                    Seq_N: Seq_N_T) is
                 
	Mess: Mess_Id_T;
	Destinos: Destinations_T;
	Success : Boolean;
	Todos_Nulos : Boolean := True;
	begin
		Debug.Put("ACK RCV: From ", Pantalla.Rojo);
		Debug.Put(End_Point_Image(EP_H_Acker)& " ", Pantalla.Azul);
		Debug.Put("EP_H_Creat: ", Pantalla.Rojo);
		Debug.Put(End_Point_Image(EP_H_Creat) & " ", Pantalla.Azul);
		Debug.Put_Line(" Seq: " & Seq_N_T'Image(Seq_N), Pantalla.Azul);
		Mess.EP := EP_H_Creat;
		Mess.Seq := Seq_N;
		--TIO.Put_Line("Antes de poner a null");
		--Sender_Dests.Print_Map(Dest);
		--se buscará en la tabla de símbolos Sender Dests el elemento 
		--correspondiente al mensaje que asiente el Ack.
		Sender_Dests.Get(Dest, Mess, Destinos, Success);
		if Success = True then
			for K in 1..10 loop
				--Se localizará
				--en el array Destinations el endpoint que envía el asentimiento,
				--asignándole null a esa posición para indicar que ya se ha 
				--recibido el Ack de ese vecino
				if Destinos(K).EP = EP_H_Acker then
					Destinos(K).EP := null; 
				end if;
			end loop;
         
			for K in 1..10 loop
				if Destinos(K).EP /= null then
					Todos_Nulos := False;
				end if;
			end loop;
      	
			if Todos_Nulos = True then 
				--TIO.Put_Line("Borramos porque ya nadie tiene que asentir");
				Sender_Dests.Delete(Dest,Mess, Success);
			else
				Sender_Dests.Put(Dest, Mess, Destinos);
				--TIO.Put_Line("Después de poner a null el mensaje asentido");
				--Sender_Dests.Print_Map(Dest); 
			end if;
		end if;
	end Receive_Ack;
   
   -------------------------ENVÍA EL REJECT-------------------------------------
     
	procedure Send_Reject(EP_H_To : LLU.End_Point_Type; Nick : ASU.Unbounded_String;
                   EP_R_Creat: LLU.End_Point_Type) is
                       
	Buffer: aliased LLU.Buffer_Type(1024);
    
	begin
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access, CM.Reject);
		LLU.End_Point_Type'Output(Buffer'Access, EP_H_To);
		ASU.Unbounded_String'Output(Buffer'Access, Nick);
		LLU.Send(EP_R_Creat, Buffer'Access);
	end Send_Reject;
    
    ----------------------------------------------------------------------------
    ---------------------ENVÍA EL LOGOUT Y AÑADE--------------------------------
    -------------------INFORMACIÓN A TABLAS SD Y SB-----------------------------
    ----------------------------------------------------------------------------
    
	procedure Resend_Logout(EP_H_Creat : LLU.End_Point_Type; Seq_N: Seq_N_T; 
                 Nick : ASU.Unbounded_String;EP_H_Rsnd: LLU.End_Point_Type; 
                EP_Rsnd1: LLU.End_Point_Type; Confirm_Sent: Boolean) is
                       
	Vecinos_Array : Neighbors.Keys_Array_Type := Neighbors.Get_Keys(My_Neighbors);
	NumC : Natural := Neighbors.Map_Length(My_Neighbors);
	--Corresponde a Sender Dest
	Mess: Mess_Id_T;
	Destino: Destinations_T;
	--Corresponde a Sender Buffering
	Tiempo: Ada.Calendar.Time;
	Value : Value_T;
        
	begin
		-- este será el buffer que quizá luego sea preciso reenviar
		CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
		CM.Message_Type'Output(CM.P_Buffer_Handler, CM.Logout);
		LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
		Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
		LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Rsnd);
		ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
		Boolean'Output(CM.P_Buffer_Handler, Confirm_Sent);
		--El Logout se reenvía a todos los vecinos menos al que me lo envió a mí.
		for K in 1..NumC loop
			if Vecinos_Array(K) /= EP_Rsnd1 then    
				LLU.Send(Vecinos_Array(K), CM.P_Buffer_Handler);
				Debug.Put_Line("        send to: " & End_Point_Image(Vecinos_Array(K)));
				Destino(K).EP := Vecinos_Array(K);
			end if;
		end loop;
		--Ahora vamos a añadir a las tablas Sender_Dest, según nos vayan asintiendo
		--borraremos a los vecinos de esta tabla(array destinations).
		Mess.EP := EP_H_Creat;
		Mess.Seq := Seq_N;
		Sender_Dests.Put(Dest, Mess, Destino);  
		--Ahora añadimos a la tabla Sender_Buffering el mensaje que enviamos y 
		--está pendiente de ser asentido.
		Tiempo := AC.Clock + Plazo_Retransmision;
		Value.EP_H_Creat := EP_H_Creat;
		Value.Seq_N := Seq_N; 
		Value.P_Buffer:= CM.P_Buffer_Handler;
		Sender_Buffering.Put(Buffering, Tiempo, Value);
		Timed_Handlers.Set_Timed_Handler
					(Tiempo , Retransmission'Access);
	end Resend_Logout;
    ----------------------------------------------------------------------------
    ---------------------REENVÍA EL WRITER Y AÑADE------------------------------
    --------------------INFORMACIÓN A TABLAS SD Y SB----------------------------
    ----------------------------------------------------------------------------
    
	procedure Resend_Writer(EP_H_Creat : LLU.End_Point_Type; 
                 EP_H_Rsnd : LLU.End_Point_Type; 
                 Seq_N: Seq_N_T; Nick : ASU.Unbounded_String;
                 EP_Rsnd1: LLU.End_Point_Type;
                 Comentario: ASU.Unbounded_String) is
                       
	Vecinos_Array : Neighbors.Keys_Array_Type := Neighbors.Get_Keys(My_Neighbors);
	NumC : Natural := Neighbors.Map_Length(My_Neighbors);
	--Corresponde a Sender Dest
	Mess: Mess_Id_T;
	Destino: Destinations_T;
	--Corresponde a Sender Buffering
	Tiempo: Ada.Calendar.Time;
	Value : Value_T;

	begin
		-- este será el buffer que quizá luego sea preciso reenviar
		CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
		CM.Message_Type'Output(CM.P_Buffer_Handler, CM.Writer);
		LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
		Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
		LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Rsnd);
		ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
		ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Comentario);
		--El Logout se reenvía a todos los vecinos menos al que me lo envió a mí.
		for K in 1..NumC loop
			if Vecinos_Array(K) /= EP_Rsnd1 then    
				LLU.Send(Vecinos_Array(K), CM.P_Buffer_Handler);
				Debug.Put_Line("          send to: " & End_Point_Image(Vecinos_Array(K)));
				Destino(K).EP := Vecinos_Array(K);
			end if;
		end loop;
		--Ahora vamos a añadir a las tablas Sender_Dest, según nos vayan asintiendo
		--borraremos a los vecinos de esta tabla(array destinations).
		Mess.EP := EP_H_Creat;
		Mess.Seq := Seq_N;
		Sender_Dests.Put(Dest, Mess, Destino);  
		--Ahora añadimos a la tabla Sender_Buffering el mensaje que enviamos y 
		--está pendiente de ser asentido.
		Tiempo := AC.Clock + Plazo_Retransmision;
		Value.EP_H_Creat := EP_H_Creat;
		Value.Seq_N := Seq_N; 
		Value.P_Buffer:= CM.P_Buffer_Handler;
		Sender_Buffering.Put(Buffering, Tiempo, Value);
		Timed_Handlers.Set_Timed_Handler
					(Tiempo , Retransmission'Access);
	end Resend_Writer;
 
 ---------------------------HANDLER RECEPCIÓN-----------------------------------
 
	procedure Handler (From: in LLU.End_Point_Type;
                      To : in LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type) is   
	Tipo : CM.Message_Type;
	EP_H_Creat: LLU.End_Point_Type;
	Seq_N: Seq_N_T;
	EP_H_Rsnd: LLU.End_Point_Type;
	EP_R_Creat: LLU.End_Point_Type;
	Nick : ASU.Unbounded_String;
	Success : Boolean;
	Old_Seq: Seq_N_T;
	EP_Rsnd_Old: LLU.End_Point_Type;
	Confirm_Sent: Boolean;
	Comentario : ASU.Unbounded_String;
	EP_H_Acker: LLU.End_Point_Type;
   
	begin
   
   ----------SACO LOS ELEMENTOS DEL MENSAJE DEL BUFFER--------------------------
        
	Tipo := CM.Message_Type'Input(P_Buffer);
	if Tipo /= CM.Ack then
		EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer);
		Seq_N := Seq_N_T'Input(P_Buffer); 
		EP_H_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
		if EP_H_Creat = EP_H_Rsnd and Tipo/= CM.Logout then
			--Añado como vecino, si me añadieron a mí.
			Update_Neighbors(My_Neighbors, EP_H_Creat);
		end if;
	else
		EP_H_Acker := LLU.End_Point_Type'Input(P_Buffer);
		EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer);
		Seq_N := Seq_N_T'Input(P_Buffer); 
		Receive_Ack(EP_H_Acker, EP_H_Creat, Seq_N);
		TIO.Put_Line("");
	end if;
    
    --Veo si el número de secuencia que he recibido ya estaba en mi tabla
    Latest_Msgs.Get(Messages, EP_H_Creat, Old_Seq, Success);        
    --Si el mensaje no estaba, pero el tipo es Logout, quiere decir que ya lo
    --borramos de Latest_Messages, y no lo reenviamos ni añadimos, solo-------
    --ponemos que lo recibimos y no reenviamos--------------------------------
        
	if Tipo = CM.Logout and Success = False then
		Nick := ASU.Unbounded_String'Input(P_Buffer);
		Confirm_Sent:= Boolean'Input(P_Buffer);
		Debug.Put("RCV Logout ", Pantalla.Amarillo);
		Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
          &  End_Point_Image(EP_H_Rsnd) & " ... " & ASU.To_String(Nick)
                                     & " "& Boolean'Image(Confirm_Sent));
		Debug.Put("    NOFLOOD Logout ", Pantalla.Amarillo);
		Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
                    &  End_Point_Image(EP_H_Rsnd)  & ASU.To_String(Nick) & " "
                                        & Boolean'Image(Confirm_Sent));
		Send_Ack(To, EP_H_Creat, EP_H_Rsnd, Seq_N);
		TIO.New_Line;
         
    ----Si no estaba, o el número de Seq recibido es inmediatamente consecutivo-
    --al que estaba Seq = Old_Seq + 1-------------------------------------------
    ----almacenado, lo añadimos/actualizamos en Latest_Messages-----------------
	elsif Success = False or Old_Seq + 1 = Seq_N then
		
      --------------------PROCESAMOS EL MENSAJE-----------------------------    
		if Tipo = CM.Init then
			Latest_Msgs.Put(Messages, EP_H_Creat, Seq_N, Success);
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
			--Envío Ack asintiendo el mensaje a quien me lo envió,
			--y que reenviaré.
			Send_Ack(To, EP_H_Creat, EP_H_Rsnd, Seq_N);

			--EL NUEVO EP_H_RSND SERÁ EL DE ESTE NODO HANDLER, Y EL QUE VENÍA EN
			--EL BUFFER SERÁ AL QUE NO HAYA QUE ENVIARLE NADA POR INUNDACIÓN, YA
			--QUE FUE EL QUE ME LO ENVIÓ A MÍ-----------------------------------
			EP_Rsnd_Old:= EP_H_Rsnd;
			EP_H_Rsnd := To;
			Debug.Put("    FLOOD Init ", Pantalla.Amarillo);
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              &  End_Point_Image(EP_H_Rsnd) & " ... " & ASU.To_String(Nick));
			--REENVIAMOS EL INIT.
			Resend_Init(EP_H_Creat, EP_H_Rsnd,Seq_N,Nick,EP_Rsnd_Old,EP_R_Creat);
			TIO.New_Line;
                     
		elsif Tipo = CM.Confirm then
			Latest_Msgs.Put(Messages, EP_H_Creat, Seq_N, Success);
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			---PARA EL ERROR DE QUE LLEGA ANTES EL INIT--
			--Neighbors.Put(Neigh, EP_H_Creat, AC.Clock, Success);
			Debug.Put("RCV Confirm ", Pantalla.Amarillo);
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              &  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick));
			Debug.Put(ASU.To_String(Nick), Pantalla.Blanco);
			Debug.Put_Line(" ha entrado en el chat", Pantalla.Blanco);
			Debug.Put_line("    Añadimos a latest_messages " & 
                   End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N));
			--Envío Ack asintiendo el mensaje a quien me lo envió,
			--y que reenviaré.
			Send_Ack(To, EP_H_Creat, EP_H_Rsnd, Seq_N);     
                                
			--EL NUEVO EP_H_RSND SERÁ EL DE ESTE NODO HANDLER, Y EL QUE VENÍA EN
			--EL BUFFER SERÁ AL QUE NO HAYA QUE ENVIARLE NADA POR INUNDACIÓN, YA
			--QUE FUE EL QUE ME LO ENVIÓ A MÍ-----------------------------------
			EP_Rsnd_Old:= EP_H_Rsnd;
			EP_H_Rsnd := To;
			Debug.Put("    FLOOD Confirm ", Pantalla.Amarillo);
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
                     &  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick));
			--REENVIAMOS EL CONFIRM.
			Resend_Confirm(EP_H_Creat, Seq_N,Nick,EP_H_Rsnd,EP_Rsnd_Old);
			TIO.New_Line;
            
		elsif Tipo = CM.Logout then
			Latest_Msgs.Put(Messages, EP_H_Creat, Seq_N, Success);
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Confirm_Sent:= Boolean'Input(P_Buffer);
			Debug.Put("RCV Logout ", Pantalla.Amarillo);
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
                &  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick)& " " &
                   Boolean'Image(Confirm_Sent));
			Debug.Put_Line("    Borramos de latest_messages a " & End_Point_Image(EP_H_Creat));
			--SI ERA VECINO NUESTRO, LO BORRAMOS
			Delete_Neighbors(My_Neighbors, EP_H_Creat);
			--Envío Ack asintiendo el mensaje a quien me lo envió,
			--y que reenviaré.
			Send_Ack(To, EP_H_Creat, EP_H_Rsnd, Seq_N);
			
			if Confirm_Sent = True then
				Debug.Put_Line(ASU.To_String(Nick) & " ha abandonado el chat", Pantalla.Blanco);
			end if;
			--EL NUEVO EP_H_RSND SERÁ EL DE ESTE NODO HANDLER, Y EL QUE VENÍA EN
			--EL BUFFER SERÁ AL QUE NO HAYA QUE ENVIARLE NADA POR INUNDACIÓN, YA
			--QUE FUE EL QUE ME LO ENVIÓ A MÍ-----------------------------------
                
			EP_Rsnd_Old:= EP_H_Rsnd;
			EP_H_Rsnd := To;
			Debug.Put("    FLOOD Logout ", Pantalla.Amarillo);
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
               &  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick)&" " &
		                Boolean'Image(Confirm_Sent));
			Resend_Logout(EP_H_Creat, Seq_N,Nick,EP_H_Rsnd,EP_Rsnd_Old, Confirm_Sent);
			Latest_Msgs.Delete(Messages, EP_H_Creat, Success);
			TIO.New_Line;
            
		elsif Tipo = CM.Writer then
			Latest_Msgs.Put(Messages, EP_H_Creat, Seq_N, Success);
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Comentario := ASU.Unbounded_String'Input(P_Buffer);
			Debug.Put("RCV Writer ", Pantalla.Amarillo);
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
                    &  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick)
                           &" " & ASU.To_String(Comentario));
			TIO.Put_Line(ASU.To_String(Nick) & ": " & ASU.To_String(Comentario));
			Debug.Put_line("    Añadimos a latest_messages " & End_Point_Image(EP_H_Creat) 
                               & Seq_N_T'Image(Seq_N));
         --Envío Ack asintiendo el mensaje a quien me lo envió,
	      --y que reenviaré.
         Send_Ack(To, EP_H_Creat, EP_H_Rsnd, Seq_N);

			--EL NUEVO EP_H_RSND SERÁ EL DE ESTE NODO HANDLER, Y EL QUE VENÍA EN
			--EL BUFFER SERÁ AL QUE NO HAYA QUE ENVIARLE NADA POR INUNDACIÓN, YA
			--QUE FUE EL QUE ME LO ENVIÓ A MÍ-----------------------------------
			EP_Rsnd_Old:= EP_H_Rsnd;
			EP_H_Rsnd := To;
			Debug.Put("    FLOOD Writer ", Pantalla.Amarillo);
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
         & End_Point_Image(EP_H_Rsnd) & ASU.To_String(Nick)& " " & ASU.To_String(Comentario));
			--REENVIAMOS EL WRITER.
			Resend_Writer(EP_H_Creat, EP_H_Rsnd, Seq_N, Nick, EP_Rsnd_Old,
                                                        Comentario);
			TIO.New_Line;
		end if;
        
       --SI LA SEQ ES LA MISMA,O <, YA NOS LLEGÓ ESE MENSAJE, PONEMOS QUE 
		 --LO RECIBIMOS---Y NO LO REENVIAMOS YA----------------------------------
       
	elsif Old_Seq = Seq_N  or Seq_N < Old_Seq then
		if Tipo = CM.Init then
			EP_R_Creat := LLU.End_Point_Type'Input(P_Buffer);
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Debug.Put("RCV Init ", Pantalla.Amarillo);
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
             &  End_Point_Image(EP_H_Rsnd) & " ... " & ASU.To_String(Nick));
         Send_Ack(To, EP_H_Creat, EP_H_Rsnd, Seq_N);
			EP_H_Rsnd := To;
			Debug.Put("    NOFLOOD Init ", Pantalla.Amarillo);
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
                     &  End_Point_Image(EP_H_Rsnd)  & ASU.To_String(Nick));
       
			TIO.Put_Line("");
          
		elsif Tipo = CM.Confirm then
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Debug.Put("RCV Confirm ", Pantalla.Amarillo);
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
                 & End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick));
			Debug.Put("    NOFLOOD Confirm ", Pantalla.Amarillo);
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
                     &  End_Point_Image(EP_H_Rsnd)  & ASU.To_String(Nick));
					
			Send_Ack(To, EP_H_Creat, EP_H_Rsnd, Seq_N);
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
			Send_Ack(To, EP_H_Creat, EP_H_Rsnd, Seq_N);
         TIO.Put_Line("");
			
		end if;
		
	elsif Seq_N >= 2 + Old_Seq then
		if Tipo = CM.Init then
			Debug.Put_Line("Mensaje Init del futuro");
			EP_R_Creat := LLU.End_Point_Type'Input(P_Buffer); 
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Debug.Put("RCV Future Init ");
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
               &  End_Point_Image(EP_H_Rsnd) & " ... " & ASU.To_String(Nick), Pantalla.Azul_Claro);
			EP_Rsnd_Old:= EP_H_Rsnd;
			EP_H_Rsnd := To;
			Debug.Put("    FLOOD Future Init ");
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              &  End_Point_Image(EP_H_Rsnd) & " ... " & ASU.To_String(Nick), Pantalla.Azul_Claro);
			Resend_Init(EP_H_Creat, EP_H_Rsnd,Seq_N,Nick,EP_Rsnd_Old,EP_R_Creat);
			TIO.New_Line;
			
		elsif Tipo = CM.Confirm then
			Debug.Put_Line("Mensaje Confirm del futuro");
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Debug.Put("RCV Future Confirm ");
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
              &  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick), Pantalla.Azul_Claro);
			EP_Rsnd_Old:= EP_H_Rsnd;
			EP_H_Rsnd := To;
			Debug.Put("    FLOOD Future Confirm ");
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
                     &  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick), Pantalla.Azul_Claro);
			Resend_Confirm(EP_H_Creat, Seq_N,Nick,EP_H_Rsnd,EP_Rsnd_Old);
			TIO.New_Line;
			
		elsif Tipo = CM.Writer then
			Debug.Put_Line("Mensaje Writer del futuro");
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Comentario := ASU.Unbounded_String'Input(P_Buffer);
			Debug.Put("RCV Future Writer ");
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
                    &  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick)
                           &" " & ASU.To_String(Comentario), Pantalla.Azul_Claro);
			EP_Rsnd_Old:= EP_H_Rsnd;
			EP_H_Rsnd := To;
			Debug.Put("    FLOOD Future Writer ");
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
        			 & End_Point_Image(EP_H_Rsnd) & ASU.To_String(Nick)& " " 
        			 & ASU.To_String(Comentario), Pantalla.Azul_Claro);
			Resend_Writer(EP_H_Creat, EP_H_Rsnd, Seq_N, Nick, EP_Rsnd_Old,
                                                        Comentario);
         TIO.New_Line;
			
		elsif Tipo = CM.Logout then
			Debug.Put_Line("Mensaje Logout del futuro");
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Confirm_Sent:= Boolean'Input(P_Buffer);
			Debug.Put("RCV Future Logout ");
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
                &  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick)& " " &
                   Boolean'Image(Confirm_Sent), Pantalla.Azul_Claro);
			EP_Rsnd_Old:= EP_H_Rsnd;
			EP_H_Rsnd := To;
			Debug.Put("    FLOOD Future Logout ");
			Debug.Put_Line(End_Point_Image(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " 
               &  End_Point_Image(EP_H_Rsnd) & " " & ASU.To_String(Nick)&" " &
		                Boolean'Image(Confirm_Sent), Pantalla.Azul_Claro);
			Resend_Logout(EP_H_Creat, Seq_N,Nick,EP_H_Rsnd,EP_Rsnd_Old, Confirm_Sent);
			TIO.New_Line;
			
		
		end if;              
	end if;
      
   end Handler;

end Chat_Handlers;
