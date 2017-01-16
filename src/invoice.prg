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

procedure browse_invoice( dDat )

local cWin := "inv_win" 
local cAll
local aCust := read_customer(, .T.), cSubs
// local cName

field customer
default ddat to date()

//cName := mg_get( "main_win", "MM", "ITEMNAME" )
// mg_log( cName )

if !OpenSubscriber(, 3)
	return
endif
cSubs := alias()
if !OpenInv(dDat,2)
	return
endif
// aDbf := getfiles(cPath+"inv*.dbf")
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
		BACKCOLORDYNAMIC { | nRow, nCol | COLOR_BACK(nRow, nCol, cWin, "invoice_b") }	
		workarea cAll
		value 1
		//AUTOSIZE .t.
		rowheightall 24
		FONTSIZE 16
		ONDBLCLICK print_invoice(mg_get(cWin, "invoice_b", "cell", mg_get(cWin,"invoice_b","value"), 1),,.t., dDat)
		ONENTER write_pay( cWin, "invoice_b" )
	END BROWSE
	create button print_b
		row 110
		col 840
		width 160
		height 60
		caption _I("&Print invoice")
		ONCLICK print_invoice(mg_get(cWin, "invoice_b", "cell", mg_get(cWin,"invoice_b","value"), 1),,.t.,dDat)
		tooltip _I("Print invoice" )
	end button
	create button edit_b
		row 190
		col 840
		width 160
		height 60
		caption _I("&Change invoice")
		ONCLICK new_invoice(.T.)
		tooltip _I("Change invoice" )
	end button
	create button cachd_b
		row 270
		col 840
		width 160
		height 60
		caption _I("C&aching date")
		ONCLICK write_pay( cWin, "invoice_b" )
		tooltip _I("Caching date")
	end button
	create button Del
		row 350
		col 840
		width 160
		height 60
		caption _I("&Delete Invoice")
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
		caption _I("Cance&l Invoice")
		ONCLICK cancel_inv()
		tooltip _I("Cancel Invoice")
//    picture cRPath+"task-reject.png"
	end button
	create button Back
		row 510
		col 840
		width 160
		height 60
		caption _I("&Back")
		ONCLICK mg_do(cWin, "release")
		tooltip _I("Close and go back")
		picture cRPath+"task-reject.png"
	end button
END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

dbcloseall()

return

function COLOR_BACK(nRow, nCol, cWin, cBrw) 

local cRet, nRecOld := recNo()
local lDisSyncOld := mg_set( cWin, cBrw, "disableSync", .t.)

field storno, date_pr

HB_SYMBOL_UNUSED( nCol )
dbgoto( mg_get( cWin, cBrw, "recNo", nRow ) )
do case 
	case storno
		// cRet := {74,164,72}
		cRet := {255, 0, 0} // red
	case empty(date_pr)
		cRet := {237,236,173}
	case !empty(date_pr)
		cRet := {0,255,0}
	otherwise
		cRet := NIL
endcase
dbgoto( nRecOld )
mg_set( cWin, cBrw, "disableSync", lDisSyncOld )

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
bSave := { || save_invoice( cWin, aFullCust, lEdit, dDate ) }

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
	nPay := ndodpo
	aItems := GetItems(nIdf, dDate)
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

	item_def( cWin, @aItems, lTax, .F., 230, 10 )

	create timer fill_it
		interval	1000
		action show_price( cWin, aItems, lTax )
		enabled .t.
	end timer

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


procedure Item_def( cWin, aItems, lTax, lVisible, nRowPos, nColPos )

local nRow := 10, nCol := 10
default lVisible to .T.
default nRowPos to 0  // 230
default nColPos to 0  // 10

	create Button add_i_b
		row nRow +  nRowPos + 10 // 250
		col 820 + nCol + nColPos // 840
		autosize .t.
		caption _I("Select item")
		onclick Get_STO_Item(@aItems, cWin)
		visible lVisible
	end button
	create Button add_ic_b
		row nRow +  nRowPos + 60 // 0300
		col 820 + nCol + nColPos
		autosize .t.
		caption _I("new item")
		onclick add_Item(@aItems, cWin)
		visible lVisible
	end button
	create button edit_i_b
		row nRow +  nRowPos + 110 // 350
		col 820 + nCol + nColPos
		autosize .t.
		caption _I("edit item")
		onclick add_item(@aItems, cWin, .t.)
		visible lVisible

	end button
	create button del_i_b
		row  nRow +  nRowPos + 160 // 400
		col 820 + nCol + nColPos
		autosize .t.
		caption _I("delete item")
		onclick del_item(cWin, "items_g")
		visible lVisible
	end button
	create grid items_g
		row  nRow + nRowPos //  240
		col nCol + nColPos  // 20
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
	   ondblclick add_item(@aItems, cWin, .T.)
		navigateby "row"
		visible lVisible
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
	create label ccena
		row  nRow + nRowPos + 222
		col nCol + nColPos + 350 
		value ""
		width 520
		height 24
		FONTSIZE 12
		FONTITALIC .t.
	end label
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
		nType := mg_get(cWin, "ftyp_c", "value" )  // Invoice type
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
function del_item( cWin, cGrid )

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
	Msg(_I("Invoice already canceled!"))
	return
endif

if msgask(_I("Do you want to cancel invoice No.") + " " + strx(idf)) + "?"
	if reclock()
		replace storno with .t.
		dbrunlock()
		Msg(_I("Invoice successfuly canceled"))
	endif
endif

return

static procedure del_inv( cWin, cAll )

local nIdf, dDate

field idf

default cAll to alias()
if lastrec() == 0 .or. empty(idf)
	return
endif
nIdf := (cAll)->idf
dDate := (cAll)->date
if msgask(_I("Do you really want to delete invoice No.") + " " + strx(nidf)) + "?"
	if (cAll)->(RecLock())
		(cAll)->(dbdelete())
		(cAll)->(dbrunlock())
		if OpenStav( dDate, 2 )
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
		Msg(_I("Invoice succesfuly removed from database!"))
	endif
endif

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
   nTax := aScan( aTax, { |y| alltrim(y) = strx(aItems[x][5]) } )
endif

create window (cWin)
	row 0
	col 0
	width 800
	height 400
	CHILD .t.
	MODAL .t.
	CreateControl(20, 20, cWin, "Itemd", _I("Item Description"), cItemD)
	CreateControl(70, 20, cWin, "Itemq", _I("Quantity"), nNo)
	CreateControl(70, 320, cWin, "Itemu", _I("Item unit"), aUnit)
	if lEdit
		mg_set( cWin, "itemu_c", "value", nUnit )
		caption _I("Edit item")
	else
		caption _I("New item")
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
	CreateControl(240, 610, cWin, "Save",, {|| fill_item(@aItems, cWin, cPWin, aTax, lTax, x)})
	CreateControl(320, 610, cWin, "Back")
	mg_set(cWin, "Itemd_t", "width", 400)
	create timer fill_it
		interval	1000
		action fill_it( cWin, aTax, lTax, .f. )
		enabled .t.
	end timer
end window

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

return

static function save_invoice( cWin, aFullCust, lEdit )

local aItems := mg_get(cWin, "items_g", "items")
local nIdf, x, cIAll, nTmp, aData := {}, cUUID, cFik, aVat
local aTax := GetTax()
local dDate := mg_get(cWin, "datfak_d", "value" ) 

field idf, zprice, pred, uuid, ndodpo

default lEdit to .f.

if !OpenInv(dDate,2) 
	return .f.
endif
cIAll := alias()
select(cIAll)

nIdf := mg_get( cWin, "inv_no_t", "value" )
if empty(nIdf)
	Msg(_I("Empty invoice identification!"))
	return .f.
endif
if !lEdit .and. dbseek(nIdf)
	Msg(_I("Invoice No.") + " " + strx(nIdf) + " " + _I("already exists!"))
	return .f.
endif

cUUID := GetUUID()
 
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
	replace uuid with cUUID                         // UUID
	replace time with time()
endif

if !OpenStav(dDate,2)
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

aadd( aData, { strx( nTmp ), "celk_trzba" })
aadd( aData, { cUUID, "uuid_zpravy" })
aadd( aData, { iif( lEdit, "false", "true"), "prvni_zaslani" })
aadd( aData, { "0", "rezim" }) // bezny:0 - zjednoduseny:1

//aadd( aData, { "POKLADNA_01", "id_pokl" }) // TODO
//aadd( aData, { "1", "id_provoz" })         // TODO
aadd( aData, { _hGetValue( hIni["EET"], "id_pokl" ), "id_pokl", "pos_id"  } ) // nazev pokladny idf pokladny
aadd( aData, { _hGetValue( hIni["EET"], "id_provoz"), "id_provoz", "ws_id" } ) //identifikace provozovny

aadd( aData, { strx(nIdf), "porad_cis"})
aadd( aData, { _hGetValue( hIni["COMPANY"], "VAT" ) , "dic_popl" } ) 

aadd( aData, { _hGetValue( hIni["EET"], "TestMode" ), "overeni", "over" })
aadd( aData, { xmlDate((cIALL)->Date, (cIAll)->time), "dat_trzby" })
aadd( aData, { xmlDate(date(), time()), "dat_odesl" })

aVat := calc_vat( aItems, aTax)
if !empty(aVat[1][1])
	aadd(aData, { alltrim(str(aVat[1][1],10,2)), "zakl_dan1", "dphz" } ) 
	aadd(aData, { strx(aVat[1][2]), "dan1", "dph" } ) // DPH
endif
if !empty(aVat[2][1])
	aadd(aData, { alltrim(str(aVat[2][1],10,2)), "zakl_dan2", "dphz" } )
	aadd(aData, { strx(aVat[2][2]), "dan2", "dph" } ) // DPH
endif
if !empty(aVat[3][1])
	aadd(aData, { alltrim(str(aVat[3][1],10,2)), "zakl_dan3", "dphz" } )
	aadd(aData, { strx(aVat[3][2]), "dan3", "dph" } ) // DPH
endif
// mg_log(aData)
if (cIAll)->ndodpo == 2 // if payment in cache 
	cFik := eet(aData)
	replace (cIAll)->fik with cFik
endif

if lEdit
	dbclosearea()
	select(cIAll)
else
	dbcloseall()
endif

mg_do(cWin, "release")

print_invoice( nIdf,, lEdit, dDate )

return .t.

function GetUUID()

local cUUID

hb_ProcessRun( "uuid",, @cUUID)

return alltrim(charrem(chr(10)+chr(13), cUUID))

/*
	Get items for invoice no. nIdf
*/

function getItems(nIdf, dDate, lPos)

local aItems := {}, cAl := select()
field name, unit, price, quantity, tax, idf, ean

default lPos to .f.

if lPos
	if !OpenPOSStav(dDate,3)
		return aItems
	endif
else
	if !OpenStav(dDate,3)
		return aItems
	endif
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

/*
	Calculate next invoice number
*/

static func GetNextFakt(nSt, dDat)

local nFakt := 0, cY
field type, idf
default nSt to 1
default dDat to date()
cY := right(dtoc(dDat),2)

if !OpenInv(dDat) 
	return nFakt
endif

do case
	case nSt < 2
		dbgotop()
		if lastrec()==0
			dbclosearea()
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

/*
	Print Invoice
*/
procedure print_invoice(nIdf, lPrev, lNC, dDat)

local cCAll, cIAll, aItems := {}, aTax := {}, lSuccess, nRow, x
local cFile, nTmp
local nFullPrice := 0, nFullPriceAndTax := 0
local nPrice, nPriceAndTax, cMail, lMail
local lTax := TaxStatus(), aPl := {}

field idf, name, unit, quantity, price, tax, serial_no,back, fik, time
field date, date_sp, uzp, objedn, email, pred, ndodpo, date_pr, storno

default nIdf to 0
default lPrev to .F.  // Show Preview window  (default external viewer)
default lNC to .F.    // No close invoice dbf (default close)
default dDat to date()
if empty(nIdf)
	return
endif

if !OpenInv(dDat,3)
	return
endif

aadd(aPl, _I("Payment on account"))
aadd(aPl, _I("in cash"))

cIAll := alias()
cFile := mg_getTempFolder()+hb_ps()+"invoice_"+strx(nIdf)+"_"+charrem(":",time())+".pdf"

if !dbseek(nIdf)
	if !lNC
		dbclosearea()
	endif
	Msg(_I("Unable to find invoice No.")+ ": " + strx(nIdf))
	return
endif

lMail := empty(date_pr)

if !OpenStav(dDat,2)
	select(cIAll)
	if !lNC
		dbclosearea()
	endif
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
	dbclosearea()
	select(cIAll)
	if !lNC
		dbclosearea()
	endif
	Msg(_I("Unable to find items for invoice No.") + ": " + strx( nIdf ))
	return
endif

dbclosearea()
if !OpenSubscriber()
	//dbclosearea()
	select(cIAll)
	if !lNC
		dbclosearea()
	endif
	Msg(_I("Unable to open customers database. Check instalation or create one"))
	return
endif
if !dbseek((cIAll)->cust_idf)
	dbclosearea()
	select(cIAll)
	if !lNC
		dbclosearea()
	endif
	Msg(_I("Unable to find customer. Please check customer database"))	
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
	//mg_log( "Set printer file to " + cFile )
endif

CREATE REPORT mR1

	CREATE STYLEFONT "Normal"
		FONTSIZE 12
		FONTBOLD .F.
      FONTNAME "mg_monospace"
	END STYLEFONT
	create stylefont "item"
		fontsize 10.5 
		fontbold .f.
      fontname "mg_monospace"
	end stylefont

	create stylefont "item_n"
		fontsize 10.5 
		FontItalic .t.
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
   END STYLEPEN

   SET STYLEFONT TO "Normal"
	CREATE PAGEREPORT "Page_1"
		@ 0, 120 PRINT _I("INVOICE") + iif(lTax, " - " + _I("The tax document"), "") FONTSIZE 16
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
		@ 84, 6 PRINT "Swift" + ": " + _hGetValue( hIni["COMPANY"], "Swift") fontsize 10

		@ 94, 6 PRINT _I("Invoice Date") + ": " + dtoc(date) + " "  + time  FONTSIZE 10
		if !empty(nDodPo)
			@ 94, 148 PRINT alltrim(_I("Method of payment")) + ": " + _I(aPl[ndodpo]) FONTSIZE 9
		endif
		@ 94, 86 PRINT _I("Due Date") + ": " + dtoc(date_sp)	FONTSIZE 10 FONTBOLD .t.
		if !empty( objedn)
			@ 100, 150 PRINT _I("Order") + ": " + objedn FONTSIZE 10
		endif

		if lTax
			@ 100, 6 PRINT _I("Date of chargeability") + ": " + dtoc(uzp)	FONTSIZE 10 FONTBOLD .T.
		else
			@ 100, 6 PRINT _I("non-payer of vat") FONTSIZE 10
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
					//FONTSIZE 8
					STYLEFONT "ITEM"
				end print
				nRow += 4.8
			else
				@ nRow, 6 PRINT alltrim(aItems[x][2]) STYLEFONT "ITEM"
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
			//nRow += 6.8
		
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
			@ nRow, 130 PRINT _I("Total price with tax")+":" STYLEFONT "ITEM"
			@ nRow, 170 PRINT transform(nFullPriceAndTax, "999,999,999.99") STYLEFONT "ITEM"
		endif
		nRow += 4.8
		nTmp := round(nFullPriceAndTax, 0)  
	 	@ nRow, 130 PRINT _I("Approximated")+":" STYLEFONT "ITEM"
	 	@ nRow, 170 PRINT transform(nTmp - nFullPriceAndTax, "999,999,999.99") STYLEFONT "ITEM"

		nFullPriceAndTax := nTmp
		nRow += 6
		@ nRow, 130 PRINT _I("Total payment amount")+":" FONTSIZE 10.5 FONTBOLD .t.
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
		@ 62, 106 PRINT (cCAll)->Country
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
		// Print financial Identification Number if exist
		if !empty((cIAll)->fik)  
			@ 72, 106 PRINT "FIK" + ": " + (cIAll)->fik FONTSIZE 6
		endif
		@ 292, 6 PRINT "Created with Fenix Open Source Project (http://fenix.msoft.cz)" FONTSIZE 6 FONTITALIC .t.
		if storno
			@ 240, 6 PRINT _I("STORNO") FONTSIZE 32 FONTBOLD .t.
		endif			
	END PAGEREPORT
END REPORT

exec Report mR1 RETO lSuccess

select(cCAll)
dbclosearea()

select(cIAll)
if !lNC
	dbclosearea()
endif

if lSuccess
	if lPrev
		OPEN FILE mg_GetPrinterName()
	else
		//	hb_processRun("atril "+cFile,,,,.t.)
		// hb_processRun("evince "+cFile,,,,.t.)
		// hb_processRun("xdg-open "+cFile,,,,.t.)
		// open file cFile
		if file( cFile )
			if mg_getPlatform() == "windows"
				hb_processRun("start "+cFile,,,,.t.)
			else
				//mg_log( " Sem " )
				hb_processRun("atril "+ cFile, , , ,.t.)
				//hb_processRun("xdg-open "+cFile,,,,.t.)
			endif
		else
			Msg(_I("Problem occurred while creating report. Unable to found file:"+ cFile ))
		endif

	endif
else
	Msg(_I("Problem occurred while creating report"))
endif

destroy report mR1

if file(cFile) .and. lMail
	if !empty(cMail) 
		if  mg_msgyesno( _I("Send invoice to customer's e-mail") + ": " + cMail )
		//if  mg_msgyesno( _I("Send invoice to customer e-mail ?" ) )
			sendmail(cMail, _I("Automatic invoice file sending") + " " + _hGetValue( hIni["COMPANY"], "Name" ), _I("Invoice No.") + ": " + strx( nIdf ),  cFile )
		endif
	endif
	if !empty(_hGetValue( hIni["INVOICE"], "MAIL"))
		if mg_msgyesno( _I("Send Invoice to") + ": " + hIni["INVOICE"]["MAIL"] ) 
			sendmail(hIni["INVOICE"]["MAIL"], _I("Automatic invoice file sending") + " " + _hGetValue( hIni["COMPANY"], "Name" ), _I("Invoice No.") + ": " + strx( nIdf ), cFile )
		endif
	endif
   deletefile(cFile)
endif
//destroy report mR1

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
	caption _I("Payment date")
	CreateControl(20, 20, cWin, "payd", _I("Payment date"), dDat )
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

procedure unpaid( dDat, nVer )

field date_pr, zprice, idf, cust_n, date, date_sp, storno

local nSuma:=0, aInv := {}, nRow:=30, x, lSuccess
local nPage := 1
local lExit := .f., y := 1, nLine := 0
default dDat to date()
default nVer to 0

if !OpenInv(dDat, 3)
	return
endif

do case
	case nVer == 0     // unpaid invoices
		Do while !EOF()
			if empty( date_pr ) .and. !storno
				aadd( aInv, { idf, cust_n, date, date_sp, zprice})
				nSuma+=zprice
			ENDIF
			dbskip()
		ENDDO
	case nVer == 1   // all invoices
		Do while !EOF()
			if !storno
				aadd( aInv, { idf, cust_n, date, date_sp, zprice})
				nSuma+=zprice
			ENDIF
			dbskip()
		ENDDO
	case nVer == 2   // select customer invoices
		
		Do while !EOF()
			if !storno
				aadd( aInv, { idf, cust_n, date, date_sp, zprice})
				nSuma+=zprice
			ENDIF
			dbskip()
		ENDDO
endcase

reset printer

set printer papersize to QPrinter_A4
set printer preview to .t.

create report unpaid
	create stylefont "Normal"
   	Fontsize 12 
   	// FontItalic .t.
		FONTBOLD .f.
   	//Fontname "mg_monospace"
	end stylefont

	create stylefont "Item_n"
   	Fontsize 12 
   	// FontItalic .t.
		FONTBOLD .f.
   	Fontname "mg_monospace"
	end stylefont
	
	create stylefont "item"
		fontsize 10.5 
		fontbold .t.
      fontname "mg_monospace"	
	end stylefont
	set stylefont TO "Normal"
	do while .t.
	create pagereport "Page_" + strx(nPage)
		PrintLogo()
		do case
			case nVer == 0	
				@ 10, 80 print _I("Unpaid invoices for year") + " " + strx(year(dDat))  Fontsize 16 fontbold .t.
			case nVer == 1	
				@ 10, 80 print _I("Invoices for year") + " " + strx(year(dDat)) Fontsize 16 fontbold .t.
			case nVer == 2
				@ 10, 80 print _I("Invoices for customer") + " "+ _I("for year") + " " + strx(year(dDat)) Fontsize 16 fontbold .t.
		endcase
		@ nRow, 10 PRINT _I("Invoice no.")
		@ nRow, 40 PRINT _I("Customer")
		@ nRow, 95 PRINT _I("Issued")
		@ nRow, 120 PRINT _I("Due date")
		@ nRow, 170 PRINT _I("Price") //stylefont "item"
		nRow +=9
		
		PRINT LINE
			ROW nRow
			COL 10
			TOROW nRow
			TOCOL 190
		END PRINT
		nRow +=3
		for x := y to len(aInv)
			@ nRow, 0 PRINT str(aInv[x][1]) 
			@ nRow, 40 PRINT aInv[x][2]
			@ nRow, 95 PRINT dtoc(aInv[x][3]) + "      " + dtoc(aInv[x][4]) 
			@ nRow, 160 PRINT str(aInv[x][5]) stylefont "Item_n"
			nRow += 6
			y++
			nLine ++ 
			if nLine == 42
				nLine := 0
				nPage++
				lExit := .t.
				exit
			endif
		next
		if lExit
			nRow := 30
			lExit := .f.
			loop
		endif
		nRow +=3
		PRINT LINE
			ROW nRow
			COL 10
			TOROW nRow
			TOCOL 190
		END PRINT
		nRow += 3
			do case 
				case nVer == 0
					@ nRow, 10 PRINT _I("Total number of unpaid invoices: ") + strx(len(aInv))
				case nVer == 1
					@ nRow, 10 PRINT _I("Total number of invoices: ") + strx(len(aInv))
				case nVer == 2
					@ nRow, 10 PRINT _I("Total number of invoices: ") + strx(len(aInv))
			endcase
			@ nRow, 150 Print _I("Total")+":"
			@ nRow, 169 PRINT strx(nSuma)
			exit
		enddo
	end pagereport
end report

dbcloseall()

exec report unpaid reto lSuccess
if !lSuccess
	Msg(_I("Problem occurred creating report"))
endif

destroy report unpaid

return

function xmlDate(dDate, cTime, cZone)

local cRet
default cTime to time()
default cZone to "+01:00"
set date format to "yyyy-mm-dd"
if empty(dDate)
	cRet := ""
else
	cRet := dtoc(dDate)
endif	
if !empty(cTime)
	cRet += "T"+alltrim(cTime)
endif
cRet += cZone
set date german
return cRet

function Datexml(cStr)

local cTmp, dRet
set date format to "yyyy-mm-dd"

cTmp := substr(cStr, 1, 10)
dRet := ctod(cTmp)
set date german

return dRet

function Timexml(cStr)

local cTmp

cTmp := substr( cStr, 12, 8 )

return cTmp

procedure writelog(cLog, cLog1, cUUID)

local cAll := alias()
default cLog1 to ""
default cUUID to ""

if OpenLog()
	if addrec()
		replace date with date()
		replace time with time()
		replace op with GetUserName()
		replace log with cLog
		replace log1 with cLog1
		replace uuid with cUUID
	endif
	dbclosearea()
endif
	
if !empty(cAll)
	select( cAll )
endif

return

function GetUserName()

return "Operator"

procedure auto_invoice()

local cWin := "auto_in"

CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("Browse invoice definition")
	CHILD .T.
	MODAL .t.
	//TOPMOST .t.
	FONTSIZE 16
	//my_mg_browse(cWin, alias(), aOptions ) 
	//	my_mg_browse(cWin, alias(), aOptions, bOnClick)
	// aData := aSort(aData,,, {|x, y| x[2] > y[2]})
	// my_grid(cWin, aData, aOptions, bOnClick,,,"el_zad_br")

/*
	create Browse invoice_b
		row 10
		col 10
		width 800
		height 564 		
		COLUMNFIELDALL {cAll+"->idf", cAll+"->Date", cAll+"->cust_n", cAll+"->date_sp", cAll+"->date_pr", cAll+"->zprice" }
		COLUMNHEADERALL {_I("Invoice No."), _I("Date"), _I("Customer") , _I("Due Date"), _I("Caching date"), _I("Total price") }
		COLUMNWIDTHALL { 130, 90, 200, 130, 120, 130 }
		COLUMNALIGNALL { Qt_AlignRight, Qt_AlignCenter, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignCenter, Qt_AlignLeft }
		BACKCOLORDYNAMIC { | nRow, nCol | COLOR_BACK(nRow, nCol, cWin, "invoice_b") }	
		workarea cAll
		value 1
		//AUTOSIZE .t.
		rowheightall 24
		FONTSIZE 16
//		ONDBLCLICK print_invoice(mg_get(cWin, "invoice_b", "cell", mg_get(cWin,"invoice_b","value"), 1),,.t., dDat)
		ONENTER write_pay( cWin, "invoice_b" )
	END BROWSE
*/
	create button new_b
		row 190
		col 840
		width 160
		height 60
		caption _I( "&New definition" )
		ONCLICK invoice_def( cWin, "invoice_b" )
		tooltip _I( "Change invoice definition" )
	end button
	create button edit_b
		row 270
		col 840
		width 160
		height 60
		caption _I("&Change definition")
		ONCLICK invoice_def( cWin, "invoice_b", .t. )
		tooltip _I("Change invoice definition")
	end button
	create button Del
		row 350
		col 840
		width 160
		height 60
		caption _I( "&Delete definition" )
//		backcolor {0,255,0}
//	ONCLICK del_inv( cWin, cAll )
		tooltip _I( "Delete Invoice definition" )
//    picture cRPath+"task-reject.png"
	end button
	create button gen
		row 430
		col 840
		width 160
		height 60
		caption _I("Generate Invoice")
//    ONCLICK cancel_inv()
		tooltip _I("Generate invoice from definition now")
//    picture cRPath+"task-reject.png"
	end button
	create button Back
		row 510
		col 840
		width 160
		height 60
		caption _I("&Back")
		ONCLICK mg_do(cWin, "release")
		tooltip _I("Close and go back")
		picture cRPath+"task-reject.png"
	end button
END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

dbcloseall()

return

static procedure invoice_def( cParWin, bInvoice, lEdit )

local cWin := "inv_def", aCust := {}, cTxt := ""
local aInvType := {}, aPl := {}, aItems := {} // {"","","","","","","",""}
local aFullCust := {}, x, cOrder := ""
local bSave
local dDate := date(), dDate_sp := date()+10, dDate_uzp := date(), nType 
local nCust, nPay, lTax := TaxStatus()

field idf, date, date_sp, uzp, type, objedn, cust_idf, cust_n, ndodpo, Pred

default lEdit to .f.
HB_SYMBOL_UNUSED( cParwin )
HB_SYMBOL_UNUSED( bInvoice )

aadd(aInvtype, _I("Normal"))
aadd(aInvType, _I("Proforma"))

aadd(aPl, _I("Payment on account"))
aadd(aPl, _I("in cash"))

//hb_threadstart( HB_THREAD_INHERIT_PUBLIC, @read_customer(), @aCust)
aFullCust := read_customer(, .T.)
bSave := { || save_invoice_def( cWin, aFullCust, lEdit, dDate ) }

if empty(aFullCust) .or. len(aFullCust) == 1
	msg(_I("Customer database empty. Please define custumers before make invoice"))
	return
endif
for x:=1 to len(aFullcust)
	aadd(aCust, aFullCust[x][1])
next

if lEdit
	//nIdf := idf
	//if empty(nIdf)
	//	return
	//endif
	dDate := date
	dDate_sp := date_sp
	dDate_uzp := uzp
	nType	 := Type
	cOrder := objedn
	nPay := ndodpo
//	aItems := GetItems(nIdf, dDate)
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
//	CreateControl(200, 20, cWin, "Inv_No",	_I("Invoice No."), nIdf, .T.)
	CreateControl(510, 650, cWin, "Save",,bSave)
	CreateControl(510, 840, cWin, "Back")
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

	item_def( cWin, @aItems, lTax, .F., 230, 10 )

/*
	create timer fill_it
		interval	1000
		action show_price( cWin, aItems, lTax )
		enabled .t.
	end timer

	Create timer wach_grid
		interval 500
		action watch_grid(cWin, "items_g")
		enabled .t.
	end timer
*/

END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

if !lEdit
	dbcloseall()
endif

return

static procedure save_invoice_def()

return

