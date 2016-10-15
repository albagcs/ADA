--
--Este programa cuenta las palabras y espacios que hay,
--y escribe el numero de cada uno, además te escribe las palabras
with Ada.Text_IO;
with Ada.Strings.Unbounded;

procedure trocea is
	package TIO renames Ada.Text_IO;
	package ASU renames Ada.Strings.Unbounded;
	
procedure Leer_String(Strg:  out ASU.Unbounded_String) is 
	begin
		TIO.Put("Escribe el texto: ");
		Strg:= ASU.to_Unbounded_String(TIO.Get_Line);
	end Leer_String;
--
--Este es el procedure que va contando las palabras y espacios y escribiendo palabras
--
procedure cuenta_trocea ( Strg: in out ASU.Unbounded_String) is
	Palabra: ASU.Unbounded_String;
	Pos : Natural := 1;
	ContadorP : Natural := 0;
	ContadorE : Natural := 0;
	begin
		while Pos /= 0 loop 
			Pos := ASU.Index(Strg, " ");
			if Pos = 0 then
				if ASU.Length(Strg) = 0 then
					TIO.Put("");-- si la lonitud es 0 significa que no tienes nada que guardar, por tanto no hace nada más
				else
					Palabra := ASU.Tail(Strg, ASU.Length(Strg) -Pos);
					ContadorP := ContadorP + 1;
					TIO.Put_Line("Palabra " & Natural'Image(ContadorP)& ": |" &ASU.To_String(Palabra)& "|");
				end if;
			elsif Pos = 1 then
				Strg := ASU.Tail(Strg, ASU.Length(Strg) - Pos);
				ContadorE := ContadorE + 1;
			else		
				Palabra := ASU.Head(Strg, Pos -1);
				Strg := ASU.Tail(Strg, ASU.Length(Strg) -Pos);
				ContadorP := ContadorP + 1;
				ContadorE := ContadorE + 1;
				TIO.Put_Line("Palabra " & Natural'Image(ContadorP)& ": |"  &ASU.To_String(Palabra)& "|");
			end if;
		 exit when Pos = 0;
		end loop;
	TIO.Put("Total:"&Natural'Image(ContadorP)& " Palabras y"&Natural'Image(ContadorE)&" espacios ");
	end cuenta_trocea;

	
	
	Texto: ASU.Unbounded_String;
	
	
begin
	Leer_String(Texto);
	cuenta_trocea(Texto);
end trocea;
