--Alba García de la Camacha Selgas

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;

procedure Chat_Client is
   package TIO renames Ada.Text_IO;
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package CM renames Chat_Messages;
   use type CM.Message_Type;
   use type ASU.Unbounded_String;

   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Expired : Boolean;
   Usage_Error : exception;
   Tipo : CM.Message_Type;
   Message : CM.Message;
   
begin
   if ACL.Argument_Count /= 3 then
        raise Usage_Error;
   end if;
   -- Construye el End_Point en el que está atado el servidor
   Server_EP := LLU.Build(LLU.To_IP(ACL.Argument(1)), Natural'Value(ACL.Argument(2)));
   -- Construye un End_Point libre cualquiera y se ata a él
   LLU.Bind_Any(Client_EP);
   
   --Construye el mensaje inicial
   Tipo := CM.Init;
   Message.EP := Client_EP;
   Message.Nick := ASU.To_Unbounded_String(ACL.Argument(3));
-- reinicializa el buffer para empezar a utilizarlo y mete los campos uno a uno
   LLU.Reset(Buffer);
   CM.Message_Type'Output(Buffer'Access, Tipo);
   LLU.End_Point_Type'Output(Buffer'Access, Message.EP);
   ASU.Unbounded_String'Output(Buffer'Access, Message.Nick);
   --Envía el mensaje inicial al servidor
   LLU.Send(Server_EP, Buffer'Access);

   if Message.Nick = "lector" then
        -- bucle infinito
        loop
             LLU.Reset(Buffer);
             LLU.Receive (Client_EP, Buffer'Access, 1000.0, Expired);
             if Expired then
                 Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo");
             else
                -- saca del buffer
                --será tipo server aquí porque el que se lo envía es el server
                Tipo := CM.Message_Type'Input(Buffer'Access);
                --Es el nick que le llegó al servidor del escritor y aquí el lector lo escribe.
                Message.Nick := ASU.Unbounded_String'Input(Buffer'Access);
                TIO.Put(ASU.To_String(Message.Nick) & ": ");
                --Es el comentario que le llegó al servidor del escritor y aquí el lector lo escribe.
                Message.Comentario := ASU.Unbounded_String'Input (Buffer'Access);
                TIO.Put_Line (ASU.To_String(Message.Comentario));

              end if;
        end loop;
              
   else
        Tipo:= CM.Writer;
        loop 
                Ada.Text_IO.Put("Introduce una cadena caracteres: ");
                Message.Comentario := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
                if Message.Comentario /= ".salir" then
                   LLU.Reset(Buffer);
                   -- introduce el Buffer
                   CM.Message_Type'Output(Buffer'Access, Tipo);
                   LLU.End_Point_Type'Output(Buffer'Access, Message.EP);
                   ASU.Unbounded_String'Output(Buffer'Access, Message.Comentario);
                   -- envía el contenido del Buffer 
                   LLU.Send(Server_EP, Buffer'Access);
                end if;
                exit when Message.Comentario = ".salir";
                
        end loop;
   end if;
   
   -- termina Lower_Layer_UDP
   LLU.Finalize;

exception
   when Usage_Error =>
      TIO.Put_Line("Argumentos incorrectos");
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Client;
