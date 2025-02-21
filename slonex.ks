@lazyGlobal on.
print "waiting for target".
wait until hasTarget.
sas on.
stage.
lock throttle to 1.
wait 5.
stage.
sas off.
local TPNShow to vecDraw(v(0,0,0), v(0,0,0), RGB(1,0,0), "GUIDANCE VECTOR", 1.2, true, 0.2).
local steeringVec to vecDraw(v(0,0,0), v(0,0,0), RGB(0,0,1), "steeringVec", 1.2, true, 0.2).
local TargetVector to vecDraw(v(0,0,0), v(0,0,0), RGB(1,1,0), "TargetVector", 1.2, true, 0.2).
set ship:control:pilotmainthrottle to 1.
set speedPID to pidLoop(0.5,-0.4,0,0,1).
set speedPID:setpoint to 1500.
set olos to target:position-ship:position.
//set parts to ship:parts.
set orange to target:distance.
until false {
    clearScreen.
    lock throttle to speedPID:update(time:seconds,ship:airspeed).
    set SteeringManager:PITCHTS to 0.3.
    set SteeringManager:YAWTS to 0.3.
    set RelativeVelocity to target:velocity:surface - ship:velocity:surface.
    set TargetDirection to (target:position - ship:position):normalized.
    set TTI to target:position:mag/RelativeVelocity:mag.
    set TPN to vcrs(RelativeVelocity:normalized, vcrs(TargetDirection:normalized, RelativeVelocity:normalized)).
    // LOFTVEC CALC 
    set nlos to target:position - ship:position.
    if TTI > 15 {
        set LoftVec to (olos - nlos) + (ship:up:vector:normalized*4).
    }
    if TTI <= 15 {
        set LoftVec to ((TargetDirection*(15-TTI)) + ((olos - nlos) + (ship:up:vector:normalized*4.5)))*(TTI/220).
    }
    set olos to nlos.

    local steering_direction to ((17 * TPN) + LoftVec):normalized.
    lock steering to steering_direction.
    set TPNShow:vec to TPN.
    set TargetVector:vec to target:position.
    set steeringVec:vec to steering_direction * 20.
    print "Time To Impact(sec): " + round(TTI,0).
    //set nrange to target:distance.
    //if (((orange - nrange) <= 0) and (target:distance <=200)) { 
    //    set WH to parts[25]:getmodule("BDExplosivePart"):doevent("detonate").
    //}
    //set orange to nrange.

    // you can un-comment these two lines if you want to gnuplot it
    log (ship:longitude:tostring + " " + ship:latitude:tostring + " " + alt:radar:tostring) to "0:/msl_PN_close_loft_WH.dat".
    log (target:geoposition:lng:tostring + " " + target:geoposition:lat:tostring + " " + target:altitude:tostring) to "0:/tgt_PN_close_loft_WH.dat".
    wait 0.
}