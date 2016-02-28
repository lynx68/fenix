
#include "marinas-gui.ch"
#include "commands.ch"

memvar fpath, rpath

  Procedure create_spot_db()
			  
			  
		  LOCAL aBrana_db:={}, cFile := "spot"

			  aadd( aBrana_db, { "Nazev", "C", 15, 0 } )
			  aadd( aBrana_db, { "Umisteni","C", 15, 0 } )
			  aadd( aBrana_db, { "idf","N", 2, 0 } )
			  aadd( aBrana_db, { "Mer_jedn","C", 5, 0 } )

			  IF !File( cFile+".dbf" )
				  dbCreate( cFile, aBrana_db )
				 // mg_msginfo( "Databaze byla vytvorena" )
			  else
				  //mg_msginfo( "Databaze: "+cFile+" jiz existuje !!!")
			  ENDIF

		  RETURN

		  Procedure create_data_db()

			  LOCAL aStruk:={}, cFile := "data"

			  aadd( aStruk, { "idf", "n", 2, 0 } )
			  aadd( aStruk, { "datum", "D", 8, 0 } )
			  aadd( aStruk, { "hodnota", "N", 10,0 })
			  IF !File( cFile + ".dbf" )
				  dbCreate( cFile, aStruk )
				  //mg_msginfo( "Databaze " +cFile+" byla vytvorena" )
			  else
				  //mg_msginfo( "Databaze: "+cFile+" jiz existuje !!!")
			  ENDIF

		  RETURN

		  PROCEDURE prohlizeni()

		  local cDbf := "spot", lCloseDbf
		  local cWin := "browse_win_sp"

		  if mg_ISWINDOWACTIVATED ( cWin )
			  mg_do( cWin , "setfocus" )
			  mg_do( cWin , "bringtofront" )
			  mg_do( cWin , "center" )
			  return
		  endif

		  if select (cDbf) == 0
			  if file(cDbf + ".dbf")
				  use (cDbf) new exclusive
			  else
				  mg_msginfo("Database: " + cDbf + " nenalezena ?!!")
				  return
			  endif
			  lCloseDbf := .T.
		  else
			  select(cDbf)
			  lCloseDbf := .F.
		  endif

		  select (cDbf)
		  dbgotop()


		  CREATE WINDOW (cWin)
			  ROW 0
			  COL 0
			  WIDTH 850
			  HEIGHT 400
			  NOSIZE .T.
			  //BACKCOLOR {39,56,38}
			  CAPTION "Prohlizeni databaze spotrebicu"
			  TOPMOST .T.

			  CREATE BROWSE myBrowse
				  ROW 40
				  COL 10
				  WIDTH 700
				  HEIGHT 285
				  //FONTCOLOR {255,255,255}
				 // BACKCOLOR {70,70,70}
				  BACKCOLORDYNAMIC {|nRow| if( mod( nRow , 5 ) == 0 , {174,171,241} , NIL ) }
				  SELECTIONFONTCOLOR  { 237,236,173 }
				  SELECTIONBACKCOLOR  {57,134,101}
				  SELECTIONBACKCOLORDYNAMIC {|nRow| if( mod( nRow , 5 ) == 0 , {174,171,241} , NIL ) }
				  FONTBOLD .T.
				  FONTSIZE 10
				  WORKAREA cDbf
				  COLUMNFIELDALL { cDbf+"->nazev" , cDbf+"->umisteni" , cDbf+"->idf" , cDbf+"->mer_jedn" }
				  COLUMNHEADERALL { "Nazev", "Umisteni", "Identifikacni cislo", "Merna jednotka"}
				  COLUMNWIDTHALL { 170, 175 , 175, 175}
				  COLUMNALIGNALL { Qt_AlignHCenter, Qt_AlignHCenter, Qt_AlignHCenter, Qt_AlignHCenter }
				  EDITINPLACEALL { .T. , .T. , .T. , .T.}
				  NAVIGATEBY "ROW"
				  TOOLTIP "Browse ToolTip"
				 // ROWHEIGHTALL 19

				  VALUE 8
				  VALUECOL 3
			  END BROWSE


			  CREATE BUTTON Odebrat
				 ROW   150
				 COL   720
				 CAPTION "Odebrat"
				 FONTBOLD .T.
				 //FONTCOLOR  {255,0,0}
				 //BACKCOLOR {37,37,37}
				 WIDTH 100
				 HEIGHT 50
				 ONCLICK del_spt(cWin)
			  END BUTTON

			  CREATE BUTTON Upravit
				 ROW   215
				 COL   720
				 CAPTION "Upravit"
				 FONTBOLD .T.
				 //FONTCOLOR  {255,0,0}
				 //BACKCOLOR {37,37,37}
				 WIDTH 100
				 HEIGHT 50
				 ONCLICK zapis_spt(.t.)
			  END BUTTON

			  CREATE BUTTON Zpet
				  ROW 275
				  COL 720
				  WIDTH 100
				  HEIGHT 50
				  //BACKCOLOR {255,0,0}
				  CAPTION "Zpet"
				  ONCLICK mg_Do( cWin , "release" )
			  END BUTTON

		  END WINDOW

		  mg_do( cWin , "center" )    
		  mg_do( cWin , "activate" )
			
		  if lCloseDbf
			  dbclosearea()
		  endif

		  return
			
		  PROCEDURE zapis_spt(lEdit)

		  local cWind := "zapis"	
		  local cUmi := "", cNaz := "", nIDF :=0 , cMRNJ := ""
		  field Umisteni, Nazev, idf, Mer_jedn in spot

		  default lEdit TO .f.

		  if lEdit
			  cUmi := Umisteni
			  cNaz := Nazev
			  nIDF := idf
			  cMRNJ := Mer_jedn
		  else 

			  if !OpenDb("spot", 2)
				  return 
			  endif
			
		  endif

		  if mg_ISWINDOWACTIVATED ( cWind )
			  mg_do( cWind , "setfocus" )
			  mg_do( cWind , "bringtofront" )
			  mg_do( cWind , "center" )
			  return
		  endif

			  CREATE WINDOW (cWind)
				  ROW 0
				  COL 0
				  WIDTH 420
				  HEIGHT 285
				  CAPTION "Zapis"
				  NOSIZE .T.
				  TOPMOST .T.
				  //BACKCOLOR {39,56,38}

			  
				  CREATE TEXTBOX Naz
					  ROW 30
					  COL 130
					  WIDTH 150
					  HEIGHT 24
					  VALUE cNaz
				  END TEXTBOX
				  
				  CREATE LABEL Naz_l
					  ROW 30
					  COL 20
					  VALUE "Nazev"
					  FONTSIZE 16
					  //FONTCOLOR {23,23,23}
				  END LABEL
					  
				  CREATE TEXTBOX Umi
					  ROW 90
					  COL 130
					  WIDTH 150
					  HEIGHT 24
					  VALUE cUmi
				  END TEXTBOX
			  
				  CREATE LABEL Umi_l
					  ROW 90
					  COL 20
					  VALUE "Umisteni"
					  FONTSIZE 16
					  //FONTCOLOR {23,23,23}
				  END LABEL

				  CREATE TEXTBOX idf
					  ROW 150
					  COL 130
					  WIDTH 150
					  HEIGHT 24
					  NUMERIC .T.
					  VALUE nIDF
				  END TEXTBOX
				  
				  CREATE LABEL IDF_l
					  ROW 150
					  COL 20
					  VALUE "IDENT. CISLO"
					  FONTSIZE 12
					  //FONTCOLOR {23,23,23}
				  END LABEL

				  CREATE TEXTBOX MRNJ
					  ROW 210
					  COL 130
					  WIDTH 150
					  HEIGHT 24
					  VALUE cMRNJ
				  END TEXTBOX

				  CREATE LABEL MRNJ_l
					  ROW 210
					  COL 20
					  VALUE "Mer. Jednotka"
					  FONTSIZE 12
					  //FONTCOLOR {23,23,23}
				  END LABEL

		CREATE BUTTON SAVE_b
			 ROW 140
   		 COL 290
			 WIDTH 100
			 HEIGHT 50
			 //BACKCOLOR {37,37,37}
			 //FONTCOLOR {255,255,255}
			 CAPTION "Ulozit"
			 ONCLICK save_spt(cWind, lEdit)
		END BUTTON

		
		CREATE BUTTON ZPET
			ROW 200
			COL 290
			WIDTH 100
			HEIGHT 50
			//BACKCOLOR {255,0,0}
			//FONTCOLOR {255,255,255}
			CAPTION "Zpet"
			ONCLICK mg_Do( "Zapis", "release" )
		END BUTTON

	END WINDOW

mg_do( cWind , "center" )
mg_do( cWind , "activate" ) 

return

Function save_spt(cWind, lEdit)

field nazev, umistneni, idf, mer_jedn in spot

if lEdit 
	dbrlock()
else 
	dbappend()
endif

replace nazev with mg_get(cWind, "naz", "value")
replace umisteni with mg_get(cWind, "umi", "value")
replace idf with mg_get(cWind, "idf", "value")
replace mer_jedn with mg_get(cWind, "MRNJ", "value")
dbrunlock()

mg_msginfo("Záznam ulo¾en")
mg_do( cWind , "release" )

RETURN NIL

Function del_spt(cWind)


if dbrlock()
	dbdelete()
	mg_do(cWind, "myBrowse", "refresh")
	mg_msginfo("Spotrebic byl smazan")
endif

return .T.

PROCEDURE prohlizeni2()

local cDbf := "data", lCloseDbf := .T.
//local cDbf2 := "spot"
local cWin2 := "browse_win2"

if mg_ISWINDOWACTIVATED ( cWin2 )
	mg_do( cWin2 , "setfocus" )
	mg_do( cWin2 , "bringtofront" )
	mg_do( cWin2 , "center" )
	return
endif

if select (cDbf) == 0
	if file(cDbf + ".dbf")
		use (cDbf) new shared
	else
		mg_msginfo("Database: " + cDbf + " nenalezena ?!!")
		return
	endif
else
	select(cDbf)
	lCloseDbf := .F.
endif

select (cDbf)
dbgotop()

CREATE WINDOW (cWin2)
	ROW 0	
	COL 0
	WIDTH 750
	HEIGHT 400
	NOSIZE .T.
	//BACKCOLOR {39,56,38}

	CREATE FRAMEBOX ramBrowse
		ROW 38
		COL 8
		WIDTH 604
		HEIGHT 288
	END FRAMEBOX 

	CREATE BROWSE myBrowse2
      ROW 40
      COL 10
      WIDTH 600
      HEIGHT 285
      //FONTCOLOR {255,255,255}
      //BACKCOLOR {70,70,70}
      BACKCOLORDYNAMIC {|nRow| if( mod( nRow , 5 ) == 0 , {174,171,241} , NIL ) }
      SELECTIONFONTCOLOR  { 237,236,173 }
      SELECTIONBACKCOLOR  {57,134,101}
      SELECTIONBACKCOLORDYNAMIC {|nRow| if( mod( nRow , 5 ) == 0 , {174,171,241} , NIL ) }
      FONTBOLD .T.
      FONTSIZE 10
      WORKAREA cDbf
      COLUMNFIELDALL { cDbf+"->idf" , cDbf+"->Nazev",cDbf+"->datum" , cDbf+"->hodnota" }
      COLUMNHEADERALL { "idf", "Nazev" , "datum", "hodnota" }
      COLUMNWIDTHALL { 198, 199, 199 }
      COLUMNALIGNALL { Qt_AlignCenter, Qt_AlignCenter, Qt_AlignHCenter  }
      EDITINPLACEALL { .T. , .T. , .T.}
      NAVIGATEBY "ROW"
      TOOLTIP "Browse ToolTip"
      //ROWHEIGHTALL 19
//      VALUE 8	ROW 150
//      VALUECOL 3
   END BROWSE

	CREATE BUTTON Odebrat
     ROW   215
     COL   620
     CAPTION "Odebrat"
     FONTBOLD .T.
     //FONTCOLOR  {255,0,0}
	  WIDTH 100
	  //BACKCOLOR {37,37,37}
	  HEIGHT 50
	  ONCLICK del_data(cWin2)
   END BUTTON

	CREATE BUTTON Zpet
		ROW 275
		COL 620
		WIDTH 100
		HEIGHT 50
		//BACKCOLOR {255,0,0}
		//FONTCOLOR {255,255,255}
		CAPTION "Zpet"
		ONCLICK mg_Do( cWin2 , "release" )
	END BUTTON
END WINDOW

mg_do( cWin2 , "center" )
mg_do( cWin2 , "activate" )  

if lCloseDbf
	select(cDbf)
	dbclosearea()
endif

return

PROCEDURE zapis_data(lEdit2)

local cDbf := "data", lCloseDbf 
local cWin2 := "zapis_d_win", aDat := {}, aDatIdf := {}
local dDatum := date(), nHodnota :=0
local lClsp
field datum, hodnota

default lEdit2 TO .f.

if mg_ISWINDOWACTIVATED ( cWin2 )
	mg_do( cWin2 , "setfocus" )
	mg_do( cWin2 , "bringtofront" )
	mg_do( cWin2 , "center" )
	return
endif

if select("spot") == 0
	use "spot" new shared
	lClsp := .t.
else
	select("spot")
	lClsp := .f.
endif

dbgotop()
do while !eof()
	aadd(aDat, spot->nazev)
	aadd(aDatIdf, spot->idf)
	DBSKIP()
ENDDO
	
	if lClsp
		dbclosearea()
	endif	

if select(cDbf) == 0
	if file(cDbf + ".dbf")
		use (cDbf) new shared
	else
		mg_msginfo("Database: " + cDbf + " nenalezena ?!!")
		return
	endif
	lCloseDbf := .T.
	else
	select(cDbf)
	lCloseDbf := .F.
endif
if lEdit2
	//nIDF := idf
	dDatum := datum
	nHodnota := hodnota
endif
	CREATE WINDOW (cWin2)
		ROW 0
		COL 0
		WIDTH 360
		HEIGHT 285
		CAPTION "Zapis"
		//NOSIZE .T.
		NOMAXIMIZEBUTTON .T.
		NOMINIMIZEBUTTON .T.
		TOPMOST .T.
		//BACKCOLOR {39,56,38}

		CREATE FRAMEBOX ram
			ROW 25
			COL 10
			WIDTH 100
			HEIGHT 160
		END FRAMEBOX

		CREATE FRAMEBOX ram2
			ROW 148
			COL 248
			WIDTH 103
			HEIGHT 52
		END FRAMEBOX
		
		CREATE FRAMEBOX ram3
			ROW 208
			COL 248
			WIDTH 103
			HEIGHT 52
		END FRAMEBOX

		CREATE comboBOX IDF_c 
			ROW 30
			COL 130
			//autosize .t.
			WIDTH 80
			HEIGHT 24
			//BACKCOLOR {70,70,70}
			//FONTCOLOR {255,255,255}
			//NUMERIC .T.
			//MAXLENGTH 2
			VALUE 1 //nIDF
			items aDat
		END comboBOX

		CREATE LABEL idf_l
			ROW 30
			COL 20
			VALUE "IDF:"
			FONTSIZE 16
			//FONTCOLOR {23,23,23}
		END LABEL
			
		CREATE TEXTBOX hodnota
			ROW 90
			COL 130
			WIDTH 80
			HEIGHT 24
			//autosize .t. 	
			NUMERIC .T.
			MAXLENGTH 10
			//BACKCOLOR {70,70,70}
			//FONTCOLOR {255,255,255}
			VALUE nHodnota
			valid {|nX| nX <> 0 }
		END TEXTBOX
	
		CREATE LABEL hod_l
			ROW 90
			COL 20
			VALUE "Hodnota"
			FONTSIZE 16
			//FONTCOLOR {23,23,23}
		END LABEL

		CREATE TEXTBOX datum
			ROW 150
			COL 130
			WIDTH 80
			HEIGHT 24
			//BACKCOLOR {70,70,70}
			//FONTCOLOR {255,255,255}
			DATE .T.
			VALUE dDatum	
			datevalidmute .t.
			allowemptydatemute .t.
		END TEXTBOX
		
		CREATE LABEL datum_l
			ROW 150
			COL 20
			VALUE "Datum"
			FONTSIZE 16
			//FONTCOLOR {23,23,23}
		END LABEL
		
	  CREATE BUTTON SAVE_b
			ROW 150
			COL 250
			WIDTH 100
			HEIGHT 50
			CAPTION "Ulozit"
			//BACKCOLOR {37,37,37}
			//FONTCOLOR {255,255,255}
			ONCLICK save_data(cWin2, lEdit2, aDatIdf)
		END BUTTON

		CREATE BUTTON ZPET
			ROW 210
			COL 250
			WIDTH 100
			HEIGHT 50
			//BACKCOLOR {255,0,0}
			CAPTION "Zpet"
			ONCLICK mg_Do( cWin2 , "release" )
		END BUTTON
	END WINDOW

mg_do( cWin2 , "center" )
mg_do( cWin2 , "activate" ) 

if lCloseDbf 
	select(cDbf)
	dbcloseall()
endif
	
return

Function save_data(cWin2, lEdit2, aDatIdf)

field idf, datum, hodnota

if mg_get(cWin2, "hodnota", "value") == 0
   mg_msginfo("Hodnota nebyla zadana")
	return NIL
endif

if empty (mg_get(cWin2, "datum", "value"))
	mg_msginfo("Datum nebyl zadan")
	return NIL
endif 

if empty (mg_get(cWin2, "idf_c", "value"))
	mg_msginfo("Spotrebic nenalezen ?!")
	return NIL
endif

if lEdit2 
	dbrlock()
else 
	dbappend()
endif

replace idf with aDatIdf[mg_get(cWin2, "idf_c", "value")]
replace datum with mg_get(cWin2, "datum", "value")
replace hodnota with mg_get(cWin2, "hodnota", "value")

dbrunlock()

mg_msginfo("Záznam ulo¾en")
mg_do( cWin2 , "release" )
//	dbclosearea()

return NIL

Function del_data(cWin2)

if dbrlock()
	dbdelete()
	mg_do(cWin2, "myBrowse2", "refresh")
	mg_msginfo("Zaznam byl smazan")
endif

return .T.

Function MainOnRelease()
	dbcloseall()
Return .T.

function Getver()

return "Loki GUI 0.1"

function proveri()
return .t.

procedure tisk()

local cWin3 := "Tisk_win"
local dOd := date(), dDo := date()

	CREATE WINDOW (cWin3)
		row 0
		col 0
		width 850
		height 700
		Modal .t.

	create label od
		row 100
		col 100 
		autosize .t.
		value "Datum od:"
	end label
	
	create dateedit time_od
		row 95
		col 220
		CALENDARPOPUP .T.
		FontSize 18
		value dOd
	end dateedit
	
	create label do
		row 200
		col 100 
		autosize .t.
		value "Datum do:"
	end label
	
	create dateedit time_do
		row 195
		col 220
		CALENDARPOPUP .T.
		FontSize 18
		value dDo
	end dateedit
   
	create button tisk
		row 320
		col 420
		width 200
		height 70
		caption "Tisk"
		ONCLICK tisk_data(cWin3)		
	end button	
	
	create button konec
		row 440
		col 420
		width 200
		height 70
		caption "Zpìt"
      ONCLICK mg_Do( cWin3 , "release" )  			
		tooltip "Zpìt"
		picture "resource/d_test_stop.png"
	end button		
end window

//mg_do(cWin, "maximize")
mg_do(cWin3, "activate")

return

static function tisk_data(cWin3)


local dOd := mg_get(cWin3, "time_od", "value")
local dDo := mg_get(cWin3, "time_do", "value")
local aRec := {}, x, cPrn := "", nTmp := 0
field idf, datum, hodnota

if !OpenDB("data",2)
	return nil
endif
//set order to 2
dbgotop()

//dbseek(dOd)

do while .t.
	if datum > dDo .or. eof()
		exit
	endif
	if !empty(idf)
		aadd(aRec, {idf, datum, hodnota })
	endif
	dbskip()
enddo
dbclosearea()

mg_log(aRec)


if empty(aRec)
	msg("®ádný záznam v zadaném období !!!")
	return nil
endif
//iniptr()
//prt1()

cPrn += "Vypis dat - Od:" +dtoc(dOd)+"  Do: "+ dtoc(dDo)+hb_eol()
cPrn += hb_eol()+hb_eol()+hb_eol()
cPrn += "Identifikacni" +hb_eol()
cPrn += "cislo              Datum        Hodnota"+hb_eol()
cPrn += hb_eol()

for x:=1 to len(aRec)
	cPrn += str(  aRec[x][1],5 ) + space(10) + dtoc(aRec[x][2])+ "                    "+ strx( aRec[x][3] ) + "       " + hb_eol()
	//nTmp := nTmp + aRec[x][3]
	nTmp += aRec[x][3]
next
cPrn += hb_eol()+"Celkem: "+str(nTmp,6)
cPrn += hb_eol()+hb_eol()+hb_eol()
cPrn += "Datum tisku:" + " "+ dtoc(date())+" "+time()+hb_eol()+hb_eol()
cPrn += space(32)+ " Kontroloval: ____________________"

//mgprint(cPrn)
//Msg("Vyti¹tìno...")

return nil

/*
static procedure toolbar(cWin)


create toolbar main_toolbar
	ToolTip "Aplication toolbar"

	create toolbutton quit
		Caption "Ukonèit program"
		Tooltip "Ukonèení programu"
		picture rpath+"exit.png"
		onclick if( mg_msgyesno("Opravdu ?!", "Ukonèit"), mg_do( cWin, "release"),)
	end toolbutton
	create toolbutton About
		caption "O programu"
		tooltip "O programu"
		Onclick msg("Vampire ver 0.6 Rev. a") // about()
		picture rpath+"about.png"
	end toolbutton
end toolbar

return
*/

