#include "marinas-gui.ch"

memvar cRPath

procedure browse_invoice()

local cWin := "inv_win"
local aOptions := {}
local bOnclick 

if !OpenInvoice()
	return
endif

aadd(aOptions, {"Invoice", "Date", "KUPAC" , "date_sp", "price_sum" })
aadd(aOptions, {"Invoice no.", "Date", "Odberatel" , "Datum splatonsti", "Cena celkova" })
aadd(aOptions, { 90, 100, 100, 120, 120 })
aadd(aOptions, { Qt_AlignRight, Qt_AlignCenter, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignLeft })
aadd(aOptions, {10,10, 800, 564}) 

CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION "Pøehled faktur"
	CHILD .T.
	TOPMOST .t.
	FONTSIZE 16
	my_mg_browse(cWin, alias(), aOptions, bOnClick)
	// aData := aSort(aData,,, {|x, y| x[2] > y[2]})
	// my_grid(cWin, aData, aOptions, bOnClick,,,"el_zad_br")
	create button Back
		row 510
		col 840
		width 160
		height 60
		caption "Back"
//		backcolor {0,255,0}
		ONCLICK mg_do(cWin, "release")
		tooltip "Close and go back"
		picture cRPath+"task-reject.png"
	end button

END WINDOW

mg_do(cWin, "activate") 

dbclosearea()

return

