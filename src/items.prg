/*
 * Fenix Open Source accounting system
 * Item managment
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

procedure browse_items()

local cWin := "item_win"
local cAll, lTax := TaxStatus()

if !OpenItems(, 2, .T.)
	return
endif

cAll := alias()

CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("Browse items")
	CHILD .T.
	MODAL .T.
	//TOPMOST .t.
	FONTSIZE 16
	create Browse item_b
		row 10
		col 10
		width 800
		height 564 		
		if lTax
			COLUMNFIELDALL { cAll+"->name", cAll+"->unit", cAll+"->type", cAll+"->price", cAll+"->tax" }
			COLUMNHEADERALL { _I("Name"), _I("Unit") , _I("Type"), _I("Price"), _I("Tax") }
			COLUMNWIDTHALL { 350, 80, 80, 122, 60 }
			COLUMNALIGNALL { Qt_AlignLeft, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignRight, Qt_AlignRight }
		else
			COLUMNFIELDALL { cAll+"->name", cAll+"->unit", cAll+"->type", cAll+"->price" }
			COLUMNHEADERALL { _I("Name"), _I("Unit") , _I("Type"), _I("Price") }
			COLUMNWIDTHALL { 350, 80, 80, 122 }
			COLUMNALIGNALL { Qt_AlignCenter, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignRight }
		endif
		workarea alias()
		value 1
		//AUTOSIZE .t.
		rowheightall 24
		FONTSIZE 16
		//ONENTER print_invoice(mg_get(cWin, "invoice_b", "cell", mg_get(cWin,"invoice_b","value"), 1))
		//ONDBLCLICK print_invoice(mg_get(cWin, "invoice_b", "cell", mg_get(cWin,"invoice_b","value"), 1))
//		ONDBLCLICK hb_threadstart(HB_THREAD_INHERIT_PUBLIC, @print_invoice(), mg_get(cWin, "invoice_b", "cell", mg_get(cWin,"invoice_b","value"), 1))

	END BROWSE
	create button edit_b
		row 350
		col 840
		width 160
		height 60
		caption _I("Change item")
		ONCLICK new_item( cWin, .T.)
		tooltip _I("Change item" )
	end button
	create button Del
		row 430
		col 840
		width 160
		height 60
		caption _I("Delete item")
//		backcolor {0,255,0}
		ONCLICK delete_item( cWin, cAll )
		tooltip _I("Delete item")
//    picture cRPath+"task-reject.png"
	end button

	create button Back
		row 510
		col 840
		width 160
		height 60
		caption _I("Back")
//		backcolor {0,255,0}
		ONCLICK mg_do(cWin, "release")
		tooltip _I("Close and go back")
		picture cRPath+"task-reject.png"
	end button

END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

dbcloseall()

return

procedure new_item(cOldW, lEdit)

local cWin := "new_i_w", nUnit := 0, nTax := 0, nType := 0
local aUnit := GetUnit() , aTax := GetTax(), cItemD := "", nPrice := 0.00
local aCat := { "", "Sluzby", "Hardware", "Software" }
local lInv := .t., lSto := .f., lCR := .f., lTax := TaxStatus(), cEan := ""

field name, price, unit, tax, type, inv_i, sto_i, cr_i, ean
default lEdit to .F.

if lEdit
	//x:= mg_get(cOldW, "item_b", "value")
	cItemD := name
	nPrice := price
	nType := aScan( aCat, { | y | alltrim(y) = alltrim(type) } ) 
	nUnit := aScan( aUnit, { |y| alltrim(y) = alltrim(unit) } )
	if lTax
	   nTax := aScan( aTax, { |y| alltrim(y) = strx(tax) } )
	endif
	lInv := inv_i
	lSto := sto_i
	lCR := cr_i
	cEan := ean
endif

create window (cWin)
	row 0
	col 0
	width 1020
	height 450
	CHILD .t.
	MODAL .t.
	if lEdit
		caption _I("Edit item")
	else
		caption _I("New item")
	endif
	CREATE TAB SET
		row 10
		col 10
		width 800
		height 420
		VALUE 1

	CREATE PAGE _I("Simple setting's")
		CreateControl(20, 20, cWin, "Itemd", _I("Item Description"), cItemD)
		CreateControl( 20, 560, cWin, "Itemu", _I("Item unit"), aUnit)
		CreateControl( 70, 20, cWin, "Itemp", _I( "Price" ), nPrice )
		if lTax
			CreateControl( 70, 280, cWin, "Itemt", _I( "Tax" ) + " %", aTax )
			CreateControl( 70, 440, cWin, "Itempwt", _I( "Price with Tax" ), 0.00 )
			mg_set(cWin,"Itempwt_t", "readonly", .t. )
		endif
		mg_set(cWin, "Itemd_t", "width", 400)

		CreateControl( 130, 20, cWin, "Cat", _I("Item category"), aCat)
		if lEdit
			mg_set( cWin, "itemu_c", "value", nUnit )
			if lTax
				mg_set( cWin, "itemt_c", "value", nTax )
			endif
			mg_set( cWin, "cat_c", "value", nType )
		endif
		Create CheckBox invoice_c
			row 120
			col 540
			autosize .t.
			Value lInv
			CAPTION _I("Invoice item")
		End CheckBox
		Create CheckBox store_c
			row 150
			col 540
			autosize .t.
			Value lSto
			CAPTION _I("Store item")
		End CheckBox
		Create CheckBox cr_c
			row 180
			col 540
			autosize .t.
			Value lCr
			CAPTION _I("Cash register item")
		End CheckBox
/*
		create barcode ean_br
			row 200
			col 20
			height 80
			width mg_barcodeGetFinalWidth("123456789012", mg_get( cWin, "ean_br", "type" ), mg_get( cWin, "ean_br", "barwidth" ))
			type "ean13"
			barwidth 2
			backcolor { 255,255,255 }
			value alltrim(mg_get( cWin, "ean_t", "value"))		
			enabled .f.	
		end barcode
*/

		create timer fill_it
			interval	1500
			action fill_it(cWin, aTax, lTax)
			enabled .t.
		end timer
	END PAGE

	CREATE PAGE _I("Advanced setting")

	   CreateControl( 10, 10, cWin, "ean", _I("Ean code"), cEan)
		Create CheckBox clot_c
			row 20
			col 340
			autosize .t.
			Value .f.
			CAPTION _I("Trace Lot No.")
		End CheckBox
		Create CheckBox cexp_c
			row 50
			col 340
			autosize .f.
			Value .f.
			CAPTION _I("Trace Expiration")
		End CheckBox
		Create CheckBox cprice_c
			row 80
			col 340
			autosize .f.
			Value .f.
			CAPTION _I("Enable change price")
			Tooltip _I("Enable operator to change/update price when make expedition")
		End CheckBox
		create button picture_b
			row 300
			col 10
			width 120
			height 40
			caption _I("Set picture")
			ONCLICK get_picture_file( cWin )
			tooltip _I( "Set item picture" )
		end button
		create button PrintBarcode_b
			row 300
			col 180
			width 120
			height 40
			caption _I("Print barcode")
			ONCLICK get_picture_file( cWin )
			tooltip _I( "Print barcode" )
		end button
	END PAGE
	create button PrintBarcode_b
		row 160
		col 520
		width 160
		height 60
		caption _I("Print barcode")
		ONCLICK get_picture_file( cWin )
		tooltip _I( "Print barcode" )
	end button

	CreateControl( 240, 820, cWin, "Save",, { || save_item(cWin, aUnit, aTax, aCat, lEdit, cOldW ) } )
	CreateControl( 320, 820, cWin, "Back" )

	END TAB
end window

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

return

static procedure save_item( cWin, aUnit, aTax, aType, lEdit, cOldW )

local lTax := TaxStatus()

default lEdit to .f.

if empty(mg_get( cWin, "itemd_t", "value" ))
	msg("Empty item name !?")
	return
endif
if empty(mg_get( cWin, "itemp_t", "value" ))
	msg("Empty price !?")
	return
endif

if !lEdit
	if !OpenItems(, 2, .t.)
		return
	endif
endif

if iif( lEdit, reclock(), addrec())
	replace name with mg_get( cWin, "itemd_t", "value" )
	replace price with mg_get( cWin, "itemp_t", "value" )
	replace unit with aUnit[ mg_get( cWin, "itemu_c", "value" ) ]
	if lTax
		replace tax  with val(aTax[ mg_get( cWin, "itemt_c", "value" ) ])
	endif
	replace type with aType[ mg_get( cWin, "cat_c", "value" ) ]
	replace inv_i with mg_get( cWin, "invoice_c", "value" )
	replace sto_i with mg_get( cWin, "store_c", "value" )
	replace cr_i  with mg_get( cWin, "cr_c", "value" )
	replace ean with mg_get( cWin, "ean_t", "value" )
	dbrunlock()
endif

if lEdit
	mg_do( cOldW, "item_b", "refresh" )
else
	dbclosearea()
endif

mg_do( cWin, "release" )

return

procedure delete_item( cWin )

local cAll := alias()
field idf

if lastrec() == 0 // .or. empty(idf)
	return
endif

if msgask(_I("Really want to delete item !?"))
	if (cAll)->(RecLock())
		(cAll)->(dbdelete())
		(cAll)->(dbrunlock())
		select(cAll)
		mg_do( cWin, "item_b", "refresh" )
		Msg(_I("Item succesfuly removed from database !!!"))
	endif
endif

return

function Get_def_Items( nType, aItems )

local lAdd, cAl := alias()
field name, unit, price, tax, type, inv_i, sto_i, cr_i, ean

default aItems to {}
default nType to 0

if !OpenItems(, 3)
	return aItems
endif

dbgotop()

do while !eof()
	lAdd := .f.
	do case 
	case nType == 0 // in case nType == 0 get all items
		lAdd := .t.
	case nType == 1 //.or. nType == 3 // invoice items
		if inv_i
			lAdd := .t.
		endif
	case nType == 2 .or. nType == 3 // stock items
		if sto_i	
			lAdd := .t.
		endif
	case nType == 4 //  cach register items
		if cr_i
			lAdd := .t.	
		endif
	endcase
	if lAdd
//		aadd( aItems, { name, unit, price, tax, type, ean } )
		aadd( aItems, { name, unit, price, tax, 0, 0, 0, ean })
	endif
	dbskip()
enddo

dbclosearea()
if !empty(cAl)
	select(cAl)
endif

return aItems


procedure Get_STO_Item(aIt, cOWin)

local cWin := "add_sto_w", aItems := get_def_items(3), aNames := {}, nNo := 1, x
local aUnit := GetUnit() , aTax := GetTax(), nPrice := 0.00, lTax := TaxStatus()
local cEan := ""
// , cItemD := ""
// mg_log(aIt)
/*
if !empty(aIt)
	aItems := aIt
endif
*/
if empty(aItems)
	msg("Unable to find any defined item"+" !?")
	return
endif

for x:=1 to len(aItems)
	aadd( aNames, aItems[x][1] )
next

create window (cWin)
	row 0
	col 0
	width 800
	height 400
	CHILD .t.
	MODAL .t.
	caption _I("Add item from stock")
	CreateControl( 120, 20, cWin, "Itemp", _I( "Price" ), nPrice )
	if lTax
		CreateControl( 120, 280, cWin, "Itemt", _I( "Tax" ) + " %", aTax )
	endif
	CreateControl(70, 310, cWin, "Itemu", _I("Item unit"), aUnit)
   CreateControl( 70, 485, cWin, "EAN", _I("Ean code"), cEan)

	create combobox itemget_c
		row 20
		col 20
		width 400
		height 30
		//autosize .t.
		items aNames
		onchange fill_cho( cWin, aItems, aTax, aUnit, lTax)
		DISPLAYEDIT .T.
		value 1
	end combobox	

	CreateControl(70, 20, cWin, "Itemq", _I("Quantity"), nNo)
	if lTax
		CreateControl(120, 440, cWin, "Itempwt", _I("Price with Tax"), 0.00)
		CreateControl(190, 20, cWin, "Itemtp", _I("Total price with Tax"), 0.00)
		mg_set(cWin,"Itempwt_t", "readonly", .t. )
		mg_set(cWin,"Itemtp_t", "readonly" , .t. )
	else
		CreateControl(190, 20, cWin, "Itemtp", _I("Total price"), 0.00)
		mg_set(cWin,"Itemtp_t", "readonly" , .t. )
	endif
	create barcode ean_br
		row 180
		col 460
		height 60
		width mg_barcodeGetFinalWidth("123456789012", mg_get( cWin, "ean_br", "type" ), mg_get( cWin, "ean_br", "barwidth" ))
		type "ean13"
		barwidth 2
		backcolor { 255,255,255 }
		value alltrim(mg_get( cWin, "ean_t", "value"))		
		enabled .f.
	end barcode

	create timer fill_choice
		interval	500
		action fill_it( cWin, aTax, lTax )
		enabled .t.
	end timer
	mg_do( cWin, "itemq_t", "setfocus" )
	CreateControl(240, 610, cWin, "Save",, {|| fill_item(@aIt, cWin, cOWin, aTax, lTax )})
	CreateControl(320, 610, cWin, "Back")
end window

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

return

procedure fill_cho(cWin, aArr, aTax, aUnit, lTax)

local nTax, nX := mg_get(cWin, "Itemget_c", "value"), nUnit, nPr

nPr := aArr[nX][3] 
mg_set( cWin, "itemp_t", "value", nPr ) // set price from item
nUnit := aScan( aUnit, { |y| alltrim(y) = alltrim(aArr[nX][2]) } )
mg_set( cWin, "itemu_c", "value", nUnit )
mg_set( cWin, "ean_t", "value", alltrim(aArr[nX][8]))

if lTax
	nTax := aScan( aTax, { |y| alltrim(y) = strx(aArr[nX][4]) } )
	mg_set( cWin, "itemt_c", "value", nTax )
endif

return

function fill_item( aItems, cWin, cPWin, aTax, lTax, nX )

local nPrice := mg_get(cWin, "Itemp_t", "value")
local nQ := mg_get(cWin, "Itemq_t", "value")
local nTax := 0, cName, lEdit
local aUnit := GetUnit()

default nX to 0

if nX == 0
	lEdit := .F.
else
	lEdit := .T.
endif

if empty( mg_getControlParentType( cWin, "Itemd_t" ) )
	cName := mg_get(cWin, "Itemget_c", "displayValue")
else
 	cName := mg_get(cWin, "Itemd_t", "Value")
endif
if empty(nPrice) .or. empty(nQ) .or. empty(cName)
	msg(_I("Please fill some more information"))
	return aItems
endif

if lTax
	nTax := val(aTax[mg_get(cWin, "Itemt_c", "value")])
	if lEdit
		aItems[nX] := { cName, ;
						aUnit[mg_get(cWin, "Itemu_c", "value")], ;
 						mg_get(cWin, "Itemp_t", "value"), ;	
						mg_get(cWin, "Itemq_t", "value"), ;	
						nTax, round((nPrice * nQ), 2), ;
						round((nPrice * nQ * (1+nTax/100)), 2) }
	else
		aadd( aItems, { cName, ;
						aUnit[mg_get(cWin, "Itemu_c", "value")], ;
 						mg_get(cWin, "Itemp_t", "value"), ;	
						mg_get(cWin, "Itemq_t", "value"), ;	
						nTax, round((nPrice * nQ), 2), ;
						round((nPrice * nQ * (1+nTax/100)), 2) })
	endif	
else
	if lEdit
		aItems[nX] := { cName, ;
						aUnit[mg_get(cWin, "Itemu_c", "value")], ;
 						mg_get(cWin, "Itemp_t", "value"), ;	
						mg_get(cWin, "Itemq_t", "value"), ;	
						nTax, round((nPrice * nQ), 2), round( nPrice * nQ, 2 ) }
	else
		aadd( aItems, { cName, ;
						aUnit[mg_get(cWin, "Itemu_c", "value")], ;
 						mg_get(cWin, "Itemp_t", "value"), ;	
						mg_get(cWin, "Itemq_t", "value"), ;	
						nTax, round((nPrice * nQ), 2), round( nPrice * nQ, 2 ) })
	endif
endif
// mg_log(aItems)	
mg_do(cPWin, "items_g", "refresh")
mg_do(cWin, "release")

return aItems

procedure fill_it(cWin, aTax, lTax, lEan)

local nPr := mg_get(cWin, "Itemp_t", "value")
local cEan
local nTax := 0

default lTax to .t.
default lEan to .t.

if lTax
	nTax := val(aTax[mg_get(cWin, "Itemt_c", "value")])
endif
if !empty(nPr)
	if !empty( mg_getControlParentType( cWin, "Itempwt_t" ) )
		mg_set(cWin,"Itempwt_t", "value", round( nPr * ( nTax/100+1 ), 2 ) )
	endif
	if !empty( mg_getControlParentType( cWin, "Itemtp_t" ) )
		if lTax
			mg_set(cWin,"Itemtp_t", "value", round( nPr * ( nTax/100+1 ), 2 ) *  mg_get(cWin, "Itemq_t", "value" ))
		else
 			mg_set(cWin,"Itemtp_t", "value", round( nPr, 2 ) * mg_get(cWin, "Itemq_t", "value" )) 
		endif
	endif
endif

/*
if lEan
	cEan := alltrim(mg_get(cWin, "ean_t", "value"))
	if len(cEan) >=12
		mg_set( cWin, "ean_br", "visible", .t.)
	else
		mg_set( cWin, "ean_br", "visible", .f.)
	endif
endif
*/

return

function get_picture_file( cWin )

local cFile

cFile := mg_GetFile( { { "All Files", mg_GetMaskAllFiles() }}, "Select File",,, .t. )

return





