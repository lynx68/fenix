#include "marinas-gui.ch"
#include "fenix.ch"

procedure mainmenu(cWin)

CREATE MAIN MENU OF (cWin)
	FONTCOLOR {255,255,255}
	BACKCOLOR {128,128,255}
   //FONTBOLD .T.
	CREATE POPUP (_I("&Invoices"))
		CREATE ITEM _I("&New invoice")
			ONCLICK new_invoice()	
		END ITEM
		CREATE ITEM _I("&Browse invoices")
			ONCLICK browse_invoice()
		END ITEM
		SEPARATOR
		CREATE ITEM _I("&Define Automatic Invoices generation")
			//ONCLICK browse_invoice()
		END ITEM
	END POPUP
	CREATE POPUP (_I("&Customer"))
		CREATE ITEM _I("&New Customer")
			ONCLICK new_subscriber()
		END ITEM
		CREATE ITEM _I("&Browse/Modify Customer")
			ONCLICK browse_subscriber()
		END ITEM
	END POPUP
	CREATE POPUP (_I("&Settings"))
		CREATE ITEM _I("&System settings")
			Onclick setup_app()
		END ITEM
		SEPARATOR
		CREATE ITEM _I("&Users and Groups settings")
		END ITEM 
		CREATE ITEM _I("&Printer settings")
			ONCLICK get_printer()
		END ITEM
	END POPUP
END MENU

return

function get_printer()

local lRet

GET PRINTER DIALOG RETO lRet

return lRet


