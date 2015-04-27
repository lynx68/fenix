//
// Marinas gui sample applicaton
//
#include "marinas-gui.ch" // Use Marinas gui Header 
#include "hbextcdp.ch"    // Request all CPs
#include "requests.ch"
#include "fenix.ch"

memvar cPath, cRPath, hIni

procedure Main()

PUBLIC cPath, cRPath, hIni

// Set database driver
Request DBFCDX , DBFFPT
Request HB_MEMIO
RddSetDefault( "DBFCDX" )

// Set Harbour Language  Environment
REQUEST HB_LANG_CSISO
REQUEST HB_CODEPAGE_CSISO
//REQUEST HB_LANG_SR646
REQUEST HB_CODEPAGE_SR646
REQUEST HB_CODEPAGE_UTF8EX

// Take a look for ini file
hIni := SetAppINI()
if empty(hIni)
	mg_msg("Initialization error")
	return
endif

// Dont match the case of ini strings
hb_HCaseMatch( hIni, .f. )

// Set application Language
SetAppLanguage(hIni) 


// Set CLipper settings
//
SET DATE TO BRITISH
SET DELETED ON
SET FIXED ON
SET EPOCH TO 2015
SET SOFTSEEK ON

// Set Default Data Path
// cPath := "dat" + hb_ps()		// Path where databases are placed

cPath := hIni[ "GLOBAL" ][ "DATAPATH" ]
// Set Default Resource Path (.png .ico .jpg) 
cRPath := hIni[ "GLOBAL" ][ "RESOURCEPATH" ]
 
// Marinas-gui specific setting
//
SET APPLSTYLE TO "MarinasLooks"
// SET FONTNAME TO "DejaVu sans"
SET FONTNAME TO "mg_normal"
// SET FONTNAME TO "mg_roman"
// SET FONTNAME TO "mg_monospace"
//
SET FONTSIZE TO 14
//
// Set log path
SET MARINAS LOG TO cPath+"fenix.log"  // Log File Path

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
	CREATE BUTTON End_b
      ROW 580
      COL 620
      WIDTH 300
      HEIGHT 100
      backcolor {255,0,0}
      CAPTION _I("EXIT")
      ONCLICK mg_Do( cWin , "Release" )
   END BUTTON
	mainmenu( cWin )	 
END WINDOW

mg_Do( cWin, "center" )
mg_Do( cWin, "Activate" )

return

static procedure SetAppLanguage( hIni )

local cLng, cLangFileName, cFile

// hb_cdpSelect( "UTF8EX" )
hb_SetTermCP( hb_cdpTerm())
set(_SET_OSCODEPAGE, hb_cdpOS())

// mg_msg(hb_iniWriteStr( hIni ))

// Set application language if requested from setup
// (Higher priority then environment setting)
if !empty( hIni ) 
	cLng := lower(hINI["GLOBAL"]["LANGUAGE"])
	do case
		case cLng = "automatic"  // Get Language settings from environment
			cLng := "" 
		case cLng == "czech"
			cLng := "cs-CZ"
		case cLng == "english"
			cLng := "en-US"
		case cLng == "serbian"
			cLng := "sr-RS"
	endcase
endif

// Set Language from environment (Default)
if empty(cLng)
	if empty( cLng := GetEnv("HB_LANG"))
		if empty( cLng := hb_UserLang() ) 
			cLng := "en-US"  // Default Language en
		endif
	endif
endif

cLangFileName := hb_dirSepAdd(hb_dirBase())+"fenix."+strtran(cLng, "-", "_")+".hbl"
if file( cLangFileName )
	hb_i18n_Check( cFile := hb_MemoRead( cLangFileName ) )
	hb_i18n_Set( hb_i18n_RestoreTable( cFile ) )
endif

do case
	case cLng = "en-US"
		hb_i18n_set( NIL )
		hb_LangSelect("EN")
	case cLng = "cs-CZ" .or. cLng = "cs_CZ"
		hb_LangSelect("CSISO")
		set( _SET_DBCODEPAGE, "cp852")
		set(_SET_CODEPAGE, "CSISO")
	case cLng = "sr-RS" .or. cLng = "sr_RS"
//		hb_LangSelect("SR646")
		set( _SET_DBCODEPAGE, "cp852")
		set(_SET_CODEPAGE, "HRISO")
end case

// mg_log(getenv("LANG"))
// mg_log(hb_cdpUniID("CSISO"))   // return iso8859-2
// mg_log(hb_cdplist())           // list of cp
// mg_log( hb_cdpTerm())          // return utf-8

return

