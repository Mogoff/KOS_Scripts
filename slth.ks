@lazyGlobal on.
print "waiting for target".
wait until hasTarget.
sas on.
stage.
lock throttle to 1.
wait until ship:airspeed>70.
sas off.
local TPNShow to vecDraw(v(0,0,0), v(0,0,0), RGB(1,0,0), "GUIDANCE VECTOR", 1.2, true, 0.2).
local steeringVec to vecDraw(v(0,0,0), v(0,0,0), RGB(0,0,1), "steeringVec", 1.2, true, 0.2).
local TargetVector to vecDraw(v(0,0,0), v(0,0,0), RGB(1,1,0), "TargetVector", 1.2, true, 0.2).
set ship:control:pilotmainthrottle to 1.
set speedPID to pidLoop(0.5,-0.4,0,0,1).
set speedPID:setpoint to 1540.
until false {
    clearScreen.
    lock throttle to speedPID:update(time:seconds,ship:airspeed).
    set SteeringManager:PITCHTS to 0.3.
    set SteeringManager:YAWTS to 0.3.
    set RelativeVelocity to target:velocity:surface - ship:velocity:surface.
    set TargetDirection to (target:position - ship:position):normalized.

    set TPN to vcrs(RelativeVelocity, vcrs(TargetDirection, RelativeVelocity)).
    local steering_direction to (0.00002 * TPN + TargetDirection:normalized):normalized.
    lock steering to steering_direction.
    set TPNShow:vec to TPN.
    set TargetVector:vec to target:position.
    set steeringVec:vec to steering_direction * 20.
    print "Time To Impact(sec): " + round(target:position:mag/RelativeVelocity:mag,0).
    wait 0.
}