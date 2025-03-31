@lazyGlobal on.
// стартовый алгоритм
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
local counterv to vecDraw(v(0,0,0),v(0,0,0),RGB(1,0,1),"Counter",1.2,true,0.2).
local omegavec to vecDraw(v(0,0,0),v(0,0,0), RGB(1,1,1),"Omega",1.2,true,0.2).
local accelvec to vecDraw(v(0,0,0),v(0,0,0), RGB(1,1,1),"ACCEL",1.2,true,0.2).
set ship:control:pilotmainthrottle to 1.
set speedPID to pidLoop(0.5,-0.4,0,0,1).
set speedPID:setpoint to 1500.
set olos to target:position-ship:position.
set otvel to target:velocity:surface.
set startTime to time:seconds.
function clamp{
    parameter num.
    parameter nmin.
    parameter nmax.
    return min(max(num, nmin), nmax).
}

until false {
    clearScreen.
    lock throttle to speedPID:update(time:seconds,ship:airspeed).
    set SteeringManager:PITCHTS to 0.3.
    set SteeringManager:YAWTS to 0.3.
    set RelativeVelocity to target:velocity:surface - ship:velocity:surface.
    set TargetDirection to (target:position - ship:position):normalized.
    set TTI to target:position:mag/RelativeVelocity:mag.
    // доп.построения
    set nlos to target:position - ship:position.
    if TTI > 15 {
        set LoftVec to (olos - nlos) + (ship:up:vector:normalized*3.5).
        //set counter to VXCL(nlos-olos,VCRS(ship:up:vector:normalized,TargetDirection)).
        set counter to VCRS(ship:up:vector:normalized,TargetDirection) * VDOT(nlos-olos,VCRS(ship:up:vector:normalized,TargetDirection)).
    }
    if TTI <= 15 {
        set LoftVec to ((TargetDirection*(15-TTI)) + ((olos - nlos) + (ship:up:vector:normalized*4.5)))*(TTI/220).
        set counter to v(0,0,0).
    }
    set olos to nlos.

    // фаза м. промаха
    set relvelmag to RelativeVelocity:mag.
    set zero_miss_phase to VANG(TargetDirection,-RelativeVelocity).
    print "Фаза М.Промаха: " + round(zero_miss_phase,2).
    set zero_miss_vec to (target:position - ship:position) - TTI * (-RelativeVelocity).
    print "Мгновенный промах: " + round(zero_miss_vec:mag,2).

    //угловая скорость
    set omega to VCRS((target:position - ship:position),RelativeVelocity)*(1/(target:position - ship:position):mag^2).
    print "Вектор омега: " + omega:mag.

    //управляющее ускорение
    set accel to VCRS(ship:velocity:surface:mag*omega,TargetDirection).
    set accelvec:vec to accel*100.

    //ускорение цели, нормальное к перемещению
    set ntvel to target:velocity:surface.
    set dTVelocity to otvel - ntvel.
    set otvel to ntvel.
    
    set normTaccel to VXCL(target:velocity:surface,dTVelocity).

    //TPN
    set TPN to VCRS(3*ship:velocity:surface:mag*omega,TargetDirection:normalized).

    local steering_direction to (((13 * TPN) + LoftVec)+(counter:normalized*clamp(zero_miss_phase+1,0,10))):normalized.
    lock steering to steering_direction.
    set TPNShow:vec to TPN*10.
    set counterv:vec to counter.
    set TargetVector:vec to target:position.
    set omegavec:vec to omega*200.
    set steeringVec:vec to steering_direction * 20.
    print "Time To Impact(sec): " + round(TTI,0).

    // вывод данных на внешний файл
    log (ship:longitude:tostring + " " + ship:latitude:tostring + " " + alt:radar:tostring) to "0:/msl_PN_close_loft_WH.dat".
    log ((time:seconds - startTime):tostring + " " + zero_miss_phase) to "0:/missPhase.dat".
    log ((time:seconds - startTime):tostring + " " + zero_miss_vec:mag) to "0:/miss.dat".
    log ((time:seconds - startTime):tostring + " " + accel:mag:tostring) to "0:/accelMag.dat" .
    log ((time:seconds - startTime):tostring + " " + normTaccel:mag:tostring) to "0:/tnaccel.dat".
    log (target:geoposition:lng:tostring + " " + target:geoposition:lat:tostring + " " + target:altitude:tostring) to "0:/tgt_PN_close_loft_WH.dat".
    wait 0.
}