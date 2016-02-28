/*
 * Fenix Open Source accounting system
 * Store managment
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
#include "hbthread.ch"

memvar cRPath, cPath, hIni

procedure store_purchase()

local cWin := "purchase_win"
local lTax := TaxStatus()
local dDat := date(), x, aItems := {}
local aFullCust := read_customer(, .T.), aCust := {}

for x:=1 to len(aFullcust)
	aadd(aCust, aFullCust[x][1])
next

CREATE WINDOW(cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("Purchase items")
	CHILD .T.
	MODAL .T.
	//TOPMOST .t.
	FONTSIZE 16
	CreateControl(10, 6, cWin, "payd", _I("Date"), dDat )
	CreateControl(10, 220,  cWin, "fOdb", _I("Supplier"), aCust )
	create grid items_g
		row 240
		col 20
		width 800
		height 220
		rowheightall 24
		if lTax
			columnheaderall { _I("Description"), _I("Unit"), _I("Unit cost"), _I("Quantity"), _I("Tax"), _I("Total"), _I("Total with tax")}
			columnwidthall { 440, 60, 120, 100, 60, 120, 120 }
		else
			columnheaderall { _I("Description"), _I("Unit"), _I("Unit cost"), _I("Quantity"), "", _I("Total"), ""}
			columnwidthall { 440, 50, 100, 84, 1, 120, 1 }
		endif
		Items aItems
	   //ondblclick add_item(@aItems, cWin, .T.)
		navigateby "row"
		visible .t.
		Items aItems
		tooltip _I("Purchase items")
	end grid
	create Button add_ist_b
		row 250
		col 840
		autosize .t.
		caption _I("Select item")
		onclick Get_STO_Item(@aItems, cWin)
		visible .t.
	end button
	create Button add_ic_b
		row 300
		col 840
		autosize .t.
		caption _I("new item")
		onclick add_Item(@aItems, cWin)
		visible .t.
	end button
	create button Back
		row 510
		col 840
		width 160
		height 60
		caption _I("Back")
		ONCLICK mg_do(cWin, "release")
		tooltip _I("Close and go back")
		picture cRPath+"task-reject.png"
	end button
END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

dbcloseall()

return
