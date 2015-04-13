#include "marinas-gui.ch"

procedure mainmenu(cWin)

CREATE MAIN MENU OF (cWin)
	FONTCOLOR {255,255,255}
	BACKCOLOR {128,128,255}
   //FONTBOLD .T.
	CREATE POPUP _I("&Invoices")
		CREATE ITEM "&New invoice"
			ONCLICK new_invoice()	
		END ITEM
		CREATE ITEM "&Browse invoices"
			ONCLICK browse_invoice()
		END ITEM
		SEPARATOR
		CREATE ITEM "&Define Automatic Invoices generation"
			//ONCLICK browse_invoice()
		END ITEM
	END POPUP
	CREATE POPUP _I("&Customer")
		CREATE ITEM "&New Customer"
			ONCLICK new_subscriber()
		END ITEM
		CREATE ITEM "&Browse/Modify Customer"
			ONCLICK browse_subscriber()
		END ITEM
	END POPUP
	CREATE POPUP _I("&Settings")
		CREATE ITEM "&System settings"
			Onclick setup_app()
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


