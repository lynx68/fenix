#include "marinas-gui.ch"

memvar cRPath

procedure browse_subscriber()

local cWin := "inv_win"
local aOptions := {}
local bOnclick 

if !OpenSubscriber()
	return
endif

aadd(aOptions, {"Idf", "Name", "adress", "City" , "Telefon", "email" })
aadd(aOptions, {"Idf", "Name", "adress" , "City", "Telephone", "Email" })
aadd(aOptions, { 60, 200, 150, 100, 60, 100 })
aadd(aOptions, { Qt_AlignRight, Qt_AlignCenter, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignRight })
aadd(aOptions, {10,10, 800, 564}) 

CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION "Subscribers"
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

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

dbclosearea()

return
