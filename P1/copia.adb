with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Ada.IO_Exceptions;


procedure Copia is
   package ASU renames Ada.Strings.Unbounded;
   package T_IO renames Ada.Text_IO;

   Usage_Error: exception;

   Fichero_Origen: T_IO.File_Type;
   Fichero_Destino: T_IO.File_Type;

   S: ASU.Unbounded_String;
   Terminar: Boolean;
   

begin

   if Ada.Command_Line.Argument_Count /= 2 then
      raise Usage_Error;
   end if;

   T_IO.Open(Fichero_Origen, T_IO.In_File, Ada.Command_Line.Argument(1));
   T_IO.Create(Fichero_Destino, T_IO.Out_File, Ada.Command_Line.Argument(2));

   Terminar := False;
   while not Terminar loop
      begin
      	S := ASU.To_Unbounded_String(T_IO.Get_Line(Fichero_Origen));
      	T_IO.Put_Line(Fichero_Destino, ASU.To_String(S));
      exception
      	when Ada.IO_Exceptions.End_Error =>
      		Terminar := True;
      end;
   end loop;

   T_IO.Close(Fichero_Origen);
   T_IO.Close(Fichero_Destino);

exception
   when Usage_Error =>
      T_IO.Put_Line("uso: copia <fichero-origen> <fichero-destino>");

end Copia;
