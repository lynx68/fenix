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
local aFullStore := getstore(), aStore := {}
local cDoc := "", cEanSearch := ""

//HB_SYMBOL_UNUSED( aStore )

for x:=1 to len(aFullcust)
	aadd(aCust, aFullCust[x][1])
next

for x:=1 to len(aFullStore)
	aadd(aStore, aFullStore[x][1])
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
	CreateControl(10, 20, cWin, "store", _I("Store"), aStore )
	CreateControl(50, 20, cWin, "payd", _I("Date"), dDat )
	CreateControl(50, 280, cWin, "fOdb", _I("Supplier"), aCust )
	CreateControl(100, 20,  cWin, "doc", _I("Document"), cDoc )
	CreateControl(200, 20,  cWin, "search", _I("Barcode Search"), cEanSearch )

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
/*
	create Button add_ic_b
		row 300
		col 840
		autosize .t.
		caption _I("New item")
		onclick add_Item(@aItems, cWin)
		visible .t.
	end button
*/
	create button edit_i_b
		row 350
		col 840
		autosize .t.
		caption _I("Edit item")
		onclick Get_STO_Item(@aItems, cWin, 5, .t.)
		visible .t.
	end button
	create button del_i_b
		row 400
		col 840
		autosize .t.
		caption _I("Delete item")
		onclick del_item(cWin, "items_g")
		visible .t.
	end button
	CreateControl(510, 610, cWin, "Save",, {|| save_store( aItems, cWin, aFullCust ) } )

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

static procedure save_store(aItems, cWin, aCust)

field name, date_b, quant_b, price_b, unit, vat, operator, time_w, date_w
field loot, exp, ean
local x, nCust

if !OpenStore(,2,, .t.)
	msg("Error opening the database!")
	return 
endif

nCust := aCust[mg_get( cWin, "fodb_c", "value" )][2]

// mg_log(aItems)

for x:=1 to len(aItems)
	if AddRec()
		replace custumer with nCust
//		replace doument  with mg_get( cWin, "doc_t", "value" )
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
		replace idf with aItems[x][11]
		replace state with aItems[x][4]                       // store qua. status
	endif
next

dbclosearea()
mg_do(cWin, "release")

return

procedure store_exp()

local cWin := "exp_st", dDat := date()
local aFullCust := read_customer(, .T.), aCust := {}
local x
local lTax := TaxStatus()
local aItems := {}
local aFullStore := getstore(), aStore := {}
local cEanSearch
// HB_SYMBOL_UNUSED( aStore )

for x:=1 to len(aFullcust)
	aadd(aCust, aFullCust[x][1])
next
for x:=1 to len(aFullStore)
	aadd(aStore, aFullStore[x][1])
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
	CreateControl(10, 20, cWin, "store", _I("Store"), aStore )
	CreateControl(50, 20, cWin, "payd", _I("Date"), dDat )
	CreateControl(50, 280, cWin, "fOdb", _I("Supplier"), aCust )
	CreateControl(200, 20,  cWin, "search", _I("Barcode Search"), cEanSearch )

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
	create Button add_ist_b
		row 250
		col 840
		autosize .t.
		caption _I("Select item")
		onclick exp_STO_Item( @aItems, cWin, 5 )
		visible .t.
	end button

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

if !OpenStore(,3,,.t.)
	Return
endif
cAll := alias()

aadd(aOptions, { cAll+"->name", cAll+"->date_b", cAll+"->quant_b", cAll+"->unit", cAll+"->price_b", cAll+"->exp", cAll+"->loot", cAll+"->document" }) //, cAll+"->vat", cAll+"->fik", cAll+"->uuid",  cAll+"->op" })
aadd(aOptions, {_I("Name"), _I("Date"), _I("Quantity"), _I("Unit"), _I("Price"), _I("Expiration"), _I("Loot") } ) //, _I("Vat"), _I("FIK"), _I("UUID"), _I("Operator") })
aadd(aOptions, { 280, 80, 90, 90, 100, 260, 200, 100 })
aadd(aOptions, { Qt_AlignLeft, Qt_AlignCenter })
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


procedure exp_STO_Item(aIt, cOWin, nI, lEdit, nStoreIdf )

local cWin := "add_sto_w", aNames := {}, nNo := 1, x, y
local aUnit := GetUnit() , aTax := GetTax(), nPrice := 0.00, lTax := TaxStatus()
local cEan := "", cLoot := "", dExp := date()
local aItems, nUnit, nTax  // cItemd 
local aFullStore := getstore(), nStore

default nI to 1
default lEdit to .f.
default nStoreIdf to 0

if mg_iscontrolcreated( cOWin, "store_c" )
	nStore:= aFullStore[ mg_Get( cOWin, "store_c", "value" )][2]
endif

aItems := get_def_items( nI,, nStore) // show only item's defined to this action
if empty(aItems)
	msg(_I("Unable to find any defined item"+" !?"))
	return
endif

//mg_log(aItems)
for y:=1 to len(aItems)
	aadd( aNames, aItems[y][1] )
next

create window (cWin)
	row 0
	col 0
	width 800
	height 400
	CHILD .t.
	MODAL .t.
	CreateControl( 120, 20, cWin, "Itemp", _I( "Price" ), nPrice )
	CreateControl(70, 310, cWin, "Itemu", _I("Item unit"), aUnit)
   CreateControl( 70, 485, cWin, "EAN", _I("Ean code"), cEan, empty(cEan) )
	CreateControl( 240, 20, cWin, "loot", _I("LOOT No."), cLoot, .t. )
	CreateControl( 285, 20, cWin, "exp", _I("Expiration date"), dExp, .t. )
	if lTax
		CreateControl( 120, 280, cWin, "Itemt", _I( "Tax" ) + " %", aTax )
		if lEdit
			mg_set( cWin, "itemt_c", "value", nTax )
		endif
		CreateControl(120, 440, cWin, "Itempwt", _I("Price with Tax"), 0.00)
		CreateControl(190, 20, cWin, "Itemtp", _I("Total price with Tax"), 0.00)
		mg_set(cWin,"Itempwt_t", "readonly", .t. )
		mg_set(cWin,"Itemtp_t", "readonly" , .t. )
	else
		CreateControl(190, 20, cWin, "Itemtp", _I("Total price"), 0.00)
		mg_set(cWin,"Itemtp_t", "readonly" , .t. )
	endif

	create combobox itemget_c
		row 20
		col 20
		width 550
		height 30
		//autosize .t.
		items aNames
		onchange fill_exp( cWin, aItems ) //fill_cho( cWin, aItems, aTax, aUnit, lTax, lEdit)
		DISPLAYEDIT .T.
		if lEdit
			value x
		else
			value 1
		endif
	end combobox	

	//mg_do( cWin, "itemq_t", "setfocus" )
	CreateControl(240, 610, cWin, "Save",, {|| fill_item(@aIt, cWin, cOWin, aTax, lTax, x )})
	CreateControl(320, 610, cWin, "Back")
end window

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

return

/*
if lEdit
	if empty( aIt )
		return
	endif
	aItems := aIt
	x := mg_get(cOWin, "items_g", "value")
	//cItemD := aIt[x][1]
	nNo := aIt[x][4]
	nPrice := aIt[x][3]
	nUnit := aScan( aUnit, { |y| alltrim(y) = alltrim(aIt[x][2]) } )
   nTax := aScan( aTax, { |y| alltrim(y) = strx(aIt[x][5]) } )
	cEan := aIt[x][8]
	cLoot := aIt[x][9]
	dExp := aIt[x][10]
else
	aItems := get_def_items( nI,, nStore) // show only item's defined to this action
	if empty(aItems)
		msg(_I("Unable to find any defined item"+" !?"))
		return
	endif
endif
*/

/*
	if lEdit
		if !empty(cLoot)
			mg_set( cWin, "loot_l", "visible", .t. )
			mg_set( cWin, "loot_t", "visible", .t. )
		endif
		if !Empty( dExp )
			mg_set( cWin, "exp_l", "visible", .t. )
			mg_set( cWin, "exp_d", "visible", .t. )
		endif
		mg_set( cWin, "itemu_c", "value", nUnit )
		caption _I("Edit item")
	else
		caption _I("New item")
	//	caption _I("Add item from stock")
	endif

	if lTax
		CreateControl( 120, 280, cWin, "Itemt", _I( "Tax" ) + " %", aTax )
		if lEdit
			mg_set( cWin, "itemt_c", "value", nTax )
		endif
		CreateControl(120, 440, cWin, "Itempwt", _I("Price with Tax"), 0.00)
		CreateControl(190, 20, cWin, "Itemtp", _I("Total price with Tax"), 0.00)
		mg_set(cWin,"Itempwt_t", "readonly", .t. )
		mg_set(cWin,"Itemtp_t", "readonly" , .t. )
	else
		CreateControl(190, 20, cWin, "Itemtp", _I("Total price"), 0.00)
		mg_set(cWin,"Itemtp_t", "readonly" , .t. )
	endif

	//CreateControl(20, 20, cWin, "Itemd", _I("Item Description"), cItemD)
	create combobox itemget_c
		row 20
		col 20
		width 550
		height 30
		//autosize .t.
		items aNames
		onchange fill_cho( cWin, aItems, aTax, aUnit, lTax, lEdit)
		DISPLAYEDIT .T.
		if lEdit
			value x
		else
			value 1
		endif
	end combobox	
   create label itemq_l
	   row 75
      col 20
		autosize .t.
      value _I("Quantity")
	end label	
   CREATE SPINNER itemq_t
		row 70
		col 110
		width 100
		height 30
		rangemin 1
		rangemax 99999
		value nNo
	//	autosize .t.
	end spinner
	// CreateControl(70, 20, cWin, "Itemq", _I("Quantity"), nNo)

	create timer fill_choice
		interval	500
		action fill_it( cWin, aTax, lTax )
		enabled .t.
	end timer

*/

static procedure fill_exp( cWin, aItems )

local nX := mg_get(cWin, "Itemget_c", "value")
local nIdf := aItems[nX][14], aInf
local nStore
// mg_log(nIdf)
aInf := GetItemInf( nIdf, nStore)

return 

static function GetItemInf( nItemIdf, nStoreIdf )

local cAll := alias(), aRet := {}
field idf, loot, exp, date_b, price_b

if !OpenStore( nStoreIdf, 3 )
	msg("Error opening the database!")
	return aRet 
endif

set order to idf
do while idf == nItemIdf
	aadd( aRet, { idf, loot, exp, date_b, price_b, recno()} )
	dbskip()
enddo

dbclosearea()
if !empty( cAll )
	select( cAll)
endif

return aRet


