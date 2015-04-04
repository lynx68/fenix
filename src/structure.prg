// Create databases

#include "commands.ch"
MEMVAR cPath

FUNCTION CreateSubscriber()

   LOCAL aDbf := {}
   LOCAL cFile := "subscribers"

   AAdd( aDbf, { "IDF       ", "N",  4, 0 } )
   AAdd( aDbf, { "NAME      ", "C", 20, 0 } )
   AAdd( aDbf, { "CITY      ", "C", 25, 0 } )
   AAdd( aDbf, { "COUNTRY   ", "C", 25, 0 } )
   AAdd( aDbf, { "BANKID    ", "C", 20, 0 } )
   AAdd( aDbf, { "POSTCODE  ", "N",  5, 0 } )
   AAdd( aDbf, { "ADRESS    ", "C", 35, 0 } )
   AAdd( aDbf, { "FULNAME   ", "M", 40, 0 } )
   AAdd( aDbf, { "BANKNAME  ", "C", 15, 0 } )
   AAdd( aDbf, { "TELEFON   ", "C", 15, 0 } )
   AAdd( aDbf, { "COMMENT   ", "C", 40, 0 } )
   AAdd( aDbf, { "ICO       ", "C", 12, 0 } )
   AAdd( aDbf, { "DICO      ", "C", 14, 0 } )
   AAdd( aDbf, { "EMAIL     ", "C", 15, 0 } )
   AAdd( aDbf, { "DATA      ", "C", 15, 0 } )
   AAdd( aDbf, { "PCEN      ", "L",  1, 0 } )
   AAdd( aDbf, { "EXT       ", "L",  1, 0 } )
   AAdd( aDbf, { "CHK       ", "C",  1, 0 } )
   AAdd( aDbf, { "KATEGORY  ", "C",  1, 0 } )

   dbCreate( cPath + cFile, aDbf )
   if !OpenDB( cPath + cFile)
		return .F.
	endif
   INDEX ON ( cFile )->idf  TAG "idf"  TO ( cPath + cFile )
   INDEX ON ( cFile )->name TAG "name" TO ( cPath + cFile )
   // index on idf tag "idf" to cFile
   ordSetFocus ( "idf" )
   ordScope( 0, 2 )
   ordScope( 1, NIL )
   dbCloseArea()

   RETURN .T.

// ***************************************************************
// ** Datum:  11/30/93 05:42pm
// ** Naziv: OpenFAKT()
// ** Opis : Otvara databaze faktura i stavki u zavisnosti od
// **       godine ili ih kreira ako ne postoje
// ***************************************************************

FUNCTION OpenInvoice( dat, mod )

   FIELD faktura, datum, datum_pr
   LOCAL cFile, aDbf1 := {}

	DEFAULT dat to date()
   DEFAULT mod TO 3 // open mode (3-readonly) default

   cFile := "fakt" + Right( DToC( dat ), 2 )

   IF !File( cFile + ".dbf" )
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
      SET INDEX TO
      // SET INDEX TO (fpath+arhiva+"1"),(fpath+arhiva+"2"),(fpath+arhiva+"3")
   ELSEIF !OpenDB( cPath + cFile, mod )
      RETURN .F.
   ENDIF

   RETURN .T.

