#include "marinas-gui.ch"

memvar cRPath, cPath

procedure setup_app()

local cWin := "set_app", cNamef := "", cVat := "", cICO := ""
local cAddr := "", cCity := "", cPost := "", cCount := ""
local cIBan := "", cSwift := ""

CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION "Setup system"
	CHILD .T.
	MODAL .t.
	// TOPMOST .t.
	create tab set
		row 10
		col 10
		width 820
		height 560
		VALUE 1
		TOOLTIP "Global Setting"
		CREATE PAGE "Global Settings"
			CREATE LABEL "path_l"
				row 10
				col 10
				VALUE "Path to data"
			END LABEL
			CREATE TEXTBOX "path_t"
				row 30
				col 10
				width 160
				height 24
				value cPath
			END TEXTBOX	
		END PAGE
		CREATE PAGE "Company Settings"
			CREATE LABEL "namef_l"
				row 10
				col 10
				autosize .t.
				value "Company name"
			END LABEL 
			CREATE EDITBOX "NAMEF"
				row 30
				col 10
				width 400
				height 100
				value cNameF
				TOOLTIP "Company name"
			END EDITBOX
			Create LABEL "vat_l"
				ROW 10
				COL 500
				AUTOSIZE .t.
				VALUE "Vat"
			END LABEL
			CREATE TEXTBOX "vat_t"
				ROW 30
				COL 500
				WIDTH 160
				HEIGHT 24
				VALUE cVat
			END TEXTBOX
			CREATE LABEL "ICO_l"
				ROW 80
				COL 500
				AUTOSIZE .t.
				VALUE "Company ID"
			END LABEL
			CREATE TEXTBOX "ico_t"
				ROW 100
				COL 500
				WIDTH 160
				HEIGHT 24
				VALUE cICO
			END TEXTBOX
			CREATE LABEL "addr_l"
				ROW 160
				COL 10
				AUTOSIZE .t.
				VALUE "Addres"
			END LABEL
			CREATE TEXTBOX "addr_t"
				ROW 180
				COL 10
				WIDTH 220
				HEIGHT 24
				VALUE cAddr
			END TEXTBOX
			CREATE LABEL "city_l"
				ROW 160
				COL 300 
				VALUE "City"
			END LABEL
			CREATE TEXTBOX "city_t"
				ROW 180
				COL 300
				WIDTH 220
				HEIGHT 24
				VALUE cCity
			END TEXTBOX
			CREATE LABEL "post_l"
				ROW 160
				COL 560 
				VALUE "PostCode"
			END LABEL
			CREATE TEXTBOX "post_t"
				ROW 180
				COL 560
				WIDTH 100
				HEIGHT 24
				VALUE cPost
			END TEXTBOX
			CREATE LABEL "count_l"
				ROW 220
				COL 10 
				VALUE "Country"
			END LABEL
			CREATE TEXTBOX "count_t"
				ROW 240
				COL 10
				WIDTH 220
				HEIGHT 24
				VALUE cCount
			END TEXTBOX
			CREATE LABEL "iban_l"
				ROW 280
				COL 10 
				VALUE "IBAN"
			END LABEL
			CREATE TEXTBOX "iban_t"
				ROW 300
				COL 10
				WIDTH 220
				HEIGHT 24
				VALUE cIBan 
			END TEXTBOX
			CREATE LABEL "swift_l"
				ROW 280
				COL 300
				VALUE "Swift code"
			END LABEL
			CREATE TEXTBOX "swift_t"
				ROW 300
				COL 300
				WIDTH 220
				HEIGHT 24
				VALUE cSwift
			END TEXTBOX

		END PAGE
		
		CREATE PAGE "Modules"
		END PAGE

	END TAB  
	
	create button Back
		row 510
		col 860
		width 150
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

return

