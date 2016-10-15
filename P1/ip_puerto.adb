with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Text_IO;
with Ada.Command_Line;
with Ada.Exceptions;

procedure IP_Puerto is

   package ASU renames Ada.Strings.Unbounded;
   package ASU_IO renames Ada.Strings.Unbounded.Text_IO;

   Usage_Error: exception;
   Format_Error: exception;

   procedure Next_Token (Src: in out ASU.Unbounded_String;
                         Token: out ASU.Unbounded_String;
                         Delimiter: in String) is
      Position: Integer;
   begin
      Position := ASU.Index(Src, Delimiter);
      Token := ASU.Head (Src, Position-1);
      ASU.Tail (Src, ASU.Length(Src)-Position);
   exception
      when others =>
         raise Format_Error;
   end Next_Token;

   IP: ASU.Unbounded_String;
   Parte_IP: ASU.Unbounded_String;
   Puerto:  Integer;
begin

   if Ada.Command_Line.Argument_Count /= 1 then
      raise Usage_Error;
   end if;

   Puerto := Integer'Value (Ada.Command_Line.Argument(1));
   Ada.Text_IO.Put ("Introduce una dirección IP: ");
   IP :=  ASU_IO.Get_Line;

   for I in 1..3 loop
      Next_Token (IP, Parte_IP, ".");
      Ada.Text_IO.Put_Line ("Byte" & Integer'Image(I) &
                            " de la dirección IP: " &
                            ASU.To_String(Parte_IP));
   end loop;
   Ada.Text_IO.Put_Line ("Byte 4 de la dirección IP: " &
                         ASU.To_String(IP));
   Ada.Text_IO.Put_Line ("Puerto: " & Integer'Image (Puerto));

exception
   when Usage_Error =>
      Ada.Text_IO.Put_Line ("Uso: ip_puerto <número-de-puerto>");
   when Format_Error =>
      Ada.Text_IO.Put_Line ("Formato incorrecto en la dirección IP");
   when Except:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                              Ada.Exceptions.Exception_Name(Except) & " en: " &
                              Ada.Exceptions.Exception_Message (Except));
end IP_Puerto;
