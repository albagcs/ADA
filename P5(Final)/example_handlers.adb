with Timed_Handlers;
with Ada.Calendar;

With Ada.Text_Io;

Package body Example_Handlers is
   use type Ada.Calendar.Time;

   procedure H (Time: in Ada.Calendar.Time) is
   begin
      Ada.Text_Io.Put_Line ("************************* ping:           " &
                           Ada.Calendar.Seconds(Time)'Img);

      Timed_Handlers.Set_Timed_Handler (Ada.Calendar.Clock + 1.0, H'Access);
   end H;


   procedure H2 (Time: in Ada.Calendar.Time) is
   begin
      Ada.Text_Io.Put_Line ("****************** pong:           " &
                           Ada.Calendar.Seconds(Time)'Img);

      Timed_Handlers.Set_Timed_Handler (Ada.Calendar.Clock + 4.0, H2'Access);
   end H2;


end Example_Handlers;
