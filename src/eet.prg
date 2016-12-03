/*
 * Fenix Open Source accounting system
 * EET communication
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

#require "hbssl"
#require "hbcurl"

memvar cPath

function eet(aData)

local cEETMessage, cEetResponse, cFik:="", n, cUuid

// Test EET 
// create test message
cEetMessage := eet_createMessage(aData)
//mg_log(cEetMessage)
if empty(cEetMessage)
	Msg("Error creating Eet Message")
	return ""
endif


// Send file to EET
//cEetResponse := SendCurlMessage("eet_response.xml")
hb_memowrit( "/tmp/eet_response.xml", cEetResponse )

if empty(cEetResponse)
	msg("sending eet request failed")
	return ""
endif
n := ascan( aData, { |x| x[2] == "uuid" } )
if n > 0 
	cUUID := aData[n][1]
endif
writelog( cEetMessage, cEetResponse, cUUID )

cFik := ProcessEetResponse(cEetResponse)

return cFik

function eet_createMessage(aData)

local cKeyFile  // demo private key
local cPublicKeyFile  // public key
local cPkp_input, cPkp_value, cBKP_value
local cFin := "", cSoapBody, x, cDigest, cPub
local cSignature, cSignature_value, cFinalXML

default aData to {}
ssl_init()
OpenSSL_add_all_ciphers()
OpenSSL_add_all_digests()
OpenSSL_add_all_algorithms()

if file( cPath + hb_ps() + "cert/privateKey.pem") .and. file( cPath + hb_ps() + "cert/publicKey.pem")
	cKeyFile := cPath + hb_ps() + "cert/privateKey.pem"       // private key
	cPublicKeyFile := cPath + hb_ps() + "cert/publicKey.pem"  // public key
else
	msg( _I("Unable to found certificates ?!!!"))
	return cFin
endif

if empty(aData)
	// demo data (PlayGround)
	aData := {}
//	aadd(aData, { dtoc(date()), "dat_odesl" } )
	cKeyFile := cPath + "cert/demokey.pem"
	cPublicKeyFile := cPath + "cert/demopublic.pem"
	aadd(aData, { "2016-09-19T23:26:41+02:00", "dat_odesl" } )
	aadd(aData, { "CZ1212121218", "dic_popl"} ) // aData[1] = DIC
	aadd(aData, { "1", "id_provoz"} ) // id_provoz identifikace provozovny
	aadd(aData, { "POKLADNA01", "id_pokl"} )  // nazev pokladny idf pokladny
	aadd(aData, { "1", "porad_cis"})
	aadd(aData, { "2016-09-19T23:26:41+02:00", "dat_trzby"} ) // date time
	aadd(aData, { "100.00", "celk_trzba"} ) // price
	aadd(aData, { "true", "prvni_zaslani" } )
	aadd(aData, { "0", "rezim" })
	aadd(aData, { "c1d4a40e-7eaf-11e6-aca7-971c4d53bfa7", "uuid_zpravy" } )
//	cPkp_input := "CZ1212121218|1|POKLADNA01|1|2016-09-19T23:26:41+02:00|100.00"
endif

cPkp_Input := Gen_Pkp_In( aData )

if empty(cPkp_Input)
	return cFin
endif

cPub := ReadPublicKey(cPublicKeyFile)
if empty( cPub )
	Msg("Error readimg public key")
	return cFin
endif
aadd(aData, { cPub, "certb64", "cert64" })

cPkp_value := compute_pkp(cPkp_Input, cKeyFile)
cBkp_value := compute_bkp(cPkp_value)
aadd( aData, { cPkp_value, "pkp", "pkp" } )
aadd( aData, { cBkp_value, "bkp", "bkp" } )

if empty(cPkp_value) .or. empty(cBkp_Value)
	msg("Empty Sign control. Something arre wrong wit singing process !!!")
	return cFin
endif

cSoapBody := memoread("template/soap_body")
if empty( cSoapBody )
	msg("Error loading Template: soap_body. Check installatiom")
	return cFin
endif

for x := 1 to len( aData )
	cSoapBody := strtran(cSoapBody, "${"+aData[x][2]+"}", aData[x][1])
next

cSoapBody := ClearNotUsedElements(cSoapBody) // remove notused elements
//mg_log( cSoapBody )

cDigest := compute_digest( cSoapBody )
if empty(cDigest)
	Msg("Error computing digest hash")
	return cFin
else
	aadd(adata, { cDigest, "digest", "dig" } )
endif

//mg_log( cSoapBody )
cSignature := memoread("template/signature") // get soap obect fill the data and sign
for x := 1 to len( aData )
	cSignature := strtran(cSignature, "${"+aData[x][2]+"}", aData[x][1])
next

cSignature_Value := compute_signature( cSignature, cKeyFile ) // compute final signature
if empty(cSignature_value)
	msg("Signature coputing problem...")
	return cFin
else
	aadd( aData, { cSignature_value, "signature", "sign" } )
endif

cFinalXML := memoread("template/final.xml")  // get final xml ftom template

for x := 1 to len( aData ) // fill the data
	cFinalXML := strtran(cFinalXML, "${"+aData[x][2]+"}", aData[x][1]) 
next
cFinalXML := ClearNotUsedElements( cFinalXML ) // remove notused elements
hb_memowrit("signed_message", cFinalXML)
cFin := cFinalXML
//mg_log(cPkp_value)

return cFin

static function Gen_Pkp_In( aData )

local cPkpTemplate := '${dic_popl}|${id_provoz}|${id_pokl}|${porad_cis}|${dat_trzby}|${celk_trzba}'
local x

for x := 1 to len( aData ) // fill the data
	cPkpTemplate := strtran(cPkpTemplate, "${"+aData[x][2]+"}", aData[x][1]) 
next

if at("${", cPKPTemplate) <> 0
	Msg("Error create PKP, check input data !!!")
	cPkpTemplate := ""
endif
//mg_log( cPKPTemplate)

return cPkpTemplate

static function compute_pkp(cPkp_input, cKeyFile)

local cCommand, cRet
local ctx, digest := ""
local cStdOut

// compute rsassa-pkcs1_5 signature for eet
ctx := EVP_MD_CTX_CREATE()
EVP_MD_CTX_init( ctx )
EVP_DIGESTInit_ex( ctx, "SHA256" )  
EVP_DigestUpdate( ctx, cPKP_Input )
EVP_DigestFinal( ctx, @digest ) // compute sha256 hash (binary)

//mg_log( PEM_READ_BIO_RSAPRIVATEKEY( cKeyFile, digest ))
// TODO make this trought ssl library
// apply rsa signature algoritm to the hash
cCommand := "openssl pkeyutl -sign -inkey " + cKeyFile + " -pkeyopt digest:SHA256"
hb_processRun( cCommand, digest, @cStdOut )
cRet := hb_base64encode(cStdOut) // encode base64 resulting raw signature
// cRet are correct PKP :-)
// mg_log(cRet)
//mg_log(hb_sha256(cPKP_Input))

evp_md_ctx_cleanup( ctx )

return cRet

static function compute_bkp(cBkp_Input)

// local cIn, ctx, digest, cRet, n, x
local cIn, cRet, n, x

cIn := hb_base64decode(cBkp_input) // base64 decode signature 
/*
ctx := EVP_MD_CTX_CREATE()
EVP_MD_CTX_init( ctx )
EVP_DIGESTInit_ex( ctx, "SHA1" )  
EVP_DigestUpdate( ctx, cIn )
EVP_DigestFinal( ctx, @digest ) // compute sha1 hash (binary)
*/
//mg_log(hb_strtohex(hb_sha1(cIn)))
//mg_log(hb_base64encode(hb_sha1(cIn)))
cRet := hb_sha1(cIn) // hb_sha1 work !!!

//cRet := hb_strtohex(digest)     // hexdump resulting hash value
cRet := alltrim(upper(cRet))    // remove spaces and upercase

for x:=1 to 4 // format finall string
	n := x*8
	cRet := stuff(cRet, n+x, 0, "-")
next
//mg_log(cRet)
//evp_md_ctx_cleanup( ctx )

return cRet

static function compute_digest(cInputDigest)

local ctx, cDigest_value, cRet // , cIn

ctx := EVP_MD_CTX_CREATE()
EVP_MD_CTX_init( ctx )
EVP_DIGESTInit_ex( ctx, "SHA256" )  
EVP_DigestUpdate( ctx, cInputDigest )
EVP_DigestFinal( ctx, @cDigest_value )   // compute sha256 hash (binary) 
cRet := hb_base64encode( cDigest_value ) // cRet are Valid result

/*
//mg_log(cInputDigest)
// cIn := hb_base64decode(cInputDigest) 
cIn := cInputDigest
mg_log(cIn)
mg_log(hb_sha256(cIn))
mg_log(hb_strtohex(hb_sha256(cIn)))
mg_log(hb_base64encode(hb_sha256(cIn)))
*/

evp_md_ctx_cleanup( ctx )

return cRet

static function compute_signature( cInput, cKeyFile)

local cCommand, cRet
local ctx, digest := ""
local cStdOut

// compute rsassa-pkcs1_5 signature for eet
ctx := EVP_MD_CTX_CREATE()
EVP_MD_CTX_init( ctx )
EVP_DIGESTInit_ex( ctx, "SHA256" )  
EVP_DigestUpdate( ctx, cInput )
EVP_DigestFinal( ctx, @digest ) // compute sha256 hash (binary)

// TODO make this trought ssl library
// apply rsa signature algoritm to the hash
cCommand := "openssl pkeyutl -sign -inkey " + cKeyFile + " -pkeyopt digest:SHA256"
hb_processRun( cCommand, digest, @cStdOut )
cRet := hb_base64encode(cStdOut) // encode base64 resulting raw signature
// cRet are corect signature :-)
//mg_log(cRet)

evp_md_ctx_cleanup( ctx )

return cRet

static function ClearNotUsedElements( cTxt )

local x, y, z, nTmp, cTmp
do while .t.
	z := at( '${', cTxt )
	if z == 0
		exit
	endif
	x := 0
	y := 0
	nTmp := z
	do while .t.
	   nTmp--
		cTmp:= substr( cTxt, nTmp, 1 )
		if cTmp == " "
			x := nTmp
			exit
		endif
	enddo
	nTmp := z
	do while .t.
		nTmp++
		cTmp:= substr( cTxt, nTmp, 1 )
		if cTmp == " " .or. cTmp == "/" .or. cTmp == ">"
			y := nTmp
			exit
		endif
	enddo
   if !empty(x) .and. !empty(y)
		// msg("X: " + str(x) + " Y: " + str(y) + "CALC:" + str(y-x+1))
		// msg( substr( cTxt , x, y-x ))
		// mg_log( cTxt )
		cTxt := stuff( cTxt, x, y-x, "")
		// mg_log( cTxt )
	endif
enddo

return cTxt

static function ReadPublicKey(cPublicKeyFile)

local cBuff := memoread( cPublicKeyFile )
local x,y

x := at('-----BEGIN CERTIFICATE-----', cBuff)
y := at('-----END CERTIFICATE-----', cBuff)
x := x+27
// msg("X: " + str(x) + " Y: " + str(y) + "CALC:" + str(y-x))

return charrem(chr(10)+chr(13), substr(cBuff, x, y-x))

static function SendCurlMessage(cFile)

local cCommand, cStdOut

//cCommand := 'curl -XPOST -H "Content-Type: text/xml;charset=UTF-8" -H "SOAPAction: http://fs.mfcr.cz/eet/OdeslaniTrzby" --data-binary @'+cFile+' https://pg.eet.cz/eet/services/EETServiceSOAP/v3'

cCommand := 'curl -XPOST -H "Content-Type: text/xml;charset=UTF-8" -H "SOAPAction: http://fs.mfcr.cz/eet/OdeslaniTrzby" --data-binary @'+cFile+' https://prod.eet.cz/eet/services/EETServiceSOAP/v3'

hb_processRun( cCommand,, @cStdOut )
// mg_log(cStdOut)

return cStdOut

function sendEetMessage( cMessage, lTest)

local cUrl, cRemote_url, cTmp
default lTest to .T.
default cMessage to ""

if empty( cMessage )
	cMessage := hb_memoread("signed_message")
endif

if lTest
	cRemote_url := "https://pg.eet.cz/eet/services/EETServiceSOAP/v3"
else
	cRemote_url := "https://prod.eet.cz/eet/services/EETServiceSOAP/v3"
endif

curl_global_init()
cUrl := curl_easy_init()
if empty(cUrl)
	msg("Error iniitalizing cUrl engine")
	return ""
endif

curl_easy_setopt( cUrl, HB_CURLPROTO_HTTPS, cRemote_url )
//curl_easy_setopt( cUrl, HB_CURLOPT_POST )
curl_easy_setopt( cUrl, HB_CURLOPT_HTTPPOST )
//curl_easy_setopt( cUrl, HB_CURLOPT_URL, cRemote_url )
curl_easy_setopt( cUrl, HB_CURLOPT_HTTPHEADER, "Content-Type: text/xml;charset=UTF-8" )
curl_easy_setopt( cUrl, HB_CURLOPT_HTTPHEADER, "SOAPAction: http://fs.mfcr.cz/eet/OdeslaniTrzby" )
curl_easy_setopt( cUrl, HB_CURLOPT_VERBOSE, .T. )
curl_easy_setopt( cUrl, HB_CURLOPT_DL_BUFF_SETUP ) 
curl_easy_setopt( cUrl, HB_CURLOPT_UL_BUFF_SETUP, cMessage )
curl_easy_setopt( cUrl, HB_CURLPROTO_HTTPS, cRemote_url )

// mg_log(curl_easy_perform( cUrl ))
//curl_easy_setopt( cUrl, HB_CURLOPT_DL_BUFF_GET, @tmp )
cTmp := curl_easy_dl_buff_get( cUrl )
//mg_log(cTmp)

curl_easy_reset( cUrl )
curl_easy_cleanup( cUrl )
curl_global_cleanup()

return cTmp

function ProcessEetResponse(cEetResponse)

local cRet := "", x, y, nTmp, cTmp
if empty(cEetResponse)
	Msg("Invalid Eet response...")
	return cRet
endif

x := at( "fik", cEetResponse )
nTmp := x
do while .t.
	nTmp++
	cTmp:= substr( cEetResponse, nTmp, 1 )
	if cTmp == " " .or. cTmp == "/" .or. cTmp == ">"
		y := nTmp
		exit
	endif
enddo
x := x+5
cRet := substr( cEetResponse, x, y-x-1 )
//mg_log(cRet)

return cRet



