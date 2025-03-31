wait until hasTarget.
print "Target acquired".
wait until target:distance <= 32000.
clearScreen.
print "Logging flight data...".
until false {
    log (ship:longitude:tostring + " " + ship:latitude:tostring + " " + alt:radar:tostring) to "0:/msl_PP_close.txt".
    log (target:geoposition:lng:tostring + " " + target:geoposition:lat:tostring + " " + target:altitude:tostring) to "0:/tgt_PP_close.txt".
    if target:distance <= 4000 {
        log (ship:longitude:tostring + " " + ship:latitude:tostring + " " + alt:radar:tostring) to "0:/msl_PP_term.txt".
        log (target:geoposition:lng:tostring + " " + target:geoposition:lat:tostring + " " + target:altitude:tostring) to "0:/tgt_PP_term.txt".
    }
    wait 0.25.
}