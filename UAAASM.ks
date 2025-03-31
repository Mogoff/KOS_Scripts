@lazyglobal on.
clearScreen.
set ship:control:pilotmainthrottle to 1.
Until False {
    print "READY".
    clearScreen.
    set LaunchDistance to 5000.
    if hastarget and target:distance <= LaunchDistance  {print "IN RANGE!".}
    if AG1 and hasTarget {
        if VANG(VELOCITY:SURFACE,target:Geoposition:POSITION) <= 12 {
            //lock steering to target:Geoposition:POSITION:normalized+((facing:vector:normalized-velocity:surface:normalized)*4.11).
            set SteeringManager:PITCHTS to 0.3.
            set SteeringManager:YAWTS to 0.3.
            set RelativeVelocity to target:velocity:surface - ship:velocity:surface.
            set TargetDirection to (target:position - ship:position):normalized.
            lock steering to (0.000175 * (vcrs(RelativeVelocity, vcrs(TargetDirection, RelativeVelocity))) + TargetDirection).
            }
        if VANG(VELOCITY:SURFACE,TARGET:GEOPOSITION:POSITION) > 12 {
            lock steering to (target:geoPosition:position:normalized*(target:distance*2/ship:altitude*4))+up:vector:normalized*3.
        }
        SAS off.  
        set NAVMODE to "SURFACE".
        //x is lat, lng is y
        print "Target locked: " + target:name.
        print "Missile coordinates " + "LAT: " + round(SHIP:geoPosition:lat,2) + " LNG: " + round(SHIP:geoposition:lng,2).
        print "Target coordinates " + "LAT: " + round(TARGET:geoposition:lat,2) + " LNG: " + round(TARGET:geoposition:lng,2).
        print "Missile Altitude "+ round(SHIP:altitude,2) + " Meters ASL".
        print "Target Altitude " + round(Target:altitude,2) + " Meters ASL".
    }
}