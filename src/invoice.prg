/*
 * Fenix Open Source accounting system
 * invoices
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

procedure browse_invoice()

local cWin := "inv_win"
local cAll
local aCust := read_customer(, .T.), cSubs
field customer

if !OpenSubscriber(, 3)
	return
endif
cSubs := alias()
if !OpenInv(,2)
	return
endif

cAll := alias()
set relation to (cAll)->cust_idf into (cSubs)
dbgotop()

if empty(aCust)
	dbcloseall()
	return
endif

CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("Browse Invoices")
	CHILD .T.
	MODAL .t.
	//TOPMOST .t.
	FONTSIZE 16
	//my_mg_browse(cWin, alias(), aOptions ) 
	//	my_mg_browse(cWin, alias(), aOptions, bOnClick)
	// aData := aSort(aData,,, {|x, y| x[2] > y[2]})
	// my_grid(cWin, aData, aOptions, bOnClick,,,"el_zad_br")
	create Browse invoice_b
		row 10
		col 10
		width 800
		height 564 		
		COLUMNFIELDALL {cAll+"->idf", cAll+"->Date", cAll+"->cust_n", cAll+"->date_sp", cAll+"->date_pr", cAll+"->zprice" }
		COLUMNHEADERALL {_I("Invoice No."), _I("Date"), _I("Customer") , _I("Due Date"), _I("Caching date"), _I("Total price") }
		COLUMNWIDTHALL { 130, 90, 200, 130, 120, 130 }
		COLUMNALIGNALL { Qt_AlignRight, Qt_AlignCenter, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignCenter, Qt_AlignLeft }
		// BACKCOLORDYNAMIC { | nRow, nCol | COLOR_BACK(nRow, nCol) }	
		workarea alias()
		value 1
		//AUTOSIZE .t.
		rowheightall 24
		FONTSIZE 16
		ONDBLCLICK print_invoice(mg_get(cWin, "invoice_b", "cell", mg_get(cWin,"invoice_b","value"), 1),,.t.)
		//ONDBLCLICK hb_threadstart(HB_THREAD_INHERIT_PUBLIC, @print_invoice(), mg_get(cWin, "invoice_b", "cell", mg_get(cWin,"invoice_b","value"), 1))
	END BROWSE
	create button print_b
		row 110
		col 840
		width 160
		height 60
		caption _I("Print invoice")
		ONCLICK print_invoice(mg_get(cWin, "invoice_b", "cell", mg_get(cWin,"invoice_b","value"), 1),,.t.)
		tooltip _I("Print invoice" )
	end button
	create button edit_b
		row 190
		col 840
		width 160
		height 60
		caption _I("Change invoice")
		ONCLICK new_invoice(.T.)
		tooltip _I("Change invoice" )
	end button
	create button cachd_b
		row 270
		col 840
		width 160
		height 60
		caption _I("Caching date")
		ONCLICK write_pay( cWin, "invoice_b" )
		tooltip _I("Caching date")
	end button
	create button Del
		row 350
		col 840
		width 160
		height 60
		caption _I("Delete Invoice")
//		backcolor {0,255,0}
		ONCLICK del_inv( cWin, cAll )
		tooltip _I("Delete Invoice")
//    picture cRPath+"task-reject.png"
	end button

	create button Cancel
		row 430
		col 840
		width 160
		height 60
		caption _I("Cancel Invoice")
//		backcolor {0,255,0}
		ONCLICK cancel_inv()
		tooltip _I("Cancel Invoice")
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

function COLOR_BACK() //nRow, nCol) 

local cRet
field storno, date_pr
do case 
	case storno
		cRet := {74,164,72}
	case empty(date_pr)
		cRet := {0,0,255}
	case !empty(date_pr)
		cRet := {0,255,0}
endcase
	
return cRet

procedure new_invoice(lEdit)

local cWin := "add_inv", aCust := {}, cTxt := ""
local aInvType := {}, aPl := {}, aItems := {} // {"","","","","","","",""}
local aFullCust := {}, x, cOrder := ""
local bSave
local nIdf := 0, dDate := date(), dDate_sp := date()+10, dDate_uzp := date(), nType 
local nCust, nPay, lTax := TaxStatus()
field idf, date, date_sp, uzp, type, objedn, cust_idf, cust_n, ndodpo, Pred

default lEdit to .f.

aadd(aInvtype, _I("Normal"))
aadd(aInvType, _I("Proforma"))

aadd(aPl, _I("Payment on account"))
aadd(aPl, _I("in cash"))

//hb_threadstart( HB_THREAD_INHERIT_PUBLIC, @read_customer(), @aCust)
aFullCust := read_customer(, .T.)
bSave := { || save_invoice( cWin, aFullCust, lEdit ) }

//mg_log(aCust)
if empty(aFullCust) .or. len(aFullCust) == 1
	msg(_I("Customer database empty. Please define custumers before make invoice"))
	return
endif
for x:=1 to len(aFullcust)
	aadd(aCust, aFullCust[x][1])
next

if lEdit
	nIdf := idf
	if empty(nIdf)
		return
	endif
	dDate := date
	dDate_sp := date_sp
	dDate_uzp := uzp
	nType	 := Type
	cOrder := objedn
//	nCust := cust_idf
//	cCustName := cust_n
	nPay := ndodpo
	aItems := GetItems(nIdf)
	nCust := aScan( aFullCust, { |x| x[2] == cust_Idf } )
	cTxt := pred
endif

CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("New Invoice")
	CHILD .T.
	MODAL .t.
	// TOPMOST .t.
	CreateControl(20,	20,  cWin, "datfak", _I("Date"), dDate )
	CreateControl(20,	260, cWin, "f_tOdb", _I("Due Date"), dDate_sp )
	CreateControl(20,	560, cWin, "f_uzp", _I("Date of chargeability"), dDate_uzp )
	CreateControl(80,	20, cWin, "ftyp", _I("Invoice Type"), aInvType )
	if lEdit
		mg_set( cWin, "ftyp_c", "value", nType)
	endif
	CreateControl(80,	300, cWin, "fpl", _I("Method of payment"), aPl)
	if lEdit
		mg_set( cWin, "fpl_c", "value", nPay)
	endif
	CreateControl(80,	720, cWin, "ord", _I("Order"), cOrder)
	CreateControl(140, 20,  cWin, "fOdb", _I("Customer"), aCust )
	if lEdit
		mg_set( cWin, "fOdb_c", "value", nCust)
	endif
	CreateControl(200, 20, cWin, "Inv_No",	_I("Invoice No."), nIdf, .T.)
	CreateControl(510, 650, cWin, "Save",,bSave)
	CreateControl(510, 840, cWin, "Back")
  	
//	mg_do(cWin, "Inv_no_l", "hide")
//	mg_do(cWin, "Inv_no_t", "hide")
	CREATE LABEL btext_l
		row 470
		col 20
		autosize .t.
		Value _I("Invoice bottom text")
	END LABEL
	CREATE EDITBOX btext_e
		row 500
		col 20
		width 350
		height 75
		value cTxt
		TOOLTIP _I("Invoice bottom text")
		visible .f.
	END EDITBOX
	create Button add_i_b
		row 250
		col 840
		autosize .t.
		caption _I("Item from catalogue")
		onclick Get_STO_Item(@aItems, cWin)
		visible .f.
	end button
	create Button add_ic_b
		row 300
		col 840
		autosize .t.
		caption _I("New Item")
		onclick add_item(@aItems, cWin)
		visible .f.
	end button
	create Button edit_i_b
		row 350
		col 840
		autosize .t.
		caption _I("Edit Item")
		onclick add_item(@aItems, cWin, .T.)
		visible .f.
	end button

	create Button del_i_b
		row 400
		col 840
		autosize .t.
		caption _I("Delete Item")
		onclick del_item(cWin, "Items_g")
	visible .f.
	end button
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
	// ondblclick Edit_item()
		navigateby "row"
		visible .f.
		Items aItems
		tooltip _I("Invoice Items")
		CREATE Context Menu cBrMn
			CREATE ITEM _I("New item")
				ONCLICK add_item(@aItems, cWin)
			END ITEM
			CREATE ITEM _I("Edit item")
				ONCLICK add_item(@aItems, cWin, .T.)
			END ITEM
			CREATE ITEM _I("Delete item")
				ONCLICK del_item(cWin, "items_g")
			END ITEM
		END Menu
	end grid
	Create timer wach_grid
		interval 500
		action watch_grid(cWin, "items_g")
		enabled .t.
	end timer
END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

if !lEdit
	dbcloseall()
endif

return

//
// show / hide controls depending of input
//
static procedure watch_grid(cWin, cGrid)

local aItems := mg_get(cWin, cGrid, "items")
local nCustomer := mg_get(cWin, "fodb_c", "value")
local nType, nIdf

if empty(aItems)
	mg_set(cWin, "save", "visible", .f.)
	mg_set( cWin, "inv_no_l", "visible", .f. )
	mg_set( cWin, "inv_no_t", "visible", .f. )
	mg_set( cWin, "btext_l", "visible", .f. )
	mg_set( cWin, "btext_e", "visible", .f. )
else
	mg_set(cWin, "save", "visible", .t.)
	if empty( mg_get( cWin, "inv_no_t", 'value' ) )
		nType := mg_get(cWin, "ftyp_c", "value" )  // Inoice type
		nIdf := GetNextFakt(nType, mg_get(cWin, "datfak_d", "value" )) // calc in. idf
		mg_set( cWin, "inv_no_t", "value", nIdf )
	endif
	mg_set( cWin, "inv_no_l", "visible", .t. )
	mg_set( cWin, "inv_no_t", "visible", .t. )
	mg_set( cWin, "btext_l", "visible", .t. )
	mg_set( cWin, "btext_e", "visible", .t. )
endif

if nCustomer > 1
	mg_set(cWin, cGrid, "visible", .t.)
	mg_set(cWin, "add_i_b", "visible", .t.)
	mg_set(cWin, "add_ic_b", "visible", .t.)
	mg_set(cWin, "del_i_b", "visible", .t.)
	mg_set(cWin, "edit_i_b", "visible", .T.)
else
	mg_set(cWin, cGrid, "visible", .f.)
	mg_set(cWin, "add_i_b", "visible", .f.)
	mg_set(cWin, "add_ic_b", "visible", .f.)
	mg_set(cWin, "del_i_b", "visible", .f.)
	mg_set(cWin, "edit_i_b", "visible", .f.)
endif

return

// 
// Delete item from grid
//
static function del_item( cWin, cGrid )

local x:= mg_get(cWin,cGrid,"value")

if x <> 0
	mg_do(cWin, cGrid, "deleteitem", x)
	mg_do(cWin, cGrid, "refresh")
endif

Return NIL

static procedure cancel_inv()

field storno, idf

if lastrec() == 0 .or. empty(idf)
	return
endif

if storno
	Msg(_I("Invoice already canceled !!!"))
	return
endif

if msgask(_I("Really cancel invoice No.") + " " + strx(idf))
	if reclock()
		replace storno with .t.
		dbrunlock()
		Msg(_I("Inoice succesfuly canceled"))
	endif
endif

return

static procedure del_inv( cWin, cAll )

local nIdf

field idf

default cAll to alias()
if lastrec() == 0 .or. empty(idf)
	return
endif
nIdf := (cAll)->idf
if msgask(_I("Really want to delete invoice No.") + " " + strx(nidf))
	if (cAll)->(RecLock())
		(cAll)->(dbdelete())
		(cAll)->(dbrunlock())
		if OpenStav(,2)
			if dbseek(nIdf)
				do while idf == nIdf
					if reclock()
						dbdelete()
						dbrunlock()
					endif
					dbskip()
				enddo
			endif
			dbclosearea()
		endif
		select(cAll)
		mg_do( cWin, "invoice_b", "refresh" )
		Msg(_I("Inoice succesfuly removed from database !!!"))
	endif
endif

return

procedure CreateControl(nRow, nCol, cWin, cKontrol, cName, xValue, lHide )

default xValue to ""
default lHide to .F.

do case
	case lower(cKontrol) == "back"
		create button Back
			row nRow
			col nCol
			width 160
			height 60
			caption _I("Back")
	//		backcolor {0,255,0}
			ONCLICK mg_do(cWin, "release")
			tooltip _I("Close and go back")
			picture cRPath+"task-reject.png"
		end button
		return
	case lower(cKontrol) == "save"
		create button save
			row nRow
			col nCol
			width 160
			height 60
			caption _I("Save")
	//		backcolor {0,255,0}
			if valtype(xValue) == "B"
				ONCLICK eval(xValue)
			endif
			tooltip _I("Save and exit")
			picture cRPath+"task-complete.png"
		end button
		return
endcase

CREATE LABEL (cKontrol+"_l")
	Row nRow+4
	Col nCol
	AUTOSIZE .t.
	Value _I(cName)+ ":"
	TOOLTIP _I(cName)
	if lHide
		VISIBLE .F.
	endif
END LABEL
do case
	case valtype(xValue) == "D"
		CREATE DATEEDIT (cKontrol+"_d")
	case valtype(xValue) == "A"
		CREATE COMBOBOX (cKontrol+"_c")
			WIDTH 260
			HEIGHT 24
	case valtype(xValue) == "C"
		CREATE TEXTBOX (cKontrol+"_t")
			WIDTH 220
			HEIGHT 24
	case valtype(xValue) == "N"
		CREATE TEXTBOX (cKontrol+"_t")
			WIDTH 100
			HEIGHT 24
endcase
	ROW nRow
	COL mg_get( cWin , cKontrol+"_l", "ColRight")+10
	// AUTOSIZE .t.
	TOOLTIP _I(cName)
	// MAXLENGTH 25
	if lHide
		VISIBLE .F.
	endif
do case
	case valtype(xValue) == "D"
		VALUE xValue
		calendarpopup .t.
		END DATEEDIT
	case valtype(xValue) == "A"
		ITEMS xValue
		value 1 
		END COMBOBOX
	case valtype(xValue) == "C"
		VALUE xValue
		END TEXTBOX
	case valtype(xValue) == "N"
		Numeric .t.
		allownegative .f.
		decimals 2
		VALUE xValue
		END TEXTBOX
endcase

return

procedure add_item(aItems, cPWin, lEdit)

local cWin := "add_i_w", nNo := 1, x, nUnit := 0, nTax := 0
local aUnit := GetUnit() , aTax := GetTax(), cItemD := "", nPrice := 0.00, lTax := TaxStatus()
default lEdit to .F.

if lEdit
	if empty( aItems )
		return
	endif
	x := mg_get(cPWin, "items_g", "value")
	cItemD := aItems[x][1]
	nNo := aItems[x][4]
	nPrice := aItems[x][3]
	nUnit := aScan( aUnit, { |y| alltrim(y) = alltrim(aItems[x][2]) } )
	//mg_log( aItems[x][5] )
   nTax := aScan( aTax, { |y| alltrim(y) = strx(aItems[x][5]) } )
	//mg_log(x)
	//mg_log(cItemd)
endif

create window (cWin)
	row 0
	col 0
	width 800
	height 400
	CHILD .t.
	MODAL .t.
	caption _I("New item")
	CreateControl(20, 20, cWin, "Itemd", _I("Item Description"), cItemD)
	CreateControl(70, 20, cWin, "Itemq", _I("Quantity"), nNo)
/*
	CREATE SPINNER itemq_t
		row 70
		COL 20
		Width 100
		HEIGHT 24
		RangeMin 1
		RangeMax 100000000
		value nNo
	end spinner
*/
	CreateControl(70, 320, cWin, "Itemu", _I("Item unit"), aUnit)
	if lEdit
		mg_set( cWin, "itemu_c", "value", nUnit )
	endif
	CreateControl( 120, 20, cWin, "Itemp", _I( "Price" ), nPrice )
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
	CreateControl(240, 610, cWin, "Save",, {|| fill_item(@aItems, cWin, cPWin, aTax, lTax)})
	CreateControl(320, 610, cWin, "Back")
	mg_set(cWin, "Itemd_t", "width", 400)
	create timer fill_it
		interval	1000
		action fill_it( cWin, aTax, lTax )
		enabled .t.
	end timer
end window

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

return

procedure fill_it(cWin, aTax, lTax)

local nPr := mg_get(cWin, "Itemp_t", "value")
local nTax := 0

default lTax to .t.

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

return

function fill_item(aItems, cWin, cPWin, aTax, lTax)

local nPrice := mg_get(cWin, "Itemp_t", "value")
local nQ := mg_get(cWin, "Itemq_t", "value")
local nTax := 0, cName
local aUnit := GetUnit()

if empty( mg_getControlParentType( cWin, "Itemd_t" ) )
//	cName := aIt[mg_get(cWin, "Itemget_c", "Value")][1]
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
	aadd( aItems, { cName, ;
						aUnit[mg_get(cWin, "Itemu_c", "value")], ;
 						mg_get(cWin, "Itemp_t", "value"), ;	
						mg_get(cWin, "Itemq_t", "value"), ;	
						nTax, round((nPrice * nQ), 2), round((nPrice * nQ * (1+nTax/100)), 2) })
else
	aadd( aItems, { cName, ;
						aUnit[mg_get(cWin, "Itemu_c", "value")], ;
 						mg_get(cWin, "Itemp_t", "value"), ;	
						mg_get(cWin, "Itemq_t", "value"), ;	
						nTax, round((nPrice * nQ), 2), round( nPrice * nQ, 2 ) })
endif
	
mg_do(cPWin, "items_g", "refresh")
mg_do(cWin, "release")

return aItems

static function save_invoice( cWin, aFullCust, lEdit)

local aItems := mg_get(cWin, "items_g", "items")
local nIdf, x, cIAll, nTmp
// local aUnit := GetUnit() 

field idf, zprice, pred

default lEdit to .f.

if !OpenInv(,2) 
	return .f.
endif
cIAll := alias()
select(cIAll)

nIdf := mg_get( cWin, "inv_no_t", "value" )
if empty(nIdf)
	Msg(_I("Empty invoiced identification !??"))
	return .f.
endif
if !lEdit .and. dbseek(nIdf)
	Msg(_I("Invoice No.") + " " + strx(nIdf) + " " + _I("already exist !!!???"))
	return .f.
endif

if iif(lEdit, RecLock(), AddRec())
	nTmp := mg_get(cWin, "fodb_c", "value")
	replace idf with nIdf                     // invoice idf
	replace cust_idf with aFullCust[nTmp][2]  // customer idf
	replace cust_n with mg_get(cWin, "fodb_c", "item", nTmp) // cust name
	replace date with mg_get(cWin, "datfak_d", "value" ) // invoice date
	replace date_sp with mg_get(cWin, "f_tOdb_d", "value" ) // splatnost
	replace uzp with mg_get(cWin, "f_uzp_d", "value" ) // uzkutecneni dan. plneni
	replace ndodpo with mg_get(cWin, "fpl_c", "value" ) // howto pay
	replace type with mg_get(cWin, "ftyp_c", "value" ) // nType
	replace objedn	with mg_get( cWin, "ord_t", "value" )  // order
	replace pred with mg_get( cWin, "btext_e", "value" ) // bottom text
endif

if !OpenStav(,2)
	return .f.
endif

// in case of edit invoice remove all old items
if lEdit  
	dbgotop()
	do while !eof()
		if idf == nIdf
			if Reclock()
				dbdelete()
				dbrunlock()
			endif
		endif
		dbskip()
	enddo
endif
nTmp := 0
for x:=1 to len(aItems)
	if addrec()
		replace idf with nIdf
		replace name with aItems[x][1]
		replace unit with aItems[x][2]
		replace price with aItems[x][3]
		replace quantity with aItems[x][4]
		replace tax with aItems[x][5]
		nTmp += aItems[x][7]
	endif
next
replace (cIAll)->zprice with nTmp 

if lEdit
	dbclosearea()
	select(cIAll)
else
	dbcloseall()
endif

mg_do(cWin, "release")

print_invoice(nIdf,,lEdit)

return .t.

static function getItems(nIdf)

local aItems := {}, cAl := select()
field name, unit, price, quantity, tax, idf

if !OpenStav(,3)
	return aItems
endif

if dbseek(nIdf)
	do while idf == nIdf
		aadd( aItems, { name, unit, price, quantity, tax, round((Price * Quantity),2), round((Price * quantity * (1+Tax/100)),2) })
		dbskip()
	enddo
endif

dbclosearea()
if !empty(cAl)
	select(cAl)
endif

return aItems

function GetUnit()

local aUnit := {}

aadd(aUnit, "Ks")
aadd(aUnit, "Hod")
aadd(aUnit, "km")
aadd(aUnit, "l")

return aUnit

function GetTax()

local aTax := {}

aadd(aTax, "21")
aadd(aTax, "16")
aadd(aTax, "0")

return aTax

static func GetNextFakt(nSt, dDat)

local nFakt := 0, cY
field type, idf
default nSt to 1
default dDat to date()
cY := right(dtoc(dDat),2)

if !OpenInv(,2) 
	return nFakt
endif

do case
	case nSt < 2
		dbgotop()
		if lastrec()==0
			return val(cY+"001")
		endif
		do while !eof()
			nFakt := idf
			if type == 2
				dbskip(-1)
				nFakt := idf
				EXIT
			ENDIF
			dbskip()
		ENDDO
		if empty(nFakt)
			nFakt := val(cY+"001")
		else
			nFakt++
		endif
	CASE nSt == 2
		dbgobottom()
		if type == 2
			nFakt := idf
			nFakt++
		else
			nFakt := val(cY+"500")
		endif
endcase
dbclosearea()

return nFakt

procedure print_invoice(nIdf, lPrev, lNC)

local cCAll, cIAll, aItems := {}, aTax := {}, lSuccess, nRow, x
local cFile, nTmp
local nFullPrice := 0, nFullPriceAndTax := 0
local nPrice, nPriceAndTax, cMail
local lTax := TaxStatus()

field idf, name, unit, quantity, price, tax, serial_no,back
field date, date_sp, uzp, objedn, email, pred

default nIdf to 0
default lPrev to .F.  // Show Preview window  (default external viewer)
default lNC to .F.    // No close invoice dbf (default close)

if empty(nIdf)
	return
endif

if !OpenInv(,3)
	return
endif

cIAll := alias()
cFile := mg_getTempFolder()+hb_ps()+"invoice_"+strx(nIdf)+"_"+charrem(":",time())+".pdf"

if !dbseek(nIdf)
	Msg(_I("Unable to Found Invoice No.")+ ": " + strx(nIdf))
	dbclosearea()
	return
endif

if !OpenStav(,2)
	select(cIAll)
	dbclosearea()
	return 
endif

if dbseek(nIdf)
	do while idf == nIdf
		if !Back
			aadd(aItems, {idf, name, unit, quantity, price, tax, serial_no})
		endif
		dbskip()
	enddo
else
	Msg(_I("Unable to found items for invoice No.") + ": " + strx( nIdf ))
	dbclosearea()
	select(cIAll)
	dbclosearea()
	return
endif

dbclosearea()
if !OpenSubscriber()
	Msg(_I("Unable to open customers database. Check instalation (create one ?!)"))
	dbclosearea()
	select(cIAll)
	dbclosearea()
	return
endif
if !dbseek((cIAll)->cust_idf)
	Msg(_I("Unable to found customer. Please Check customer database ?!"))	
	dbclosearea()
	select(cIAll)
	dbclosearea()
	return
endif 

cCAll := alias()
cMail := email

select(cIAll)

RESET PRINTER

// Removed after Carozo fix the printing area
SET PRINTER PAPERSIZE TO QPrinter_A4

if lPrev 
	//SELECT PRINTER TO DEFAULT
	SET PRINTER PREVIEW TO .T. 
else
	SELECT PRINTER TO PDF FILE (cFile)
endif

CREATE REPORT mR1

	CREATE STYLEFONT "Normal"
		FONTSIZE 12
      //FONTCOLOR {0,255,0}
      //FONTUNDERLINE .T.
		FONTBOLD .F.
      FONTNAME "mg_monospace"
	END STYLEFONT
	create stylefont "item"
		fontsize 10.5 
      //fontcolor {0,255,0}
      //fontunderline .t.
		fontbold .f.
      fontname "mg_monospace"
	end stylefont

	create stylefont "item_n"
		fontsize 10.5 
      //fontcolor {0,255,0}
      //fontunderline .t.
		FontItalic .t.
		//fontbold .f.
      fontname "mg_monospace"
	end stylefont

	CREATE STYLEFONT "Big"
		FONTSIZE 18
      //FONTCOLOR {0,255,0}
      //FONTUNDERLINE .T.
		FONTBOLD .T.
      FONTNAME "mg_monospace"
	END STYLEFONT
	CREATE STYLEPEN "pen_1"
      PENWIDTH 2
//    COLOR {0,0,255}
   END STYLEPEN

   SET STYLEFONT TO "Normal"
//	SET STYLEFONT TO 
	CREATE PAGEREPORT "Page_1"
		@ 0, 120 PRINT _I("INVOICE") + iif(lTax, " "+_I("The tax document"), "") FONTSIZE 16
		@ 8, 120 PRINT _I("No.") + ": " + strx( nIdf ) FONTSIZE 16 FONTBOLD .t.
		PRINT _I("Supplier")+ ":" 
			row 30 
			col 0
			FONTSIZE 12
		END PRINT
		PRINT _hGetValue( hIni["COMPANY"], "Name")
			row 42 
			col 6
			FONTBOLD .t. 
			FONTSIZE 14
		END PRINT
		PRINT _hGetValue( hIni["COMPANY"], "Address") + ", " + ;
				_hGetValue( hIni["COMPANY"], "PostCode") + " " + ;
				_hGetValue( hIni["COMPANY"], "City")
			row 48 
			col 6
			FONTSIZE 12
		END PRINT
		@ 54, 6 PRINT _hGetValue( hIni["COMPANY"], "Country")	FONTSIZE 12
		@ 60, 6 PRINT _I("Idf") + ": " + _hGetValue( hIni["COMPANY"], "IDF" ) FONTSIZE 12
		@ 66, 6 PRINT _I("VAT") + ": " + _hGetValue( hIni["COMPANY"], "VAT" ) FONTSIZE 12

		@ 72, 6 PRINT _I("Bank ID.") + ": " + iban2bank(_hGetValue( hIni["COMPANY"], "IBAN")) FONTSIZE 12 FONTBOLD .T.
		@ 78, 6 PRINT _I("IBAN") + ": " + _hGetValue( hIni["COMPANY"], "IBAN") fontsize 10 
		@ 84, 6 PRINT _I("Swift") + ": " + _hGetValue( hIni["COMPANY"], "Swift") fontsize 10

		@ 94, 6 PRINT _I("Invoice Date") + ": " + dtoc(date)	FONTSIZE 10
		@ 94, 80 PRINT _I("Due Date") + ": " + dtoc(date_sp)	FONTSIZE 10 FONTBOLD .t.
		if lTax
			@ 100, 6 PRINT _I("Date of chargeability") + ": " + dtoc(uzp)	FONTSIZE 10
		else
			@ 100, 6 PRINT _I("non-payer of vat") FONTSIZE 10
		endif
		
		if !empty( objedn)
			@ 100, 150 PRINT _I("Order") + ": " + objedn FONTSIZE 10
		endif
		nRow := 110
		@ nRow,   6 PRINT _I("Item") STYLEFONT "Item_n"
		@ nRow,  85 PRINT _I("Quantity") STYLEFONT "Item_n"
		@ nRow, 115 PRINT _I("Price") STYLEFONT "Item_n"
		if lTax
			@ nRow, 138 PRINT _I("Tax base") STYLEFONT "Item_n"
			@ nRow, 164 PRINT _I("Tax") STYLEFONT "Item_n"
		endif
		@ nRow, 175 PRINT _I("Total price") STYLEFONT "Item_n"
		nRow += 4 
		PRINT LINE
			ROW nRow
			COL 6
			TOROW nRow
			TOCOL 200
		END PRINT

		nRow += 3
		for x:=1 to len( aItems )
			if len( alltrim( aItems[x][2] ) ) > 34
				print aItems[x][2]
					row nRow
					col 6	
					torow nRow + 8
					tocol 80
					STYLEFONT "ITEM"
				end print
				nRow += 4
			else
				@ nRow, 6 PRINT aItems[x][2] STYLEFONT "ITEM"
			endif
			if lTax
				nPriceAndTax := round( aItems[x][5] * aItems[x][4] * (1+aItems[x][6]/100),2)
			else
				nPriceAndTax := round( aItems[x][5] * aItems[x][4], 2 ) //* (1+aItems[x][6]/100),2)
			endif
			nPrice := round( aItems[x][5] * aItems[x][4], 2)
			@ nRow, 80 PRINT str(aItems[x][4]) STYLEFONT "ITEM"
			@ nRow, 100 PRINT aItems[x][3] STYLEFONT "ITEM"
			@ nRow, 115 PRINT alltrim(transform(aItems[x][5], "9,999,999.99")) STYLEFONT "ITEM"
			if lTax
				@ nRow, 138 PRINT alltrim(transform(nPrice, "9,999,999.99"))STYLEFONT "ITEM"
				@ nRow, 164 PRINT str(aItems[x][6]) + "%" STYLEFONT "ITEM"
			endif
			@ nRow, 170 PRINT transform(nPriceAndTax, "999,999,999.99") STYLEFONT "ITEM"
			aaddTax(@aTax, aItems[x][6], nPrice)
			nFullPrice += nPrice
			nFullPriceAndTax += nPriceAndTax
			nRow += 4.8
		next
		nRow += 6 

		PRINT LINE
			ROW nRow
			COL 130
			TOROW nRow
			TOCOL 200
		END PRINT
		nRow += 2
		if !empty(pred)
			print pred
				row nRow
				col 6	
				torow nRow + 8
				tocol 80
				STYLEFONT "ITEM"
			end print
		endif

		@ nRow, 130 PRINT _I("Total price")+": " stylefont "ITEM"
		@ nRow, 170 PRINT transform(nFullPrice, "999,999,999.99") stylefont "ITEM"
		if lTax
			for x:=1 to len(aTax)
				nRow += 4.8
				@ nRow, 130 PRINT _I("Tax") + " " + str( aTax[x][1], 2) + "%:" stylefont "ITEM"
				@ nRow, 170 PRINT transform(aTax[x][2], "999,999,999.99") stylefont "ITEM"
			next
			nRow += 4.8
			@ nRow, 130 PRINT _I("Total price with Tax")+":" STYLEFONT "ITEM"
			@ nRow, 170 PRINT transform(nFullPriceAndTax, "999,999,999.99") STYLEFONT "ITEM"
		endif
		nRow += 4.8
		nTmp := round(nFullPriceAndTax, 0)  
	 	@ nRow, 130 PRINT _I("Approximated")+":" STYLEFONT "ITEM"
	 	@ nRow, 170 PRINT transform(nTmp - nFullPriceAndTax, "999,999,999.99") STYLEFONT "ITEM"

		nFullPriceAndTax := nTmp
		nRow += 6
		@ nRow, 130 PRINT _I("Total to pay")+":" FONTSIZE 10.5 FONTBOLD .t.
		@ nRow, 170 PRINT transform(nFullPriceAndTax, "999,999,999.99") + " " + _hGetValue( hIni["INVOICE"], "CURRENCY" ) STYLEFONT "ITEM" // FONTBOLD .T.

		nRow += 16

		if empty(_hGetValue( hIni["COMPANY"], "Sign" ))
			@ nRow, 80 PRINT _I( "Stamp and signature" ) + ": _________________________" 
		else
			@ nRow, 70 PRINT _I( "Stamp and signature" ) + ":" 
			CREATE PRINT IMAGE hIni["COMPANY"]["Sign"]
				row nRow - 10
				col 130
				torow nRow -10 + 45
				tocol 200
				stretch .t.
				//SCALED .t.
			END PRINT
		endif
		if !empty(_hGetValue( hIni["COMPANY"], "Logo"))
			CREATE PRINT IMAGE hIni["COMPANY"]["Logo"]
				row 0
				col 0
				torow mg_getimageheight( hIni["COMPANY"]["Logo"]) * 2 / 100
			   tocol mg_getimagewidth( hIni["COMPANY"]["Logo"]) * 2 /100
				if !empty(_hGetValue( hIni["COMPANY"], "LogoWidth"))
					torow val(hIni["COMPANY"]["LogoWidth"])
				else
					torow 16  // 16
				endif
				if !empty(_hGetValue( hIni["COMPANY"], "LogoHeight"))
					tocol val(hIni["COMPANY"]["LogoHeight"])
				else				
					tocol 46 // 32  // 55
				endif
				stretch .t.
			   //scaled .t.
			END PRINT
		endif
      PRINT RECTANGLE
         COORD { 100, 20, 210, 70 }
         COLOR {226,226,226}
         ROUNDED 3
			PENWIDTH 2
			FILLED .t.
      END PRINT
		@ 22, 104 PRINT _I("Customer")+ ":"
		if empty((cCAll)->fullname)
			@ 30, 106 PRINT (cCAll)->name FONTBOLD .t.
		else
			print (cCAll)->fullname
				row 30
				col 106	
				torow 48
				tocol 200
				FONTBOLD .t.
			end print
		endif
		@ 48, 106 PRINT (cCall)->address
		@ 53, 106 PRINT (cCAll)->POSTCODE + " " + (cCAll)->City
		@ 69, 106 PRINT (cCAll)->Country
		@ 62, 172 PRINT _I("IDF")+": "+(cCAll)->ICO FONTSIZE 10
		@ 66, 172 PRINT _I("VAT")+": "+(cCAll)->VAT FONTSIZE 10

		if !empty(_hGetValue( hIni["COMPANY"], "IBAN")) 
			CREATE PRINT BARCODE "SPD*1.0*ACC:"+hIni["COMPANY"]["IBAN"]+"*AM:"+strx(round(nFullPriceAndTax,2))+"*CC:CZK"+"*X-VS:"+strx(nIDF)+"*"
				row 72
				col 185
				type "QRcode"
				barwidth 2
			END PRINT
		endif
		if !empty(_hGetValue( hIni["COMPANY"], "TEXT")) 
			print hIni["COMPANY"]["TEXT"]
				row 284
				col 6
				torow 290
				tocol 200
				FONTSIZE 8
			end print
		endif 
		@ 292, 6 PRINT "Created with Fenix Open Source Project (http://fenix.msoft.cz)" FONTSIZE 6 FONTITALIC .t.
	END PAGEREPORT
END REPORT

select(cCAll)
dbclosearea()
select(cIAll)
if !lNC
	dbclosearea()
endif

exec Report mR1 RETO lSuccess

if lSuccess
	if lPrev
		OPEN FILE mg_GetPrinterName()
	else
//		hb_processRun("evince "+cFile,,,,.t.)
//		open file cFile
		if mg_getPlatform() == "windows"
			hb_processRun("start "+cFile,,,,.t.)
		else
			hb_processRun("xdg-open "+cFile,,,,.t.)
		endif
	endif
else
	Msg(_I("Problem occurs creating report"))
endif

destroy report mR1

if file(cFile)
	if !empty(cMail) 
		if  mg_msgyesno( _I("Send invoice to customer e-mail") + ": " + cMail )
		//if  mg_msgyesno( _I("Send invoice to customer e-mail ?" ) )
			sendmail(cMail, _I("Automatic invoice file sending"), _I("Invoice No.") + ": " + strx( nIdf ),  cFile )
		endif
	endif
	if !empty(_hGetValue( hIni["INVOICE"], "MAIL"))
		if mg_msgyesno( _I("Send Invoice to") + ": " + hIni["INVOICE"]["MAIL"] ) 
			sendmail(hIni["INVOICE"]["MAIL"], _I("Automatic invoice file sending"), _I("Invoice No.") + ": " + strx( nIdf ), cFile )
		endif
	endif
	deletefile(cFile)
endif

return

func aaddTAX(aDPH, nDPH, nCDPH) 
local n 
 
if nDPH <> 0 
   if (n := ascan(aDPH, {|aVal| aVal[1] == nDPH})) == 0 
      aadd(aDPH,{nDPH, round(nCDPH*(nDPH/100) , 2)}) 
   else 
      aDPH[n][2] := aDPH[n][2] + round(nCDPH*(nDPH/100),2)  
   endif 
endif 
 
return nil 

static function iban2bank( cIban )

local cTmp, cRet := ""

if empty( cIban )
	return cRet
endif

cTmp := strx( val( substr( cIban, 9 , 6 ) ) )

if !empty(cTmp) 
	if cTmp == "0"
		cTmp := ""
	else
		cTmp += "-"
	endif
endif

cRet := + cTmp + substr( cIban, 15 ) + "/" + substr( cIban, 5, 4 ) 

return cRet

procedure write_pay( cOldWin, cGrid )

local cWin := "pay_inv", dDat := date(), cVyp := ""

field date_pr, pr_vyp, idf

if empty(idf)
	return
endif

if !empty(date_pr) 
	dDat := date_pr
endif
if !empty(pr_vyp)
	cVyp := pr_vyp
endif

create window (cWin)
	row 0
	col 0
	width 800
	height 400
	CHILD .t.
	MODAL .t.
	caption _I("Date of payment")
	CreateControl(20, 20, cWin, "payd", _I("Date of payment"), dDat )
	CreateControl(70, 20, cWin, "vypis", _I("Bank statement"), cVyp )
	CreateControl(240, 610, cWin, "Save",, {|| save_pay( cWin, cOldWin, cGrid )})
	CreateControl(320, 610, cWin, "Back")
end window

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

return

static procedure save_pay( cWin, cOldWin, cGrid )

field date_pr, pr_vyp

if RecLock()
	replace date_pr with mg_get( cWin, "payd_d", "value" )
	replace pr_vyp  with mg_get( cWin, "vypis_t", "value" )
	dbrunlock()
	mg_do(cOldWin, cGrid, "refresh")
	mg_do(cWin, "release")
endif

return

