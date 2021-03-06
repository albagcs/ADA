with Ada.Text_IO;
With Ada.Strings.Unbounded;
with Maps_G;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Lower_Layer_UDP;
with Maps_Protector_G;

procedure Maps_Test is
   package ASU  renames Ada.Strings.Unbounded;
   package ATIO renames Ada.Text_IO;
   package C_IO renames Gnat.Calendar.Time_IO;
   package LLU renames Lower_Layer_UDP;
   package AC renames Ada.Calendar;


   type Seq_N_T is mod Integer'Last;
   
    function Image_3 (T: Ada.Calendar.Time) return String is
    begin
      return C_IO.Image(T, "%T.%i");
    end Image_3;

   package NP_Neighbors is new Maps_G (Key_Type   => LLU.End_Point_Type,
                               Value_Type => Ada.Calendar.Time,
                               Null_Key => null,
                               Null_Value => Ada.Calendar.Time_Of(2000,1,1),
                               Max_Length => 10,
                               "="        => LLU."=",
                               Key_To_String  => LLU.Image,
                               Value_To_String  => Image_3);
                               
   package NP_Latest_Msgs is new Maps_G (Key_Type   => LLU.End_Point_Type,
                               Value_Type => Seq_N_T,
                               Null_Key => null,
                               Null_Value => 2000,
                               Max_Length => 50,
                               "="        => LLU."=",
                               Key_To_String  => LLU.Image,
                               Value_To_String  => Seq_N_T'Image);


   package Neighbors is new Maps_Protector_G (NP_Neighbors);
   
   package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);


   procedure Write_Keys(My_Neighbors: Neighbors.Prot_Map) is
   Keys : Neighbors.Keys_Array_Type;
   begin
   Keys := Neighbors.Get_Keys(My_Neighbors);
   for K in 1..10 loop
   	ATIO.Put_Line(LLU.Image(Keys(K)));
   end loop;
   end Write_Keys;

   Success : Boolean;
   My_Neighbors : Neighbors.Prot_Map;
   Messages : Latest_Msgs.Prot_Map;
   EP1 : LLU.End_Point_Type;
   EP2 : LLU.End_Point_Type;
   EP3 : LLU.End_Point_Type;
   Value : AC.Time := AC.Clock;
   
   
begin

     
   LLU.Bind_Any(EP1);
   LLU.Bind_Any(EP2);
   LLU.Bind_Any(EP3);

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Neighbors.Map_Length(My_Neighbors)));
   Neighbors.Print_Map (My_Neighbors);

   Neighbors.Put (My_Neighbors,
             EP1,
             Ada.Calendar.Clock,
             Success);
   ATIO.Put_Line("insertado EP1");
   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Neighbors.Map_Length(My_Neighbors)));
   Neighbors.Print_Map(My_Neighbors);


   ATIO.New_Line;
   Neighbors.Get (My_Neighbors, EP2, Value, Success);
   if Success then
      ATIO.Put_Line ("Get: Dirección IP EP2: " & LLU.Image(EP2) &
                       Image_3(Value));
   else
      ATIO.Put_Line ("Get: NO hay una entrada para la clave EP2");
   end if;

   Neighbors.Put (My_Neighbors, EP2,
              Value, Success);
              
   Write_Keys(My_Neighbors);

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Neighbors.Map_Length(My_Neighbors)));
   Neighbors.Print_Map(My_Neighbors);

   ATIO.New_Line;
   Neighbors.Get (My_Neighbors, EP2, Value, Success);
   if Success then
      ATIO.Put_Line ("Get: Dirección IP EP2: " & LLU.Image(EP2) &
                       Image_3(Value));
   else
      ATIO.Put_Line ("Get: NO hay una entrada para la clave www.urjc.es");
   end if;

   Neighbors.Put (My_Neighbors, EP3,
              Value, Success);
              

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Neighbors.Map_Length(My_Neighbors)));
   Neighbors.Print_Map(My_Neighbors);
   ATIO.New_Line;
   
   Neighbors.Delete (My_Neighbors, EP1, Success);
   if Success then
      ATIO.Put_Line ("Delete: BORRADO EP1");
   else
      ATIO.Put_Line ("Delete: EP1 no encontrado");
   end if;

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Neighbors.Map_Length(My_Neighbors)));
   Neighbors.Print_Map(My_Neighbors);

   ATIO.New_Line;
   Neighbors.Delete (My_Neighbors, EP2, Success);
   if Success then
      ATIO.Put_Line ("Delete: BORRADO EP2");
   else
      ATIO.Put_Line ("Delete: EP2 no encontrado");
   end if;

   ATIO.New_Line;
   Neighbors.Delete (My_Neighbors, EP3, Success);
   if Success then
      ATIO.Put_Line ("Delete: BORRADO EP3");
   else
      ATIO.Put_Line ("Delete: EP3 no encontrado");
   end if;
   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Neighbors.Map_Length(My_Neighbors)));
   Neighbors.Print_Map (My_Neighbors);


   Write_Keys(My_Neighbors);
   
end Maps_Test;
