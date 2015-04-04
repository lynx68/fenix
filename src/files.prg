/*
 * $Id: files.prg,v 1.14 2008-11-18 09:19:18 siki Exp $
 */

#include "common.ch"
#include "fileio.ch"
#include "directry.ch"
#include "set.ch"
#include "commands.ch"

#ifdef __UNIX__
#define ENDLINE chr(10)
#else
#define ENDLINE chr(13)+chr(10)
#endif

MEMVAR fpath

// FileRead function like memoread but with offset and length
FUNCTION FileRead( cFileName, nOffset, nLength ) // --> Contents, max 63K

   LOCAL csString := ""
   LOCAL nsFileHandle := 0
   LOCAL nBytes := 0

   DEFAULT nOffset TO 0


   IF ( nsFileHandle := FOpen( cFileName, FO_READ ) ) == -1   // Error if -1
      // OutStd( "REM: Error "+ltrim(str(Ferror()))+" attempting to open "+cFileName+ENDLINE)
      Msg( [ Nepovedlo se otevrit soubor: ] + " " + cFileName )
      RETURN ""
   ELSE
      DEFAULT nLength TO FSeek( nsFileHandle, 0, FS_END ) // Seek to EOF for filesize
#ifndef __CLIP__
      IF nLength > 64000   // max Clipper string length is 65000, but be safe.
         nLength := 64000
      ENDIF
#endif
      FSeek( nsFileHandle, nOffset, FS_SET )       // go to offset posn
      csString := Space( nLength )
      nBytes := FRead( nsFileHandle, @csString, nLength )
      IF nBytes < nLength  // unexpected
         csString := SubStr( csString, 1, nBytes )
      ENDIF
      FClose( nsFileHandle )
   ENDIF

   RETURN csString

FUNCTION U_TempFile( cPath, cExtn, lCreate )   // -> MDDHMMSS.tt

   // returns a new file Name from current time + Extension passed
   // in given directory. Ext is the fractions of a sec if not specified
   LOCAL cFileName, nHandle, dDate, nTime

   DEFAULT cPath TO ""
   DEFAULT lCreate TO .F.

   DO WHILE .T.      // keep trying until we get a unique file
      dDate := Date()
      nTime := Seconds()
      cFileName := cPath + Chr( 64 + Month( dDate ) )   ;           // Month Jan=A to Dec=L
      + Right( DToS( dDate ), 2 )   ;           // Day 2 digits
      + Chr( 65 + Int( nTime / 3600 ) )         ;  // Hour 00=A to 23=X
      + PadL( LTrim( Str( Int( nTime / 60 % 60 ) ) ), 2, "0" )  ;  // Mins 2 digits
      + PadL( LTrim( Str( Int( nTime    % 60 ) ) ), 2, "0" )     // Secs 2 digits
      IF cExtn == NIL
         cFileName += LTrim( Str( nTime - Int( nTime ), 5, 3 ) )   // ext is hundredths secs
      ELSE
         cFileName += iif( '.' $ cExtn, '', '.' ) + cExtn  // specified ext
      ENDIF
      IF ( nHandle := FOpen( cFileName ) ) != -1
         FClose( nHandle )
      ELSE
         IF lCreate  // create the file just to reserve the name (multiuser)
            nHandle := FCreate( cFileName )
            FClose( nHandle )
         ENDIF
         EXIT // this file name does not exist (yet) so return it
      ENDIF
   ENDDO

   RETURN ( cFileName )

/***
*
*  ListAsArray( <cList>, <cDelimiter> ) --> aList
*  Convert a delimited string to an array
*
*/
FUNCTION ListAsArray( cList, cDelimiter )

   LOCAL nPos
   LOCAL aList := {}                  // Define an empty array
   LOCAL lDelimLast := .F.

   DEFAULT cDelimiter TO ";"

   DO WHILE ( Len( cList ) <> 0 )

      nPos := At( cDelimiter, cList )

      IF ( nPos == 0 )
         nPos := Len( cList )
      ENDIF

      IF ( SubStr( cList, nPos, 1 ) == cDelimiter )
         lDelimLast := .T.
         AAdd( aList, SubStr( cList, 1, nPos - 1 ) ) // Add a new element
      ELSE
         lDelimLast := .F.
         AAdd( aList, SubStr( cList, 1, nPos ) ) // Add a new element
      ENDIF

      cList := SubStr( cList, nPos + 1 )

   ENDDO

   IF ( lDelimLast )
      AAdd( aList, "" )
   ENDIF

   RETURN aList                       // Return the array

/***
*
*  FilePath( <cFile> ) --> cFilePath
*
*  Extract the full path name (without the filename or extension) from
*  a complete file specification
*
*  Example:
*     FilePath( "c:\clipper5\bin\clipper.exe" ) --> "c:\clipper5\bin\"
*
*/
FUNCTION FilePath( cFile )

   LOCAL nPos        // Marks the posistion of the last "\" in cFile, if any
   LOCAL cFilePath   // The extracted path for cFile, exluding the filename

   IF ( nPos := RAt( PATH_DELIM, cFile ) ) != 0
      cFilePath := SubStr( cFile, 1, nPos )
   ELSE
      cFilePath := ""
   ENDIF

   RETURN ( cFilePath )

// ***************************************************************
// ** Datum:  11-01-06 02:25am
// ** Naziv: mFileName(cFile)
// ** Opis : return the name of file
// ***************************************************************

FUNCTION mFileName( cFile )

   LOCAL nPos        // Marks the posistion of the last "\" in cFile, if any
   LOCAL cFileName   // The extracted name for cFile, exluding the path

   IF ( ( nPos := RAt( "/", cFile ) ) != 0 ) .OR. ;
         ( ( nPos := RAt( "\", cFile ) ) != 0 )

      cFileName := SubStr( cFile, nPos + 1 )
   ELSE
      cFileName := cFile
   ENDIF

   RETURN ( cFileName )

/***
*
*  FileExt( <cFile> ) --> cFileExt
*
*  Extract the three letter extension from a filename
*
*/
FUNCTION FileExt( cFile )

   LOCAL nPos        // Marks the position of the extension, if any
   LOCAL cFileExt    // Return value, the extension of cFile

   // Does the file extension exist?
   IF ( nPos := RAt( ".", cFile ) ) != 0
      cFileExt := SubStr( cFile, nPos + 1 )  // Extract it
   ELSE
      cFileExt := ""                         // None exists, return ""
   ENDIF

   RETURN ( cFileExt )

/***
*
*  FilewoExt( <cFile> ) --> cFileExt
*
*  Extract the filename without extension
*
*/
FUNCTION FilewoExt( cFile )

   LOCAL nPos              // Marks the position of the extension, if any
   LOCAL cFileName := ""    // Return value, the extension of cFile

   // Does the file extension exist?
   cFile := mfilename( cFile )  // remove path if are there
   IF ( nPos := RAt( ".", cFile ) ) != 0
      cFileName := Left( cFile, nPos - 1 )  // Extract it
   ELSE
      cFileName := cFile
   ENDIF

   RETURN ( cFileName )

FUNCTION direxist( cDir )
	
   LOCAL nPos, cTmp, cFind
   LOCAL aRet, lRet := .F.

   IF Right( cDir, 1 ) == PATH_DELIM
      cDir := SubStr( cDir, 1, Len( cDir ) -1 )
   ENDIF
   nPos := RAt( PATH_DELIM, cDir )
   cTmp := SubStr( cDir, 1, nPos ) + "*"
   cFind := SubStr( cDir, nPos + 1 )

   aRet := Directory( cTmp, "D" )
   IF Empty( aRet )
      RETURN lRet
   ENDIF
   IF AScan( aRet, {| x| x[ 1 ] == cFind .AND. x[ 5 ] == "D" } ) <> 0
      lRet := .T.
   ENDIF

   RETURN lRet

FUNCTION chown( cFile, cUID, cGID, lRecursive, lSudo )

   LOCAL cline := "", a

   DEFAULT lRecursive TO .F.
   DEFAULT cFile TO ""
   DEFAULT cUID TO ""
   DEFAULT cGID TO ""
   DEFAULT lSudo TO .F.

   IF lSudo
      cLine := "sudo "
   ENDIF
   cLine := cLine + "chown" + " "
   IF Empty( cUID ) .OR. Empty( cFile )
      RETURN .F.
   ENDIF
   IF lRecursive
      cLine := cLine + "-R" + " "
   ENDIF
   cLine := cLine + cUID
   IF !Empty( cGID )
      cLine := cLine + "." + cGID
   ENDIF
   // cLine := cLine + " " + cFile
   // writesyslog(cLine)
	
   a := hb_processRun( cLine, "", "", "" )

   IF a <> 0 // failed
      //writesyslog( cLine + " " + [Return error:] + strx( a ) )
      RETURN .F.
   ENDIF

   RETURN .T.

// ***************************************************************
// ** Datum:  12-01-96 05:58am
// ** Naziv: GetFiles(lOpen)
// ** Opis : Returning the array with dbf names form mask
// ***************************************************************

FUNCTION GetFiles( aFile, lOpen, nOrder, lCleanExt )

   LOCAL aTmp, aName := {}, x

   DEFAULT lOpen TO .F.
   DEFAULT nOrder TO 1
   DEFAULT lCleanExt TO .F. // clean extensions of file
   IF ValType( aFile ) == "C"
      aFile := { aFile }
   ENDIF
   AEval ( aFile, {|f| aTmp := Directory ( f ), ;
      AEval ( aTmp, {|x| AAdd ( aName, x[ 1 ] ) } ) } )

   FOR x := 1 TO Len( aName )
      IF lCleanExt
         aName[ x ] := SubStr( aName[ x ], 1, ( Len( aName[ x ] ) -4 ) )
      ENDIF
      IF lOpen
         IF !OpenDB( fpath + aName[ x ], 3 )
            RETURN aName
         ENDIF
         SET ORDER to ( nOrder )
         dbGoTop()
      ENDIF
   NEXT

   RETURN aName

// *******************************************************
// ** DATUM: 16. 6.1992.
// ** NAZIV: xDel (cSpec)
// ** OPIS:  Brisanje specificiranog dir-a
// *******************************************************

PROC xDel ( cSpec )

   LOCAL aFiles, i
   LOCAL cMask
#ifdef __UNIX__

   cMask := "*"
#else
   cMask := "*.*"
#endif
   // Prvo uzmi sve datoteke
   IF Right( cSpec, 1 ) <> PATH_DELIM
      cSpec := cSpec + PATH_DELIM
   ENDIF
   aFiles := Directory ( cSpec + cMask, "HSD" )

   // Izbrisi sve u tekucem
   AEval ( aFiles, {|f| iif ( f[ 5 ] <> "D", ;
      deletefile( Lower( cSpec + f[ 1 ] ) ), ) } )

   FOR i := 1 TO Len ( aFiles )
      IF ! ( aFiles[ i ][ 1 ] $ ".." ) .AND. aFiles[ i ][ 5 ] == "D"
         xDel ( cSpec + aFiles[ i ][ 1 ] + PATH_DELIM )
         // Msgg (cSpec + aFiles[i][1])
         // FT_RMDIR(cSpec + aFiles[i][1])
         DirRemove( cSpec + aFiles[ i ][ 1 ] )
      END IF
   NEXT
   DirRemove( cSpec )

   RETURN

PROCEDURE recode( xFile, cPath, cCode )

   LOCAL x

   IF ValType( xFile ) == "C"
      xFile := { xFile }
   ENDIF

   FOR x := 1 TO Len( xFile )
      IF OpenDB( cPath + xFile[ x ] )
         dbGoTop()
         recode_dbf( cCode )
         dbCloseArea()
      ELSE
         Msg( [ Neslo otevrit soubor: ] + " " + cPath + xFile[ x ] )
      ENDIF
   NEXT

   RETURN

STATIC PROCEDURE recode_dbf( cCode )

   LOCAL cIn, cOut, cAl, x
   LOCAL aStructure := {}, xReplace

   DEFAULT cIn TO "kamen"
   DEFAULT cOut TO "cp852"
   cAl := Alias()
   DO CASE
   CASE cCode == "win-l2" .OR. cCode == "w-l"
      cIn := "cp1250"
      cOut := "cp852"
   CASE cCode == "lat-852" .OR. cCode == "l-2"
      cIn := "lat2"
      cOut := "cp852"
   CASE cCode == "iso2-lat2" .OR. cCode == "i-l"
      cIn := "8859-2"
      cOut := "cp852"
   CASE cCode == "utf-lat2" .OR. cCode == "u-l"
      cIn := "utf_8"
      cOut := "cp852"
   CASE cCode == "lat2-kam" .OR. cCode == "l-k"
      cIn := "cp852"
      cOut := "kamen"
   CASE cCode == "kam-lat2" .OR. cCode == "k-l"
      cIn := "kamen"
      cOut := "cp852"
   CASE cCode == "win"
      cIn := __CHARSET__
      cOut := "cp1250"
   ENDCASE

   aStructure := dbStruct()
   DO WHILE !( cAl )->( Eof() )
      FOR x := 1 TO Len( aStructure )
         IF aStructure[ x ][ 2 ] == "C" .OR. aStructure[ x ][ 2 ] == "M"
            xReplace := ( cAl )->( FieldGet( ( cAl )->( FieldPos( aStructure[ x ][ 1 ] ) ) ) )
            #ifdef __CLIP__
            	xReplace := translate_charset( cIn, cOut, xReplace )
				#else
					xReplace := hb_translate(xReplace, cIN, cOut)
            #endif
            ( cAl )->( FieldPut( ( cAl )->( FieldPos( aStructure[ x ][ 1 ] ) ), xReplace ) )
         ENDIF
      NEXT
      ( cAl )->( dbSkip() )
   ENDDO

   RETURN
