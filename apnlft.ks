@lazyGlobal on.
print "waiting for target".
wait until hasTarget.
sas on.
stage.
lock throttle to 1.
wait 5.
stage.
sas off.
local APNShow to vecDraw(v(0,0,0), v(0,0,0), RGB(1,0,0), "GUIDANCE VECTOR", 1.2, true, 0.2).
local TargetVector to vecDraw(v(0,0,0), v(0,0,0), RGB(1,1,0), "LoftVec", 1.2, true, 0.2).
set ship:control:pilotmainthrottle to 1.
set speedPID to pidLoop(0.5,-0.4,0,0,1).
set speedPID:setpoint to 1300.
set olos to target:position-ship:position.
until false {
    clearScreen.
    lock throttle to speedPID:update(time:seconds,ship:airspeed).
    set SteeringManager:PITCHTS to 0.3.
    set SteeringManager:YAWTS to 0.3.
    set RelativeVelocity to ship:velocity:surface - target:velocity:surface.
    set TargetDirection to (target:position - ship:position):normalized.
    set TTI to target:position:mag/RelativeVelocity:mag.
    
    // LOFTVEC CALC 
    set nlos to (target:position - ship:position).
    set LoftVec to (olos - nlos) + (ship:up:vector:normalized*3).
    //if TTI <= 15 {
    //    set LoftVec to ((TargetDirection*(15-TTI)) + ((olos - nlos) + (ship:up:vector:normalized*2)))*(TTI/50).
    //}
    set APN to LoftVec + TargetDirection. //+ (RelativeVelocity:normalized*(1/target:distance))*0.
    set deltalos to (olos - nlos):mag.
    set olos to nlos.

    local steering_direction to APN.
    lock steering to steering_direction.
    set APNShow:vec to APN:normalized * 1000.
    set TargetVector:vec to LoftVec:normalized * 1000.
    print "Time To Impact(sec): " + round(TTI,0).
    print "RelVel " + RelativeVelocity:mag.
    print "deltaLos amg" + deltalos.
    log (ship:longitude:tostring + " " + ship:latitude:tostring + " " + alt:radar:tostring) to "0:/msl_PN_close_loft_WH.dat".
    log (target:geoposition:lng:tostring + " " + target:geoposition:lat:tostring + " " + target:altitude:tostring) to "0:/tgt_PN_close_loft_WH.dat".
    wait 0.
}