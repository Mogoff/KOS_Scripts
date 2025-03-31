@lazyglobal off.

clearscreen.
wait until alt:radar > 10.
until False and ship:status = FLYING {
    clearscreen.
    if ship:verticalspeed<0 {
        if (((abs(alt:radar/ship:verticalspeed)<2) and RCS and (alt:radar>15)) or ((abs(alt:radar/ship:verticalspeed)<2) and RCS and (alt:radar<=15)) ) {
            toggle ABORT.
            HUDTEXT("EJECT! EJECT!", 1,2,100, GREEN, false).
        }
    }
    print alt:radar/ship:verticalspeed.
    if ABORT = True {
        wait 3.
        SAS off.
        shutdown.
    }
    wait 0.
}.
