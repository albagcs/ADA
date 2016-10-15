--Alba García de la Camacha Selgas

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with List;

procedure cuenta is
	package TIO renames Ada.Text_IO;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package AE renames Ada.Exceptions;
        
procedure Cuenta( Strg: in out ASU.Unbounded_String; CP:in out Natural; CC: in out Natural; L:in out List.Cell_A) is
	Palabra: ASU.Unbounded_String;
	Pos : Natural := 1;
	Esta_Pal :Boolean;
	begin
		while Pos /= 0 loop 
			Pos := ASU.Index(Strg, " ");
			if Pos = 0 then
				if ASU.Length(Strg) = 0 then
					TIO.Put("");
					CC := CC + 1;
				else
			        	Palabra := ASU.Tail(Strg, ASU.Length(Strg) -Pos);
			        	CP := CP + 1;
					CC := CC + ASU.Length(Palabra) + 1;--para que cuente el eol pongo este + 1, el num de caracteres;
					List.Buscar(L, Palabra, Esta_Pal); -- es igual a los que tenía más la longitud de palabra.
					if Esta_Pal = False then
						List.Add(L, Palabra);--busca y si no está la palabra, la añade
					end if;
				end if;
			elsif Pos = 1 then
				Strg := ASU.Tail(Strg, ASU.Length(Strg) - Pos);
				CC := CC + 1;--porque le sumo el espacio que pasa
			else		
				Palabra := ASU.Head(Strg, Pos -1);
				Strg := ASU.Tail(Strg, ASU.Length(Strg) -Pos);
				CP := CP + 1;
				CC := CC + ASU.Length(Palabra) + 1;--los caracteres son los que tenía más la longitud de la palabra
				List.Buscar(L, Palabra, Esta_Pal); -- más el espacio que pasa aquí, no es el mismo 1 que arriba ya que
				if Esta_Pal = False then           -- ahí no hay espacio
					List.Add(L, Palabra);
				end if;
			end if;
		end loop;
	end Cuenta;

Fichero: TIO.File_Type;
Texto: ASU.Unbounded_String;
Usage_Error : exception;
Terminar: Boolean := False;
Lineas : Natural:= 0;
ContadorP : Natural := 0;
Caracteres : Natural := 0;
P_Lista : List.Cell_A;

begin
	if ACL.Argument_Count = 3 then
		if ACL.Argument(1) = "-t" and ACL.Argument(2) = "-f" then
			TIO.Open(Fichero, TIO.In_File, ACL.Argument(3));
		elsif ACL.Argument(1) = "-f" and ACL.Argument(3) = "-t" then
			TIO.Open(Fichero, TIO.In_File, ACL.Argument(2));
		else 
			raise Usage_Error;
		end if;
		while not Terminar loop
		   begin
		   	Texto := ASU.To_Unbounded_String(TIO.Get_Line(Fichero));
		   	Cuenta(Texto, ContadorP, Caracteres, P_Lista);
		   	Lineas := Lineas + 1;
		   exception
		   	 when Ada.IO_Exceptions.End_Error =>
		   	 	Terminar := True;
		   end;
		end loop;
		TIO.Put_Line(""&Natural'Image(Lineas)& " Lineas,"&Natural'Image(ContadorP)& " Palabras y"&Natural'Image(Caracteres)&
			        " caracteres");
		List.Escribir_Palabs(P_Lista);
		List.Borrar(P_Lista);
		TIO.Close(Fichero);
	elsif ACL.Argument_Count = 2 then
		if ACL.Argument(1) = "-f" then
			TIO.Open(Fichero, TIO.In_File, ACL.Argument(2));
			while not Terminar loop
			   begin
			      Texto := ASU.To_Unbounded_String(TIO.Get_Line(Fichero));
			      Cuenta(Texto, ContadorP, Caracteres, P_Lista);
			      Lineas := Lineas + 1;
			   exception
      	                         when Ada.IO_Exceptions.End_Error =>
      		                         Terminar := True;
      		           end;
			end loop;
			TIO.Put_Line(""&Natural'Image(Lineas)& " Lineas,"&Natural'Image(ContadorP)& " Palabras y"&Natural'Image(Caracteres)&
			        " caracteres");
			TIO.Close(Fichero);
		else
			raise Usage_Error;
		end if;	
	else 
		raise Usage_Error;
	end if;
	
	
exception
	when Usage_Error =>
		TIO.Put_Line("Has escrito argumentos erroneos");
        when ADA.IO_Exceptions.STATUS_ERROR =>
                TIO.Put_Line("Este fichero ya está abierto");	
        when ADA.IO_EXCEPTIONS.NAME_ERROR =>
                TIO.Put_Line("Este fichero no existe, créalo primero si quieres abrirlo");
        when Except: Others =>
                TIO.Put_Line("Excepción imprevista");
end cuenta;
