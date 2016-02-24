/*
 * Fenix Open Source accounting system
 * Main Menu
 *	
 * Copyright 2015 Davor Siklic (www.msoft.cz)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.txt.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site https://www.gnu.org/).
 *
 */

#include "marinas-gui.ch"
#include "fenix.ch"

memvar cPath

procedure mainmenu(cWin)

local aDbf := getfiles(cPath+"inv*.dbf")
local cY, x

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
		CREATE POPUP (_I("&Reports"))
			CREATE ITEM _I("Print invoice summary")
			END ITEM
			CREATE ITEM _I("Neproplacene faktury")
			END ITEM
			CREATE ITEM _I("Tisk dle odberatele")
			END ITEM		
		END POPUP
		if len( aDbf ) > 1
			SEPARATOR
			CREATE POPUP (_I( "&Invoices - old years" ))
				for x := 1 to len( aDbf )
					cY := "20" + substr(aDbf[x],4,2)
					CREATE ITEM _I( "Invoices" ) + ": " + cY
						ONCLICK browse_invoice(ctod("01/01/"+cY))
					END ITEM
				next
			END POPUP
		endif
		//SEPARATOR
		//CREATE ITEM _I("&Define Automatic Invoices generation")
			//ONCLICK 
		//END ITEM
	END POPUP
	CREATE POPUP (_I("I&tems"))
		CREATE ITEM _I("&New Item")
			ONCLICK new_item()
		END ITEM
		CREATE ITEM _I("&Browse/Modify Items")
			ONCLICK browse_items()
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

	CREATE POPUP (_I("&Store"))
		CREATE ITEM _I("&Purchase")
			// ONCLICK new_subscriber()
		END ITEM
		CREATE ITEM _I("&Sale")
			// ONCLICK browse_subscriber()
		END ITEM
	END POPUP
/*
	CREATE POPUP (_I("&Cash register"))
		CREATE ITEM _I("&Sale")
			// ONCLICK new_subscriber()
		END ITEM
		CREATE ITEM _I("&Status")
			// ONCLICK browse_subscriber()
		END ITEM
	END POPUP
*/
	CREATE POPUP (_I("&Settings"))
		CREATE ITEM _I("&System settings")
			Onclick setup_app()
		END ITEM
		//SEPARATOR
		//CREATE ITEM _I("&Users and Groups settings")
		//END ITEM 
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


