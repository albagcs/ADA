with Ada.Text_IO;
with Debug;
with Pantalla;


procedure Test_Debug is
   
begin
   
   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line("Por defecto la depuración está activada");
   Ada.Text_IO.New_Line;
   
   Ada.Text_IO.Put_Line ("Texto normal del programa");
   Debug.Put_Line("Mensaje de depuración en color por defecto");
   Ada.Text_IO.Put_Line ("Texto normal del programa");
   Debug.Put_Line("Mensaje de depuración en color amarillo", Pantalla.Amarillo);
   Ada.Text_IO.Put_Line ("Texto normal del programa");
   Debug.Put_Line("Mensaje de depuración en color rojo", Pantalla.Rojo);
   Ada.Text_IO.Put_Line ("Texto normal del programa");
   
   Debug.Set_Status(False);
   
   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line("Depuración desactivada con Set_Status(False)");
   Ada.Text_IO.New_Line;
   
   Ada.Text_IO.Put_Line ("Texto normal del programa");
   Debug.Put_Line("Mensaje de depuración en color por defecto");
   Ada.Text_IO.Put_Line ("Texto normal del programa");
   Debug.Put_Line("Mensaje de depuración en color amarillo", Pantalla.Amarillo);
   Ada.Text_IO.Put_Line ("Texto normal del programa");
   Debug.Put_Line("Mensaje de depuración en color rojo", Pantalla.Rojo);
   Ada.Text_IO.Put_Line ("Texto normal del programa");      
      
end Test_Debug;
