/*
 * Fenix Open Source accounting system
 * Main file
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

#include "marinas-gui.ch" // Use Marinas gui Header 
#include "hbextcdp.ch"    // Request all CPs
//#include "requests.ch"
#include "fenix.ch"

memvar cPath, cRPath, hIni, cIni, cLog

procedure Main(cIniFile)

PUBLIC hIni
PUBLIC cPath, cRPath, cIni

DEFAULT cIniFile to ""

// Set database driver
Request DBFCDX , DBFFPT
Request HB_MEMIO
RddSetDefault( "DBFCDX" )

// Set Harbour Language  Environment
REQUEST HB_LANG_CSISO
REQUEST HB_CODEPAGE_CSISO
REQUEST HB_CODEPAGE_SR646
//REQUEST HB_LANG_SR646
REQUEST HB_CODEPAGE_UTF8EX
if !empty( cIniFile ) .and. !file( cIniFile )
	? "Requested ini file not exist, aborting startup !"
	return
endif

// Take a look for ini file
if !SetAppINI( cIniFile )
	mg_msg("Initialization error")
	return
endif
// Dont match the case of ini strings
hb_HCaseMatch( hIni, .F. )

// Set CLipper settings
//
SET DATE TO BRITISH
SET DELETED ON
SET FIXED ON
SET EPOCH TO 2015
SET SOFTSEEK ON

// Set Default Data Path
cPath := hIni["GLOBAL"]["DATAPATH"]

if !hb_direxists(cPath)
	Msg(_I("Unable to found path for data files !?. Please fix .ini file and start again"))
	return
endif

if right(cPath,1) <> hb_ps()
	cPath := cPath + hb_ps()
endif

// Set Default Resource Path (.png .ico .jpg) 
cRPath := hIni["GLOBAL"]["RESOURCEPATH"]
if !hb_direxists(cRPath)
	Msg(_I("Unable to found resource path !?. Please fix .ini settings... "))
endif

if right(cRPath,1) <> hb_ps()
	cRPath := cRPath + hb_ps()
endif

// Marinas-gui specific setting
SET APPLSTYLE TO "MarinasLooks"
// SET FONTNAME TO "DejaVu sans"
SET FONTNAME TO "mg_normal"
// SET FONTNAME TO "mg_roman"
// SET FONTNAME TO "mg_monospace"
//
SET FONTSIZE TO 14
//
// Set log path
if hb_direxists(cPath+"log") 
	cLog := cPath+"log"+hb_ps()+"fenix.log"  // Log File Path
else
	cLog := cPath+"fenix.log"  // Log File Path
endif

SET MARINAS LOG TO cLog  // Log File Path

// Set application Language
SetAppLanguage(hIni) 

Main_Fenix()				// Start main procedure
	
Return

procedure Main_Fenix()

local cWin := "main_win"

if !direxist(cPath)
	dirmake(cPath)
endif

CREATE WINDOW (cWin)
  	ROW 0 
  	COL 0
  	WIDTH 1000
  	HEIGHT 750
  	CAPTION "Fenix Open Source Project" + " - " + _hGetValue( hIni["COMPANY"], "Name")
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


