// Create databases

//#include "commands.ch"
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
   AAdd( aDbf, { "EMAIL     ", "C", 25, 0 } ) // Email
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

// ***************************************************************
// ** Datum:  11/30/93 05:42pm
// ** Naziv: OpenFAKT()
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


****************************************************************
*** Datum:  11/30/93 05:42pm
*** Naziv: OpenFAKT()
*** Opis : Otvara databaze faktura i stavki u zavisnosti od
***       godine ili ih kreira ako ne postoje
****************************************************************

func OpenINV(dat,mod)

field idf, date
local arhiva, adbf1 :={}

default dat to date()
default mod to 3

arhiva := cPath+"inv"+ right(dtoc(dat),2)

if !file(arhiva+".dbf")
	aadd(adbf1, {"IDF","N",14,0})
	AADD(adbf1, {"CUST_N",  "C",20,0})
	AADD(adbf1, {"CUST_IDF","N",10,0})
	AADD(ADBF1, {"DATE",  "D", 8,0})
	AADD(ADBF1, {"DATE_SP",  "D", 8,0})
	AADD(ADBF1, {"DATE_PR",  "D", 8,0})
	AADD(ADBF1, {"PR_VYP",  "C",10,0})
	AADD(adbf1, {"DODAVKA","C",14,0})
	aadd(adbf1, {"PRICE",   "N",10,2})
	aadd(adbf1, {"TYPE",  "N",1,0})
	aadd(adbf1, {"NDODPO", "N",1,0})
	aadd(adbf1, {"OP",     "C",10,0})
	aadd(adbf1, {"TIME",  "C", 8,0})
	aadd(adbf1, {"OBH_PR", "C",15,0})
	aadd(adbf1, {"STATTAX","L", 1,0})
	aadd(adbf1, {"FAKT",   "M",10,0})
	aadd(adbf1, {"PRED",   "M",10,0})
	aadd(adbf1, {"OBJEDN", "C",20,0})
	aadd(adbf1, {"ZIDF", "N",14,0})
	aadd(adbf1, {"ZPRICE", "N",10,2})
	aadd(adbf1, {"UZP",   "D",8,0})
	aadd(adbf1, {"STORNO","L",1,0})
   dbcreate(arhiva, adbf1)
	if !OpenDB(arhiva,mod)
		return .f.
	endif
	INDEX ON IDF TAG "IDF" TO (arhiva)
	INDEX ON date TAG "DATE" TO (arhiva)
elseif !OpenDB(arhiva,mod)
	return .f.
endif
return .t.

****************************************************************
*** Datum:  11/30/93 06:59pm
*** Naziv: OpenStav
*** Opis : otvara/ kreira ako ne postoji bazu stavki
****************************************************************

func OpenStav(dat,mod, ARHIVA2)

field idf
LOCAL adbf1 :={}
DEFAULT dat TO date()
default mod to 1
DEFAULT arhiva2 TO cPath+"stav"+ right(dtoc(dat),2)

aadd(adbf1, {"IDF","N",14,0})
aadd(adbf1, {"NAME", "C", 50, 0})
aadd(adbf1, {"UNIT", "C", 5, 0})
aadd(adbf1, {"QUANTITY","N",8,1})
AADD(adbf1, {"SERIAL_NO","M",10,0})
AADD(adbf1, {"BACK","L",1,0})
aadd(adbf1, {"DATE","D",4,0})
aadd(adbf1, {"PRICE","N",10,2})
aadd(adbf1, {"TAX",   "N", 2, 0})

if !file(arhiva2+".dbf")
	dbcreate(arhiva2, adbf1)
	if !OpenDB(arhiva2,mod)
		return .f.
	endif
	INDEX ON IDF TAG "IDF" TO (arhiva2)
	dbclosearea()
endif

if !OpenDB(arhiva2,mod)
	return .f.
endif

return .t.


