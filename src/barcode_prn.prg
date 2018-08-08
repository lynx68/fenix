/*
 * Fenix Open Source accounting system
 * Network lock functions
 *	
 * Copyright 2018 Davor Siklic (www.msoft.cz)
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

memvar cRPath, cTPath, cPath, hIni, cIni, cLog

//static cBuffer := ""

/*
****************************************************************
*** Datum:  07-03-06 12:56pm
*** Naziv: Open_Zebra_com(cPrinter)
*** Opis :
****************************************************************

function Open_Zebra_com(cPrinter)

local cTmp
default cPrinter to "p1"

cTmp := GetBarcodePrinterType() 

if InitPort(cPrinter)
	do case
		case cTmp == "Zebra S600" .or. cTmp =="Zebra TLP2844Z"
			init_z600(cPrinter, .f.)
		case cTmp == "Zebra ZT230"
			init_zZT(cPrinter, .f.)
	endcase
	return .t.
endif
Msg([Nelze pripojit tiskarnu:]+" "+ cPrinter)

return .f.

****************************************************************
*** Datum:  07-03-06 12:56pm
*** Naziv: Close_Zebra_com(cPrinter)
*** Opis :
****************************************************************

function Close_Zebra_com(cPrinter)

default cPrinter to "p1"
if lower(left(cPrinter,2)) == "lp" // if lineprinter do nothing
	return .t.
endif
ClosePort(cPrinter)

return .t.

*/


****************************************************************
*** Datum:  09-30-04 05:39am
*** Naziv: Init_zZt()
*** Opis :
****************************************************************

procedure init_zZT(cPort, lInitPort)

local cTmp := ""
default cPort to "p1"
default lInitPort to .t.

/*
if lInitPort
	if !Open_zebra_com(cPort)
		return
	endif
endif
*/

cTmp += "^XA^" + DOS_CRLF
cTmp += "^A0N,24,16^" + DOS_CRLF
cTmp += "^CI28^" + DOS_CRLF
cTmp += "^CW1,E:TT0003M_.TTF^XZ^" + DOS_CRLF
cTmp += "^A@N,24,18,e:TT0003M_.TTF^XZ^" + DOS_CRLF
cTmp += "^JUS"

lpr( cPort, cTmp )

/*
writecom(cPort, cTmp )
if lInitPort
	close_zebra_com(cPort)
endif
*/

return

****************************************************************
*** Datum:  09-30-04 05:39am
*** Naziv: Init_z600()
*** Opis :
****************************************************************

procedure init_z600(cPort, lInitPort)

local cTmp := ""
default cPort to "p1"
default lInitPort to .t.
/*
if lInitPort
	if !Open_zebra_com(cPort)
		return
	endif
endif
*/

cTmp += "^XA" + DOS_CRLF
cTmp += "^CWA,E:EEUR_UN.FNT^XZ" + DOS_CRLF
cTmp += "^JUS"

/*
writecom(cPort, cTmp )
if lInitPort
	close_zebra_com(cPort)
endif
*/

lpr( cPort, cTmp )

return

/*
****************************************************************
*** Datum:  09-30-04 05:39am
*** Naziv: zebra_font_list()
*** Opis :
****************************************************************

procedure zebra_font_list(cPort, lInitPort)

default cPort to "lp1"
default lInitPort to .t.
if lInitPort
	if !Open_zebra_com(cPort)
		return
	endif
endif

writecom(cPort, "^XA^WDE:")
writecom(cPort, "^XZ")
if lInitPort
	close_zebra_com(cPort)
endif

return
*/


****************************************************************
*** Datum:  04-04-95 09:46pm
*** Naziv: sravnaj(cStr,nChr)
*** Opis :
****************************************************************

func sravnaj(cStr, nChr, lConvert, lCenter, lNoPad)

default nChr to len(cStr)
default lConvert to .f.
default lCenter to .f.
default lNoPad to .f.
if lConvert
	cStr := hb_strtoutf8( cStr, __CHARSET__ )  //"CS852" ) 
//      cStr := translate_charset(__CHARSET__, "cp852", cStr)
endif

if lCenter
	return center(cStr,nChr,, .t.)
endif
if !lNoPad
   cStr := padright(alltrim(cStr),nChr)
endif

return cStr

****************************************************************
*** Datum:  07-31-99 04:08am
*** Naziv: Send2Zebra(nNo)
*** Opis :
****************************************************************

procedure Send2Zebra(aNiz, nNo, nFontType, lNocode, cPort)

local cFStr:="", nRow := 0, x, cPrn 
local cPoz, cBstr := "^BCN,55,N,N,N"
local cOdrazeni := "45,25", cTmp := "", nOffset := 0
local nOds := 30

default cPort to "" 
default nFontType to 5 
default nNo to 1
default lNoCode to .f.
default cPort to ""

if empty(cPort)
	cPort := FindBarcodePrinter()
endif

if empty( cPort )
	Msg( "Nenalezena zadna tiskarna car. kodu!" )
	return	
endif

nFontType := GetBarcodeType()
//nOffset := getDevOffset(cPort)

if !empty(nOffset)
	cOdrazeni := strx(nOffset)+",25"  
endif

do case
   case nFontType == 1
		cFStr := "^A3N"
   case nFontType == 2
		cFStr := "^A1N,36,28"
   case nFontType == 4
		cFStr := "^A1N,36,28"
		cOdrazeni := "240,5"
      cBStr := "^BCN,55,N,N,N"
		if !empty(nOffset)
			cOdrazeni := strx(nOffset)+",5"  
		endif
   case nFontType == 5 
		cFStr := "^A0N,36,32"
      cBStr := "^BCN,55,N,N,N"
		nOds := 34
		if empty(nOffset)
			cOdrazeni := "10,12"
		else
			cOdrazeni := strx(nOffset)+",5"  
		endif
	case nFontType == 6
		cFStr := "^A1N,36,32"
      cBStr := "^BCN,55,N,N,N"
		if empty(nOffset)
			cOdrazeni := "10,12"
		else
			cOdrazeni := strx(nOffset)+",5"  
		endif
	otherwise
 		msg("Undefined fons for printer: " +strx(nFontType))
endcase

cTmp := cTmp + "^XA"+DOS_CRLF
cTmp := cTmp + "^LH"+cOdrazeni+DOS_CRLF
for x:=1 to len(aNiz)
   do case
      case valtype(aNiz[x]) == "A"
         if len(aNiz[x]) > 2 .and. !empty(aNiz[x][3])
            cPrn := aNiz[x][3]
         else 
            cPrn := cFStr
         endif
         if len(aNiz[x]) > 3 .and. !empty(aNiz[x][4])
            cPoz := aNiz[x][4]
         else
            cPoz := "3,"+strx(nRow)
         endif
         if aNiz[x][2]  
	         if len(aNiz[x]) < 3 
           		cPoz := "30,"+strx(nRow)
	         endif
				if lNoCode
			     cTmp := cTmp + "^FO"+cPoz +cBStr+"^FD"+alltrim(aNiz[x][1])+"^FS"+DOS_CRLF
				else
					cTmp := cTmp + "^FO"+cPoz +cBStr+"^FD"+codeno(aNiz[x][1])+"^FS"+DOS_CRLF
				endif
         else
            cTmp := cTmp + "^FO" +cPoz +cPrn+"^FD"+SRAVNAJ(aNiz[x][1],,.t.,,.t.)+"^FS"+DOS_CRLF         
         endif      
      otherwise
         cTmp := cTmp + "^FO3,"+strx(nRow)+cFStr+"^FD"+SRAVNAJ(aNiz[x],,.t.,,.t.)+"^FS"+DOS_CRLF
   endcase
   nRow := nRow+nOds
next
cTmp := cTmp + "^PQ"+strx(nNo)+",0,1,Y"+DOS_CRLF
cTmp := cTmp + "^XZ"+DOS_CRLF
if nFontType == 5
   cTmp := hb_strtoutf8( cTmp, __CHARSET__ )  //"CS852" ) 
//	cTmp := translate_charset(__CHARSET__, "utf-8", cTmp)
  //memowrit(cTmp, "/tmp/zt230_print.txt")
endif

lpr(cPort, cTmp)

//endif

return

function GetBarcodeType()
  
local cType, nType
 
cType := UPPER(GetBarcodePrinterType())
do case
   case cType == "Zebra S300"
      nType :=1
   case cType == "Zebra S600"
	   nType :=2
   case cType == "EPL"
      nType := 3
   case cType == "Zebra TLP2844" .or. cType == "Zebra TLP2844Z"
      nType := 4
   case cType == "Zebra TLP2824"
      nType := 4
	case cType == "Zebra GK420T" .or. cType == "Zebra GK420"
		nType := 4 
	case cType == "Zebra ZT230" .or. cType == "Zebra ZT230T"
		nType := 5
	otherwise
		nType := 2
endcase

return nType

Function GetBarcodePrinterType()

return Alltrim(_hGetValue( hIni["Pheripherals"], "pos_device_barcode_printer_type" ))


function FindBarcodePrinter()

local cRet

cRet :=  _hGetValue( hIni["Pheripherals"], "pos_device_barcode_printer_remote_device" )  // Try if there remote port defined
if empty( cRet )
	cRet := _hGetValue( hIni["Pheripherals"], "pos_device_barcode_printer_device" )       // Try local device 
else
	cRet := GetHost() + ":" + cRet
	mg_log( cRet )
endif

return cRet

static function CodeNo(cNo)

local nNo := len(cNo)

if nNo = 3 .or. nNo = 5 .or. nNo = 7 .or. nNo = 9 .or. nNo = 11 .or. nNo = 13 .or. nNo = 15
   cNo := left(cNo,1)+">5"+substr(cNo,2)
else
   cNo := ">5"+cNo
endif

return cNo


