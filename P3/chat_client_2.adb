--Alba García de la Camacha Selgas

with Handlers;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;

procedure Chat_Client_2 is
   package TIO renames Ada.Text_IO;
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package CM renames Chat_Messages;
   use type CM.Message_Type;
   use type ASU.Unbounded_String;

   Server_EP: LLU.End_Point_Type;
   Client_EP_Receive: LLU.End_Point_Type;
   Client_EP_Handler: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Expired : Boolean;
   Usage_Error : exception;
   Nick_Error : exception;
   Tipo : CM.Message_Type;
   Nick : ASU.Unbounded_String;
   Comentario: ASU.Unbounded_String;
   Aceptado: Boolean;
   
begin
   if ACL.Argument_Count /= 3 then
        raise Usage_Error;
   end if;
   if ACL.Argument(3) = "servidor" then
        raise Nick_Error;
   else
         -- Construye el End_Point en el que está atado el servidor
         Server_EP := LLU.Build(LLU.To_IP(ACL.Argument(1)), Natural'Value(ACL.Argument(2)));
         -- Construye un End_Point libre cualquiera y se ata a él, este será el que utilizaré con Receive
         LLU.Bind_Any(Client_EP_Receive);
         -- Se ata a otro End_Point libre para el Handler
         LLU.Bind_Any (Client_EP_Handler, Handlers.Client_Handler'Access);
   
         --Construyo el mensaje inicial
         Tipo := CM.Init;
         Nick := ASU.To_Unbounded_String(ACL.Argument(3));
        -- reinicializo el buffer para empezar a utilizarlo y meto los campos uno a uno
         LLU.Reset(Buffer);
         CM.Message_Type'Output(Buffer'Access, Tipo);
         LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Receive);
         LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
         ASU.Unbounded_String'Output(Buffer'Access, Nick);
        --Envío el mensaje inicial al servidor
         LLU.Send(Server_EP, Buffer'Access);
         LLU.Reset(Buffer);
        --Ahora el cliente espera a recibir el mensaje de aceptación del servidor
         LLU.Receive (Client_EP_Receive, Buffer'Access, 10.0, Expired);
        if Expired then
             TIO.Put_Line("No es posible comunicarse con el servidor");
        else
             --Saco del buffer el tipo y el booleano Aceptado.
             Tipo := CM.Message_Type'Input(Buffer'Access);
             Aceptado := Boolean'Input(Buffer'Access);
             if Aceptado = True then 
                 Tipo:= CM.Writer;
                 TIO.Put_Line("Mini-Chat v2.0: Bienvenido " & ASU.To_String(Nick));
                 loop 	
                      Ada.Text_IO.Put(">>");
                      Comentario := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
                      if Comentario /= ".salir" then
                           LLU.Reset(Buffer);
                           -- introduce el Buffer
                           CM.Message_Type'Output(Buffer'Access, Tipo);
                           LLU.End_Point_Type'Output(Buffer'Access,Client_EP_Handler);
                           ASU.Unbounded_String'Output(Buffer'Access, Comentario);
                           -- envía el contenido del Buffer 
                           LLU.Send(Server_EP, Buffer'Access);
                      else
                          Tipo := CM.Logout;
                          LLU.Reset(Buffer);
                          CM.Message_Type'Output(Buffer'Access, Tipo);
                          LLU.End_Point_Type'Output(Buffer'Access,Client_EP_Handler);
                          LLU.Send(Server_EP, Buffer'Access);
                      end if;
                      exit when Comentario = ".salir";
                  end loop;
             else
                TIO.Put("Mini-Chat v2.0: Cliente rechazado porque el nickname"& ASU.To_String(Nick)&
                        " ya existe en este servidor.");
             end if;    
         end if;
  end if;
   
   -- termina Lower_Layer_UDP
   LLU.Finalize;

exception
   when Usage_Error =>
      TIO.Put_Line("Argumentos incorrectos: Pon: nombre máquina del servidor, puerto en el que escucha y tu Nick");
      
      LLU.Finalize;
   when Nick_Error =>
      TIO.Put_Line("El Nick servidor no puede ser usado por un cliente");
      
      LLU.Finalize;
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Client_2;
