/*
 * Fenix Open Source accounting system
 * Network lock functions
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

function RecLock( nseconds )

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
         lock_num

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
