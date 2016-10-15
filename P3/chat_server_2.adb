--Alba García de la Camacha Selgas

with Handlers;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Users;
with Ada.Calendar;


procedure Chat_Server_2 is

   package TIO renames Ada.Text_IO;
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package CM renames Chat_Messages;
   package AC renames Ada.Calendar;
   use type CM.Message_Type;
   use type ASU.Unbounded_String;
   use type LLU.End_Point_Type;


   Server_EP: LLU.End_Point_Type;
   Client_EP_Receive: LLU.End_Point_Type;
   Client_EP_Handler: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Expired : Boolean;
   Usage_Error : exception;
   Max_Error : exception;
   Nick : ASU.Unbounded_String;
   Comentario : ASU.Unbounded_String;
   Tipo : CM.Message_Type;
   NumC : Natural := 0;
   Cliente : Users.Clients_List;
   Esta : Boolean;
   Aceptado : Boolean;
   Maximo: Natural;
   Nick_Fuera : ASU.Unbounded_String;

begin
   if ACL.Argument_Count /= 2 then
        raise Usage_Error;
   end if;
   
   Maximo := Natural'Value(ACL.Argument(2));
   
   if Maximo < 2 or Maximo > 50 then
        raise Max_Error;
   end if;
   
   -- construye un End_Point en una dirección y puerto concretos
   Server_EP := LLU.Build (LLU.To_IP(LLU.Get_Host_Name), Natural'Value(ACL.Argument(1)));
   -- se ata al End_Point para poder recibir en él
   LLU.Bind (Server_EP);
   -- bucle infinito
   loop
      -- reinicializa (vacía) el buffer para ahora recibir en él
      LLU.Reset(Buffer);
      -- espera 1000.0 segundos a recibir algo dirigido al Server_EP
      --   . si llega antes, los datos recibidos van al Buffer
      --     y Expired queda a False
      --   . si pasados los 1000.0 segundos no ha llegado nada, se abandona
      --     la espera y Expired queda a True
      LLU.Receive (Server_EP, Buffer'Access, 1000.0, Expired);

      if Expired then
         Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo");
      else
         -- saca el tipo del Buffer y en función de lo que sea hace una cosa u otra
         Tipo := CM.Message_Type'Input(Buffer'Access);
         if Tipo = CM.Init then
            Client_EP_Receive := LLU.End_Point_Type'Input (Buffer'Access);
            Client_EP_Handler := LLU.End_Point_Type'Input (Buffer'Access);
            Nick := ASU.Unbounded_String'Input(Buffer'Access);
            --Busca si el Nick está o no en la lista o array.
            Users.Buscar_Esta(Cliente, Nick, Maximo, Esta);
            if Esta = False then
            	NumC := NumC + 1;-- Me aumenta el Número de clientes en 1
            	if NumC = Maximo + 1 then
            	   Users.Expulsar(Cliente, Maximo, Nick_Fuera);
                   --Server que informa de que Nick_Fuera ha sido expulsado del chat a 
                   --los demás clientes.
            	   Tipo := CM.Server;
            	   Comentario := Nick_Fuera & ASU.To_Unbounded_String(" ha sido expulsado del  chat");
            	   LLU.Reset(Buffer);
            	   CM.Message_Type'Output(Buffer'Access, Tipo);
		   ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String("servidor"));                
		   ASU.Unbounded_String'Output(Buffer'Access, Comentario);
		   Users.Buscar_y_Envia(Cliente, ASU.To_Unbounded_String(""), Maximo, Buffer'Access);
		   NumC := NumC - 1;
            	end if;      	
            	Users.Add(Cliente, Client_EP_Handler, Nick, Maximo);
	        Aceptado := True;
	        TIO.Put_Line("recibido mensaje inicial de " & ASU.To_String(Nick)&": ACEPTADO");
	        --El servidor informa al resto de clientes de que este usuario ha entrado.
	        Tipo := CM.server;
	        Comentario := Nick & ASU.To_Unbounded_String(" ha entrado en el chat");
	        LLU.Reset(Buffer);
	        CM.Message_Type'Output(Buffer'Access, Tipo);
	        ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String("servidor"));                
	        ASU.Unbounded_String'Output(Buffer'Access, Comentario);
		Users.Buscar_y_Envia(Cliente, Nick, Maximo, Buffer'Access);
          	 
            else
            	Aceptado := False;
            	TIO.Put_Line("recibido mensaje inicial de " & ASU.To_String(Nick)&": RECHAZADO");
            end if;
            --Envía el mensaje de acogida al cliente diciéndole si ha sido
            --aceptado.
            Tipo := CM.Welcome;
            LLU.Reset(Buffer);
            CM.Message_Type'Output(Buffer'Access, Tipo);
            Boolean'Output(Buffer'Access, Aceptado);
            LLU.Send(Client_EP_Receive, Buffer'Access);
            
         elsif Tipo = CM.Writer then
            -- sacar EP
            Client_EP_Handler := LLU.End_Point_Type'Input (Buffer'Access);
            -- sacar comentario
            Comentario := ASU.Unbounded_String'Input(Buffer'Access);
            --Busco el Nick correspondiente a la dirección EP_Handler que me llegó.
            Users.Buscar_Nick(Cliente, Client_EP_Handler, Nick, Maximo);
            TIO.Put("recibido mensaje de ");
            TIO.Put_Line(ASU.To_String(Nick)&": " &ASU.To_String(Comentario));
            --El servidor  reenvía los mensajes que le llegan de este usuario a los demás.
            Tipo := CM.Server;
            LLU.Reset(Buffer);
            CM.Message_Type'Output(Buffer'Access, Tipo);
            ASU.Unbounded_String'Output(Buffer'Access, Nick);                
            ASU.Unbounded_String'Output(Buffer'Access, Comentario);
            Users.Buscar_y_Envia(Cliente, Nick, Maximo, Buffer'Access);
            
         elsif Tipo = CM.Logout then
            Client_EP_Handler := LLU.End_Point_Type'Input (Buffer'Access);
            Users.Buscar_Nick(Cliente, Client_EP_Handler, Nick, Maximo);
            TIO.Put_Line("Recibido mensaje de salida de "& ASU.To_String(Nick));
            --El servidor envía al resto de clientes un mensaje diciendo 
            --que este usuario se ha ido(voluntariamente);
            Tipo := CM.server;
            Comentario := Nick & ASU.To_Unbounded_String(" ha abandonado el chat");
            LLU.Reset(Buffer);
            CM.Message_Type'Output(Buffer'Access, Tipo);
            ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String("servidor"));                
            ASU.Unbounded_String'Output(Buffer'Access, Comentario);
            Users.Buscar_y_Envia(Cliente, Nick, Maximo, Buffer'Access);
            Users.Delete(Cliente, Client_EP_Handler, Maximo);
            NumC := NumC - 1;
         else
            TIO.Put_Line("Recibido mensaje de tipo inesperado");
         end if;
      end if;
   end loop;

   -- nunca se alcanza este punto
   -- si se alcanzara, habría que llamar a LLU.Finalize;

exception
   when Usage_Error =>
      TIO.Put_Line("Argumentos incorrectos");
      LLU.Finalize;
   when Max_Error =>
      TIO.Put_Line("Número de clientes no válido");
      LLU.Finalize;
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Server_2;
