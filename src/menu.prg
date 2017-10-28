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

memvar cPath, hIni

procedure mainmenu(cWin)
	

local aDbf := getfiles(cPath+"inv*.dbf")
local cY, x //, cName

CREATE MAIN MENU "MM" OF (cWin)
	FONTCOLOR {255,255,255}
	BACKCOLOR {128,128,255}
   //FONTBOLD .T.
	CREATE POPUP (_I("&Invoices"))
		CREATE ITEM _I("&New invoice")
			ONCLICK new_invoice() //uncovered invoice	
		END ITEM
		CREATE ITEM _I("&Browse invoices")
			ONCLICK browse_invoice()
		END ITEM
		CREATE POPUP (_I("&Reports"))
			CREATE ITEM _I("Print invoice summary")
				ONCLICK unpaid(date()-365, 1)
			END ITEM
			CREATE ITEM _I("Unpaid invoices")
				ONCLICK unpaid()
			END ITEM
			CREATE ITEM _I("Print by customer")
				ONCLICK unpaid(, 2)
			END ITEM		
		END POPUP
		CREATE ITEM _I( "Invoices" ) + ": " + "2016"
		//	cName := mg_get( cWin, "MM", "ITEMNAME" )
			ITEMNAME	"inv2016"
			ONCLICK (browse_invoice(ctod("01/01/16")))
		//	ONCLICK 	browse_invoice(cName)	
		END ITEM

		if len( aDbf ) > 1
			SEPARATOR
			CREATE POPUP (_I( "&Invoices - old years" ))
				for x := 1 to len( aDbf )
					cY := "20" + substr(aDbf[x],4,2)
					CREATE ITEM _I( "Invoices" ) + ": " + cY
						ITEMNAME &cY
						ONCLICK (browse_invoice(ctod("01/01/"+cY)))
					END ITEM
				next
			END POPUP
		endif
		SEPARATOR
		CREATE ITEM _I("&Automatic Invoices creation")
			ONCLICK auto_invoice()
		END ITEM
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

	if _hGetValue(hIni["STORE"],"Module") <> "Disabled"
		CREATE POPUP (_I("&Store"))
			CREATE ITEM _I("&Purchase")
				ONCLICK store_purchase()
			END ITEM
			CREATE ITEM _I("&Sale")
				ONCLICK store_exp()
			END ITEM
			SEPARATOR
			CREATE ITEM _I("&Browse")
				ONCLICK store_browse()
			END ITEM
			CREATE POPUP (_I("&Reports"))
				CREATE ITEM _I("&Purchase report")
				END ITEM
				CREATE ITEM _I("&Sale report")
				END ITEM
				CREATE ITEM _I("&Statistical reports")
				END ITEM
			END POPUP
			SEPARATOR
			CREATE ITEM _I( "&Select working store" )
				ONCLICK select_working_store()
			END ITEM

		END POPUP
	endif
	if _hGetValue(hIni["CachRegister"],"Module") <> "Disabled"
		CREATE POPUP (_I("&Cash register"))
			CREATE ITEM _I("&Simple sale")
				ONCLICK simple_sale()
			END ITEM

			CREATE ITEM _I("S&ale")
				ONCLICK sale()
			END ITEM
			CREATE ITEM _I("&POS sale")
				ONCLICK pos_sale()
			END ITEM
			CREATE ITEM _I("&Browse sale's database")
				ONCLICK browse_pos()
			END ITEM

		END POPUP
	endif
	if _hGetValue(hIni["LOKI"],"Module") <> "Disabled"
		CREATE POPUP (_I("&Loki"))
			CREATE POPUP (_I("&Add"))
				CREATE ITEM (_I("&Data"))
					ONCLICK zapis_data()
				END ITEM 
				
				CREATE ITEM (_I("&Measure device"))
					ONCLICK zapis_spt()
				END ITEM
			END POPUP
	
			CREATE POPUP (_I("&Show databases"))
				CREATE ITEM (_I("&Databaze spotrebicu"))
					ONCLICK prohlizeni()
				END ITEM
		
				CREATE ITEM (_I("&Databaze dat"))
					ONCLICK prohlizeni2()
			END POPUP
	
			CREATE ITEM (_I("&Print"))
				//ONCLICK tisk()
			END ITEM
		END POPUP
	endif

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
//		CREATE ITEM _I("&EET Playgraund test")
//			ONCLICK eet_test()
//		END ITEM
		CREATE ITEM _I("&Show log file")
			ONCLICK showlog()
		END ITEM

	END POPUP
END MENU

return

function get_printer()

local lRet

GET PRINTER DIALOG RETO lRet

return lRet


