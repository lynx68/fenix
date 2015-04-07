#command DEFAULT <p> TO <val> [,<pn> TO <valn>] ;
        => <p> = iif(<p> = NIL, <val>, <p>) ;
        [;<pn> = iif(<pn> = NIL, <valn>, <pn>)]

#command REPEAT => DO WHILE .T.
#command UNTIL <exp1> => IF <exp1>; EXIT; END; END
#translate STRX( <exp1> ) => ( Alltrim(Str( <exp1> ) ) )

#ifdef __HARBOUR__
    #define PATH_DEL  hb_ps()
    #define PATH_DELIM  hb_ps()
    #define CRLF hb_OSnewline()
	 #define EOL  hb_eol()
//	 #define __CHARSET__ hb_setcodepage()		 
	 #define __CHARSET__ hb_cdpselect()
#else
	#ifdef __UNIX__
	   #define PATH_DEL "/"
		#ifndef __CLIP__  
		   #define PATH_DELIM "/"
		#endif
	#else
	  #define PATH_DEL "\"
	  #define PATH_DELIM "\"
	#endif
#endif

#ifdef __UNIX__
  #define ENDOFLINE chr(10)
#else 
  #define ENDOFLINE chr(13)+chr(10)
#endif

#define DOS_CRLF chr(13)+chr(10)




