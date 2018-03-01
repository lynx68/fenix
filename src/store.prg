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
local aStore := getstore()

HB_SYMBOL_UNUSED( aStore )

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
		tooltip _I("Purchase items")
	end grid
	create Button add_ist_b
		row 250
		col 840
		autosize .t.
		caption _I("Select item")
		onclick Get_STO_Item( @aItems, cWin, 5 )
		visible .t.
	end button
	create Button add_ic_b
		row 300
		col 840
		autosize .t.
		caption _I("New item")
		onclick add_Item(@aItems, cWin)
		visible .t.
	end button
	create button edit_i_b
		row 350
		col 840
		autosize .t.
		caption _I("Edit item")
		onclick add_item(@aItems, cWin, .t.)
		visible .f.
	end button
	create button del_i_b
		row 400
		col 840
		autosize .t.
		caption _I("Delete item")
		onclick del_item(cWin, "items_g")
		visible .f.
	end button
	CreateControl(510, 610, cWin, "Save",, {|| save_store( aItems, cWin, lTax)})

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

static procedure save_store(aItems, cWin)

field name, date_b, quant_b, price_b, unit, vat, operator, time_w, date_w
field loot, exp, ean
local x

if !OpenStore(,,, .t.)
	msg("Error opening the database!")
	return 
endif

mg_log(aItems)

for x:=1 to len(aItems)
	if AddRec()
		replace name with aItems[x][1]  // item name
		replace date_b with mg_get( cWin, "payd_d", "value")  // bay date
		replace time_b with time()                            // time
		replace quant_b with aItems[x][4]                     // quantity
		replace price_b with aItems[x][3]                     // price
		replace unit with aItems[x][2]
		replace vat with aItems[x][5]                         // vat
//		replace operator with GetUserName()
		replace time_w with time()                            // act. date
		replace date_w with date()										// act. time 
		replace ean with aItems[x][8]
		replace loot with aItems[x][9]
		replace exp with 	aItems[x][10]
	endif
next

dbclosearea()
mg_do(cWin, "release")

return

procedure store_exp()

local cWin := "exp_st", dDat := date()
local aFullCust := read_customer(, .T.), aCust := {}
local aStore := getstore(), x
local lTax := TaxStatus()
local aItems := {}

HB_SYMBOL_UNUSED( aStore )

for x:=1 to len(aFullcust)
	aadd(aCust, aFullCust[x][1])
next

CREATE WINDOW(cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("Sale items")
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
		tooltip _I("Sale items")
	end grid
end window

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

dbcloseall()

return

procedure select_working_store()

return

procedure store_browse()

local aOptions:={}, cAll // , bOnclick
local cWin := "br_st_win"
//local aStore := GetStore()

if !OpenStore(,3)
	Return
endif
cAll := alias()

aadd(aOptions, { cAll+"->Idf", cAll+"->name", cAll+"->date_b", cAll+"->time_b", cAll+"->price_b"}) //, cAll+"->vat", cAll+"->fik", cAll+"->uuid",  cAll+"->op" })
aadd(aOptions, {_I("ID"), _I("Name"), _I("Date"), _I("Time"), _I("Price")}) //, _I("Vat"), _I("FIK"), _I("UUID"), _I("Operator") })
aadd(aOptions, { 70, 280, 90, 80, 80, 60, 260, 200, 100 })
aadd(aOptions, { Qt_AlignLeft, Qt_AlignLeft })
aadd(aOptions, {10,10, 800, 400}) 
// bOnClick := { || show_memo() }

create window (cWin)
	ROW 5
	COL 10
	HEIGHT 430 
	WIDTH  1040
	CHILD .t.
	MODAL .t.
//	my_grid( cNWin, aArr, aOptions, , , , cNWin+"_g" )
 	my_mg_browse(cWin, alias(), aOptions )

/*
	create button OK
		row 180
		col 840
		width 160
		height 60
		caption _I("&ReSend")
		// ONCLICK Send_again() 
		tooltip _I("Try to send unsent record")
//		picture cRPath+"task-reject.png"
	end button

	create button print
		row 260
		col 840
		width 160
		height 60
		caption _I("&Print")
		// ONCLICK print_again()
		tooltip _I("Print")
//picture cRPath+"task-reject.png"
	end button
*/

	create button Back
		row 340
		col 840
		width 160
		height 60
		caption _I("Back")
		ONCLICK mg_do(cWin, "release")
		tooltip _I("Close and go back")
		picture cRPath+"task-reject.png"
	end button

end window

mg_do( cWin, "center")
mg_do( cWin, "activate")

dbclosearea()

return


