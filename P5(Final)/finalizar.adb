with Ada.Text_IO;
with Lower_Layer_UDP;
package body Finalizar is
		procedure Ctrl_C_Handler is
		begin
			Ada.Text_IO.Put(" Has pulsado Ctrl_C, ¿Quieres salir? "); 
			Ada.Text_IO.Put_Line("Pulsa S(Sí) o N(No) ");
			Lower_Layer_UDP.Finalize;
		raise Program_Error;
end Ctrl_C_Handler;
