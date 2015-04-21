#include "marinas-gui.ch"
#include "fenix.ch"

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

local cWin := "add_inv", cKust := space(10)
local aInvType := {}, aPl := {}

aadd(aInvtype, "Normal")
aadd(aInvType, "Zalohova")

aadd(aPl, "Platba na ucet")
aadd(aPl, "v hotovosti   ")

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
	CreateControl(80,	20,  cWin, "fOdb", _I("Customer"), cKust )
	CreateControl(80,	320, cWin, "ftyp", _I("Typ faktury"), aInvType )
	CreateControl(80,	550, cWin, "fpl", _I("Zpusob placeni"), aPl)
	CreateControl(510, 840, cWin, "Save",,)
	CreateControl(510, 650, cWin, "Back")
END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

return

procedure CreateControl(nRow, nCol, cWin, cKontrol, cName, xValue )

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
	case valtype(xValue) == "C"
		CREATE TEXTBOX (cKontrol+"_t")
endcase
	ROW nRow
	COL mg_get( cWin , cKontrol+"_l", "ColRight")+10
	AUTOSIZE .t.
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
endcase

return

