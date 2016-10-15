--Alba García de la Camacha Selgas

package body Pac is
        use type ASU.Unbounded_String;
        
        procedure Add(Cliente: in out Clientes; Mess : CM.Message; NumC : Natural) is
         begin
                Cliente(NumC).EP := Mess.EP;
                Cliente(NumC).Nick := Mess.Nick;    
        end Add;
        
        procedure Buscar(Cliente:in out Clientes; EP: LLU.End_Point_Type; Nick: out ASU.Unbounded_String; NumC : Natural) is
            N : Natural :=1;
            Found: Boolean;
        begin
              Found:= False;
              while N <= NumC and not Found loop
                      if (EP = Cliente(N).EP) then
                        Nick := Cliente(N).Nick;
                        Found := True;
                      end if;
                      N := N + 1;
              end loop;
        end Buscar;
       
end Pac;
