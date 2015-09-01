/*
 * Fenix Open Source accounting system
 * Message functions
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

// *******************************************************************************
// *** NAZIV : Msg (Text, Sec)
// *** OPIS  : Ispisuje i ceka Sec sekundi
// *******************************************************************************

PROCEDURE Msg( Text, Sec )

   DEFAULT Sec TO 0

   mg_MsgInfo( Text )

   RETURN


// ***************************************************************
// ** Datum:  06-05-94 02:12am
// ** Naziv: MsgAsk(cAsk)
// ** Opis : Message sa odgovorom
// ***************************************************************

FUNC MsgAsk( cAskYes, cAskNo )

   DEFAULT cAskNo TO ""

   RETURN mg_msgyesno( cAskYes, cAskNo )

// ***************************************************************
// ** Datum:  11/01/93 07:19pm
// ** Naziv: upitok(cText, lAnoNe, cIDN)
// ** Opis : Postavlja upit (A/N) i vraca logicku vrednost (upit)
// **      AnoNe je logicki argument od koga zavisi default odgovor
// **      IDN   je identifikacija menija ako je potrebno vezati
// **      neku help informaciju za specificno pitanje
// ***************************************************************
/*
FUNC UpitOk( Text, AnoNe, idn )

   LOCAL cVim,lenght, xx, yy

   DEFAULT anone TO .F.  // default "Ne"
   DEFAULT idn TO "mezz3"
   iif( anone, cVim := "A", cVim := "N" )
   xx := m_x; yy := m_y
   h[ 1 ] := ""
   lenght := Len( text ) + 3
   box( idn, 1, lenght, .T. )
   CLEAR TYPEAHEAD
   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY TEXT GET cVim PICT "@! A"
      READ
      IF LastKey() == K_ESC
         BoxC()
         m_x := xx; m_y := yy
         RETURN .F.
      ENDIF
      IF cVim $ "AYDN"
         EXIT
      ENDIF
   ENDDO
   boxc()
   m_x := xx; m_y := yy
   IF cVim $ "AYD"
      RETURN .T.
   ENDIF

   RETURN .F.
*/

