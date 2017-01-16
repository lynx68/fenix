/*
 * Fenix Open Source accounting system
 * Data structure
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

#include "fenix.ch"

MEMVAR cPath

FUNCTION OpenSubscriber( cFile, nMod )

LOCAL aDbf := {}
FIELD IDF, NAME
DEFAULT cFile TO "subscriber"
DEFAULT nMod to 3  

IF !File( cPath + cFile + ".dbf" )
   AAdd( aDbf, { "IDF       ", "N", 10, 0 } ) // IDF No. (search key)
   AAdd( aDbf, { "NAME      ", "C", 20, 0 } ) // Short name
   AAdd( aDbf, { "CITY      ", "C", 25, 0 } ) // City 
   AAdd( aDbf, { "COUNTRY   ", "C", 25, 0 } ) // Country
   AAdd( aDbf, { "BANKID    ", "C", 20, 0 } ) // Bank ID 
   AAdd( aDbf, { "POSTCODE  ", "C",  5, 0 } ) // Postcode
   AAdd( aDbf, { "ADDRESS   ", "C", 35, 0 } ) // Address
   AAdd( aDbf, { "FULLNAME  ", "M", 40, 0 } ) // Ful Subscriber name
   AAdd( aDbf, { "BANKNAME  ", "C", 15, 0 } ) // BankName
   AAdd( aDbf, { "PHONE     ", "C", 15, 0 } ) // Phone
   AAdd( aDbf, { "COMMENT   ", "C", 40, 0 } ) 
   AAdd( aDbf, { "ICO       ", "C", 12, 0 } ) // ICO ?
   AAdd( aDbf, { "VAT       ", "C", 14, 0 } ) // VAT (DIC)
   AAdd( aDbf, { "EMAIL     ", "C", 30, 0 } ) // Email
   AAdd( aDbf, { "DATA      ", "C", 15, 0 } ) 
   AAdd( aDbf, { "PCEN      ", "L",  1, 0 } )
   AAdd( aDbf, { "EXT       ", "L",  1, 0 } )
   AAdd( aDbf, { "CHK       ", "C",  1, 0 } )
   AAdd( aDbf, { "KATEGORY  ", "C",  1, 0 } ) 
   AAdd( aDbf, { "IBAN      ", "C", 14, 0 } ) // Intern. Bank Account No.
   AAdd( aDbf, { "SWIFT     ", "C", 14, 0 } ) // Bank swift code
	
   dbCreate( cPath + cFile, aDbf )
   if !OpenDB( cPath + cFile)
		return .F.
	endif
   INDEX ON idf  TAG "idf"  TO ( cPath + cFile )
   INDEX ON name TAG "name" TO ( cPath + cFile )
   // index on idf tag "idf" to cFile
elseif !OpenDB(cPath + cFile, nMod)
	RETURN .F.
endif

// ordSetFocus ( "idf" )
// ordScope( 0, 2 )
// ordScope( 1, NIL )

RETURN .T.
/*
// ***************************************************************
// ** Datum:  11/30/93 05:42pm
// ** Naziv: OpenInvoice()
// ** Opis : Otvara databaze faktura i stavki u zavisnosti od
// **       godine ili ih kreira ako ne postoje
// ***************************************************************

FUNCTION OpenInvoice( dat, mod )

   FIELD invoice, date, date_pr
   LOCAL cFile, aDbf1 := {}

	DEFAULT dat to date()
   DEFAULT mod TO 3 // open mode (3-readonly) default

   cFile := "fakt" + Right( DToC( dat ), 2 )

   IF !File( cPath + cFile + ".dbf" )
      AAdd( aDbf1, { "INVOICE", "N", 14, 0 } )
      AAdd( aDbf1, { "KUPAC",  "N", 10, 0 } )
      AAdd( aDBF1, { "DATE",  "D", 8, 0 } )
      AAdd( aDBF1, { "DATE_SP",  "D", 8, 0 } )
      AAdd( aDBF1, { "DATE_PR",  "D", 8, 0 } )
      AAdd( aDBF1, { "PR_VYP",  "C", 10, 0 } )
      AAdd( aDbf1, { "DODAVKA", "C", 14, 0 } )
      AAdd( aDbf1, { "PRICE",   "N", 10, 2 } )
      AAdd( aDbf1, { "NSTIL",  "N", 1, 0 } )
      AAdd( aDbf1, { "NDODPO", "N", 1, 0 } )
      AAdd( aDbf1, { "OP",     "C", 10, 0 } )
      AAdd( aDbf1, { "TIME",  "C", 8, 0 } )
      AAdd( aDbf1, { "OBH_PR", "C", 15, 0 } )
      AAdd( aDbf1, { "STAVDPH", "L", 1, 0 } )
      AAdd( aDbf1, { "FAKT",   "M", 10, 0 } )
      AAdd( aDbf1, { "PRED",   "M", 10, 0 } )
      AAdd( aDbf1, { "OBJEDN", "C", 20, 0 } )
      AAdd( aDbf1, { "ZFAKT", "N", 14, 0 } )
      AAdd( aDbf1, { "PRICE_SUM", "N", 10, 2 } )
      AAdd( aDbf1, { "UZP",   "D", 8, 0 } )
      AAdd( aDbf1, { "CANCELED", "L", 1, 0 } )
		AAdd( aDbf1, { "UUID", "C", 36, 0 } )
		AAdd( aDbf1, { "FIK", "C", 40, 0 } )

      dbCreate( cPath + cFile, aDbf1 )
      IF !OpenDB( cPath + cFile, mod )
         RETURN .F.
      ENDIF
      INDEX ON invoice TAG "invoice" TO ( cPath + cFile )
      INDEX ON date TAG "date" TO ( cPath + cFile )
      INDEX ON date_pr TAG "date_pr" TO ( cPath + cFile )
      //SET INDEX TO
      // SET INDEX TO (fpath+arhiva+"1"),(fpath+arhiva+"2"),(fpath+arhiva+"3")
   ELSEIF !OpenDB( cPath + cFile, mod )
      RETURN .F.
   ENDIF

   RETURN .T.
*/


func OpenPOS( dDat, nMode )

return OpenInv( dDat, nMode, "pos" )

func OpenPOSStav( dDat, nMode )

return OpenStav( dDat, nMode, "posst" )

****************************************************************
*** Datum:  11/30/93 05:42pm
*** Naziv: OpenINV()
*** Opis : Open invoice database 
****************************************************************

func OpenINV( dat, mod, cName )

field idf, date
local cArch, adbf1 :={}

default dat to date()
default mod to 3 
default cName to "inv"

cArch := cPath + cName + right(dtoc(dat),2)

if !file( cArch + ".dbf" )
	aadd(aDbf1, {"IDF","N",14,0})
	aadd(aDbf1, {"CUST_N",  "C",20,0})
	aadd(aDbf1, {"CUST_IDF","N",10,0})
	aadd(aDbf1, {"DATE",  "D", 8,0})
	aadd(aDbf1, {"DATE_SP",  "D", 8,0})
	aadd(aDbf1, {"DATE_PR",  "D", 8,0})
	aadd(aDbf1, {"PR_VYP",  "C",10,0})
	aadd(aDbf1, {"DODAVKA","C",14,0})
	aadd(aDbf1, {"PRICE",   "N",10,2})
	aadd(aDbf1, { "VAT",     "N", 10, 2 } )

	aadd(aDbf1, {"TYPE",  "N",1,0})
	aadd(aDbf1, {"NDODPO", "N",1,0})
	aadd(aDbf1, {"OP",     "C",10,0})  // Operator       
	aadd(aDbf1, {"TIME",  "C", 8,0})
	aadd(aDbf1, {"OBH_PR", "C",15,0})
	aadd(aDbf1, {"STATTAX","L", 1,0})
	aadd(aDbf1, {"FAKT",   "M",10,0})
	aadd(aDbf1, {"PRED",   "M",10,0})
	aadd(aDbf1, {"OBJEDN", "C",20,0})
	aadd(aDbf1, {"ZIDF", "N",14,0})
	aadd(aDbf1, {"ZPRICE", "N",10,2})
	aadd(aDbf1, { "UZP",     "D",  8, 0 } )
	aadd(aDbf1, { "STORNO",  "L",  1, 0 } )
 	aadd(aDbf1, { "UUID",    "C", 36, 0 } )
	aadd(aDbf1, { "FIK",     "C", 40, 0 } )
	aadd(aDbf1, { "BKP",     "C", 55, 0 } )
	aadd(aDbf1, { "PKP",     "C", 350, 0 } )
	aadd(aDbf1, { "DATE_S",  "D",  8, 0 } )  // sending date ( EET )
	aadd(aDbf1, { "TIME_S",  "C",  8, 0 } )  // sending time ( EET )
	aadd(aDbf1, { "POS_ID",  "C",  8, 0 } )  // cache dr.identification 
	aadd(aDbf1, { "WS_ID",   "C",  8, 0 } )  // workshop identification 
	dbcreate( cArch, adbf1)
	if !OpenDB( cArch, mod )
		return .f.
	endif
	INDEX ON IDF TAG "IDF" TO ( cArch )
	INDEX ON date TAG "DATE" TO ( cArch )
elseif !OpenDB( cArch, mod )
	return .f.
endif

return .t.

****************************************************************
*** Datum:  11/30/93 06:59pm
*** Naziv: OpenStav
*** Opis : otvara/ kreira ako ne postoji bazu stavki
****************************************************************

func OpenStav( dDat, nMod, cName )


LOCAL aDbf1 :={}, cArh

field idf

DEFAULT dDat TO date()
default nMod to 1
default cName to "stav"

cArh := cPath + cName + right(dtoc(dDat),2)

aadd(aDbf1, {"IDF","N",14,0})
aadd(aDbf1, {"NAME", "C", 50, 0})
aadd(aDbf1, {"UNIT", "C", 5, 0})
aadd(aDbf1, {"QUANTITY","N",8,1})
AADD(aDbf1, {"SERIAL_NO","M",10,0})
AADD(aDbf1, {"BACK","L",1,0})
aadd(aDbf1, {"DATE","D",4,0})
aadd(aDbf1, {"PRICE","N",10,2})
aadd(aDbf1, {"TAX",   "N", 2, 0})

if !file( cArh +".dbf" )
	dbcreate(cArh, adbf1)
	if !OpenDB(cArh, nMod)
		return .f.
	endif
	INDEX ON IDF TAG "IDF" TO ( cArh )
	dbclosearea()
endif

if !OpenDB( cArh, nMod )
	return .f.
endif

return .t.

****************************************************************
*** Datum:  08-12-95 11:25pm
*** Naziv: OpenItems( ... )
*** Opis : Open (Generating) items database 
****************************************************************

func OpenItems(cArch, nMod, lGen)

local adbf1 :={} 
field idf, name

default cArch to "items"
default nMod to 1
default lGen to .f.

cArch := lower( ALLTRIM( cArch ) )

if lGen .and. !file( cPath + cArch + ".dbf" )
	aadd(adbf1, {"IDF"   , "N",10, 0}) 
	aadd(adbf1, {"N_IDN", "C",18, 0})
	aadd(adbf1, {"T_IDN", "N", 4, 0})
	aadd(adbf1, {"NAME",  "C",50, 0})
	aadd(adbf1, {"UNIT",  "C", 5, 0})
	aadd(adbf1, {"WH",    "C",20, 0})
	aadd(adbf1, {"TYPE",  "C",30, 0})
	aadd(adbf1, {"PRICE",  "N",10, 2})
	aadd(adbf1, {"TAX",   "N", 2, 0})
	aadd(adbf1, {"MONTAZ","N",10, 2})
	aadd(adbf1, {"MDPH",  "N", 2, 0})
	aadd(adbf1, {"DOD",   "N", 4, 0})
	aadd(adbf1, {"COMM",  "C",20, 0})
	aadd(adbf1, {"DOV",   "L", 1, 0})
	aadd(adbf1, {"DESC",  "M",10, 0})
	aadd(adbf1, {"EEE",   "C", 8, 0})
	aadd(adbf1, {"OPN",   "N",10, 0})
	aadd(adbf1, {"REZIE", "N",10, 0})
	aadd(adbf1, {"ZISK",  "N",10, 0})
	aadd(adbf1, {"JCENA", "N",10, 2})
	aadd(adbf1, {"KOL",   "N",10, 2})
	aadd(adbf1, {"PERC",  "N", 8, 3})
	aadd(adbf1, {"LEVEL", "N", 4, 0})
	AADD(adbf1, {"SERIAL_NO","M",10,0})
	AADD(adbf1, {"ZD",    "C",14,0})
	AADD(adbf1, {"DODAVKA","C",14,0})
	AADD(adbf1, {"KCENA","N",10,2})
	aadd(aDbf1, {"inv_i", "L", 1,0})
	aadd(aDbf1, {"sto_i", "L", 1,0})
	aadd(aDbf1, {"cr_i", "L", 1,0})
	aadd(aDbf1, {"ean", "C", 13,0})

	dbcreate(cPath + cArch, aDbf1)
	if !OpenDB(cPath + cArch, nMod)
		return .f.
	endif
	INDEX ON IDF  TAG "IDF"  TO ( cPath + cArch )
	INDEX ON NAME TAG "NAME" TO ( cPath + cArch )
	INDEX ON NAME TAG "EAN"  TO ( cPath + cArch )

elseif !OpenDB( cPath + cArch, nMod)
	return .f.
endif

return .t.

****************************************************************
*** Datum:  04-28-98 09:06pm
*** Naziv: OpenStore()
*** Opis : Otvaranje radne baze magacina
****************************************************************

func OpenStore(nSkl, nMod, cArch, lGen)

FIELD MAT, DATUM_N, idf, date_b
local aDbf1 :={}
default nMod to 1
default nSkl to 1 // alltrim(str(radni_konto))
default cArch to "store" + strx(nSkl)
default lGen to .f.

if lGen .and.  !file( cPath + cArch + ".dbf")
	aadd(aDbf1, {"MAT",       "N", 5,0})  // item
	aadd(aDbf1, {"NAME",      "C",50,0})  // item name
	AADD(aDbf1, {"DOCUMENT",  "C",16,0})  
	aadd(aDbf1, {"CUSTUMER",  "N",10,0})
	AADD(aDbf1, {"DATE_B",    "D", 8,0})  // bay date
	AADD(aDbf1, {"TIME_B",    "C", 8,0})  // bay time
	aadd(aDbf1, {"UNIT",		  "C", 5,0})  // unit	
	aadd(aDbf1, {"QUANT_B",   "n",10,1})  // quantity
	aadd(aDbf1, {"PRICE_B",   "N",10,2})  // price
	aadd(aDbf1, {"LOOT",      "C",16,0})  // loot
	aadd(aDbf1, {"EXP",       "D", 8,0})  // expiration date
	AADD(aDbf1, {"STATE",     "N",10,1})  
	aadd(aDbf1, {"VAT",       "N", 2,0}) 
	aadd(aDbf1, {"IDF",       "N",10,0})
	aadd(aDbf1, {"IDFF",      "N",10,2})
	aadd(aDbf1, {"SPEC",      "N", 1,0})
	aadd(aDbf1, {"OP",        "C",10,0})  // operator
	aadd(aDbf1, {"TIME_W",    "C", 8,0})   
	aadd(aDbf1, {"DATE_W",    "D", 8,0})
	aadd(aDbf1, {"EAN",       "C",13,0})  // ean code
	aadd(aDbf1, {"PIC",       "P",10,0})  // picture
	dbcreate( cPath + cArch, aDbf1 )
	if !OpenDB(cPath + cArch, nMod)
		return .f.
	endif
	INDEX ON MAT TAG "MAT" TO ( cPath + cArch )
	INDEX ON DATE_B TAG "DATE_B" TO ( cPath + cArch )
	INDEX ON IDF TAG "IDF" TO ( cPath + cArch )
elseif !OpenDB( cPath + cArch, nMod)
	return .f.
endif

return .T.

****************************************************************
*** Date :  04-28-98 09:06pm
*** Name: OpenStoreDef(...)
*** Opis : Open / create store definition 
****************************************************************

func OpenStoreDef( nMod, lGen)

FIELD MAT, DATUM_N, idf, date_b
local aDbf1 :={}
local cArch := "stdef"
default nMod to 1
default lGen to .f.

if lGen .and.  !file( cPath + cArch + ".dbf")
	aadd(aDbf1, {"IDF",       "N", 5,0})
	aadd(aDbf1, {"NAME",      "C",50,0})
	aadd(aDbf1, {"DATE",    "D", 8,0})
	aadd(aDbf1, {"NOIN",    "N", 10,0})
	aadd(aDbf1, {"NOUT",    "N", 10,0})
	dbcreate( cPath + cArch, aDbf1 )
	if !OpenDB(cPath + cArch, nMod)
		return .f.
	endif
elseif !OpenDB( cPath + cArch, nMod)
	return .f.
endif

return .T.

****************************************************************
*** Date :  04-28-98 09:06pm
*** Name: OpenLog(...)
*** Opis : Open / create store definition 
****************************************************************

func OpenLog( nMod )

FIELD MAT, DATUM_N, idf, date_b
local aDbf1 :={}
local cArch := "log"
default nMod to 1

if !file( cPath + cArch + ".dbf")
	aadd(aDbf1, {"IDF",    "N", 5,0})
	aadd(aDbf1, {"UUID",   "C",40,0})
	aadd(aDbf1, {"DATE",   "D", 8,0})
	aadd(aDbf1, {"TIME",   "C", 8,0})
	aadd(aDbf1, {"LOG",    "M", 10,0})
	aadd(aDbf1, {"LOG1",   "M", 10,0})
	aadd(aDbf1, {"OP",     "C", 10,0})

	dbcreate( cPath + cArch, aDbf1 )
	if !OpenDB(cPath + cArch, nMod)
		return .f.
	endif
elseif !OpenDB( cPath + cArch, nMod)
	return .f.
endif

return .T.


