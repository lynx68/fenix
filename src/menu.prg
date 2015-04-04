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
			ONCLICK new_invoice()	
		END ITEM
		CREATE ITEM "&Browse invoices"
			ONCLICK browse_invoice()
		END ITEM
	END POPUP
	CREATE POPUP "&Subscriber"
		FONTSIZE 16
		CREATE ITEM "&Browse subscribers"
			ONCLICK browse_subscriber()
		END ITEM
	END POPUP
	CREATE POPUP "&Settings"
		FONTSIZE 16
		CREATE ITEM "&System settings"
		END ITEM
		SEPARATOR
		CREATE ITEM "&Users and Groups settings"
		END ITEM 
		CREATE ITEM "&Printer settings"				
			ONCLICK get_printer()
		END ITEM
	END POPUP
END MENU

return

function get_printer()

local lRet

GET PRINTER DIALOG RETO lRet

return lRet


