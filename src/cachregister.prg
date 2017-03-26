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
	CreateControl(80, 10, cWin, "Itemp",_I("Total price"), nPrice )
	mg_do( cWin, "itemp_t", "setfocus" )
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
		caption _I("Send")
		ONCLICK Send_c(cWin, aData) 
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
 
static procedure send_c( cWin, aData )

local nPrice, nTax := 0, nPriceWithVat, cFik, nIdf
local lOpak := .f.
local lTax := Taxstatus()
local aTax := GetTax()
local aVat

default cWin to ""

if empty( cWin )
	nPrice := ret_val( aData, "dphz" )
	lOpak := .t.
else
	nPrice := mg_get( cWin, "Itemp_t", "value" )
endif

if empty(nPrice)
	msg(_I("Price field empty!"))
	return
endif

if !lOpak
	if lTax 
		nTax := val(aTax[ mg_get( cWin, "itemt_c", "value" ) ])
		nPriceWithVat := nPrice * (1+nTax/100)
		aVat := calc_vat( { , , , , nTax, nPrice, nPriceWithVat }, aTax )
		aadd(aData, { nTax, "nTax", "ntax" } ) // DPH %
		aadd(aData, { strx(nPriceWithVat), "celk_trzba", "zprice" } ) // cena s DPH
		if !empty(aVat[1][1])
			aadd(aData, { alltrim(str(aVat[1][1],10,2)), "zakl_dan1", "dphz" } ) 
			aadd(aData, { strx(aVat[1][2]), "dan1", "dph" } ) // DPH
		endif
		if !empty(aVat[2][1])
			aadd(aData, { alltrim(str(aVat[2][1],10,2)), "zakl_dan2", "dphz" } )
			aadd(aData, { strx(aVat[2][2]), "dan2", "dph" } ) // DPH
		endif
		if !empty(aVat[3][1])
			aadd(aData, { alltrim(str(aVat[3][1],10,2)), "zakl_dan3", "dphz" } )
			aadd(aData, { strx(aVat[3][2]), "dan3", "dph" } ) // DPH
		endif
	else
		aadd(aData, { alltrim(str(nPrice,10,2)), "celk_trzba", "zprice" } ) // cena celkem
	endif
	nIdf := GetNextPosIdf(date())	
	aadd( aData, { strx(nIdf), "porad_cis", "idf" } )
	aadd( aData, { xmlDate(date(), time()), "dat_odesl", "date_s" })
endif	

// mg_log( aData )	
cFik := eet( @aData )
aadd( aData, { cFik, "fik", "fik" } )

if lOpak
	if empty( cFik )
		Msg("Opakovane odeslani se nepovedlo !!!")
		return
	endif
endif

if OpenPOS(,2)
	if lOpak
		if RecLock()
			replace fik with cFik
		endif	
	else
		if addrec()
			replace idf with val(ret_val( aData, "idf" ))
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
			replace pkp with ret_val( aData, "pkp" )
			replace bkp with ret_val( aData, "bkp" )
		endif
	endif
endif
dbcloseall()
if !lOpak
	mg_do(cWin, "release")
endif

if lOpak
	print_tic(aData, 1)
else
	print_tic(aData, 2)
endif

return

static function ret_val( aData, cIdf )

local nPos //:= aScan( aData, { |z| z[3] == cIdf } )
local cRet

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

local aOptions:={}, cAll // , bOnclick
local cWin := "br_pos_win"

if !OpenPOS(,2)
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
	HEIGHT 430 
	WIDTH  1040
	CHILD .t.
	MODAL .t.
//	my_grid( cNWin, aArr, aOptions, , , , cNWin+"_g" )
 	my_mg_browse(cWin, alias(), aOptions )
	create button OK
		row 180
		col 840
		width 160
		height 60
		caption _I("&ReSend")
		ONCLICK Send_again() 
		tooltip _I("Try to send unsent record")
//		picture cRPath+"task-reject.png"
	end button

	create button print
		row 260
		col 840
		width 160
		height 60
		caption _I("&Print")
		ONCLICK print_again()
		tooltip _I("Print")
//picture cRPath+"task-reject.png"
	end button

	create button Back
		row 340
		col 840
		width 160
		height 60
		caption _I("Back")
		ONCLICK mg_do(cWin, "release")
		tooltip _I("Close and go back")
		picture cRPath+"task-reject.png"
	end button

end window

mg_do( cWin, "center")
mg_do( cWin, "activate")

dbclosearea()

return

static procedure send_again()

local aData := {}
local nDph 
field price, zprice, vat, idf, op,fik,bkp,pkp,pos_id,ws_id,uuid,date,time,date_s,time_s

if !empty( fik )
	Msg( "Doklad jiz byl odeslan, FIK je vyplnen !!!" )
	return
endif	

aadd( aData, { _hGetValue( hIni["COMPANY"], "VAT" ), "dic_popl", "vat" } ) 
aadd( aData, { _hGetValue( hIni["EET"], "TestMode" ), "overeni", "over" })
nDph := (Price * (1+vat/100)) - price
aadd( aData, { alltrim(str(nDph, 6, 2)),"dan1", "dph" })
aadd( aData, { strx(idf),"porad_cis", "idf" })
aadd( aData, { xmldate( date, time ),"dat_trzby", "date" }) 
aadd( aData, { xmldate( date_s, time_s ), "dat_odesl", "date_s" }) 
aadd( aData, { op,"", "op" })
aadd( aData, { uuid,"uuid_zpravy", "uuid" })
aadd( aData, { strx(price),"zakl_dan1", "dphz" })
aadd( aData, { strx(zprice),"celk_trzba", "zprice" })
aadd( aData, { vat,"", "ntax" })
aadd( aData, { alltrim(pos_id),"id_pokl", "pos_id" })
aadd( aData, { alltrim(ws_id), "id_provoz", "ws_id" })
aadd( aData, { "false", "prvni_zaslani", "first" })
aadd( aData, { "0", "rezim", "rezim" }) // bezny:0 - zjednoduseny:1

//aadd( aData, { fik,, "fik" })
//aadd( aData, { bkp,, "bkp" })
//aadd( aData, { pkp,, "pkp" })
// mg_log( aData )

send_c( "", aData )

return

static procedure print_again()

local aData := {}
local nDph, aItems 
field price, zprice, vat, idf, op,fik,bkp,pkp,pos_id,ws_id,uuid,date,time,date_s,time_s
nDph := (Price * (1+vat/100)) - price

aItems := getItems( idf, date, .T. ) // todo

//aadd( aData, { iif( lEdit, "false", "true"), "prvni_zaslani", "first" })
aadd( aData, { "true", "prvni_zaslani", "first" }) // TODO
aadd( aData, { "0", "rezim", "rezim" }) // bezny:0 - zjednoduseny:1

aadd( aData, { str(nDph, 6, 2),, "dph" })
aadd( aData, { str(idf),, "idf" })
aadd( aData, { xmldate( date_s, time_s ),, "date" }) 
aadd( aData, { xmldate( date_s, time_s ),, "date" }) 
aadd( aData, { fik,, "fik" })
aadd( aData, { op,, "op" })
aadd( aData, { uuid,, "uuid" })
aadd( aData, { strx(price),, "dphz" })
aadd( aData, { strx(zprice),, "zprice" })
aadd( aData, { vat,, "ntax" })
aadd( aData, { pos_id,, "pos_id" })
aadd( aData, { ws_id,, "ws_id" })
aadd( aData, { bkp,, "bkp" })
aadd( aData, { pkp,, "pkp" })

print_tic( aData,, aItems )

return

static procedure print_tic( aData, nCopy, aItems )

local cPrn := "", x, cFile
#define ESC CHR(27)           // Escape
#define FS  CHR(28)           // File Separation
#define GS  CHR(29)
default nCopy to 1
default aItems to {}

//cPrn += ESC + "@" + DOS_CRLF // reset printer

// codepage set
//cPrn += ESC + "t47" + DOS_CRLF //hb_eol() // latin 2  "47"  // Bixolon 1250

cPrn += FS + "p50" + DOS_CRLF //  hb_eol() // Bixolon logo print from buffer
//cPrn += GS + "(L12048" + hb_eol() // Bixolon logo print from buffer

cPrn += _hGetValue( hIni["COMPANY"], "Name") + DOS_CRLF
cPrn += _hGetValue( hIni["COMPANY"], "Address") + ", " + ;
				_hGetValue( hIni["COMPANY"], "PostCode") + " " + ;
				_hGetValue( hIni["COMPANY"], "City") + DOS_CRLF
cPrn += _I("VAT") + ": " +  _hGetValue( hIni["COMPANY"], "VAT" ) + hb_eol()
//cPrn += replicate( ".", 30 ) + DOS_CRLF
cPrn += replicate( "-", 40 ) + DOS_CRLF
cPrn += "cislo provozovny: " + ret_val( aData, "ws_id" ) + DOS_CRLF
cPrn += "pokladna: " + ret_val( aData, "pos_id" ) + DOS_CRLF

cPrn += "Datum: " + dtoc(DateXml(ret_val(aData, "date"))) + DOS_CRLF
cPrn += DOS_CRLF
cPrn += "Danovy doklad cislo: " + ret_val( aData, "idf") + DOS_CRLF + DOS_CRLF

if empty( aItems )
	cPrn += replicate( "-", 40 ) + DOS_CRLF
	if empty( ret_val( aData, "ntax" ) )
		cPrn += "Celkem cena:  " + ret_val( aData, "zprice" ) + _hGetValue( hIni["INVOICE"], "CURRENCY" ) + hb_eol() + hb_eol()
		cPrn += "Neplatce DPH" + hb_eol()
	else
		cPrn += "Platba: " + ret_val( aData, "dphz" ) + " DPH:" + str(ret_val( aData, "ntax" ),4,0) + "%" + "  " + ret_val( aData, "dph" ) + _hGetValue( hIni["INVOICE"], "CURRENCY" ) + hb_eol() + hb_eol()
		cPrn += replicate( "-", 40 ) + DOS_CRLF
		cPrn += "          Celkem: " + ret_val( aData, "zprice" ) + _hGetValue( hIni["INVOICE"], "CURRENCY" ) + DOS_CRLF
	endif
else
	//mg_log( aItems )
	cPrn += replicate( "-", 40 ) + DOS_CRLF
	cPrn += "           Pocet      Cena      Celkem" + hb_eol()
   cPrn += replicate( "-", 40 ) + DOS_CRLF
	for x:=1 to len(aItems)
					// name, unit, price, quantity, tax,
		cPrn += alltrim(aItems[x][1]) + hb_eol()
		cPrn += str(aItems[x][5],2) + iif(empty(aItems[x][5]), space(3),"%  ") +  aItems[x][2] + " " + str(aItems[x][4], 7, 1 ) + " x " + str(aItems[x][3], 8, 2) + " " + str(aItems[x][7], 8, 2 ) + hb_eol()
	next
//	cPrn += hb_eol()
	cPrn += replicate( "-", 40 ) + DOS_CRLF
	cPrn += space(23) + "Celkem: " + ret_val( aData, "zprice" ) + _hGetValue( hIni["INVOICE"], "CURRENCY" ) + DOS_CRLF
endif
cPrn += replicate( "-", 40 ) + hb_eol() + hb_eol()
// cPrn += replicate( ".", 40 ) + DOS_CRLF
cPrn += "Vyhotoveno: " + dtoc(DateXml(ret_val(aData, "date"))) + " " + TimeXml(ret_val(aData, "date")) + DOS_CRLF

if empty( ret_val( aData, "fik" ))
   cPrn += "Rezim EET: Zjednoduseny" + hb_eol()
	cPrn += "BKP: " + alltrim( ret_val( aData, "bkp" ) ) + hb_eol()
	cPrn += "PKP: " + alltrim( ret_val( aData, "pkp" ) ) + hb_eol() + hb_eol()
else
	cPrn += "Rezim EET: Bezny" + hb_eol()
	cPrn += "BKP: " + ret_val( aData, "bkp" ) + hb_eol()
	cPrn += "FIK: " + ret_val( aData, "fik" ) + hb_eol() + hb_eol()
endif

cPrn += "      Dekujeme Vam za navstevu" + hb_eol()

for x := 1 to 8
	cPrn += hb_eol() // DOS_CRLF
next

//cPrn += ESC + "d" + "1" // STAR cut
cPrn += ESC + "i" + DOS_CRLF  // bixolon cut

cPrn := hb_translate( cPrn, hb_cdpselect(), "CS852" ) // translate to codepage 

cFile := u_TempFile( "/tmp/" )
hb_memowrit( cFile, cPrn )


for x:=1 to nCopy
	hb_processRun( "cp "+ cFile + " /dev/usb/lp0")
next


//lpr( "", cPrn)
mg_log( cPrn )

deletefile( cFile )  // removed to debug activate!

return

function lpr(cSpooler, cTxt, lFile)

local cCmd := "lpr ", a, lRet
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
	msg(_I("Printer problem occured: ") + cSpooler)
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


procedure sale( lEdit )

local cWin := "simple_sale_win"
local dDat := date()
local aData := {} //, nPrice := 0
local lTax := Taxstatus()
// local aTax := GetTax()
local aItem := {}

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
	width 1000
	height 500
	CAPTION _I("Simple sale")
	CHILD .T.
	MODAL .T.
	//TOPMOST .t.
	FONTSIZE 16
	CreateControl(20, 10, cWin, "payd", _I("Date"), dDat )
	item_def( cWin, @aItem, lTax,, 50, 0 )
	create button OK
		row 320
		col 820
		width 160
		height 60
		caption _I("Send")
		ONCLICK Send_cache(cWin, aData, aItem) 
//		tooltip _I("Close and go back")
//		picture cRPath+"task-reject.png"
	end button
	create button Back
		row 400
		col 820
		width 160
		height 60
		caption _I("Back")
		ONCLICK mg_do(cWin, "release")
		tooltip _I("Close and go back")
		picture cRPath+"task-reject.png"
	end button
	create timer fill_it
		interval	1000
		action show_price( cWin, aItem, lTax )
		enabled .t.
	end timer
END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

dbcloseall()

return

static procedure send_cache( cWin, aData, aItem, lEdit )

local nPrice, nTax := 0, nPriceWithVat := 0, cFik, nIdf
local lOpak := .f.
local lTax := Taxstatus()
local aTax := GetTax(), aVat, x
local nTmp, cIAll

field idf, date, time, fik

default cWin to ""
default aItem to {}
default lEdit to .f.

if empty( cWin )
	nPrice := ret_val( aData, "dphz" )
	lOpak := .t.
endif

if !Empty(aItem)
	nPrice := 0
	for x:=1 to len(aItem)
		nPrice += aItem[x][6]
		nPriceWithVat += aItem[x][7]
	next
	aVat := calc_vat( aItem, aTax)
endif

if empty(nPrice)
	msg(_I("Price field empty!"))
	return
endif

if !lOpak
	if lTax 
		aadd(aData, { strx(nPriceWithVat), "celk_trzba", "zprice" } ) //cena s DPH
		if !empty(aVat[1][1])
			aadd(aData, { alltrim(str(aVat[1][1],10,2)), "zakl_dan1", "dphz" } ) 
			aadd(aData, { strx(aVat[1][2]), "dan1", "dph" } ) // DPH
		endif
		if !empty(aVat[2][1])
			aadd(aData, { alltrim(str(aVat[2][1],10,2)), "zakl_dan2", "dphz" } )
			aadd(aData, { strx(aVat[2][2]), "dan2", "dph" } ) // DPH
		endif
		if !empty(aVat[3][1])
			aadd(aData, { alltrim(str(aVat[3][1],10,2)), "zakl_dan3", "dphz" } )
			aadd(aData, { strx(aVat[3][2]), "dan3", "dph" } ) // DPH
		endif
	else
		aadd(aData, { str(nPrice,10,2), "celk_trzba", "zprice" } ) //cena celkem neplatce
	endif
	nIdf := GetNextPosIdf(date())	
	aadd( aData, { strx(nIdf), "porad_cis", "idf" } )
	aadd( aData, { xmlDate(date(), time()), "dat_odesl", "date_s" })
endif	

mg_log( aData )	
//cFik := eet( @aData )
cFik := "xxx-xxx-xxx-xxxx-fik"
aadd( aData, { cFik, "fik", "fik" } )

if lOpak
	if empty( cFik )
		Msg("Opakovane odeslani se nepovedlo !!!")
		return
	endif
endif

if OpenPOS(,2)
	cIAll := alias()
	if lOpak
		if RecLock()
			replace fik with cFik
		endif	
	else
		if addrec()
			replace idf with val(ret_val( aData, "idf" ))
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
			replace pkp with ret_val( aData, "pkp" )
			replace bkp with ret_val( aData, "bkp" )
		endif
	endif
endif

if !OpenPOSStav((cIAll)->Date,2)
	return 
endif

if lEdit  
	dbgotop()
	do while !eof()
		if idf == nIdf
			if Reclock()
				dbdelete()
				dbrunlock()
			endif
		endif
		dbskip()
	enddo
endif
nTmp := 0
for x:=1 to len(aItem)
	if addrec()
		replace idf with val(ret_val( aData, "idf" ))
		replace name with aItem[x][1]
		replace unit with aItem[x][2]
		replace price with aItem[x][3]
		replace quantity with aItem[x][4]
		replace tax with aItem[x][5]
		nTmp += aItem[x][7]
	endif
next
replace (cIAll)->zprice with nTmp 

dbcloseall()

if !lOpak
	mg_do(cWin, "release")
endif

if lOpak
	print_tic(aData, 1, aItem)
else
	print_tic(aData, 2, aItem)
endif

return

/* Calculate and put VAT to category */
function calc_vat( aItem, aVat )

local aRet := { {0,0,0}, {0,0,0}, {0,0,0} }
local x, y

for x := 1 to len( aItem )
	y := aScan( aVat, { |z| val( z ) == aItem[ x ][ 5 ] } )
	if y <> 0
		aRet[y][1] += aItem[x][6]
		aRet[y][2] += (aItem[x][7] - aItem[x][6])
		aRet[y][3] += aItem[x][7]
	endif
next

return aRet

procedure show_price( cWin, aItem, lTax )

local nPrice := 0, x, nTax := 0

if empty(aItem)
	return
endif
// mg_log(aItem)
for x:=1 to len(aItem)
	nPrice += aItem[x][6]
	nTax += aItem[x][7]
next

if lTax
	mg_set( cwin, "ccena", "value", "Celkem cena:" + " " + strx( nprice )+ "  " +"DPH: "+ strx( nTax - nPrice ) + "  " + "Celkem s DPH:" + " " + strx( nTax ))
else
	mg_set( cwin, "ccena", "value", "Celkem cena:" + " " + strx( nprice ))
endif

return


procedure pos_sale()

local cWin := "pos_cw"
local nWidth := 2050, nHeight := 1600
CREATE WINDOW(cWin)
	row 0
	col 0
	width nWidth
	height nHeight 
	CAPTION _I("POS sale")
	CHILD .T.
	//MODAL .T.
	TOPMOST .t.
//	FONTSIZE 16
	//  NOCAPTION .t.
//	NOSIZE .t.
	//NOSYSMENU .t.
	// INITIALSHOWMODE 5 // full screen

//	CreateControl(20, 10, cWin, "payd", _I("Date"), dDat )
//	item_def( cWin, @aItem, lTax,, 50, 0 )
	create framebox Display
		row 5
		col 945
		width 715
		height 350
		Caption "Display"
		Backcolor { 141, 170, 214 }	// BETTER IS BLACK	
		
	end framebox
	keypad( 660, 1410, .f. )

	create button Back
		col 1515
		row 935
		width 160
		height 60
		caption _I("Back")
		ONCLICK mg_do(cWin, "release")
		tooltip _I("Close and go back")
		picture cRPath+"task-reject.png"
	end button

/*
	create button OK
		row 320
		col 820
		width 160
		height 60
		caption _I("Send")
		ONCLICK Send_cache(cWin, aData, aItem) 
//		tooltip _I("Close and go back")
//		picture cRPath+"task-reject.png"
	end button
	create timer fill_it
		interval	1000
		action show_price( cWin, aItem, lTax )
		enabled .t.
	end timer
*/

END WINDOW

//mg_Do(cWin, "center")
//mg_Do( cWin, "maximize" )
mg_do( cWin, "activate" ) 

//dbcloseall()

return

static function keypad(nRow, nCol, lCreateWin)

local nSize := 62
local nMez := 5
local cWin := "numpad"
//default nRow to 25 
//default nCol to 460  
default nRow to 5 
default nCol to 5  
default lCreatewin to .t.

if lCreateWin
	Create window (cWin)
		 //child .t.
    modal .t.
	 TOPMOST .T.	
//	 nosize .T.	
//	 NOSYSMENU .T.
	 Caption "Numpad"
	 row	  25
	 col    485
    height (4 * nSize) + (3 * nMez) 
	 width  (4 * nSize) + (3 * nMez)
endif
    CREATE BUTTON B_Key_7
           ROW    nRow
           COL    nCol
           WIDTH  nSize
           HEIGHT nSize
           CAPTION "7"
           FONTBOLD .T.
			  onclick pushkey("7")
     END BUTTON

    CREATE BUTTON B_Key_8
           ROW    nRow
           COL    nCol + nSize + nMez
           WIDTH  nSize
           HEIGHT nSize
           CAPTION "8"
           FONTBOLD .T.
			  onclick pushkey("8")
     END BUTTON

    CREATE BUTTON B_Key_9
           ROW    nRow
           COL    nCol +  2 * (nSize + nMez)
           WIDTH  nSize
           HEIGHT nSize
           CAPTION "9"
           FONTBOLD .T.
			  onclick pushkey("9")
     END BUTTON

		CREATE BUTTON B_BACK
        	ROW    nRow
         COL    nCol +  3 * (nSize + nMez)
         WIDTH  nSize
         HEIGHT nSize
         CAPTION "Del"
         FONTBOLD .T.
			onclick pushkey("bck")
	   END BUTTON

		CREATE BUTTON B_Key_4
      	ROW    nRow + 1 * nSize + nMez
         COL    nCol
         WIDTH  nSize
         HEIGHT nSize
         CAPTION "4"
         FONTBOLD .T.
			onclick pushkey("4")
		END BUTTON

    CREATE BUTTON B_Key_5
           ROW    nRow + 1 * (nSize + nMez)
           COL    nCol + nSize + nMez
           WIDTH  nSize
           HEIGHT nSize
           CAPTION "5"
           FONTBOLD .T.
 			  onclick pushkey("5")
    END BUTTON

    CREATE BUTTON B_Key_6
           ROW    nRow + 1 * (nSize + nMez)
           COL    nCol + 2 * (nSize + nMez)
           WIDTH  nSize
           HEIGHT nSize
           CAPTION "6"
           FONTBOLD .T.
 			  onclick pushkey("6")
    END BUTTON

    CREATE BUTTON B_Key_1
           ROW   nRow + 2 * (nSize + nMez)
           COL   nCol          
			  WIDTH  nSize
           HEIGHT nSize
           CAPTION "1"
           FONTBOLD .T.
 			  onclick pushkey("1")
    END BUTTON

    CREATE BUTTON B_Key_2
           ROW    nRow + 2 * (nSize + nMez)
           COL    nCol + 1 * (nSize + nMez)
           WIDTH  nSize
           HEIGHT nSize
           CAPTION "2"
           FONTBOLD .T.
 			  onclick pushkey("2")
    END BUTTON

    CREATE BUTTON B_Key_3
           ROW    nRow + 2 * (nSize + nMez)
           COL    nCol + 2 * (nSize + nMez)
           WIDTH  nSize
           HEIGHT nSize
           CAPTION "3"
           FONTBOLD .T.
 			  onclick pushkey("3")
    END BUTTON
 
    CREATE BUTTON B_Key_0
           ROW    nRow + 3 *( nSize + nMez)
           COL    nCol
           WIDTH  (2 * nSize)+ nMez
           HEIGHT nSize
           CAPTION "0"
           FONTBOLD .T.
 			  onclick pushkey("0")
    END BUTTON
/*
    CREATE BUTTON B_Key_Clear
           ROW    nRow + 3 * (nSize + nMez)
           COL    nCol + 2 * (nSize + nMez)
           WIDTH  nSize
           HEIGHT nSize
           CAPTION "Clr"
           FONTBOLD .T.
			  onclick pushkey("del")
     END BUTTON
*/
    CREATE BUTTON B_Key_C
           ROW    nRow + 3 * (nSize + nMez)
           COL    nCol + 2 * (nSize + nMez)
           WIDTH  nSize
           HEIGHT nSize
           CAPTION "C"
           FONTBOLD .T.
			  onclick pushkey("C")
     END BUTTON


    CREATE BUTTON B_Enter
           ROW    nRow + 1 * (nSize + nMez)
           COL    nCol + 3 * (nSize + nMez)
           WIDTH  nSize
           HEIGHT (3 * nSize) + 2 * nMez
           CAPTION "Enter"
           FONTBOLD .T.
			  onclick pushkey("ent")
			  // VERTICAL .T.
     END BUTTON
if lCreateWin
	end window
	mg_do(cWin, "activate")
endif

return NIL

static function pushkey(cKey)

//local cWin := mg_GetLastFocusedWindowName()
//local cWin := "main_win"
local cWin :=   mg_GetMainWindowName ()
local cControl :=  mg_GETlastFOCUSEDCONTROLNAME ( cWin )
local xTmp
if !empty(cControl)
	do case
		case cKey == "del"
			xTmp := ""
		case cKey == "bck"
			xTmp := alltrim(mg_get(cWin,cControl,"value"))
			xTmp := left(xTmp,(len(xTmp)-1))
		case cKey == "ent"
			xTmp := alltrim(mg_get(cWin,cControl,"value"))
			do case
				case cControl == "vak_t"
//					find_vak(cWin, xTmp)
				case cControl == "zadanka_t"
	//				xTmp :=  xTmp+Chr(13)
//					get_barcode(xTmp+chr(13),cWin)
				case cControl == "z_kriz_vak"
//					xTmp := "&"+xTmp+Chr(13)
//					get_barcode("&"+xTmp+chr(13),cWin)										
			endcase	
		otherwise
			xTmp := alltrim(mg_get(cWin,cControl,"value")) + cKey
	endcase
	mg_set(cWin,cControl,"value", xTmp)
	mg_do(cWin,cControl,"setfocus")
endif

return .t.


