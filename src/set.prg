/*
 * Fenix Open Source accounting system
 * Network lock functions
 *	
 * Copyright 2015 Davor Siklic (www.msoft.cz)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.txt.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site https://www.gnu.org/).
 *
 */


#include "marinas-gui.ch"
#include "fenix.ch"

memvar cRPath, cPath, hIni, cIni, cLog

procedure setup_app()

local cWin := "set_app", cNamef := "", cVat := "", cICO := "", cText := ""
local cAddr := "", cCity := "", cPost := "", cCount := "", cSign := ""
local cIBan := "", cSwift := "", cBPath := "", cBPass := "", cLogo := ""
local x, cMail := "", cCurr := ""
local	aLang := {"Automatic", "English", "Czech", "Serbian", "Croatian"}
local cLw := "", cLh := "", cIPath := ""
local aVatSt := {"payer of vat","non-payer of vat"}
local aModule := { "Disabled", "Enabled" }

if empty(hIni) // ini file in not found
	setAppIni(hIni)
endif

if hb_HHasKey( hIni, "Company" )
	cNameF := _hGetValue( hIni["COMPANY"], "Name" )
	cAddr  := _hGetValue( hIni["COMPANY"], "Address" )
	cCity  := _hGetValue( hIni["COMPANY"], "City" )
	cPost  := _hGetValue( hIni["COMPANY"], "PostCode" )
	cICO	 := _hGetValue( hIni["COMPANY"], "IDF" )
	cVat   := _hGetValue( hIni["COMPANY"], "VAT" )
	cIBan  := _hGetValue( hIni["COMPANY"], "IBAN" )
	cSwift := _hGetValue( hIni["COMPANY"], "Swift" )
	cCount := _hGetValue( hIni["COMPANY"], "Country" )
	cLogo  := _hGetValue( hIni["COMPANY"], "LOGO" )
	cSign  := _hGetValue( hIni["COMPANY"], "SIGN" )
	cText  := _hGetValue( hIni["COMPANY"], "TEXT" )
	cLw := _hGetValue( hIni["COMPANY"], "LOGOWIDTH" )
	cLh := _hGetValue( hIni["COMPANY"], "LOGOHEIGHT" )
	if empty(_hGetValue( hIni["COMPANY"], "VatStatus" ))
		hIni["COMPANY"]["VatStatus"] := aVatSt[1]
	endif
endif

if hb_HHasKey( hIni, "INVOICE" )
	cMail := _hGetValue( hIni["INVOICE"], "MAIL" )
	cCurr := _hGetValue( hIni["INVOICE"], "CURRENCY")
	cIPath := _hGetValue( hIni["INVOICE"], "SAVEINVOICEPATH" )
else
	hIni["INVOICE"] := { => }
endif

if !hb_HHasKey( hIni, "CachRegister" )
	hIni["CachRegister"] := { => }
	hIni["CachRegister"]["Module"] := "Disabled"
endif

if !hb_HHasKey( hIni, "Store" )
	hIni["STORE"] := { => }
	hIni["STORE"]["Module"] := "Disabled"
endif

//	hIni["Company"] := { => }
//	hIni["Company"]["Name"] := "Default Company Name"
//	save_set(cWin, .t. )

CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("Setup system")
	CHILD .T.
	MODAL .t.
	// TOPMOST .t.
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
				row 35
				col 10
				width 300
				height 24
				value cPath
				onchange hIni["GLOBAL"]["DATAPATH"] := mg_get(cWin, "path_t", "value")
			END TEXTBOX	
			CREATE LABEL "rpath_l"
				row 70
				col 10
				VALUE _I("Resource path")
			END LABEL
			CREATE TEXTBOX "rpath_t"
				row 95
				col 10
				width 300
				height 24
				value cRPath
				onchange hIni["GLOBAL"]["RESOURCEPATH"] := mg_get(cWin, "rpath_t", "value")
			END TEXTBOX	
			CREATE LABEL "inipath_l"
				row 120
				col 200
				VALUE _I("Initialization file") + ": " + cIni
			END LABEL
			CREATE LABEL "logpath_l"
				row 140
				col 200
				VALUE _I("Log file") + ": " + cLog
			END LABEL

			CREATE LABEL "country_l"
				row 10
				col 500
				VALUE _I("Language")
			END LABEL
			CREATE COMBOBOX "country_c"
				row 30
				col 500
				width 220
				height 24
				ITEMS aLang
				value iif((x:= aScan(aLang, hINI["GLOBAL"]["LANGUAGE"])) == 0, 1, x)
				onchange hIni["GLOBAL"]["LANGUAGE"] := aLang[mg_get(cWin, "country_c", "value")]
			END COMBOBOX
			CREATE CHECKBOX "crypt_c"
				ROW 180
				COL 10
				AUTOSIZE .t.
				FONTBOLD .t.
				Value .f.
				CAPTION _I("Encrypt Data Path (encfs)")
				TOOLTIP _I("Encrypt data path")
			END CHECKBOX
			createcontrol(220, 10, cWin, "mail_f", _I("Outgoing Mail Setup"), {"mutt", "intrnal mail system", "Mail client"})
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
				WIDTH 260
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
				WIDTH 280
				HEIGHT 24
				VALUE cIBan 
				onchange hIni["COMPANY"]["IBAN"] := mg_get(cWin, "iban_t", "value")
			END TEXTBOX
			CREATE LABEL "swift_l"
				ROW 280
				COL 320
				VALUE "Swift code"
			END LABEL
			CREATE TEXTBOX "swift_t"
				ROW 300
				COL 320
				WIDTH 160
				HEIGHT 24
				VALUE cSwift
				onchange hIni["COMPANY"]["SWIFT"] := mg_get(cWin, "swift_t", "value")
			END TEXTBOX
			CREATE LABEL "logo_l"
				ROW 355
				COL 10
				VALUE "Company logo"
			END LABEL
			CREATE TEXTBOX "logo_t"
				ROW 380
				COL 10
				WIDTH 300
				HEIGHT 24
				VALUE cLogo
				onchange hIni["COMPANY"]["LOGO"] := mg_get(cWin, "logo_t", "value")
			END TEXTBOX
			Create label logw_l
				row 470
				col 10
				if empty( cLogo )
					Value ""
				else
					Value "Logo width/height (" + strx(mg_getimagewidth( cLogo ))+"/"+strx(mg_getimageheight( cLogo )) + ")"
				endif
			end label
 			CREATE TEXTBOX "logow_t"
				ROW 470
				COL 300
				WIDTH 60
				HEIGHT 24
				VALUE cLw
				onchange hIni["COMPANY"]["LOGOWIDTH"] := mg_get(cWin, "logow_t", "value")
			END TEXTBOX
 			CREATE TEXTBOX "logoh_t"
				ROW 470
				COL 380
				WIDTH 60
				HEIGHT 24
				VALUE cLh
				onchange hIni["COMPANY"]["LOGOHEIGHT"] := mg_get(cWin, "logoh_t", "value")
			END TEXTBOX
			CREATE BUTTON "get_logo_b"
				ROW 380
				COL 320
				WIDTH 25
				HEIGHT 25
				CAPTION ".."
				ONCLICK get_set_File( cWin, "logo_t" )	
			END BUTTON
			CREATE BUTTON "show_logo_b"
				ROW 380
				COL 360
				WIDTH 100
				Caption "Show Logo"
				HEIGHT 25
				ONCLICK showimage(mg_get(cWin, "logo_t", "value"))
			END BUTTON
			CREATE LABEL "sign_l"
				ROW 405
				COL 10
				VALUE "Company sign"
			END LABEL
			CREATE TEXTBOX "sign_t"
				ROW 430
				COL 10
				WIDTH 300
				HEIGHT 24
				VALUE cSign
				onchange hIni["COMPANY"]["SIGN"] := mg_get(cWin, "sign_t", "value")
			END TEXTBOX
			CREATE BUTTON "get_sign_b"
				ROW 430
				COL 320
				WIDTH 25
				HEIGHT 25
				CAPTION ".."
				ONCLICK get_set_File( cWin, "sign_t" )	
			END BUTTON
			CREATE BUTTON "show_sign_b"
				ROW 430
				COL 360
				WIDTH 100
				Caption "Show Sign"
				HEIGHT 25
				ONCLICK showimage(mg_get(cWin, "sign_t", "value"))
			END BUTTON
			CREATE LABEL "Text_l"
				ROW 355
				COL 480
				VALUE _I("Bound text")
			END LABEL
			CREATE EDITBOX "TextF"
				row 380
				col 480
				width 300
				height 80
				value cText
				TOOLTIP _I("Bound text")
				onchange hIni["COMPANY"]["Text"] := mg_get(cWin, "Textf", "value")
			END EDITBOX

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
		CREATE PAGE _I("Invoice setting")
			// CreateControl( 10, 6, cWin, "VatStatus", _I("VAT status"), {"Payer of VAT","Non-payer of VAT"})
			CREATE LABEL "vatst_l"
				row 10
				col 6
				VALUE _I("Vat Status")
			END LABEL
			CREATE COMBOBOX "vatst_c"
				row 10
				COL mg_get( cWin, "vatst_l", "ColRight")+10
				width 220
				height 24
				ITEMS aVatSt
				value iif((x:= aScan(aVatSt, hINI["COMPANY"]["VatStatus"])) == 0, 1, x)
				onchange hIni["COMPANY"]["VatStatus"] := aVatSt[mg_get(cWin, "vatst_c", "value")]
			END COMBOBOX
			CreateControl( 50, 6, cWin, "Aprox", _I("Aproximate total price"), {"Yes","No "})			
			CREATE LABEL "curr_l"
				row 100
				col 6
				Value _I("Currency")
			end label
			CREATE TEXTBOX "curr_t"
				row 100
				COL mg_get( cWin, "curr_t", "ColRight")+10
				WIDTH 60
				HEIGHT 24
				VALUE cCurr
				TOOLTIP _I("Currency")
				onchange hIni["INVOICE"]["CURRENCY"] := mg_get(cWin, "curr_t", "value")
			END TEXTBOX
			Create button "man_u_b"
				row 20
				col 550
				width 150
				height 60
				Caption "Manage units"
				ONCLICK manage_array( GetUnit(), 10, 10, "Units" )
			end button
			Create button "man_t_b"
				row 100
				col 550
				width 150
				height 60
				Caption "Manage Tax"
				ONCLICK manage_array( GetTax(), 10, 10, "Tax" )
			end button
			CREATE LABEL "mail_l"
				row 220
				col 6
				Value _I("Automatic send new invoice to mail address")
			END LABEL
  			CREATE TEXTBOX "mail_t"
				row 220
				COL mg_get( cWin, "mail_l", "ColRight") + 15
				WIDTH 220 
				HEIGHT 24
				value cMail
				TOOLTIP _I("Write mail addres for automatic invoice sending")
				onchange hIni["INVOICE"]["MAIL"] := mg_get(cWin, "mail_t", "value")
			END TEXTBOX		
			create label "savei_l"
				row 280
				col 6
				Value _I("Automatic save invoice pdf file to directory")
			end label
			CREATE BUTTON "get_folder_b"
				ROW 280
				COL 380
				WIDTH 25
				HEIGHT 25
				CAPTION ".."
				ONCLICK mg_getFolder( cWin, "" )	
			END BUTTON

  			CREATE TEXTBOX "savei_t"
				row 280
				COL mg_get( cWin, "savei_l", "ColRight") + 15
				WIDTH 220 
				HEIGHT 24
				value cIPath
				TOOLTIP _I("Automatic save invoice pdf file to directory")
				onchange hIni["INVOICE"]["SAVEINVOICEPATH"] := mg_get(cWin, "savei_t", "value")
			END TEXTBOX		

		END PAGE
    	CREATE PAGE "Store"
			//CreateControl( 10, 6, cWin, "Storesett", _I("Activate store module"), {"Disabled","Enabled"}, ,	{ || hIni["STORE"]["Module"] := mg_get( cWin, "StoreSetT_c", "value")})
			CREATE COMBOBOX "StoreModule_c"
				row 10
				COL 6  //mg_get( cWin, "vatst_l", "ColRight")+10
				width 220
				height 24
				ITEMS aModule 
				value iif((x:= aScan(aModule, hINI["STORE"]["Module"])) == 0, 1, x)
				onchange hIni["STORE"]["Module"] := aModule[mg_get(cWin, "StoreModule_c", "value")]
			END COMBOBOX
			
			Create button "man_s_b"
				row 20
				col 550
				width 150
				height 60
				Caption "Manage store's"
				ONCLICK manage_array( GetStore(), 10, 10, "StoreDef", "STORE" )
			end button

		END PAGE
		CREATE PAGE "Cach register"
			CREATE COMBOBOX "CRModule_c"
				row 10
				COL 6  
				width 220
				height 24
				ITEMS aModule 
				value iif((x:= aScan(aModule, hINI["CachRegister"]["Module"])) == 0, 1, x)
				onchange hIni["CachRegister"]["Module"] := aModule[mg_get(cWin, "CRModule_c", "value")]
			END COMBOBOX

		END PAGE
    	CREATE PAGE "Loki"
			CREATE COMBOBOX "LokiModule_c"
				row 10
				COL 6  //mg_get( cWin, "vatst_l", "ColRight")+10
				width 220
				height 24
				ITEMS aModule 
				value iif((x:= aScan(aModule, hINI["LOKI"]["Module"])) == 0, 1, x)
				onchange hIni["LOKI"]["Module"] := aModule[mg_get(cWin, "LokiModule_c", "value")]
			END COMBOBOX
		END PAGE
	END TAB 
	create button SaveAS
		row 350
		col 860
		width 150
		height 60
		caption _I("Save as")
//		backcolor {0,255,0}
		ONCLICK save_set(cWin, .f., .t., .t.)
		tooltip _I("Save configuration to alternate file and go back")
		picture cRPath+"task-complete.png"
	end button
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

static procedure save_set( cWin, lQuet, lQuit , lSaveAs)

local cIniFile := IniFileName( )
local cCP

hb_default( @lQuet, .f.)
hb_default( @lSaveAs, .f. )

if lSaveAs
	cIniFile := mg_PutFile( { { "Ini Files", "*.ini" }}, "Save Ini file",filepath(cIniFile),,, .t. )
	if empty( cIniFile )
		msg("Please add full name and path")
		return
	endif
endif

if !mg_msgyesno(_I("Write setup to file") + ": "	+ cIniFile)
	return
endif

if ( cCP := Set( _SET_CODEPAGE ) ) <> "UTF8"
	recode_hash( cCP, "UTF8" )
endif

if hb_iniWrite( cIniFile, hIni, "# Fenix Open Source Project INI File" )
	if !lQuet
		msg(_I("File saved:") + " " + cIniFile )
	endif
else
	msg(_I("Unable to create .ini file:") + " " + cIniFile )
	if lQuit
		lQuit := .f.
	endif
endif

if cCP <> "UTF8"
	recode_hash( "UTF8", cCP )
endif
	
if lQuit
	mg_do(cWin, "release")
endif

return

static function get_set_file(cWin, cControl)

local cFile, cOutFile := ""

cFile := mg_GetFile( { { "All Files", mg_GetMaskAllFiles() }}, "Select File",,, .t. )

if !empty( cFile )
	cOutFile := cPath + mg_fileNameOnlyNameAndExt( cfile )
	if cFile <> cOutFile 
		if file( cOutFile ) 
			if	mg_msgNoYes(_I("File" + " " + cOutFile +" " + _I("already exist in destination, replace !?" ) ) )
				ferase(cOutfile)
				mg_FileCopy( cFile, cOutFile )
			else
				return ""
			endif	
		else
			mg_FileCopy( cFile, cOutFile ) 
		endif
		mg_set( cWin, cControl, "value", cOutFile )

	else
		mg_msgStop(_I("The files are the same..."))
		return ""
	endif
endif

return cOutFile

/*
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
*/

// Automatic detect & find INI File Name

function IniFileName( lNew )

   LOCAL nInx
   local cINIFileName := "", aFile := {}
   default lNew to .f. // Return default .ini file (change for linux and win)
                       // for now place where reside binary, only for dev !!!
                       // thinking about...
	if !empty(cIni)
		return cIni
	endif

   aadd(aFile, mg_getHomeFolder()+hb_ps()+"."+_SELF_NAME_+".ini")
   aadd(aFile, hb_dirSepAdd(hb_dirBase())+_SELF_NAME_+".ini")
   if mg_getPlatform() == "windows"
      aadd(aFile, mg_getTempFolder()+hb_ps()+_SELF_NAME_+".ini")
   else
      aadd(aFile, "/usr/local/etc/"+_SELF_NAME_+".ini")
      aadd(aFile, "/etc/"+_SELF_NAME_+".ini")
   endif

   FOR nInx :=1 to len( aFile )
      if file( aFile[ nInx ] )
         cIniFileName := aFile[ nInx ]
         exit
      endif
   next
   if lNew .and. empty( cIniFileName ) // If new and didn't found return default
      FOR nInx := 1 TO len( aFile )
         IF mg_DirWrite( mg_fileNameOnlyPath( aFile[ nInx ] ) )
            cIniFileName := aFile[ nInx ]
            EXIT
         ENDIF
      NEXT
      IF empty( cIniFileName )
         mg_msgStop( "Error creating INI file" )
         mg_abort( 12 )
      ENDIF
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

Function SetAppINI( cINIFileName )

default cINIFileName to ""

if empty( cIniFileName ) 
	cIniFileName := IniFileName()
endif

if empty( cIniFileName ) 
	if !CreateIniFile()
		return .f.
	else
		return .t.
	endif
endif

cIni := cIniFilename

//hb_LangSelect("CSISO")
//set( _SET_DBCODEPAGE, "cp852")
// set(_SET_CODEPAGE, "CSISO")
//msg( "Character encoding: " + Set( _SET_CODEPAGE ))
//msg( hb_cdpOS() )

hIni := hb_iniRead( cIniFileName, .F. )

if empty(hIni)
	return .f.
endif

if !hb_HHasKey( hIni, "INVOICE" )
	hIni["INVOICE"] := { => }
endif

if !hb_HHasKey( hIni, "CachRegister" )
	hIni["CachRegister"] := { => }
	hIni["CachRegister"]["Module"] := "Disabled"
endif

if !hb_HHasKey( hIni, "Store" )
	hIni["STORE"] := { => }
	hIni["STORE"]["Module"] := "Disabled"
endif

if !hb_HHasKey( hIni, "LOKI" )
	hIni["LOKI"] := { => }
	hIni["LOKI"]["Module"] := "Disabled"
endif

return .t.

static procedure recode_hash( cFromCP, cToCP )

local aSect, cKey, cSect

FOR EACH cSect IN hIni:Keys
	aSect := hIni[ cSect ]
	IF HB_ISHASH( aSect )
		FOR EACH cKey IN aSect:Keys
			hIni [ cSect ][ cKey ] := hb_translate( hIni [ cSect ][ cKey ], cFromCP, cToCP )
		NEXT
	ENDIF
NEXT

return

procedure SetAppLanguage( hIni )

local cLng, cLangFileName, cFile

// hb_cdpSelect( "UTF8EX" )
hb_SetTermCP( hb_cdpTerm())
set(_SET_OSCODEPAGE, hb_cdpOS())

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

if !file( cLangFileName )
   if mg_getPlatform() == "linux"
		cLangFileName := "/usr/local/share/fenix/lang"+ hb_ps() + "fenix."+strtran(cLng, "-", "_") + ".hbl"
	endif
endif

if file( cLangFileName )
	hb_i18n_Check( cFile := hb_MemoRead( cLangFileName ) )
	hb_i18n_Set( hb_i18n_RestoreTable( cFile ) )
else
	if !("en_US" $ cLangFilename)
		msg( "Lang file not found: " + cLangFileName )
	endif
endif

do case
	case cLng = "en-US"
		hb_i18n_set( NIL )
		hb_LangSelect("EN")
	case cLng = "cs-CZ" .or. cLng = "cs_CZ"
		hb_LangSelect("CSISO")
		set( _SET_DBCODEPAGE, "cp852")
		set(_SET_CODEPAGE, "CSISO")
		recode_hash( "UTF8", "CSISO" )
	case cLng = "sr-RS" .or. cLng = "sr_RS"
//		hb_LangSelect("SR646")
		set( _SET_DBCODEPAGE, "cp852")
		set(_SET_CODEPAGE, "HRISO")
		recode_hash( "UTF8", "HRISO" )
end case

// mg_log(getenv("LANG"))
// mg_log(hb_cdpUniID("CSISO"))   // return iso8859-2
// mg_log(hb_cdplist())           // list of cp
// mg_log( hb_cdpTerm())          // return utf-8

return


function _hGetValue(hHash, cKey)

local xRet := ""
hb_HCaseMatch( hHash, .f. )

if HB_ISHASH(hHash)
	xRet := hb_hGetDef( hHash, cKey )
	if xRet == NIL
		xRet := ""
	endif
endif

return xRet

//return iif( HB_ISHASH(hHash), iif( hb_hGetDef( hHash, cKey ) == NIL, "", hb_hGetDef( hHash, cKey )), "" )

static function showimage( cFile )

  CREATE WINDOW WinFullImage
      ROW 0
      COL 0
      CAPTION "Image"
      MODAL .T.

      CREATE IMAGE FullImage
         ROW 0
         COL 0
         PICTURE cFile
         WIDTH mg_get( "WinFullImage" , "FullImage" , "realWidth" )
         HEIGHT mg_get( "WinFullImage" , "FullImage" , "realHeight" )
         STRETCH .T.
      END IMAGE

      WIDTH mg_get( "WinFullImage" , "FullImage" , "width" )
      HEIGHT mg_get( "WinFullImage" , "FullImage" , "height" )

   END WINDOW

   mg_do( "WinFullImage" , "center" )
   mg_do( "WinFullImage" , "activate" )

return NIL

function sendmail(xTo, cSubj, cText, cFileToAttach)

local a, b:="", e := "", lRet := .f., cTo, n := 1, x
local cCommand 
local cMuttrc := ""
default cText to ""
default cFileToAttach to ""

if file("/usr/local/etc/muttrc")
	cMuttrc := "/usr/local/etc/muttrc"
elseif file("/etc/fenix/muttrc")
	cMuttrc := "/etc/fenix/muttrc"
endif

if valtype(xTo) == "A"
	n:=len(xTo)
else
	cTo := xTo
endif

for x :=1 to n
	if valtype(xTo) == "A"
		cTo := xTo[x]
	endif
	cCommand := "mutt " + cTo + " -s '" + cSubj + "'" 
	if !empty(cMuttrc)
		cCommand += " -F " + cMuttrc
	endif
	if !empty(cFileToAttach)
		cCommand := cCommand + " -a " + cFileToAttach
	endif
	#ifdef __CLIP__
	   a:=syscmd(cCommand, cText, @b, @e)
	#endif
	#ifdef __HARBOUR__
	   a:=hb_ProcessRun(cCommand, cText, @b, @e)
	#endif
next
if a = 0
	 lRet := .t.
else
	#ifdef __CLIP__
		outlog(b)
		outlog(e)
	#endif
endif

return lRet

function TaxStatus()

local avatst := {"payer of vat","non-payer of vat"}
local lTax
default lTax to .t.

if aScan(aVatSt, _hGetValue(hINI["COMPANY"],"VatStatus")) == 2
	lTax := .f.
endif

return lTax

procedure manage_array( aArr, nRow, nCol, cTxt, cSect)

local cnWin := "man_a_w"
local nWidth := 120
local nHeight := 180
local aOptions := {}

default nRow to 10
default nCol to 20
default cTxt to "Name"
default cSect to "GLOBAL"

aadd(aOptions, { cTxt } )
aadd(aOptions, { _I(cTxt) } )
aadd(aOptions, { 150 })
aadd(aOptions, { Qt_AlignLeft})
aadd(aOptions, {nRow,nCol, nWidth, nHeight })
// mg_log(aArr)
create window (cnWin)
	ROW 5
	COL 10
	HEIGHT nHeight + 30
	WIDTH  nWidth + 220
	CHILD .t.
	MODAL .t.
	my_grid( cNWin, aArr, aOptions, , , , cNWin+"_g" )
 
CREATE BUTTON array_add_b
	row nRow + 35
	Col nCol + nWidth + 30
	AUTOSIZE .t.
	CAPTION "Add new"
	ONCLICK add_arr_i( cNWin, cNWin+"_g", cTxt, cSect )
END BUTTON

CREATE BUTTON array_del_b
	row nRow + 75
	Col nCol + nWidth + 30 
	AUTOSIZE .t.
	CAPTION "Delete"
	ONCLICK del_arr_i( cNWin, cNWin+"_g", cTxt, cSect )
END BUTTON

CREATE BUTTON close_b
	row nRow + 115
	Col nCol + nWidth + 30 
	AUTOSIZE .t.
	CAPTION "Close"
	ONCLICK mg_do( cNWin, "release" )
	//picture cRPath+"task-reject.png"
end button
 
end window

mg_do( cnWin, "center")
mg_do( cnWin, "activate")

return

static procedure del_arr_i(cWin, cControl, cTxt, cSect)

local x := mg_get( cWin, cControl, "value" )
default cSect to "GLOBAL"

if x == 0
	return
endif

mg_do( cWin, cControl, "deleteitem", x )
mg_do( cWin, cControl, "refresh" )
hIni[cSect][cTxt] := ArrayAsList( mg_get( cWin, cControl, "items" ), "," )
 
return

static procedure add_arr_i(cWin, cControl, cTxt, cSect)

local cIn 
default cSect to "GLOBAL"

cIn := mg_inputdialog("Add new", "Unit name", "" )
if !empty(cIn)
	mg_do( cWin, cControl, "additem", cIn )
	mg_do( cWin, cControl, "refresh" )
	hIni[cSect][cTxt] := ArrayAsList( mg_get( cWin, cControl, "items" ), "," ) 
endif

return 

function GetUnit()

local aUnit

aUnit := listasarray( _hGetValue( hIni["GLOBAL"], "Units" ) , "," )

if empty( aUnit )
	aadd(aUnit, "Ks")
	aadd(aUnit, "Hod")
	aadd(aUnit, "km")
	aadd(aUnit, "l")
endif

return aUnit

function GetTax()

local aTax 

aTax := listasarray( _hGetValue( hIni["GLOBAL"], "Tax" ) , "," )

if empty( aTax )
	aadd(aTax, "21")
	aadd(aTax, "16")
	aadd(aTax, "0")
endif

return aTax

function GetStore()

local aStore

aStore := listasarray( _hGetValue( hIni["STORE"], "StoreDef" ) , "," )

if empty( aStore )
	aadd(aStore, "Default")
endif

return aStore

procedure PrintLogo()

if !empty(_hGetValue( hIni["COMPANY"], "Logo"))
	CREATE PRINT IMAGE hIni["COMPANY"]["Logo"]
		row 0
		col 0
		torow mg_getimageheight( hIni["COMPANY"]["Logo"]) * 2 / 100
	   tocol mg_getimagewidth( hIni["COMPANY"]["Logo"]) * 2 /100
		if !empty(_hGetValue( hIni["COMPANY"], "LogoWidth"))
			torow val(hIni["COMPANY"]["LogoWidth"])
		else
			torow 16  // 16
		endif
		if !empty(_hGetValue( hIni["COMPANY"], "LogoHeight"))
			tocol val(hIni["COMPANY"]["LogoHeight"])
		else				
			tocol 46 // 32  // 55
		endif
		stretch .t.
	   //scaled .t.
	END PRINT
endif

return

Procedure CreateControl(nRow, nCol, cWin, cKontrol, cName, xValue, lHide )

default xValue to ""
default lHide to .F.

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
			tooltip _I("Save and exit")
			picture cRPath+"task-complete.png"
		end button
		return
endcase

CREATE LABEL (cKontrol+"_l")
	Row nRow+4
	Col nCol
	AUTOSIZE .t.
	Value _I(cName)+ ":"
	TOOLTIP _I(cName)
	if lHide
		VISIBLE .F.
	endif
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
			WIDTH 220
			HEIGHT 24
	case valtype(xValue) == "N"
		CREATE TEXTBOX (cKontrol+"_t")
			WIDTH 100
			HEIGHT 24
endcase
	ROW nRow
	COL mg_get( cWin , cKontrol+"_l", "ColRight")+10
	// AUTOSIZE .t.
	TOOLTIP _I(cName)
	// MAXLENGTH 25
	if lHide
		VISIBLE .F.
	endif
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
