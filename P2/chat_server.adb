--Alba García de la Camacha Selgas

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Pac;


procedure Chat_Server is

   package TIO renames Ada.Text_IO;
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package CM renames Chat_Messages;
   use type CM.Message_Type;
   use type ASU.Unbounded_String;
   use type LLU.End_Point_Type;


   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Request: ASU.Unbounded_String;
   Expired : Boolean;
   Usage_Error : exception;
   Message : CM.Message;
   Tipo : CM.Message_Type;
   NumC : Natural := 0;
   Cliente : Pac.Clientes;
   Esta : Boolean:= False;

begin
   if ACL.Argument_Count /= 1 then
        raise Usage_Error;
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
            Message.EP := LLU.End_Point_Type'Input (Buffer'Access);
            Message.Nick := ASU.Unbounded_String'Input(Buffer'Access);
            NumC := NumC + 1;-- Me aumenta el Número de clientes en 1
            Pac.Add(Cliente, Message, NumC);
            TIO.Put_Line("recibido mensaje inicial de " & ASU.To_String(Message.Nick));
            
         elsif Tipo = CM.Writer then
            -- sacar EP
            Message.EP := LLU.End_Point_Type'Input (Buffer'Access);
            -- sacar comentario
            Message.Comentario := ASU.Unbounded_String'Input(Buffer'Access);
            -- busca nick del escritor
            Pac.Buscar(Cliente, Message.EP, Message.Nick, NumC);
            TIO.Put("recibido mensaje de ");
            TIO.Put_Line(ASU.To_String(Message.Nick)&": " &ASU.To_String(Message.Comentario));
           
            --Compone Server que enviará a los lectores
            Tipo := CM.Server;
            LLU.Reset(Buffer);
            -- introduce tipo, nick y comentario en el Buffer
            CM.Message_Type'Output(Buffer'Access, Tipo);
            ASU.Unbounded_String'Output(Buffer'Access, Message.Nick);                
            ASU.Unbounded_String'Output(Buffer'Access, Message.Comentario);
            -- Busca a los lectores en el array para enviarles lo que recibió del escritor.
            for C in 1..NumC loop   
             	if Cliente(C).Nick = "lector" then 
                   Client_EP := Cliente(C).EP;		   
                   -- enviar Server a lectores
                   LLU.Send(Client_EP, Buffer'Access);
            	end if;
            end loop;
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
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Server;
