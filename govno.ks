wait 5.
set otvel to target:velocity:surface.
set startTime to time:seconds.
until False {
    clearScreen.
    // фаза м. промаха
    set RelativeVelocity to target:velocity:surface - ship:velocity:surface.
    set TargetDirection to (target:position - ship:position):normalized.
    set relvelmag to RelativeVelocity:mag.
    set zero_miss_phase to VANG(TargetDirection,-RelativeVelocity).
    set TTI to target:position:mag/RelativeVelocity:mag.
    print "Фаза М.Промаха: " + round(zero_miss_phase,2).
    set zero_miss_vec to (target:position - ship:position) - TTI * (-RelativeVelocity).
    print "Мгновенный промах: " + round(zero_miss_vec:mag,2).

    //угловая скорость
    set omega to VCRS((target:position - ship:position),RelativeVelocity)*(1/(target:position - ship:position):mag^2).
    print "Вектор омега: " + omega:mag.

    //ускорение цели, нормальное к перемещению
    set ntvel to target:velocity:surface.
    set dTVelocity to otvel - ntvel.
    set otvel to ntvel.
    set normTaccel to VXCL(target:velocity:surface,dTVelocity).

    log (ship:longitude:tostring + " " + ship:latitude:tostring + " " + alt:radar:tostring) to "0:/msl_PP.dat".
    log ((time:seconds - startTime):tostring + " " + zero_miss_phase) to "0:/missPhase.dat".
    log ((time:seconds - startTime):tostring + " " + zero_miss_vec:mag) to "0:/miss.dat".
    log ((time:seconds - startTime):tostring + " " + normTaccel:mag:tostring) to "0:/tnaccel.dat".
    log (target:geoposition:lng:tostring + " " + target:geoposition:lat:tostring + " " + target:altitude:tostring) to "0:/tgt_PP.dat".
    wait 0.
}