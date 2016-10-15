--Alba García de la Camacha Selgas

package body List is
    use type ASU.Unbounded_String;
        
        
        procedure Add(L: in out Cell_A; Palab : ASU.Unbounded_String) is
                P_Aux : Cell_A;
        begin
                P_Aux := new Cell;
                P_Aux.Name := Palab;
                P_Aux.Count := 1;
                P_Aux.Next := L;
                L := P_Aux;
        end Add;
        
        procedure Buscar(L: in out Cell_A; Palab : ASU.Unbounded_String; Found : out Boolean) is
        
                P_Aux : Cell_A;       
        begin
              Found:= False;
              P_Aux := L;
              while P_Aux /= null loop
                if Palab = P_Aux.Name then
                        Found := True;
                        P_Aux.Count := P_Aux.Count + 1;
                end if;
                P_Aux := P_Aux.Next;
              end loop;
        end Buscar;
       
        procedure Escribir_Palabs(L: in out Cell_A) is
                P_Aux : Cell_A;
        begin
                P_Aux := L;
                TIO.Put_Line("Palabras");
                TIO.Put_Line("---------");
                while P_Aux /= null loop
                        TIO.Put_Line(""&ASU.To_String(P_Aux.Name)& ":" &Natural'Image(P_Aux.Count)&"");
                        P_Aux := P_Aux.Next;
                end loop;
        end Escribir_Palabs;
        
        procedure Borrar(L: in out Cell_A) is
                P_Aux : Cell_A;
        begin
                while P_Aux /= null loop
                    P_Aux := L;
                    L := L.Next;
                    Free(P_Aux);
                end loop;
                Free(L);
       end Borrar;
end list;         
