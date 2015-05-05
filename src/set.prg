#include "marinas-gui.ch"
#include "fenix.ch"

memvar cRPath, cPath, hIni

procedure setup_app()

local cWin := "set_app", cNamef := "", cVat := "", cICO := ""
local cAddr := "", cCity := "", cPost := "", cCount := ""
local cIBan := "", cSwift := "", cBPath := "", cBPass := ""
local x
local	aLang := {"Automatic", "English", "Czech", "Serbian", "Croatian"}

if empty(hIni) // ini file in not found
	setAppIni(hIni)
//	cRPath := hIni["GLOBAL"]["ResourcePath"]
//	cPath := hIni["GLOBAL"]["DataPath"]
endif

if hb_HHasKey( hIni, "Company")
	cNameF := _hGetValue( hIni["COMPANY"], "Name")
	cAddr  := _hGetValue( hIni["COMPANY"], "Address")
	cCity  := _hGetValue( hIni["COMPANY"], "City")
	cPost  := _hGetValue( hIni["COMPANY"], "PostCode")
	cICO	 := _hGetValue( hIni["COMPANY"], "IDF")
	cVat   := _hGetValue( hIni["COMPANY"], "VAT")
	cIBan  := _hGetValue( hIni["COMPANY"], "IBAN")
	cSwift := _hGetValue( hIni["COMPANY"], "Swift")
	cCount := _hGetValue( hIni["COMPANY"], "Country")
//else
//	hIni["Company"] := { => }
//	hIni["Company"]["Name"] := "Default Company Name"
//	save_set(cWin, .t. )
endif

CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("Setup system")
	CHILD .T.
	MODAL .t.
	TOPMOST .t.
	create tab set
		row 10
		col 10
		width 820
		height 560
		VALUE 1
		TOOLTIP _I("Global Setting")
		CREATE PAGE _I("Global Settings")
			CREATE LABEL "path_l"
				row 10
				col 10
				VALUE _I("Data Path")
			END LABEL
			CREATE TEXTBOX "path_t"
				row 30
				col 10
				width 160
				height 24
				value cPath
			END TEXTBOX	
			CREATE LABEL "rpath_l"
				row 50
				col 10
				VALUE _I("Resource path")
			END LABEL
			CREATE TEXTBOX "rpath_t"
				row 70
				col 10
				width 160
				height 24
				value cRPath
			END TEXTBOX	
			CREATE LABEL "country_l"
				row 10
				col 300
				VALUE _I("Language")
			END LABEL
			CREATE COMBOBOX "country_c"
				row 30
				col 300
				width 330
				height 24
				ITEMS aLang
				value iif((x:= aScan(aLang, hINI["GLOBAL"]["LANGUAGE"])) == 0, 1, x)
				onchange hIni["GLOBAL"]["LANGUAGE"] := aLang[mg_get(cWin, "country_c", "value")]
			END COMBOBOX
			CREATE CHECKBOX "crypt_c"
				ROW 120
				COL 10
				AUTOSIZE .t.
				FONTBOLD .t.
				Value .f.
				CAPTION _I("Encrypt Data Path (encfs)")
				TOOLTIP "Encrypt data path"
			END CHECKBOX

		END PAGE
		CREATE PAGE _I("Company Settings")
			CREATE LABEL "namef_l"
				row 10
				col 10
				autosize .t.
				value _I("Company name")
			END LABEL 
			CREATE EDITBOX "NAMEF"
				row 30
				col 10
				width 400
				height 100
				value cNameF
				TOOLTIP _I("Company name")
				onchange hIni["COMPANY"]["Name"] := mg_get(cWin, "namef", "value")
			END EDITBOX
			Create LABEL "vat_l"
				ROW 10
				COL 500
				AUTOSIZE .t.
				VALUE _I("VAT")
			END LABEL
			CREATE TEXTBOX "vat_t"
				ROW 30
				COL 500
				WIDTH 160
				HEIGHT 24
				VALUE cVat
				onchange hIni["COMPANY"]["VAT"] := mg_get(cWin, "vat_t", "value")
			END TEXTBOX
			CREATE LABEL "ICO_l"
				ROW 80
				COL 500
				AUTOSIZE .t.
				VALUE _I("Company ID")

			END LABEL
			CREATE TEXTBOX "ico_t"
				ROW 100
				COL 500
				WIDTH 160
				HEIGHT 24
				VALUE cICO
				onchange hIni["COMPANY"]["IDF"] := mg_get(cWin, "ico_t", "value")
			END TEXTBOX
			CREATE LABEL "addr_l"
				ROW 160
				COL 10
				AUTOSIZE .t.
				VALUE _I("Address")
			END LABEL
			CREATE TEXTBOX "addr_t"
				ROW 180
				COL 10
				WIDTH 220
				HEIGHT 24
				VALUE cAddr
				onchange hIni["COMPANY"]["Address"] := mg_get(cWin, "addr_t", "value")
			END TEXTBOX
			CREATE LABEL "city_l"
				ROW 160
				COL 300 
				VALUE _I("City")
			END LABEL
			CREATE TEXTBOX "city_t"
				ROW 180
				COL 300
				WIDTH 220
				HEIGHT 24
				VALUE cCity
				onchange hIni["COMPANY"]["City"] := mg_get(cWin, "city_t", "value")
			END TEXTBOX
			CREATE LABEL "post_l"
				ROW 160
				COL 560 
				VALUE _I("PostCode")
			END LABEL
			CREATE TEXTBOX "post_t"
				ROW 180
				COL 560
				WIDTH 100
				HEIGHT 24
				VALUE cPost
				onchange hIni["COMPANY"]["PostCode"] := mg_get(cWin, "post_t", "value")
			END TEXTBOX
			CREATE LABEL "count_l"
				ROW 220
				COL 10 
				VALUE _I("Country")
			END LABEL
			CREATE TEXTBOX "count_t"
				ROW 240
				COL 10
				WIDTH 220
				HEIGHT 24
				VALUE cCount
				onchange hIni["COMPANY"]["Country"] := mg_get(cWin, "count_t", "value")
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
				onchange hIni["COMPANY"]["IBAN"] := mg_get(cWin, "iban_t", "value")
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
				onchange hIni["COMPANY"]["SWIFT"] := mg_get(cWin, "swift_t", "value")

			END TEXTBOX
			CREATE LABEL "logo_l"
				ROW 360
				COL 10
				VALUE "Upload Company logo"
			END LABEL
			CREATE LABEL "sign_l"
				ROW 360
				COL 300
				VALUE "Upload Company signature"
			END LABEL
		END PAGE
		CREATE PAGE _I("Backup")
			CREATE LABEL "BPath_l"
				ROW 10
				COL 10
				VALUE _I("Path to save backup file")
			END LABEL
			CREATE TEXTBOX "BPath_t"
				ROW 40 
				COL 10 
				WIDTH 220
				HEIGHT 24
				VALUE cBPath
			END TEXTBOX
			CREATE LABEL "BPass_l"
				ROW 10
				COL 300
				VALUE _I("Backup password")
			END LABEL
			CREATE TEXTBOX "BPass_t"
				ROW 40 
				COL 300
				WIDTH 220
				HEIGHT 24
				PASSWORD .t.
				VALUE cBPass
			END TEXTBOX
			CREATE CHECKBOX "Batend_c"
				ROW 40
				COL 580
				AUTOSIZE .t.
				FONTBOLD .t.
				Value .f.
				CAPTION _I("Backup on Exit")
				TOOLTIP _I("Always make backup after closing application")
			END CHECKBOX
			CREATE CHECKBOX "Upload_c"
				ROW 100
				COL 10
				AUTOSIZE .t.
				FONTBOLD .t.
				Value .f.
				CAPTION "Upload encrypted backup data to Cloud Server "
				TOOLTIP "Always make backup after closing application trought internet"
			END CHECKBOX	

		END PAGE
		CREATE PAGE "Modules"
		END PAGE
	END TAB  
	create button Save
		row 430
		col 860
		width 150
		height 60
		caption _I("Save")
//		backcolor {0,255,0}
		ONCLICK save_set(cWin, .f., .t.)
		tooltip _I("Save and go back")
		picture cRPath+"task-complete.png"
	end button

	create button Back
		row 510
		col 860
		width 150
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

return

static procedure save_set( cWin, lQuet, lQuit )

local cIniFile := IniFileName( )

hb_default( @lQuet, .f.)
hb_default( @lQuit, .f.)
if hb_iniWrite( cIniFile, hIni, "# Fenix Open Source Project INI File" )
	if !lQuet
		msg(_I("File saved:") + " " + cIniFile )
	endif
else
	msg(_I("Unable to create .ini file:") + " " + cIniFile )
endif

if lQuit
	mg_do(cWin, "release")
endif

return

/*

static function get_set_file()

local cFile

cFile := mg_GetFile( { { "All Files", mg_GetMaskAllFiles() }}, "Select File",,, .t. )

return cFile

*/

// Automatic detect & find  INI File Name
function IniFileName( lNew )

local cINIFileName := "", aFile := {}, x
default lNew to .f.  // Return default .ini file (change for linux and win)
							// for now place where reside binary, only for dev !!!
							// thinking about...

aadd(aFile, mg_getHomeFolder()+hb_ps()+"."+_SELF_NAME_+".ini")
aadd(aFile, hb_dirSepAdd(hb_dirBase())+_SELF_NAME_+".ini")
if mg_getPlatform() == "linux"
	aadd(aFile, "/usr/local/etc/"+_SELF_NAME_+".ini")
	aadd(aFile, "/etc/"+_SELF_NAME_+".ini")
endif

for x:=1 to len(aFile)
	if file(aFile[x])
		cINIFileName := aFile[x]
		exit
	endif
next

if lNew .and. empty( cIniFileName ) // If new and didn't found return default
//	cIniFileName := hb_dirSepAdd(hb_dirBase())+_SELF_NAME_+".ini"
	cIniFileName := GetEnv("HOME")+hb_ps()+"."+_SELF_NAME_+".ini"
endif

return cIniFileName

Function CreateIniFile()

local cIniFile, lRet

cIniFile := IniFileName( .T. )

// Defaults
hIni := hb_iniNew( .T. )
hIni["GLOBAL"] := { => }
hIni["GLOBAL"]["DATAPATH"] := "dat"+hb_ps()
hIni["GLOBAL"]["RESOURCEPATH"] := "res"+hb_ps()
hIni[ "GLOBAL" ][ "LANGUAGE" ] := "Automatic"
hIni["Company"] := { => }
hIni["Company"]["Name"] := "Default Company Name"

if hb_iniWrite( cIniFile, hIni, "# Fenix Open Source Project INI File" )
	msg(_I("Created new .ini file:") + " " + cIniFile )
	lRet := .t.
else
	msg(_I("Unable to create .ini file:") + " " + cIniFile )
	lRet := .f.
endif

return lRet

Function SetAppINI()

local cINIFileName := IniFileName()

if empty( cIniFileName ) 
	if !CreateIniFile()
		return .f.
	else
		return .t.
	endif
endif

hIni := hb_iniRead( cIniFileName, .F. )

if empty(hIni)
	return .f.
endif

return .t.

procedure SetAppLanguage( hIni )

local cLng, cLangFileName, cFile

// hb_cdpSelect( "UTF8EX" )
hb_SetTermCP( hb_cdpTerm())
set(_SET_OSCODEPAGE, hb_cdpOS())

// mg_msg(hb_iniWriteStr( hIni ))

// Set application language if requested from setup
// (Higher priority then environment setting)

if !empty( hIni )
	cLng := lower(_hGetValue(hINI["GLOBAL"],[LANGUAGE]))
	if empty(cLng)
		cLng := "automatic"
	endif 
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

function _hGetValue(hHash, cKey)
hb_HCaseMatch( hHash, .f. )
return iif( HB_ISHASH(hHash), iif( hb_hGetDef( hHash, cKey ) == NIL, "", hb_hGetDef( hHash, cKey )), "" )
