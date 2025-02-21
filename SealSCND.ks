@lazyGlobal on.
//[[GLOBAL LAUNCH_SUCCESSFUL IS FALSE.
//main().
//FUNCTION MAIN {
//   UNTIL LAUNCH_SUCCESSFUL {
//        WAIT_FOR_TARGET().
//        LAUNCH().
//    }
//}
//FUNCTION WAIT_FOR_TARGET {
//    PRINT "WAITING FOR TARGET".
//    WAIT UNTIL NOT CORE:MESSAGES:EMPTY.
//    GLOBAL TARGET_NAME IS CORE:MESSAGES:POP:CONTENT.
//    PRINT "RECIEVED TARGET: " + TARGET_NAME.
//}
//FUNCTION LAUNCH {
//    LOCAL DECOUPLER IS CORE:PART:DECOUPLER.
//    IF DECOUPLER:MODULES:FIND("MODULEDECOUPLE") <> -1 {
//        DECOUPLER:GETMODULE("MODULEDECOUPLE"):DOEVENT("отделить").
//    } ELSE IF DECOUPLER:MODULES:FIND("MODULEANCHOREDDECOUPLER") <> -1 {
//        DECOUPLER:GETMODULE("MODULEANCHOREDDECOUPLER"):DOEVENT("отделить").
//    } ELSE {
//        PRINT "UNABLE TO DECOUPLE".
//        RETURN.
//    }
//    WAIT 0.5.
//    LIST ENGINES IN ENGS.
//    FOR ENG IN ENGS {
//        ENG:ACTIVATE().
//    }
//    LOCK THROTTLE TO 1.0.
//    SET LAUNCH_SUCCESSFUL TO TRUE.
//}
set kuniverse:activevessel to vessel("HCM").
//set target to TARGET_NAME.
//set kuniverse:activevessel to vessel("Revelator").
sas off.
stage.
lock throttle to 1.
lock steering to heading(target:geoposition:heading,90,0).
wait until ship:airspeed>100.
lock steering to heading(target:geoposition:heading,45,0).
wait until ship:altitude>11600.
lock steering to heading(target:geoposition:heading,5).
wait until ship:airspeed>=1200.
set speedPID to pidLoop(0.05,0.4,0,0,1).
set speedPID:setpoint to 1600.
set AltPID to pidLoop(0.01,0,0.04).
set AltPID:setpoint to 20000.
set SteeringManager:PITCHTS to 0.3.
set SteeringManager:YAWTS to 0.3.
set SteeringManager:ROLLTS to 0.1.
set defPack to kuniverse:defaultloaddistance:landed:pack.
set defUnpack to kuniverse:defaultloaddistance:landed:unpack.
set defLoad to kuniverse:defaultloaddistance:landed:load.
set defUnload to kuniverse:defaultloaddistance:landed:unload.
set dDistance to V(0,0,0).
until false {
    clearScreen.
    set RelativeVelocity to target:velocity:surface - ship:velocity:surface.
    set TargetDirection to (target:position - ship:position):normalized.
    set dDistance to target:position.
    set TPN to vcrs(RelativeVelocity, vcrs(TargetDirection, RelativeVelocity)) + (dDistance - target:position).
    local steering_direction to (0.00002 * TPN + TargetDirection:normalized):normalized.

    if target:distance > 60000{
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
