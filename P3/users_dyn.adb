--Alba García de la Camacha Selgas

package body Users is
        use type ASU.Unbounded_String;
        use type Ada.Calendar.Time;
        
     
       procedure Free is new
        Ada.Unchecked_Deallocation
        (Client, Clients_List); 
        
       procedure Buscar_Tiempo_Menor(Cliente: Clients_List; Max : Natural; Tiempo_Menor: in out AC.Time) is
       P_Aux : Clients_List;
       begin
       	      
              while P_Aux /= null loop
              	  P_Aux := Cliente;
                  Tiempo_Menor := P_Aux.Time;
                     if P_Aux.Next.Time < Tiempo_Menor then
                             Tiempo_Menor := P_Aux.Next.Time;        
                     end if; 
                  P_Aux := P_Aux.Next;
              end loop;
        end Buscar_Tiempo_Menor;
        
        procedure Add(Cliente: in out Clients_List; EP : LLU.End_Point_Type; Nick: ASU.Unbounded_String; Max : Natural) is
                P_Aux : Clients_List;
        begin
                P_Aux := new Client;
                P_Aux.EP := EP;
                P_Aux.Nick := Nick;
                P_Aux.Time := AC.Clock;
                P_Aux.Next := Cliente;
                Cliente := P_Aux;
        end Add;
        
        procedure Expulsar(Cliente: in out Clients_List; Max: Natural; Nick_Fuera: out ASU.Unbounded_String) is
        P_Aux : Clients_List;
        P_Before : Clients_List:= null;
        Tiempo_Menor: AC.Time;
        Tipo : CM.Message_Type := CM.Server;
        Comentario: ASU.Unbounded_String := ASU.To_Unbounded_String(" Has sido expulsado del chat");
        Buffer: aliased LLU.Buffer_Type(1024);
        begin
            P_Aux := Cliente;
            Buscar_Tiempo_Menor(Cliente, Max, Tiempo_Menor);
            while P_Aux /=null loop
                  if P_Aux.Time = Tiempo_Menor then   
                     Nick_Fuera := P_Aux.Nick;
                     
                     LLU.Reset(Buffer);
                     CM.Message_Type'Output(Buffer'Access, Tipo);
		     ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String("servidor"));                
		     ASU.Unbounded_String'Output(Buffer'Access, Comentario);
		     LLU.Send(P_Aux.EP, Buffer'Access);
		     
                     P_Before := P_Aux.Next;
                     Free(P_Aux);
                  end if;
                  P_Before := P_Aux;
                  P_Aux := P_Aux.Next;
            end loop;
        end Expulsar;
        
        procedure Buscar_Esta(Cliente: in out Clients_List; Nick: ASU.Unbounded_String; Max : Natural; Esta: out Boolean) is
            P_Aux : Clients_List;
        begin
              Esta:= False;
              P_Aux := Cliente;
              while P_Aux /= null loop
                      if (Nick = P_Aux.Nick) then
                        Esta := True;
                      end if;
                 P_Aux := P_Aux.Next;
              end loop;
        end Buscar_Esta;
        
        procedure Buscar_Nick(Cliente: Clients_List; EP: LLU.End_Point_Type; Nick: out ASU.Unbounded_String; Max : Natural) is
            P_Aux : Clients_List;
            Found: Boolean;
        begin
              Found:= False;
              P_Aux := Cliente;
              while P_Aux /= null and not Found loop
                      if (EP = P_Aux.EP) then
                        Nick := P_Aux.Nick;
                        Found := True;
                        P_Aux.Time := AC.Clock;
                      end if;
                     P_Aux := P_Aux.Next; 
              end loop;
        end Buscar_Nick;
        
        procedure Buscar_y_Envia(Cliente : Clients_List; Nick: ASU.Unbounded_String; Max : Natural;
        		P_Buffer: access LLU.Buffer_Type) is
        P_Aux : Clients_List;
        begin 
            P_Aux := Cliente;
            -- Busca a los clientes en el array con /= nick al suyo para enviarles lo que recibe de otros  escritores.
            while P_Aux /= null loop   
             	if Nick /= P_Aux.Nick then 	   
                   -- enviar Server a lectores
                   LLU.Send(P_Aux.EP, P_Buffer);
            	end if;
            	P_Aux := P_Aux.Next;
            end loop;
        end Buscar_y_Envia;
        
        procedure Delete(Cliente: in out Clients_List; EP_Handler: LLU.End_Point_Type; Max: Natural) is
        	P_Aux : Clients_List;
        	P_Before : Clients_List:= null;
        begin
                while P_Aux /= null loop
                    if EP_Handler = P_Aux.EP then 
                       P_Aux := Cliente;
                       P_Before := Cliente;	
                       P_Aux := P_Aux.Next;
                       Cliente := P_Aux;
                       Free(P_Before);   
                    end if;
                    P_Aux := P_Before;
                    P_Before := P_Aux.Next;
                end loop;
        end Delete;
        
       
end Users;
