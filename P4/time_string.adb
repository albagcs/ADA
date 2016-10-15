with Ada.Text_IO;
with Ada.Calendar;
with Ada.Strings.Unbounded;
with Gnat.Calendar.Time_IO;

procedure Time_String is
   package ASU renames Ada.Strings.Unbounded;
   package C_IO renames Gnat.Calendar.Time_IO;
   
   function Image_1 (T: Ada.Calendar.Time) return String is
      use type ASU.Unbounded_String;

      S_Decimals: constant Integer := 4;
      D: Duration;
      H, M: Integer;
      S: Duration;
      Hst, Mst, Sst, Tst: ASU.Unbounded_String;
   begin
      D := Ada.Calendar.Seconds(T);
      H := Integer(D)/3600;
      D := D - Duration(H)*3600;
      M := Integer(D)/60;
      S := D - Duration(M)*60;
      Hst := ASU.To_Unbounded_String(Integer'Image(H));
      Mst := ASU.To_Unbounded_String(Integer'Image(M));
      Sst := ASU.To_Unbounded_String(Duration'Image(S));
      Hst := ASU.Tail(Hst, ASU.Length(Hst)-1);
      Mst := ASU.Tail(Mst, ASU.Length(Mst)-1);
      Sst := ASU.Tail(Sst, ASU.Length(Sst)-1);
      Sst := ASU.Head(Sst, ASU.Length(Sst)-(9-S_Decimals));
      Tst := Hst & ":" & Mst & ":" & Sst;
      return ASU.To_String(Tst);
   end Image_1;   
   
   
   function Image_2 (T: Ada.Calendar.Time) return String is
   begin
      return C_IO.Image(T, "%c");
   end Image_2;
   
   
   function Image_3 (T: Ada.Calendar.Time) return String is
   begin
      return C_IO.Image(T, "%T.%i");
   end Image_3;
   
   
   T: Ada.Calendar.Time;
   
begin
   
   T := Ada.Calendar.Clock;
   
   Ada.Text_IO.Put_Line("Mostrando hora con un Image propio: " & 
			  Image_1(T));
   
   Ada.Text_IO.Put_Line("Mostrando fecha y hora con Gnat.Calendar.Time_IO: " & 
			  Image_2(T));
   
   Ada.Text_IO.Put_Line("Mostrando hora con Gnat.Calendar.Time_IO: : " & 
			  Image_3(T));


end Time_String;
