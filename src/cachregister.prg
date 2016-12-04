/*
 * Fenix Open Source accounting system
 * Cach Register
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

#require "hbssl"
#require "hbcurl"

memvar cPath, cRPath, hIni

procedure simple_sale(lEdit)

local cWin := "simple_sale_win"
local dDat := date()
local aData := {}, nPrice := 0
local lTax := Taxstatus()
local aTax := GetTax()

default lEdit to .f.

aadd( aData, { iif( lEdit, "false", "true"), "prvni_zaslani", "first" })
aadd( aData, { "0", "rezim", "rezim" }) // bezny:0 - zjednoduseny:1

aadd(aData, { GetUUID(), "uuid_zpravy", "uuid" } )

// Datum
aadd( aData, { xmlDate(date(), time()), "dat_trzby", "date" })

// Promeny staticke dle nastaveni odberatele
aadd( aData, { _hGetValue( hIni["COMPANY"], "VAT" ), "dic_popl", "vat" } ) 

aadd( aData, { _hGetValue( hIni["EET"], "id_pokl" ), "id_pokl", "pos_id"  } ) // nazev pokladny idf pokladny
aadd( aData, { _hGetValue( hIni["EET"], "id_provoz"), "id_provoz", "ws_id" } ) //identifikace provozovny
aadd( aData, { _hGetValue( hIni["EET"], "TestMode" ), "overeni", "over" })

// mg_log(aData)
CREATE WINDOW(cWin)
	row 0
	col 0
	width 900
	height 400
	CAPTION _I("Simple sale")
	CHILD .T.
	MODAL .T.
	//TOPMOST .t.
	FONTSIZE 16
	CreateControl(20, 10, cWin, "payd", _I("Date"), dDat )
	CreateControl(80, 10, cWin, "Itemp", "Celkova cena", nPrice )
	if lTax 
		Createcontrol( 80, 340, cWin, "Itemt", _I( "Tax" ) + " %", aTax )
		CreateControl( 80, 490, cWin, "Itempwt", _I( "Price with Tax" ), 0.00 )
		mg_set(cWin,"Itempwt_t", "readonly", .t. )
	endif

//	CreateControl(10, 220,  cWin, "fOdb", _I("Supplier"), aCust )
	create button OK
		row 210
		col 600
		width 160
		height 60
		caption _I("Odeslat")
		ONCLICK Send_c(cWin, aData, lTax, aTax) 
//		tooltip _I("Close and go back")
//		picture cRPath+"task-reject.png"
	end button

	create button Back
		row 310
		col 600
		width 160
		height 60
		caption _I("Back")
		ONCLICK mg_do(cWin, "release")
		tooltip _I("Close and go back")
		picture cRPath+"task-reject.png"
	end button
	create timer fill_it
		interval	1000
		action fill_it( cWin, aTax, lTax, .f. )
		enabled .t.
	end timer

END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

dbcloseall()

return
 
static procedure send_c(cWin, aData, lTax, aTax)

local nPrice, nTax := 0, nPriceWithVat, cFik, nIdf

nPrice := mg_get( cWin, "Itemp_t", "value" )
aadd(aData, { dtos(date())+"/100", "porad_cis", "pidf" } ) // TODO

if empty(nPrice)
	msg("Bez ceny ?!")
endif

if lTax
	nTax := val(aTax[ mg_get( cWin, "itemt_c", "value" ) ])
	aadd(aData, { nTax, "nTax", "ntax" } ) // DPH %

	nPriceWithVat := nPrice * (1+nTax/100)

	aadd(aData, { alltrim(str(nPrice,10,2)), "zakl_dan1", "dphz" } ) // cena bez DPH
	aadd(aData, { strx(nPriceWithVat), "celk_trzba", "zprice" } ) // cena s DPH
	aadd(aData, { strx(nPriceWithVat - nPrice), "dan1", "dph" } ) // DPH
else
	aadd(aData, { nPrice, "celk_trzba", "zprice" } ) // cena celkem
endif

//mg_log(aData)

aadd( aData, { xmlDate(date(), time()), "dat_odesl", "date_s" })
cFik := eet( @aData )
aadd( aData, { cFik, "fik", "fik" } )
// msg( "FIK: " + cFik)
nIdf := GetNextPosIdf(date())	
aadd( aData, { nIdf, "idf", "idf" } )

//mg_log("cIdf:" + strx(nIdf))
if OpenPOS(,2)
	if addrec()
		replace idf with nIdf
		replace date with DateXml(ret_val(aData, "date"))
		replace time with TimeXml(ret_val(aData, "date"))
		replace fik with cFik
		replace op with "operator"
//		replace op with GetUserName()
		replace uuid with ret_val(aData, "uuid")
		replace date_s with DateXml(ret_val(aData, "date_s"))
		replace time_s with TimeXml(ret_val(aData, "date_s"))
		replace price with nPrice
		replace vat with nTax
		replace zprice with val(ret_val(aData, "zprice"))
		replace pos_id with ret_val( aData, "pos_id" )
		replace ws_id  with ret_val( aData, "ws_id" )
		//replace pkp with ret_val( aData, "pkp" )
		replace bkp with ret_val( aData, "bkp" )
	endif
endif

dbcloseall()
mg_do(cWin, "release")

print_tic(aData, 2)

return

static function ret_val( aData, cIdf )

local nPos //:= aScan( aData, { |z| z[3] == cIdf } )
local cRet

if cIdf == "idf"
	//mg_log(aData)
	//mg_log(cIdf)
endif

nPos := aScan( aData, { |z| z[3] == cIdf } )

if nPos == 0
	cRet := ""
else 
	cRet := aData[nPos][1]
endif

return cRet

static func GetNextPosIdf(dDat)

local nFakt := 0, cY
field type, idf

default dDat to date()
cY := right(dtoc(dDat),2)

if !OpenPOS(dDat, 2) 
	return nFakt
endif

	dbgotop()
	if lastrec()==0
		return val(cY+"00001")
	endif
	do while !eof()
		nFakt := idf
		if type == 2
			dbskip(-1)
			nFakt := idf
			EXIT
		ENDIF
		dbskip()
	ENDDO
	if empty(nFakt)
		nFakt := val(cY+"00001")
	else
		nFakt++
	endif

dbclosearea()

return nFakt

procedure browse_pos()

local aOptions:={}, cAll, bOnclick
local cWin := "br_pos_win"

if !OpenPOS(,3)
	Return
endif
cAll := alias()

aadd(aOptions, { cAll+"->Idf", cAll+"->date", cAll+"->time", cAll+"->price", cAll+"->vat", cAll+"->fik", cAll+"->uuid",  cAll+"->op" })
aadd(aOptions, {_I("ID"), _I("Date"), _I("Time"), _I("Price"), _I("Vat"), _I("FIK"), _I("UUID"), _I("Operator") })
aadd(aOptions, { 120, 90, 80, 80, 60, 260, 200, 100 })
aadd(aOptions, { Qt_AlignLeft, Qt_AlignLeft })
aadd(aOptions, {10,10, 800, 400}) 
// bOnClick := { || show_memo() }

create window (cWin)
	ROW 5
	COL 10
	HEIGHT 400 + 30
	WIDTH  800 + 220
	CHILD .t.
	MODAL .t.
//	my_grid( cNWin, aArr, aOptions, , , , cNWin+"_g" )
 	my_mg_browse(cWin, alias(), aOptions, bOnClick )
end window

mg_do( cWin, "center")
mg_do( cWin, "activate")

dbclosearea()

return

static procedure print_again()

local aData := {}

aadd( aData, { idf,, "idf" })
aadd( aData, { xmldate( date_s, time_s ),, "date" }) 
aadd( aData, { xmldate( date_s, time_s ),, "date" }) 
aadd( aData, { fik,, "fik" })
aadd( aData, { op,, "op" })
aadd( aData, { uuid,, "uuid" })
aadd( aData, { price,, "dphz" })
aadd( aData, { zprice,, "zprice" })
aadd( aData, { vat,, "ntax" })
aadd( aData, { pos_id,, "pos_id" })
aadd( aData, { ws_id,, "ws_id" })
aadd( aData, { bkp,, "bkp" })
aadd( aData, { pkp,, "pkp" })

print_tic( aData )

return

static procedure print_tic( aData, nCopy )

local cPrn := "", x, cFile
#define ESC CHR(27)           // Escape

default nCopy to 1

cPrn += ESC + "@" + DOS_CRLF 
cPrn += _hGetValue( hIni["COMPANY"], "Name") + DOS_CRLF
cPrn += _hGetValue( hIni["COMPANY"], "Address") + ", " + ;
				_hGetValue( hIni["COMPANY"], "PostCode") + " " + ;
				_hGetValue( hIni["COMPANY"], "City") + DOS_CRLF
cPrn += _I("VAT") + ": " +  _hGetValue( hIni["COMPANY"], "VAT" ) + hb_eol()
cPrn += replicate( ".", 30 ) + DOS_CRLF
cPrn += "cislo provozovny: " + ret_val( aData, "ws_id" ) + DOS_CRLF
cPrn += "pokladna: " + ret_val( aData, "pos_id" ) + DOS_CRLF

cPrn += "Datum: " + dtoc(DateXml(ret_val(aData, "date"))) + DOS_CRLF
cPrn += DOS_CRLF
cPrn += "Danovy doklad cislo: " + str(ret_val( aData, "idf")) + DOS_CRLF + DOS_CRLF
cPrn += "Platba: " + ret_val( aData, "dphz" ) + " DPH:" + strx(ret_val( aData, "ntax" )) + "%" + "  " + ret_val( aData, "dph" ) + hb_eol() + hb_eol()

cPrn += "          Celkem: " + ret_val( aData, "zprice" ) + _hGetValue( hIni["INVOICE"], "CURRENCY" ) + DOS_CRLF

cPrn += replicate( ".", 40 ) + DOS_CRLF

cPrn += "Vyhotoveno: " + dtoc(DateXml(ret_val(aData, "date"))) + " " + TimeXml(ret_val(aData, "date")) + DOS_CRLF

if empty( ret_val( aData, "fik" ))
   cPrn += "Rezim EET: Zjednoduseny" + hb_eol()
	cPrn += "BKP: " + ret_val( aData, "bkp" ) + DOS_CRLF
	cPrn += "PKP: " + ret_val( aData, "pkp" ) + DOS_CRLF + hb_eol()
else
	cPrn += "Rezim EET: Bezny" + hb_eol()
	cPrn += "BKP: " + ret_val( aData, "bkp" ) + DOS_CRLF
	cPrn += "FIK: " + ret_val( aData, "fik" ) + DOS_CRLF + hb_eol()
endif

cPrn += "      Dekujeme Vam za navstevu" + hb_eol()

// cPrn += DOS_CRLF + DOS_CRLF + DOS_CRLF + DOS_CRLF
for x := 1 to 8
	cPrn += hb_eol() // DOS_CRLF
next
//cPrn += ESC + "a" + "1" 
cPrn += ESC + "d" + "1"

cFile := u_TempFile( "/tmp/" )
hb_memowrit( cFile, cPrn )

for x:=1 to nCopy
	hb_processRun( "cp "+ cFile + " /dev/usb/lp0")
next
//lpr( "", cPrn)
mg_log( cPrn )
deletefile( cFile )

return

function lpr(cSpooler, cTxt, lFile)

local cCmd := "lpr ", a, lRet, cTmp
local cFile := u_tempfile("/tmp/") 
default cSpooler to ""
default lFile to .f.
if "LPT" $ cSpooler
	cSpooler := strtran(cSpooler, "LPT", "lp")
endif

if cSpooler == "lp"
	cSpooler := ""
endif

if !empty(cSpooler)
	cCmd := cCmd + "-P "+cSpooler
endif

#ifdef __HARBOUR__
	hb_memowrit(cFile, cTxt)
#else
	memowrit(cFile, cTxt)
#endif

if lfile
	// pokud je lTofile .t. tak uloz do soboru a vrat se zpet
	return .t.
endif
cCmd := cCmd + " " + cFile
a := hb_processrun( cCmd )
if a <> 0
	msg("Problem pri tisku na tiskarnu: " + cSpooler)
	lRet := .f.
else
	lRet := .t.
endif
deletefile(cFile)

return lRet

Function U_TempFile( cPath, cExtn, lCreate )   // -> MDDHMMSS.tt
// returns a new file Name from current time + Extension passed
// in given directory. Ext is the fractions of a sec if not specified
local cFileName, nHandle, dDate, nTime

default cPath to ""
default lCreate to .F.

   Do While .T.      // keep trying until we get a unique file
      dDate := date()
      nTime := seconds()
      cFileName := cPath+chr(64+month(dDate))   ;           // Month Jan=A to Dec=L
                  +right(dtos(dDate),2)   ;           // Day 2 digits
                  +chr(65+int(nTime/3600))         ;  // Hour 00=A to 23=X
                  +padl(ltrim(str(int(nTime/60 % 60))),2,"0")  ;  // Mins 2 digits
                  +padl(ltrim(str(int(nTime    % 60))),2,"0")     // Secs 2 digits
      if cExtn == NIL
         cFileName += ltrim(str(nTime-int(nTime),5,3))   // ext is hundredths secs
      else
         cFileName += iif('.' $ cExtn, '', '.') + cExtn  // specified ext
      endif
      if (nHandle := Fopen( cFileName )) != -1
         Fclose(nHandle)
      else
         if lCreate  // create the file just to reserve the name (multiuser)
            nHandle := FCreate( cFileName )
            Fclose( nHandle )
         endif
         exit // this file name does not exist (yet) so return it
      endif
   Enddo
Return (cFileName)

