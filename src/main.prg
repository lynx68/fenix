//
// Marinas gui sample applicaton
//
#include "marinas-gui.ch"

memvar cPath

procedure Main()

PUBLIC cPath

SET APPLSTYLE TO "MarinasLooks"

Request DBFCDX , DBFFPT
RddSetDefault( "DBFCDX" )

REQUEST HB_LANG_CSISO
REQUEST HB_CODEPAGE_CSISO

hb_LANGSELECT("CSISO")
set(_SET_CODEPAGE, "CSISO")

SET DATE TO BRITISH
SET DELETED ON
SET FIXED ON
SET EPOCH TO 2015
SET SOFTSEEK ON

//SET MARINAS LOG TO /tmp/fenix.log
cPath := "dat/"
MainDemo()
	
Return

procedure MainDemo( )

local cWin := "main_win"

CREATE WINDOW (cWin)
  	ROW 0 
  	COL 0
  	WIDTH 1000
  	HEIGHT 750
  	CAPTION "Sample"
  	MAIN .T.

	CREATE BUTTON Test_b
		Row 5
		COL 5
		Autosize .t.
		Caption "Test Cups"
		ONCLICK testcups()
	END BUTTON
	CREATE BUTTON End_b
      ROW 500
      COL 600
      WIDTH 300
      HEIGHT 100
      backcolor {255,0,0}
      CAPTION "EXIT"
      ONCLICK mg_Do( cWin , "Release" )
     END BUTTON
	mainmenu( cWin )	 
END WINDOW

mg_Do( cWin , "Activate" )

return

static procedure TestCups()

local aPrinter := cupsGetDests()
local nTest := 1
mg_log(aPrinter)

mg_log(cupsgetdefault())
if nTest = 0
//	lpr("test")
endif

return

function getver()

return "ver 0.1"
