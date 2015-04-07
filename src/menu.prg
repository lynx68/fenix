#include "marinas-gui.ch"

procedure mainmenu(cWin)

CREATE MAIN MENU OF (cWin)
	FONTCOLOR {255,255,255}
   BACKCOLOR {128,128,255}
   FONTBOLD .T.
   FONTSIZE 16
	CREATE POPUP "&Invoices"
		FONTSIZE 16
		CREATE ITEM "&New invoice"
			FONTSIZE 16
			ONCLICK new_invoice()	
		END ITEM
		CREATE ITEM "&Browse invoices"
			FONTSIZE 16
			ONCLICK browse_invoice()
		END ITEM
		SEPARATOR
		CREATE ITEM "&Define Automatic Invoices generation"
			FONTSIZE 16
			//ONCLICK browse_invoice()
		END ITEM
	END POPUP
	FONTSIZE 16
	CREATE POPUP "&Custumer"
		CREATE ITEM "&New Custumer"
			FONTSIZE 16
			ONCLICK new_subscriber()
		END ITEM
		CREATE ITEM "&Browse/Modify Custumer"
			FONTSIZE 16
			ONCLICK browse_subscriber()
		END ITEM
	END POPUP
	CREATE POPUP "&Settings"
		FONTSIZE 16
		CREATE ITEM "&System settings"
			FONTSIZE 16
		END ITEM
		SEPARATOR
		CREATE ITEM "&Users and Groups settings"
			FONTSIZE 16
		END ITEM 
		CREATE ITEM "&Printer settings"				
			FONTSIZE 16
			ONCLICK get_printer()
		END ITEM
	END POPUP
END MENU

return

function get_printer()

local lRet

GET PRINTER DIALOG RETO lRet

return lRet


