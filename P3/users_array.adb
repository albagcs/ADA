--Alba García de la Camacha Selgas

package body Users is
        use type ASU.Unbounded_String;
        use type Ada.Calendar.Time;
        
       --Busco el menor tiempo de la lista para luego usarlo al expulsar.
       procedure Buscar_Tiempo_Menor(Cliente: Clients_List; Max : Natural; Tiempo_Menor: in out AC.Time) is
       N : Natural:= 1;
       begin
              while N <= Max and Cliente(N).Ocupado = True loop
                  if N = 1 then
                     Tiempo_Menor := Cliente(N).Time;
                  else
                     if Cliente(N).Time < Tiempo_Menor then
                             Tiempo_Menor := Cliente(N).Time;        
                     end if; 
                  end if;
                  N := N + 1;
              end loop;
        end Buscar_Tiempo_Menor;
        
        --Añado en los huecos del array cuyos campos Ocupado es False.
        procedure Add(Cliente: in out Clients_List; EP : LLU.End_Point_Type; Nick: ASU.Unbounded_String; Max: Natural) is
         N: Natural:= 1;
         Guardado : Boolean:= False;
         begin
                while N <= Max and Guardado =False loop
                      if Cliente(N).Ocupado = False then
                         Cliente(N).EP := EP;
                         Cliente(N).Nick := Nick;
                         Cliente(N).Ocupado := True;
                         Cliente(N).Time := AC.Clock;
                         Guardado := True;
                      end if;
                      N := N +1;
               end loop;               
        end Add;
        
        --Expulsa al cliente que lleva más tiempo sin hablar y le informa
        --a él de que fue expulsado.
        procedure Expulsar(Cliente: in out Clients_List; Max: Natural; Nick_Fuera: out ASU.Unbounded_String) is
        N: Natural:= 1;
        Tiempo_Menor: AC.Time;
        Tipo : CM.Message_Type := CM.Server;
        Comentario: ASU.Unbounded_String := ASU.To_Unbounded_String("Has sido expulsado del chat, cierre su cliente(Ctrl+C)");
        Buffer: aliased LLU.Buffer_Type(1024);
        begin
            Buscar_Tiempo_Menor(Cliente, Max, Tiempo_Menor);
            while N <= Max and Cliente(N).Ocupado = True loop
                  if Cliente(N).Time = Tiempo_Menor then
                     Cliente(N).Ocupado := False;
                     Nick_Fuera := Cliente(N).Nick;
                     LLU.Reset(Buffer);
                     CM.Message_Type'Output(Buffer'Access, Tipo);
		     ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String("servidor"));                
		     ASU.Unbounded_String'Output(Buffer'Access, Comentario);
		     LLU.Send(Cliente(N).EP, Buffer'Access);
                  end if;
                  N := N + 1;
            end loop;
        end Expulsar;
        
        
        --Busca si un Nick que le pasan está Repetido, es decir si está ya o no en el array.
        procedure Buscar_Esta(Cliente: in out Clients_List; Nick: ASU.Unbounded_String; Max : Natural; Esta: out Boolean) is
            N : Natural :=1;
        begin
              Esta:= False;
              while N <= Max and not Esta loop
                      if (Nick = Cliente(N).Nick) and Cliente(N).Ocupado = True then
                        Esta := True;
                      end if;
                      N := N + 1;
              end loop;
        end Buscar_Esta;
        
        --Busca y te devuelve un Nick que le corresponde a una dirección EP que le pasas.
        procedure Buscar_Nick(Cliente: in out Clients_List; EP: LLU.End_Point_Type; Nick: out ASU.Unbounded_String; Max : Natural) is
            N : Natural :=1;
            Found: Boolean;
        begin
              Found:= False;
              while N <= Max and not Found loop
                      if (EP = Cliente(N).EP) and Cliente(N).Ocupado = True then
                        Nick := Cliente(N).Nick;
                        Found := True;
                        Cliente(N).Time := AC.Clock;
                      end if;
                      N := N + 1;
              end loop;
        end Buscar_Nick;
        
        -- Busca a los clientes en el array con /= nick al suyo para reenviar lo que recibe de otros  escritores.
        procedure Buscar_y_Envia(Cliente : Clients_List; Nick: ASU.Unbounded_String; Max : Natural;
        		P_Buffer: access LLU.Buffer_Type) is
        N: Natural:= 1;
        begin 
            while N <=Max loop   
             	if Nick /= Cliente(N).Nick and Cliente(N).Ocupado = True  then 
                   -- enviar Server a lectores
                   LLU.Send(Cliente(N).EP, P_Buffer);
            	end if;
            	N := N + 1;
            end loop;
        end Buscar_y_Envia;
        
        --Borra el cliente, para ello pone su campo Ocupado a False, así según las condiciones del resto de 
        --procedures de que Ocupado = True es como si lo borrara.
        procedure Delete(Cliente: in out Clients_List; EP_Handler: LLU.End_Point_Type; Max: Natural) is
        begin
                for N in 1..Max loop
                    if EP_Handler = Cliente(N).EP and Cliente(N).Ocupado = True then 
                          Cliente(N).Ocupado := False;
                    end if;
                end loop;
        end Delete;
       
end Users;
