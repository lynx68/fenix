/*
 * $Id: netlock.prg,v 1.3 2004-06-27 12:41:43 siki Exp $
 */

****************************************************************
*** File: net.prg
*** Author: (c) MSoft All Rights Reserved
*** Date:  12/20/93 05:04am
*** Notes: Zbirka funkcija za mrezu
****************************************************************

//#include "alerts.ch"
#include "commands.ch"

****************************************************************
*** Datum:  12/20/93 05:05am
*** Naziv: AddRec()
*** Opis : Dodavanje zapisa u Shared databazi. Provera i upit
****************************************************************

function AddRec(nwaitseconds)

local lforever, wait_time, restart
default nwaitseconds to 3

dbappend()
if .not. neterr()
    return .t.
endif

restart := .t.
lforever := (nwaitseconds = 0)

do while restart

   wait_time := nwaitseconds
   do while (lforever .or. wait_time > 0)
      dbappend()
      if .not. neterr()
         return .t.
      endif
      inkey(.5)
      wait_time := wait_time  - .5
   enddo
   //restart := alert("Blokov n¡ nebylo £spˆ¨n‚. Zkus¡te to znovu ?",2) = 1
   MsgAsk("Se z znamem pracuje kolega, zkuste to pozdˆji.",4)
   restart := .f.
enddo

return .f.

****************************************************************
*** Datum:  12/20/93 05:06am
*** Naziv:  RecLock()
*** Opis :  Pokusava da blokira zapis u Shared bazi
****************************************************************

function reclock(nseconds)

local lforever, wait_time, restart
default nseconds to 3

if dbrlock()
   return .t.
endif

lforever := (nseconds = 0)
restart := .t.

do while restart
   wait_time := nseconds
   do while (lforever .or. wait_time > 0)
      if dbrlock()
         return .t.
      endif
      inkey(.5)
      wait_time := wait_time - .5
   enddo
    // restart := alert("Blokov n¡ nebylo £spˆ¨n‚. Zkus¡te to znovu ?",2) = 1
   MsgAsk("Se z znamem pracuje kolega, zkuste to pozdˆji.",4)
   restart := .f.
enddo

return .f.

****************************************************************
*** Datum:  12/20/93 05:07am
*** Naziv: Tran_Setup(arg)
*** Opis : Inicijalizacija transakcije
****************************************************************

function tran_setup(tran_ar)

local num_locks := len(tran_ar), ;
            lock_num := 0, lock_failed := .f.

do while !lock_failed .and. ++lock_num <= num_locks

    do case
    case valtype(tran_ar[lock_num]) = "A"
        (tran_ar[lock_num, 1]) -> ;
        (gotof(tran_ar[lock_num, 2]))
        lock_failed := !(tran_ar[lock_num, 1]) -> (flock())

    case valtype(tran_ar[lock_num]) = "C"
        lock_failed := !(tran_ar[lock_num]) -> (flock())

    case valtype(tran_ar[lock_num]) = "N"
        goto tran_ar[lock_num]
        lock_failed := !rlock()
    endcase
enddo

return !lock_faILED

****************************************************************
*** Datum:  12/20/93 05:08am
*** Naziv: Tran_Fin(arg)
*** Opis : Kraj transakcije
****************************************************************


FUNCTION TRAN_FIN(TRAN_AR)

LOCAL NUM_LOCKS := LEN(TRAN_ar), ;
         lock_num, dummy

for lock_num := 1 to num_locks
    do case
        case valtype(tran_ar[lock_num]) = "a"
            (tran_ar[lock_num, 1]) -> (unlockf())
        case valtype(tran_ar[lock_num]) = "c"
            (tran_ar[lock_num]) -> (unlockf())
        case valtype(tran_ar[lock_num]) = "n"
            unlock
    endcase
next
return nil

****************************************************************
*** Datum:  12/20/93 05:10am
*** Naziv: GotoF(rec)
*** Opis : Osvezavanje bafera
****************************************************************


static function gotof(rec_no)

goto rec_no

return nil

****************************************************************
*** Datum:  12/20/93 05:09am
*** Naziv: UnLockF()
*** Opis : Odkljucavanje aktivnog fajla
****************************************************************

static function unlockf

unlock

return nil