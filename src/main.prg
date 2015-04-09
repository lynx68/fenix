//
// Marinas gui sample applicaton
//
#include "marinas-gui.ch"

memvar cPath, cRPath

procedure Main()

PUBLIC cPath, cRPath

// Set database driver
Request DBFCDX , DBFFPT
Request HB_MEMIO
RddSetDefault( "DBFCDX" )

// Set Language
// to do! make configurable

// Set Harbour Environment
REQUEST HB_LANG_CSISO
REQUEST HB_CODEPAGE_CSISO

hb_LANGSELECT("CSISO")
set(_SET_CODEPAGE, "CSISO")

SET DATE TO BRITISH
SET DELETED ON
SET FIXED ON
SET EPOCH TO 2015
SET SOFTSEEK ON

// Marinas-gui specific setting
SET APPLSTYLE TO "MarinasLooks"
// SET FONTNAME TO "DejaVu sans"
SET FONTNAME TO "mg_normal"
// SET FONTNAME TO "mg_roman"
// SET FONTNAME TO "mg_monospace"
SET FONTSIZE TO 14

// Set log path

//SET MARINAS LOG TO /tmp/fenix.log  // Log File Path

cPath := "dat" + hb_ps()		// Path where databases are placed
cRPath := "res" + hb_ps()  	// Resource path (.png .ico .jpg) 

Main_Fenix()				// Start main procedure
	
Return

procedure Main_Fenix()

local cWin := "main_win"

// FONTSIZE 16
if !direxist(cPath)
	dirmake(cPath)
endif

CREATE WINDOW (cWin)
  	ROW 0 
  	COL 0
  	WIDTH 1000
  	HEIGHT 750
  	CAPTION "Fenix Open Source Project"
  	MAIN .T.
	FONTSIZE 16
/*
	CREATE BUTTON Test_b
		Row 5
		COL 5
		Autosize .t.
		Caption "Test Cups"
		ONCLICK testcups()
	END BUTTON
*/

	CREATE BUTTON End_b
      ROW 580
      COL 620
      WIDTH 300
      HEIGHT 100
      backcolor {255,0,0}
      CAPTION "EXIT"
      ONCLICK mg_Do( cWin , "Release" )
   END BUTTON
	mainmenu( cWin )	 
END WINDOW

mg_Do( cWin, "center" )
mg_Do( cWin, "Activate" )

return
/*
static procedure TestCups()

local aPrinter := cupsGetDests()
local nTest := 1
mg_log(aPrinter)

mg_log(cupsgetdefault())
if nTest = 0
//	lpr("test")
endif

return
*/

function getver()

return "ver 0.1"

