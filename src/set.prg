#include "marinas-gui.ch"

memvar cRPath

procedure setup_app()

local cWin := "set_app"

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
		END PAGE
		CREATE PAGE "Company Settings"
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

