#command DEFAULT <p> TO <val> [,<pn> TO <valn>] ;
        => <p> = iif(<p> = NIL, <val>, <p>) ;
        [;<pn> = iif(<pn> = NIL, <valn>, <pn>)]

#translate STRX( <exp1> ) => ( Alltrim(Str( <exp1> ) ) )

#define _SELF_NAME_	"fenix"
#define _I(x)	hb_i18n_gettext( x /*, _SELF_NAME_ */ )		  

#define PATH_DEL  hb_ps()
#define NL hb_OSnewline()
#define EOL  hb_eol()
#define __CHARSET__ hb_cdpselect()

#define DOS_CRLF chr(13)+chr(10)
#define DOS_EOL chr(13)+chr(10)

