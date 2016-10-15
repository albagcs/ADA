with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Calendar;

package body Maps_G is

   package TIO renames Ada.Text_IO;

   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);


   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
      P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;
      Success := False;
      while not Success and P_Aux /= null Loop
         if P_Aux.Key = Key then
            Value := P_Aux.Value;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
   end Get;


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type;
                  Success: out Boolean)
                   is 
      P_Aux : Cell_A;
      Found : Boolean;
   begin
      -- Si ya existe Key, cambiamos su Value
      P_Aux := M.P_First;
      Found := False;
      Success := False;
      while not Found and P_Aux /= null loop
         if P_Aux.Key = Key then
            P_Aux.Value := Value;
            Found := True;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;

      -- Si no hemos encontrado Key añadimos al principio
      if not Found and M.Length <= Max_Length then
         P_Aux := new Cell;
         P_Aux.Key := Key;
         P_Aux.Value := Value;
         P_Aux.Prev := null;
         P_Aux.Next := M.P_First;
         if P_Aux.Next /= null then
            P_Aux.Next.Prev := P_Aux;
         end if;
         M.P_First := P_Aux;
         M.Length := M.Length + 1;
         Success := True;
      end if;
   end Put;



   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
      P_Current  : Cell_A;
   begin
      Success := False;
      P_Current  := M.P_First;
      while not Success and P_Current /= null  loop
         if P_Current.Key = Key then
            Success := True;
            M.Length := M.Length - 1;
            
            if P_Current.Prev /= null then 
               P_Current.Prev.Next := P_Current.Next;
            else
                M.P_First := P_Current.Next;
            end if;
            
	    if P_Current.Next /= null then
               P_Current.Next.Prev := P_Current.Prev;
            end if;
            Free (P_Current);
         else
            P_Current := P_Current.Next;
         end if;
      end loop;

   end Delete;

   function Get_Keys (M : Map) return Keys_Array_Type is
   Keys_Array : Keys_Array_Type;
   P_Aux : Cell_A;
   begin
   	 P_Aux := M.P_First;
   	 
   	 for Pos in 1..Max_Length loop
   	 	  Keys_Array(Pos) := Null_Key;
   	 end loop;
   	 	
       for Pos in 1..M.Length loop 
       		Keys_Array(Pos) := P_Aux.Key;
       		P_Aux := P_Aux.Next;
       end loop;
       
       return Keys_Array;

	end Get_Keys;	
	
	
	function Get_Values (M : Map) return Values_Array_Type is
	Values_Array : Values_Array_Type;
   	P_Aux : Cell_A;
   	begin
   	 P_Aux := M.P_First;
   	 
   	 for Pos in 1..Max_Length loop
   	 	  Values_Array(Pos) := Null_Value;
   	 end loop;
   	 	
       	 for Pos in 1..M.Length loop 
       		Values_Array(Pos) := P_Aux.Value;
       		P_Aux := P_Aux.Next;
      	 end loop;
       
        return Values_Array;

	end Get_Values;	
	
   function Map_Length (M : Map) return Natural is
   begin
      return M.Length;
   end Map_Length;

   procedure Print_Map (M : Map) is
      P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;

      Ada.Text_IO.Put_Line ("Map");
      Ada.Text_IO.Put_Line ("===");
      while P_Aux /= null loop
         Ada.Text_IO.Put_Line (Key_To_String(P_Aux.Key) & " " &
                                 VAlue_To_String(P_Aux.Value));
         P_Aux := P_Aux.Next;
      end loop;
   end Print_Map;
   

end Maps_G;
