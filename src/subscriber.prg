#include "marinas-gui.ch"

memvar cRPath, cPath

procedure browse_subscriber()

local cWin := "sub_win"
local aOptions := {}
local bOnclick, cAll 

if !OpenSubscriber()
	return
endif
cAll := alias()

aadd(aOptions, {cAll+"->Idf", cAll+"->Name", cAll+"->address", cAll+"->City" , cAll+"->phone", cAll+"->Email" })
aadd(aOptions, {"Idf", "Name", "Address" , "City", "Telephone", "Email" })
aadd(aOptions, { 60, 200, 160, 100, 120, 120 })
aadd(aOptions, { Qt_AlignRight, Qt_AlignCenter, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignLeft, Qt_AlignRight })
aadd(aOptions, {10,10, 800, 564}) 
bOnClick := { || new_subscriber(.t.) }
CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION "Subscribers"
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
		caption "Back"
//		backcolor {0,255,0}
		ONCLICK mg_do(cWin, "release")
		tooltip "Close and go back"
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
field name, address, city, postcode, country, phone, ico, vat, email

default lEdit to .f.

if lEdit
	cName := name
	cNamef := fullname
	cAdd := address
	cCity := city	
	cPost := postcode
	cTel := phone
	cIco := ico
	cVat := vat
	cEmail := email
	cCountry := country
endif
	
CREATE WINDOW (cWin)
	row 0
	col 0
	width 1050
	height 600
	CAPTION "Add / Edit Subscribers"
	CHILD .T.
	TOPMOST .t.
	FONTSIZE 16
	CREATE LABEL name_l
		FONTSIZE 16
		Row 35
		Col 20
		Value "Name (Short name for fast search)"
		TOOLTIP "Short name for fast search"
	END LABEL
	CREATE TEXTBOX name_t
		FONTSIZE 16
		ROW 35
		COL 400
		WIDTH 150
		HEIGHT 26
		MAXLENGTH 20
		VALUE cName
		TOOLTIP "Short name for fast search"
	END TEXTBOX
	CREATE LABEL namef_l
		FONTSIZE 16
		Row 80
		Col 20
		Value [Name (Full Subscriber Name)]
		TOOLTIP [Full Subscriber Name]
	END LABEL
	CREATE EDITBOX namef_t
		FONTSIZE 16
		ROW 80
		COL 400
		WIDTH 400
		HEIGHT 100
		VALUE cNameF
		TOOLTIP [Full Subscriber Name]
	END EDITBOX
	CREATE LABEL addr_l
		FONTSIZE 16
		Row 210
		Col 20
		Value [Address]
	END LABEL
	CREATE TEXTBOX addr_t
		FONTSIZE 16
		ROW 210
		COL 120
		WIDTH 150
		HEIGHT 26
		VALUE cAdd
		MAXLENGTH 35
	END TEXTBOX
	CREATE LABEL city_l
		FONTSIZE 16
		Row 210
		Col 310
		Value [City]
	END LABEL
	CREATE TEXTBOX city_t
		FONTSIZE 16
		ROW 210
		COL 360
		WIDTH 150
		HEIGHT 24
		VALUE cCity
		MAXLENGTH 20
	END TEXTBOX
	CREATE LABEL post_l
		FONTSIZE 16
		Row 210
		Col 545
		Value [Post code]
	END LABEL
	CREATE TEXTBOX post_t
		FONTSIZE 16
		ROW 210
		COL 660
		WIDTH 150
		HEIGHT 24
		VALUE cPost
		MAXLENGTH 20
	END TEXTBOX
	CREATE LABEL country_l
		FONTSIZE 16
		Row 250
		Col 20
		Value [Country]
	END LABEL

	CREATE TEXTBOX country_t
		FONTSIZE 16
		ROW 250
		COL 120
		WIDTH 150
		HEIGHT 24
		VALUE cCountry
		MAXLENGTH 20
	END TEXTBOX

	CREATE LABEL email_l
		FONTSIZE 16
		Row 300
		Col 20
		Value [Email for sending invoices]
		TOOLTIP [Email for sending invoices]
	END LABEL

	CREATE TEXTBOX email_t
		FONTSIZE 16
		ROW 300
		COL 290
		WIDTH 150
		HEIGHT 24
		VALUE cEmail
		TOOLTIP [Email for sending invoices]
		MAXLENGTH 25
	END TEXTBOX
	CREATE LABEL tel_l
		FONTSIZE 16
		Row 300
		Col 470
		Value [Contact Phone]
		TOOLTIP [Contact Phone]
	END LABEL

	CREATE TEXTBOX tel_t
		FONTSIZE 16
		ROW 300
		COL 630
		WIDTH 150
		HEIGHT 24
		VALUE cTel
		TOOLTIP [Contact Phone]
		MAXLENGTH 25
	END TEXTBOX

	CREATE LABEL vat_l
		FONTSIZE 16
		Row 350
		Col 20
		Value [VAT]
		TOOLTIP [VAT IDENTIFICATION]
	END LABEL

	CREATE TEXTBOX vat_t
		FONTSIZE 16
		ROW 350
		COL 100
		WIDTH 150
		HEIGHT 24
		VALUE cVat
		TOOLTIP [VAT IDENTIFICATION]
		MAXLENGTH 25
	END TEXTBOX

	CREATE LABEL ICO_l
		FONTSIZE 16
		Row 350
		Col 350
		Value [Company ID]
		TOOLTIP [Company Identification Number]
	END LABEL

	CREATE TEXTBOX ICO_t
		FONTSIZE 16
		ROW 350
		COL 400
		WIDTH 150
		HEIGHT 24
		VALUE cICO
		TOOLTIP [Company Identification Number]
		MAXLENGTH 25
	END TEXTBOX

	create button save
		row 510
		col 640
		width 160
		height 60
		caption "Save"
//		backcolor {0,255,0}
		ONCLICK save_sub(cWin, lEdit)
		tooltip "Save  and exit"
		picture cRPath+"task-complete.png"
	end button

	create button Back
		row 510
		col 840
		width 160
		height 60
		caption "Back"
//		backcolor {0,255,0}
		ONCLICK mg_do(cWin, "release")
		tooltip "Close and go back"
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
	Msg([Please fill some more info about subscriber])
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




