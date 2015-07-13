/*
 * Fenix Open Source accounting system
 * Subscribers
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

memvar cRPath, cPath

procedure browse_subscriber()

local cWin := "sub_win"
local aOptions := {}
local bOnclick, cAll 

if !OpenSubscriber(, 2)
	return
endif
set order to 2
dbgotop()
cAll := alias()

aadd(aOptions, {cAll+"->Name", cAll+"->address", cAll+"->City" , cAll+"->phone", cAll+"->Email" })
aadd(aOptions, {_I("Name"), _I("Address") , _I("City"), _I("Phone"), _I("email") })
aadd(aOptions, { 200, 160, 160, 140, 140 })
aadd(aOptions, { Qt_AlignLeft, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignRight })
aadd(aOptions, {10,10, 800, 564}) 
bOnClick := { || new_subscriber(.t.) }
CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("Browse Customers")
	CHILD .T.
	TOPMOST .t.
	my_mg_browse(cWin, alias(), aOptions, bOnClick)
	// aData := aSort(aData,,, {|x, y| x[2] > y[2]})
	// my_grid(cWin, aData, aOptions, bOnClick,,,"el_zad_br")
	create button Back
		row 510
		col 840
		width 160
		height 60
		caption _I("Back")
//		backcolor {0,255,0}
		ONCLICK mg_do(cWin, "release")
		tooltip _I("Close and go back")
		picture cRPath+"task-reject.png"
	end button
END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

dbclosearea()

return

procedure new_subscriber(lEdit)

local cName := "" , cAdd := "", cCity := "", cPost := "", cCountry := ""
local cWin:= "add_sub", cTel := "", cIco := "", cVat := "", cNameF:= ""
local cEmail := ""
field name, address, city, postcode, country, phone, ico, vat, email, fullname

default lEdit to .f.

if lEdit
	cName := alltrim(name)
	cNamef := fullname
	cAdd := alltrim(address)
	cCity := alltrim(city)
	cPost := postcode
	cTel := alltrim(phone)
	cIco := alltrim(ico)
	cVat := alltrim(vat)
	cEmail := alltrim(email)
	cCountry := alltrim(country)
endif
	
CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION _I("Add / Edit Customers")
	CHILD .T.
	TOPMOST .t.
	CREATE LABEL name_l
		Row 35
		Col 20
		Value _I("Name (Short name for fast search)")
		TOOLTIP _I("Short name for fast search")
	END LABEL
	CREATE TEXTBOX name_t
		ROW 35
		COL 400
		WIDTH 150
		HEIGHT 26
		MAXLENGTH 20
		VALUE cName
		TOOLTIP _I("Short name for fast search")
	END TEXTBOX
	CREATE LABEL namef_l
		Row 80
		Col 20
		Value _I("Name (Full Customer Name)")
		TOOLTIP _I([Full Customer Name])
	END LABEL
	CREATE EDITBOX namef_t
		ROW 80
		COL 400
		WIDTH 400
		HEIGHT 100
		VALUE cNameF
		TOOLTIP _I([Full Subscriber Name])
	END EDITBOX
	CREATE LABEL addr_l
		Row 210
		Col 20
		Value _I([Address])
	END LABEL
	CREATE TEXTBOX addr_t
		ROW 210
		COL mg_get( cWin, "addr_l", "ColRight")+10
		WIDTH 150
		HEIGHT 26
		VALUE cAdd
		MAXLENGTH 35
	END TEXTBOX
	CREATE LABEL city_l
		Row 210
		Col 310
		Value _I("City")
	END LABEL
	CREATE TEXTBOX city_t
		ROW 210
		COL mg_get( cWin, "city_l", "ColRight")+10
		WIDTH 150
		HEIGHT 24
		VALUE cCity
		MAXLENGTH 20
	END TEXTBOX
	CREATE LABEL post_l
		Row 210
		Col 560
		Value _I([Post code])
	END LABEL
	CREATE TEXTBOX post_t
		ROW 210
		COL mg_get( cWin, "post_l", "ColRight")+10
		WIDTH 150
		HEIGHT 24
		VALUE cPost
		MAXLENGTH 20
	END TEXTBOX
	CREATE LABEL country_l
		Row 250
		Col 20
		Value _I([Country])
	END LABEL

	CREATE TEXTBOX country_t
		ROW 250
		COL mg_get( cWin, "country_l", "ColRight")+10
		WIDTH 180
		HEIGHT 24
		VALUE cCountry
		MAXLENGTH 20
	END TEXTBOX

	CREATE LABEL email_l
		Row 300
		Col 20
		Value _I([Email for sending invoices])
		TOOLTIP _I([Email for sending invoices])
	END LABEL

	CREATE TEXTBOX email_t
		ROW 300
		COL mg_get( cWin, "email_l", "ColRight")+10
		WIDTH 240
		HEIGHT 24
		VALUE cEmail
		TOOLTIP _I([Email for sending invoices])
		MAXLENGTH 30
	END TEXTBOX
	CREATE LABEL tel_l
		Row 300
		Col 580
		Value _I([Contact Phone])
		TOOLTIP _I([Contact Phone])
	END LABEL

	CREATE TEXTBOX tel_t
		ROW 300
		COL mg_get( cWin, "tel_l", "ColRight")+10
		WIDTH 180
		HEIGHT 24
		VALUE cTel
		TOOLTIP _I([Contact Phone])
		MAXLENGTH 25
	END TEXTBOX

	CREATE LABEL vat_l
		Row 350
		Col 20
		Value _I([VAT])
		TOOLTIP _I([VAT IDENTIFICATION])
	END LABEL

	CREATE TEXTBOX vat_t
		ROW 350
		COL mg_get( cWin, "vat_l", "ColRight")+10
		WIDTH 160
		HEIGHT 24
		VALUE cVat
		TOOLTIP _I([VAT IDENTIFICATION])
		MAXLENGTH 25
	END TEXTBOX

	CREATE LABEL ICO_l
		Row 350
		Col 350
		Value _I([Company ID])
		TOOLTIP _I([Company Identification Number])
	END LABEL

	CREATE TEXTBOX ICO_t
		ROW 350
		COL mg_get( cWin, "ico_l", "ColRight")+10
		WIDTH 180
		HEIGHT 24
		VALUE cICO
		TOOLTIP _I([Company Identification Number])
		MAXLENGTH 25
	END TEXTBOX

	create button save
		row 510
		col 650
		width 160
		height 60
		caption _I("Save")
//		backcolor {0,255,0}
		ONCLICK save_sub(cWin, lEdit)
		tooltip _I("Save  and exit")
		picture cRPath+"task-complete.png"
	end button

	create button Back
		row 510
		col 840
		width 160
		height 60
		caption _I("Back")
//		backcolor {0,255,0}
		ONCLICK mg_do(cWin, "release")
		tooltip _I("Close and go back")
		picture cRPath+"task-reject.png"
	end button
END WINDOW

mg_Do(cWin, "center")
mg_do(cWin, "activate") 

if !lEdit
	dbclosearea()
endif

return

static function save_sub(cWin, lEdit)

local lClose := .f.
local cAll := alias()
default lEdit to .f.

if !lEdit
	if select("subscriber") == 0
		if OpenDB(cPath+"subscriber", 2)
			lClose := .t.
		else
			return .f.
		endif 
	endif
endif
select("subscriber")

//mg_log(select("subscriber"))

if empty(mg_get(cWin, "name_t", "value")) .or.  ;
	empty(mg_get(cWin, "namef_t", "value")) .or. ;
	empty(mg_get(cWin, "addr_t", "value"))
	mg_msginfo(_I("Please fill some more info about customer"))

	return .f.
endif

if	iif(lEdit, RecLock(), AddRec())
	if !lEdit	
		replace idf			with hb_random(1,100000)
	endif
	replace name 		with mg_get(cWin, "name_t", "value")
	replace fullname	with mg_get(cWin, "namef_t", "value")
	replace address 	with mg_get(cWin, "addr_t", "value")
	replace city	 	with mg_get(cWin, "city_t", "value")
	replace postcode 	with mg_get(cWin, "post_t", "value")
	replace country	with mg_get(cWin, "country_t", "value")
	replace email		with mg_get(cWin, "email_t", "value")
	replace phone		with mg_get(cWin, "tel_t", "value")
	replace vat  		with mg_get(cWin, "vat_t", "value")
	replace ico  		with mg_get(cWin, "ico_t", "value")
//replace email		with mg_get(cWin, "email_t", "value")
	dbrunlock()
endif

if lClose
	Dbclosearea()
endif
	
if !empty(cAll)
	select(cAll)
endif

mg_do( cWin, "release")

return .t.

function read_customer(aCust, lOneEmpty)

local cAll := alias()
default aCust to {}
default lOneEmpty to .t.

if lOneEmpty 
	aadd(aCust, {"",0})
endif

if OpenSubscriber(, 3)
//if OpenDB(cPath+"subscriber", 3)
	set order to 2
	dbgotop()
	do while !eof()
		aadd(aCust, {subscriber->name, subscriber->idf})
		dbskip()
	enddo
	dbclosearea()
endif
if !Empty(cAll)
	select(cAll)
endif

return aCust

