--Alba García de la Camacha Selgas.


with Chat_Handlers;

package Chat_Messages is
       
       	package CH renames Chat_Handlers;
       	
        type Message_Type is (Init, Reject, Confirm, Writer,Logout,Ack);
 
 	P_Buffer_Main: CH.Buffer_A_T;
	P_Buffer_Handler: CH.Buffer_A_T;

end Chat_Messages;
