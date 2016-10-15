--
--  TAD genérico de una tabla de símbolos (map) implementada como una lista
--  enlazada no ordenada.
--

generic
   type Key_Type is private;
   type Value_Type is private;
   Null_Key: in Key_Type;
   Null_Value: in Value_Type;
   Max_Length: in Natural;

   with function "=" (K1, K2: Key_Type) return Boolean;
   with function Key_To_String (K: Key_Type) return String;
   with function Value_To_String (K: Value_Type) return String;
package Maps_G is

   type Map is limited private;

   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean);


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type;
                  Success : out Boolean);

   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean);


   type Keys_Array_Type is array (1..Max_Length) of Key_Type;
   
   function Get_Keys (M : Map) return Keys_Array_Type;

   type Values_Array_Type is array (1..Max_Length) of Value_Type;
   
   function Get_Values (M : Map) return Values_Array_Type;

   function Map_Length (M : Map) return Natural;

   procedure Print_Map (M : Map);

   
private

   type Cell;
   type Cell_A is access Cell;
   type Cell is record
      Key   : Key_Type;
      Value : Value_Type;
      Next  : Cell_A := null;
      Prev  : Cell_A := null;
   end record;

   type Map is record
      P_First : Cell_A;
      Length  : Natural := 0;
   end record;


end Maps_G;
