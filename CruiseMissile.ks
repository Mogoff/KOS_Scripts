@lazyglobal on.
clearScreen.
sas on.
print "Select the target.".
wait until hastarget.
clearScreen.
print "Target acquired: " + target:name.
print "================================".
print "LAT: " + round(target:geoposition:lat,3) + "; LNG: " + round(target:geoposition:lng,3).
print "================================".
stage.
wait until ship:altitude>100.
sas off.
lock steering to heading (target:geoposition:heading,50).
wait until stage:solidfuel<1.
stage.
lock throttle to 1.
wait until ship:altitude>18000.
rcs on.
lock steering to heading(target:geoposition:heading,5).
wait until ship:airspeed>=1000.
set TerminalZ to false.
//set KRadius to 600000. //радиус кербина в метрах
Until TerminalZ=True {
    clearScreen.
    // перевод декартовых в сферические
    //set sYMissile to arctan(sqrt((ship:geoposition:lat)^2+(ship:geoposition:lng)^2)/ship:altitude).
    //set sZMissile to arctan(ship:geoposition:lng/ship:geoposition:lat).

    //set sYTarget to arctan(sqrt((target:geoPosition:lat)^2+(target:geoposition:lng)^2)/target:altitude).
    //set sZTarget to arctan(target:geoposition:lng/target:geoposition:lat).

    //set SphereDistance to KRadius*arccos((sin(ship:geoposition:lat)*sin(target:geoposition:lat))+(cos(ship:geoposition:lat)*cos(target:geoposition:lat)*cos(target:geoposition:lng-ship:geoposition:lng))).

    set AltPID to pidLoop(0.015,0.01,0.015).
    set AltPID:setpoint to 21000.

    if target:distance > 80000{
        lock steering to heading(target:geoposition:heading,AltPID:update(time:seconds,ship:altitude),0).
        print "================================".
        print "Target acquired: " + target:name.
        print "================================".
        print "LAT: " + round(target:geoposition:lat,3) + "; LNG: " + round(target:geoposition:lng,3).
        print "================================".
        print "CRUISE STAGE.".
        print "================================".
        print "Distance: " + round(target:distance,2) + " Meters".
        print "================================".
        print "Time to impact: " + round(target:distance/velocity:surface:mag,1).
        print "================================".
    }
    if VANG(VELOCITY:SURFACE,target:Geoposition:POSITION) <= 12 and target:distance <= 80000{
        clearScreen.
        lock steering to target:Geoposition:POSITION:normalized+((facing:vector:normalized-velocity:surface:normalized))*3.
        lock throttle to 0.5.
        print "================================".
        print "TERMINAL STAGE.".
        print "================================".
        print "Time to impact: " + round(target:distance/velocity:surface:mag,1).
        print "================================".
    }
    if VANG(VELOCITY:SURFACE,TARGET:GEOPOSITION:POSITION) > 12 and target:distance <= 80000{
        clearScreen.
        lock steering to target:geoPosition:position.
        lock throttle to 0.5.
        print "================================".
        print "TERMINAL-LOS STAGE.".
        print "================================".
        print "Time to impact: " + round(target:distance/velocity:surface:mag,1).
        print "================================".
    }
}