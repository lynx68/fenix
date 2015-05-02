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

memvar cRPath, cPath

procedure browse_invoice()

local cWin := "inv_win"
local aOptions := {}, cAll
// local bOnclick := print_invoice(nIdf)

local aCust := read_customer(, .T.), cSubs
field customer

if !OpenSubscriber(, 3)
	return
endif
cSubs := alias()
if !OpenInv()
	return
endif

cAll := alias()
set relation to (cAll)->cust_idf into (cSubs)
dbgotop()

aadd(aOptions, {cAll+"->idf", cAll+"->Date", cAll+"->Cust_n", cAll+"->date_sp", cAll+"->zprice" })
aadd(aOptions, {"Invoice no.", "Date", "Customer" , "Date sp.", "Price summ" })
aadd(aOptions, { 90, 100, 100, 120, 120 })
aadd(aOptions, { Qt_AlignRight, Qt_AlignCenter, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignLeft })
aadd(aOptions, {10,10, 800, 564}) 

if empty(aCust)
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
		COLUMNFIELDALL {cAll+"->idf", cAll+"->Date", cAll+"->cust_n", cAll+"->date_sp", cAll+"->zprice" }
		COLUMNHEADERALL {_I("Invoice no."), _I("Date"), _I("Customer") , "Date sp.", "Price summ" }
		COLUMNWIDTHALL { 90, 100, 200, 120, 120 }
		COLUMNALIGNALL { Qt_AlignRight, Qt_AlignCenter, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignLeft }
		workarea alias()
		value 1
		//AUTOSIZE .t.
		rowheightall 24
		FONTSIZE 18
		ONENTER print_invoice(mg_get(cWin, "invoice_b", "cell", mg_get(cWin,"invoice_b","value"), 1))
		ONDBLCLICK print_invoice(mg_get(cWin, "invoice_b", "cell", mg_get(cWin,"invoice_b","value"), 1))

	END BROWSE
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

dbclosearea()

return

procedure new_invoice()

local cWin := "add_inv", aCust := {}
local aInvType := {}, aPl := {}, aItems := {} // {"","","","","","","",""}

local aFullCust := {}, x
local bSave := { || save_invoice( cWin, aFullCust ) }

aadd(aInvtype, _I("Normal"))
aadd(aInvType, _I("Zalohova"))

aadd(aPl, _I("Platba na ucet"))
aadd(aPl, _I("v hotovosti   "))

//hb_threadstart( HB_THREAD_INHERIT_PUBLIC, @read_customer(), @aCust)
aFullCust := read_customer(, .T.)

//mg_log(aCust)
if empty(aFullCust) .or. len(aFullCust) == 1
	msg(_I("Customer database empty. Please define custumers before make invoice"))
	return
endif
for x:=1 to len(aFullcust)
	aadd(aCust, aFullCust[x][1])
next

CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("New Invoice")
	CHILD .T.
	MODAL .t.
	// TOPMOST .t.
	CreateControl(20,	20,  cWin, "datfak", _I("Date"), date() )
	CreateControl(20,	260, cWin, "f_tOdb", _I("Splatnost"), date()+10 )
	CreateControl(20,	500, cWin, "f_uzp", _I("Datum UZP "), date() )
	CreateControl(80,	20, cWin, "ftyp", _I("Typ faktury"), aInvType )
	CreateControl(80,	550, cWin, "fpl", _I("Zpusob placeni"), aPl)
	CreateControl(140, 20,  cWin, "fOdb", _I("Customer"), aCust )
	CreateControl(510, 650, cWin, "Save",,bSave)
	CreateControl(510, 840, cWin, "Back")
	create Button add_i_b
		row 250
		col 840
		autosize .t.
		caption _I("Item from catalogue")
//		onclick add_item(@aItems, cWin)
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
	create Button del_i_b
		row 350
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
		columnheaderall { _I("Description"), _I("unit"), _I("Unit cost"), _I("Quantity"), _I("Tax"), _I("Total"), _I("Total with tax")}
		columnwidthall { 400, 40, 120, 100, 60, 120, 120 }
	// ondblclick Edit_item()
		navigateby "row"
		visible .f.
		Items aItems
		tooltip _I("Invoice Items")
		CREATE Context Menu cBrMn
			CREATE ITEM _I("New Item")
				ONCLICK add_item(@aItems, cWin)
			END ITEM
			CREATE ITEM _I("Delete Item")
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

return

//
// show / hide controls depending of input
//
static procedure watch_grid(cWin, cGrid)

local aItems := mg_get(cWin, cGrid, "items")
local nCustomer := mg_get(cWin, "fodb_c", "value")
if empty(aItems)
	mg_set(cWin, "save", "visible", .f.)
else
	mg_set(cWin, "save", "visible", .t.)
endif
if nCustomer > 1
	mg_set(cWin, cGrid, "visible", .t.)
	mg_set(cWin, "add_i_b", "visible", .t.)
	mg_set(cWin, "add_ic_b", "visible", .t.)
	mg_set(cWin, "del_i_b", "visible", .t.)
else
	mg_set(cWin, cGrid, "visible", .f.)
	mg_set(cWin, "add_i_b", "visible", .f.)
	mg_set(cWin, "add_ic_b", "visible", .f.)
	mg_set(cWin, "del_i_b", "visible", .f.)
endif

return

static function del_item(cWin, cGrid)

local x:= mg_get(cWin,cGrid,"value")

if x <> 0
	mg_do(cWin, cGrid, "deleteitem", x)
	mg_do(cWin, cGrid, "refresh")
endif

Return NIL

procedure CreateControl(nRow, nCol, cWin, cKontrol, cName, xValue )

default xValue to ""

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
			tooltip _I("Save  and exit")
			picture cRPath+"task-complete.png"
		end button
		return
endcase

CREATE LABEL (cKOntrol+"_l")
	Row nRow+4
	Col nCol
	AUTOSIZE .t.
	Value _I(cName)+ ":"
	TOOLTIP _I(cName)
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
	case valtype(xValue) == "N"
		CREATE TEXTBOX (cKontrol+"_t")
endcase
	ROW nRow
	COL mg_get( cWin , cKontrol+"_l", "ColRight")+10
	// AUTOSIZE .t.
	//WIDTH 160
	//HEIGHT 24
	TOOLTIP _I(cName)
	// MAXLENGTH 25
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

procedure add_item(aItems, cPWin)

local cWin := "add_i_w", nNo := 1
local aUnit := GetUnit() , aTax := GetTax()

create window (cWin)
	row 0
	col 0
	width 800
	height 400
	CHILD .t.
	MODAL .t.
	caption _I("New item")
	CreateControl(20, 20, cWin, "Itemd", _I("Item Description"),"")
	CreateControl(70, 20, cWin, "Itemu", _I("Item unit"), aUnit)
	CreateControl(70, 260, cWin, "Itemt", _I("Tax")+ " %", aTax)
	CreateControl(120, 20, cWin, "Itemq", _I("Quantity"), nNo)
	CreateControl(120, 360, cWin, "Itemp", _I("Price"), 0.00)

	CreateControl(240, 610, cWin, "Save",, {|| fill_item(@aItems,cWin,cPWin,aTax)})
	CreateControl(320, 610, cWin, "Back")

end window

mg_Do(cWin, "center")
mg_do(cWin, "activate") 


return

static function fill_item(aItems, cWin, cPWin, aTax)

local nPrice := mg_get(cWin, "Itemp_t", "value")
local nQ := mg_get(cWin, "Itemq_t", "value")
local nTax := val(aTax[mg_get(cWin, "Itemt_c", "value")])

if empty(nPrice) .or. empty(nQ) .or. empty(mg_get(cWin, "Itemd_t", "Value"))
	msg(_I("Please fill some more information"))
	return aItems
endif

aadd( aItems, { 	mg_get(cWin, "Itemd_t", "Value"), ;
						mg_get(cWin, "Itemu_c", "value"), ;
 						mg_get(cWin, "Itemp_t", "value"), ;	
						mg_get(cWin, "Itemq_t", "value"), ;	
						nTax, round((nPrice * nQ),2), round((nPrice * nQ * (1+nTax/100)),2) })
	
mg_do(cPWin, "items_g", "refresh")
mg_do(cWin, "release")

return aItems

static function save_invoice( cWin, aFullCust )

local aItems := mg_get(cWin, "items_g", "items")
local nIdf, x, cIAll, aUnit := GetUnit(), nTmp, nType

if !OpenInv(,2) 
	return .f.
endif
cIAll := alias()
select(cIAll)

nType := mg_get(cWin, "ftyp_c", "value" )  // Inoice type
nIdf := GetNextFakt(nType, mg_get(cWin, "datfak_d", "value" )) // calc in. idf

if AddRec()
	nTmp := mg_get(cWin, "fodb_c", "value")
	replace idf with nIdf                     // invoice idf
	replace cust_idf with aFullCust[nTmp][2]  // customer idf
	replace cust_n with mg_get(cWin, "fodb_c", "item", nTmp) // cust name
	replace date with mg_get(cWin, "datfak_d", "value" ) // invoice date
	replace date_sp with mg_get(cWin, "f_tOdb_d", "value" ) // splatnost
	replace uzp with mg_get(cWin, "f_uzp_d", "value" ) // uzkutecneni dan. plneni
	replace ndodpo with mg_get(cWin, "fpl_c", "value" ) // howto payment
	replace type with nType
endif

if !OpenStav(,2)
	return .f.
endif

for x:=1 to len(aItems)
	if addrec()
		replace idf with nIdf
		replace name with aItems[x][1]
		replace unit with aUnit[aItems[x][2]]
		replace price with aItems[x][3]
		replace quantity with aItems[x][4]
		replace tax with aItems[x][5]
	endif
next

dbcloseall()
mg_do(cWin, "release")
print_invoice(nIdf)

return .t.

static function GetUnit()

local aUnit := {}

aadd(aUnit, "Kus")
aadd(aUnit, "Hod")
aadd(aUnit, "km")
aadd(aUnit, "l")

return aUnit

static function GetTax()

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
		nFakt++
	CASE nSt == 2
		dbgobottom()
		if type == 2
			nFakt := idf
			nFakt++
		else
			nFakt := val(cY+"500")
		endif
endcase

return nFakt

procedure print_invoice(nIdf)

local cIAll, aItems := {}, lSuccess, cFile := "/tmp/test.pdf"
field idf, name, unit, quantity, price, tax, serial_no,back

if !OpenInv(,3)
	return
endif
cIAll := alias()
if !dbseek(nIdf)
	Msg(_I("Not Found Invoice no.")+ ": " + strx(nIdf))
	dbclosearea()
	return
endif

if !OpenStav(,2)
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
	Msg(_I("Any items found to invoice No.") + ": " + strx( nIdf ))
	dbclosearea()
	select(cIAll)
	dbclosearea()
	return
endif

dbclosearea()
select(cIAll)

reset printer

// SELECT PRINTER TO PDF File (cFile)

SELECT PRINTER TO DEFAULT
SET PRINTER PREVIEW TO .T. 

CREATE REPORT mR1

	CREATE STYLEFONT Normal
		FONTSIZE 18
      FONTCOLOR {0,255,0}
      //FONTUNDERLINE .T.
		FONTBOLD .T.
      FONTNAME "mg_monospace"
	END STYLEFONT
	CREATE STYLEPEN pen_1
      PENWIDTH 2
      COLOR {0,0,255}
   END STYLEPEN

   SET STYLEFONT TO "Normal"
//	SET STYLEFONT TO 
	CREATE PAGEREPORT "Page_1"
		PRINT "Invoice No. : " + strx(nIdf)
			row 20
			col 20
			FONTSIZE 48
		END PRINT

		CREATE PRINT BARCODE strx(nIDF)
			row 45
			col 125
			type "ean13"
			// height 15
			barwidth 2.5
		END PRINT
		CREATE PRINT IMAGE cPath + "msoftware.jpg"
			row 85
			col 125
			torow 160
			tocol 250
			stretch .t.
		END PRINT

      PRINT RECTANGLE
         COORD { 120 , 80 , 200 , 160 }
         COLOR {255,0,0}
         ROUNDED 10
      END PRINT
	END PAGEREPORT

	CREATE PAGEREPORT "Page_2"
		PRINT "TEST 2 tttttttttttt"
			col 20
			row 20
			FONTSIZE 56
		END PRINT	
	END PAGEREPORT
END REPORT

exec Report mR1 RETO lSuccess

if lSuccess
//	OPEN FILE mg_GetPrinterName()
//	hb_processRun("evince "+cFile)
else
	Msg("Problem occurs creating report")
endif

destroy report mR1

deletefile(cFile)

return

