/*
 * $Id: msgf.prg,v 1.9 2005-12-21 23:21:03 siki Exp $
 */

// ***************************************************************
// ** File:  MsgF.prg
// ** Author: (c) MSoft All Rights Reserved
// ** Date:  05-04-94 00:54am
// ** Notes: funkcije poruka
// ***************************************************************

/*  $DOC$
 *  $FUNCNAME$
 *     Msg()
 *  $CATEGORY$
 *     Menu
 *  $ONELINER$
 *     Symple Message function
 *  $SYNTAX$
 *     Msg( <cText>, [nSec] )
 *  $ARGUMENTS$
 *     <cText>   Message Text
 *
 *     <nSec> Seconds to show. Default is 0, Wait to the keypres
 *
 *  $RETURNS$
 *     NIL
 *  $DESCRIPTION$
 *
 *  $EXAMPLES$
 *
 *            Msg( "Halo", 3 )
 *
 *  $END$
 */

#include "inkey.ch"
#include "colors.ch"
#include "commands.ch"

MEMVAR m_x, m_y, getlist, h
MEMVAR col

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

