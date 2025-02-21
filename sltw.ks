@lazyGlobal on.
print "waiting for target".
wait until hasTarget.
sas off.
stage.
lock throttle to 1.
lock steering to heading(target:geoposition:heading,90,0).
wait until ship:airspeed>100.
lock steering to heading(target:geoposition:heading,45,0).
wait until ship:altitude>11600.
lock steering to heading(target:geoposition:heading,5).
wait until ship:airspeed>=1400.
local APNShow to vecDraw(v(0,0,0), v(0,0,0), RGB(1,0,0), "GUIDANCE VECTOR", 1.2, true, 0.2).
local steeringVec to vecDraw(v(0,0,0), v(0,0,0), RGB(0,0,1), "steeringVec", 1.2, true, 0.2).
local TargetAcc to vecDraw(V(0,0,0), v(0,0,0), RGB(0,1,0), "TargetAcc", 1.2, true, 0.2).
set speedPID to pidLoop(0.05,0.4,0,0,1).
set speedPID:setpoint to 1600.
set AltPID to pidLoop(0.01,0,0.04).
set AltPID:setpoint to 18000.
set SteeringManager:PITCHTS to 0.3.
set SteeringManager:YAWTS to 0.3.
set SteeringManager:ROLLTS to 0.1.
set defPack to kuniverse:defaultloaddistance:landed:pack.
set defUnpack to kuniverse:defaultloaddistance:landed:unpack.
set defLoad to kuniverse:defaultloaddistance:landed:load.
set defUnload to kuniverse:defaultloaddistance:landed:unload.
until false {
    clearScreen.
    set RelativeVelocity to target:velocity:surface - ship:velocity:surface.
    set TargetDirection to (target:position - ship:position):normalized.
    set APN to vcrs(RelativeVelocity, vcrs(TargetDirection, RelativeVelocity)).
    set APNShow:vec to APN.
    local steering_direction to (0.00002 * APN + TargetDirection:normalized):normalized.
    set steeringVec:vec to steering_direction * 20.

    if target:distance > 50000{
        lock throttle to speedPID:update(time:seconds,ship:airspeed).
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
        print "Time to impact: " + round(target:position:mag/(target:velocity:surface - ship:velocity:surface):mag,1).
        print "================================".
        wait 0.
    }
    if target:distance <= 50000{
        set ship:control:pilotmainthrottle to 1.
        set speedPID:setpoint to 610.
        lock steering to steering_direction.
        set dist to kuniverse:defaultloaddistance:landed.
        set dist:unload TO 30500.
        set dist:load TO 29500.
        wait 0.
        set dist:pack TO 29999.
        set dist:unpack TO 29000.
        wait 0.
        print "================================".
        print "TERMINAL STAGE.".
        print "================================".
        print "Time to impact: " + round(target:position:mag/(target:velocity:surface - ship:velocity:surface):mag,1).
        print "================================".
        wait 0.
    }
    if target:distance<=50 {
        set dist:unload TO defUnload.
        set dist:load TO defLoad.
        wait 0.
        set dist:pack TO defPack.
        set dist:unpack TO defUnpack.
        wait 0.
    }
    wait 0.
}
