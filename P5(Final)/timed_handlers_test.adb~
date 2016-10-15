with Ada.Text_IO;
with Timed_handlers;
with Ada.Calendar;

With Example_Handlers;

procedure Timed_Handlers_Test is
   use type Ada.Calendar.Time;
begin

   Timed_Handlers.Set_Timed_Handler
     (Ada.Calendar.Clock + 1.0, Example_Handlers.H'Access);

   Timed_Handlers.Set_Timed_Handler
     (Ada.Calendar.Clock + 1.0, Example_Handlers.H2'Access);

   delay 20.0;

   Timed_Handlers.finalize;

end Timed_Handlers_test;

