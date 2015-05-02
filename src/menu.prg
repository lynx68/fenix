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
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */


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


