#include "marinas-gui.ch"

procedure mainmenu(cWin)


CREATE MAIN MENU OF (cWin)
	FONTCOLOR {255,255,255}
   BACKCOLOR {128,128,255}
   FONTBOLD .T.
   FONTSIZE 16
	CREATE POPUP "&Invoices"
		FONTSIZE 14
		CREATE ITEM "&Browse invoices"
		   FONTSIZE 14
				ONCLICK browse_invoice()
			END ITEM
		END ITEM
	END POPUP
END MENU

return

