--Alba García de la Camacha Selgas

with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package List is
       
        package ASU renames Ada.Strings.Unbounded;
       	package TIO renames Ada.Text_IO;
       	
       	
        type Cell;
        type Cell_A is access Cell;
       
        type Cell is record
                Name : ASU.Unbounded_String;
                Count: Natural := 0;
                Next : Cell_A;
        end record;
        
        procedure Free is new
        Ada.Unchecked_Deallocation
        (Cell, Cell_A);
        
        procedure Add(L: in out Cell_A; Palab: ASU.Unbounded_String);
        procedure Buscar(L: in out Cell_A; Palab: ASU.Unbounded_String; Found: out Boolean);
        procedure Escribir_Palabs(L: in out Cell_A);
        procedure Borrar(L: in out Cell_A);
        
end List;

