#include "marinas-gui.ch"
#include "fenix.ch"
#include "hbthread.ch"

memvar cRPath

procedure browse_invoice()

local cWin := "inv_win"
local aOptions := {}, cAll
// local bOnclick

if !OpenInvoice()
	return
endif
cAll := alias()
aadd(aOptions, {cAll+"->Invoice", cAll+"->Date", cAll+"->KUPAC" , cAll+"->date_sp", cAll+"->price_sum" })
aadd(aOptions, {"Invoice no.", "Date", "Customer" , "Date sp.", "Price summ" })
aadd(aOptions, { 90, 100, 100, 120, 120 })
aadd(aOptions, { Qt_AlignRight, Qt_AlignCenter, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignLeft })
aadd(aOptions, {10,10, 800, 564}) 

CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("Browse Invoices")
	CHILD .T.
	TOPMOST .t.
	FONTSIZE 16
	my_mg_browse(cWin, alias(), aOptions ) 
	//	my_mg_browse(cWin, alias(), aOptions, bOnClick)
	// aData := aSort(aData,,, {|x, y| x[2] > y[2]})
	// my_grid(cWin, aData, aOptions, bOnClick,,,"el_zad_br")
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

local cWin := "add_inv", aCust // {}
local aInvType := {}, aPl := {}, aItems := {} // {"","","","","","","",""}

aadd(aInvtype, "Normal")
aadd(aInvType, "Zalohova")

aadd(aPl, "Platba na ucet")
aadd(aPl, "v hotovosti   ")

//hb_threadstart( HB_THREAD_INHERIT_PUBLIC, @read_customer(), @aCust)
aCust := read_customer(, .T.)
//mg_log(aCust)
if empty(aCust) .or. len(aCust) == 1
	msg(_I("Customer database empty. Please define custumers before make invoice"))
	return
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
	CreateControl(20,	20,  cWin, "datfak", _I("Date"), date() )
	CreateControl(20,	260, cWin, "f_tOdb", _I("Splatnost"), date()+10 )
	CreateControl(20,	500, cWin, "f_uzp", _I("Datum UZP "), date() )
	CreateControl(80,	20, cWin, "ftyp", _I("Typ faktury"), aInvType )
	CreateControl(80,	550, cWin, "fpl", _I("Zpusob placeni"), aPl)
	CreateControl(140, 20,  cWin, "fOdb", _I("Customer"), aCust )
	CreateControl(510, 650, cWin, "Save")
	CreateControl(510, 840, cWin, "Back")
	create Button add_i_b
		row 250
		col 840
		autosize .t.
		caption _I("Item from catalogue")
//		onclick add_item(@aItems, cWin)
	end button
	create Button add_ic_b
		row 300
		col 840
		autosize .t.
		caption _I("New Item")
		onclick add_item(@aItems, cWin)
	end button
	create Button del_i_b
		row 350
		col 840
		autosize .t.
		caption _I("Delete Item")
		onclick del_item(cWin, "Items_g")
	end button

	create grid items_g
		row 240
		col 20
		width 800
		height 220
		rowheightall 24
		columnheaderall { _I("Item"), _I("Description"), _I("unit"), _I("Unit cost"), _I("Quantity"), _I("Tax"), _I("Total"), _I("Total with tax")}
		columnwidthall { 60, 400, 40, 120, 100, 60, 120, 120 }
	// ondblclick Edit_item()
		navigateby "row"
		visible .t.
		Items aItems
		tooltip _I("Invoice Items")
	end grid
END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

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
	Row nRow
	Col nCol
	AUTOSIZE .t.
	Value _I(cName)
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
	TOOLTIP _I([cName])
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
local aUnit := {}, aTax := {}

aadd(aUnit, "Kus")
aadd(aUnit, "Hod")
aadd(aUnit, "km")
aadd(aUnit, "l")
aadd(aTax, "DPH 21%")
aadd(aTax, "DPH 16%")

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
	CreateControl(70, 260, cWin, "Itemt", _I("Tax"), aTax)
	CreateControl(120, 20, cWin, "Itemq", _I("Quantity"), nNo)
	CreateControl(120, 360, cWin, "Itemp", _I("Price"), 0.00)

	CreateControl(240, 610, cWin, "Save",, {|| fill_item(@aItems,cWin,cPWin)})
	CreateControl(320, 610, cWin, "Back")

end window

mg_Do(cWin, "center")
mg_do(cWin, "activate") 


return

static function fill_item(aItems, cWin, cPWin)

local nPrice := mg_get(cWin, "Itemp_t", "value")
local nQ := mg_get(cWin, "Itemq_t", "value")
if empty(nPrice) .or. empty(nQ) .or. empty(mg_get(cWin, "Itemd_t", "Value"))
	msg(_I("Please fill some more information"))
	return aItems
endif

aadd( aItems, { 	hb_random(1,90000), ;
						mg_get(cWin, "Itemd_t", "Value"), ;
						mg_get(cWin, "Itemu_c", "value"), ;
 						mg_get(cWin, "Itemp_t", "value"), ;	
						mg_get(cWin, "Itemq_t", "value"), ;	
						mg_get(cWin, "Itemt_c", "value"), ;
						(nPrice * nQ), round((nPrice * nQ *1.21),2) }) 		
mg_do(cPWin, "items_g", "refresh")
mg_do(cWin, "release")

return aItems
