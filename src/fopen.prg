/*
 * Fenix Open Source accounting system
 * open db
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
#include "marinas-gui.ch"

#define NET_WAIT     0.5   // Seconds to wait between retries

// static cDBFCP := "CSKAMC"
STATIC cDBFCP := "CSISO"

// ***************************************************************
// ** Datum:  12/08/93 01:15am
// ** Naziv: OpenDB(imef [, mode] [,lQ])
// ** Opis : Otvara databazu u mrezi
// ** Napomena : Imef
// **   - Naziv datoteke, ako je ekstenzija razlicita
// **     od dbf treba je zadati                  (Char)
// **   Mode
// **   - Mod u kom treba orvoriti dbf.        (Num)
// **         1 - Eksluzivno
// **         2 - Shared
// **         3 - Read Only
// **  lQ - Prijaviti ako ne postoji. Default je .T.
// **       tj. prijaviti.                           (Logical)
// **  lNoIndex  - Otvara bez indexa
// ***************************************************************

FUNCTION OpenDB( ImeF, Mode, lQ, lNoIndex, cDBF_CP )

   LOCAL lForever, What_is, nSeconds := 4, restart := .T.

   DEFAULT lQ TO .T.
   DEFAULT lNoIndex TO .F.
   DEFAULT Imef TO ""
   DEFAULT cDBF_CP TO "CSISO"
   IF cDBFCP <> cDBF_CP
      cDBFCP := cDBF_CP
   ENDIF
   lForever := ( nSeconds == 0 )
   IF Empty( ImeF )
      Msg( [ Nespr vn˜ parametr ], 6 )
      RETURN .F.
   ENDIF

   DO WHILE restart
      // Keep trying as long as our time's not up
      DO WHILE ( lForever .OR. ( nSeconds > 0 ) )
         What_is := NetUse( Imef, Mode, lQ, lNoIndex )
         IF What_is = 1 .OR. What_is = 3
            EXIT
         ENDIF
         Inkey( NET_WAIT )     // Wait
         nSeconds -= NET_WAIT
      ENDDO

      DO CASE
      CASE What_Is = 1
         RETURN .T.
      CASE What_Is = 2 .AND. lQ
         IF MsgAsk( [ Datab ze ] + " " + ImeF + " " + [je nep©¡stupn . Zkusit znovu A/N ?] )
            restart := .T.
            nSeconds := 4
         ELSE
            dbCloseAll()
            RETURN .F.
         ENDIF
      CASE What_Is = 3 .OR. ( What_Is = 2 .AND. !lQ )
         RETURN .F.
      ENDCASE
   ENDDO

   RETURN .F.

// **********************************************************************************
// **  Naziv: NetUse(imef)
// **  Opis : Ispituje da li postoji baza imef i pripadajuci indeksni fajlovi
// **         otvara bazu sa ili bez indeksa i vraca .t., ako ne uspe vraca .f.
// ******************************************************************************

STATIC FUNC netuse( imef, OpenMode, lQ, lIndx )

   LOCAL fnamei1, fnamei2, fnamei3, fnamei4, fNamei5
   LOCAL work_area,  in  // , imefexs
   LOCAL otvori := 0
   LOCAL ind
   LOCAL cFile, cPath, cAll

   DEFAULT OpenMode TO 1

   imef := AllTrim( Lower( imef ) )
   cFile := mfilename( imef )
   cPath := filepath( imef )
   cAll := filewoext( imef )
   IF Empty( cFile )
      Msg( _I("Database name was not entered") + imef, 5 )
      RETURN 3
   ENDIF
   in := At( ".", cFile )     // proverava da li je prisutna ekstenzija
   IF in = 0                                 // AKO NIJE
      cFile := cFile + ".dbf"       // DODAJE EKSTENZIJU
   ENDIF

   work_area := Select( cAll )
   IF Work_area <> 0           // Proverava da li je baza vec otvorena
      SELECT( Work_area )   // ako je otvorena uzima je za radnu
      RETURN 1          // i vraca kao da je otvorio bazu
   ENDIF
   IF File ( cPath + cFile )    // ako postoji dbf fajl
      ind := myIndexExt()
      FNamei1 := cPath + cAll + "1"
      FNamei2 := cPath + cAll + "2"
      FNamei3 := cPath + cAll + "3"       // i ako postoji ntx fajl
      FNamei4 := cPath + cAll + "4"
		FNamei5 := cPath + cAll 
      DO CASE
      CASE File ( FNamei1 + ind ) .AND. File ( FNamei2 + IND ) .AND. File ( FNamei3 + IND ) .AND. File ( FNamei4 + IND )
         otvori := 4
      CASE File ( FNamei1 + IND ) .AND. File ( FNamei2 + IND ) .AND. File ( FNamei3 + IND )
         otvori := 3
      CASE File ( FNamei1 + IND ) .AND. File ( FNamei2 + IND )
         otvori := 2
      CASE File ( FNamei1 + IND )
         otvori := 1
		CASE File ( FNamei5 + IND )		
			otvori := 5
      ENDCASE
      IF lIndx
         otvori := 0
      ENDIF
      // If !Open_Check(1+otvori,lQ)   // test for free handle
      // return 3
      // endif
      // If !IsDbf(imefexs)
      // Msg("Databaze " + imef + " je poskozena !!!!!")
      // WriteMsg("File " + imef + " is corrupted !!!!!!")
      // return 3
      // EndIF
#ifdef __HARBOUR__
      // msg("Open with CP: " + cDBFCP)
      DO CASE
      CASE openmode = 1
         USE ( cPath + cFile ) NEW EXCLUSIVE CODEPAGE cDBFCP  // inace samo dbf
      CASE openmode = 2
         USE ( cPath + cFile ) NEW SHARED CODEPAGE cDBFCP  // inace samo dbf
      CASE openmode = 3
         USE ( cPAth + cFile ) NEW SHARED READONLY CODEPAGE cDBFCP // inace samo dbf
      ENDCASE
#else
      DO CASE
      CASE openmode = 1
         USE ( cPath + cFile ) NEW EXCLUSIVE   // inace samo dbf
      CASE openmode = 2
         USE ( cPath + cFile ) NEW SHARED   // inace samo dbf
      CASE openmode = 3
         USE ( cPAth + cFile ) NEW SHARED READONLY  // inace samo dbf
      ENDCASE
#endif

      IF NetErr()
         RETURN 2
      ENDIF
      DO CASE
		CASE otvori == 5
			SET INDEX TO ( Fnamei5 )
      CASE otvori = 4
         SET INDEX to ( Fnamei1 ), ( Fnamei2 ), ( Fnamei3 ), ( Fnamei4 )
      CASE otvori = 3
         SET INDEX to ( Fnamei1 ), ( Fnamei2 ), ( Fnamei3 )
      CASE otvori = 2
         SET INDEX to ( Fnamei1 ), ( Fnamei2 )
      CASE otvori = 1
         SET INDEX to ( Fnamei1 )
      ENDCASE
      RETURN 1
   ELSE
      IF lQ
         Msg( [ P©¡stup k datab zi ] + " " + cFile + " " + [nen¡ mo‘n˜!?!], 4 )   // NEMAA !?!
         dbCloseAll()
      ENDIF
      RETURN 3
   ENDIF

   RETURN 1

// ***************************************************************
// ** Datum:  04-27-95 08:55am
// ** Naziv: myIndexExst()
// ** Opis :
// ***************************************************************

FUNC myIndexExt()

   LOCAL drv := Upper( dbSetDriver() ), ret := ".ntx"

   DO CASE
   CASE drv == "DBFNTX"
      ret := ".ntx"
   CASE drv == "DBFCDX"
      ret := ".cdx"
   CASE drv == "SIXNSX"
      ret := ".nsx"
   CASE drv == "DBFNSX"
      ret := ".nsx"
   CASE DRV == "SIXCDX"
      ret := ".idx"
   ENDCASE

   RETURN ret
