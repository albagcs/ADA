--Alba García de la Camacha Selgas.

with Lower_Layer_UDP;

package Handlers is
   package LLU renames Lower_Layer_UDP;

   -- Handler para utilizar como parámetro en LLU.Bind en el cliente
   -- Muestra en pantalla las cadenas de texto recibidas
   -- Este procedimiento NO debe llamarse explícitamente
   procedure Client_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type);


end Handlers;
