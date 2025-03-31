clearVecDraws().
set terminal:width to 34.
set terminal:height to 14.
set SHIP:CONTROL:NEUTRALIZE to true.
print "waiting for target".
wait until hasTarget.
set old_LOS_Vector to target:position-ship:position.
ON AG9 {print 1/0.}.
set cyclogram to 0.
set SteeringManager:PITCHTS to 0.3.
set SteeringManager:YAWTS to 0.3.
local LOSShow to vecDraw(v(0,0,0), v(0,0,0), RGB(1,0,0), "LOS", 1.2, true, 0.2).
local steeringVec to vecDraw(v(0,0,0), v(0,0,0), RGB(0,0,1), "steeringVec", 1.2, true, 0.2).
local RV to vecDraw(v(0,0,0), v(0,0,0), RGB(0,1,0), "RV", 1.2, true, 0.2).
local LOFT to vecDraw(v(0,0,0),v(0,0,0),RGB(1,0,1),"LOFT",1.2,true,0.2).
set old_LOS_Vector to V(0,0,0).
until false {
    clearScreen.
    set LOS_Vector to target:orbit:position - ship:orbit:position.
    set RelativeVelocity to target:velocity:orbit - ship:velocity:orbit.

    //log (ship:longitude:tostring + " " + ship:latitude:tostring + " " + alt:radar:tostring) to "0:/kkv.dat".
    //log (target:geoposition:lng:tostring + " " + target:geoposition:lat:tostring + " " + target:altitude:tostring) to "0:/sat.dat".

    set vertical_relVel_Vector to vdot(VXCL(LOS_Vector,RelativeVelocity),ship:facing:topvector).
    set horizontal_relVel_Vector to vdot(VXCL(LOS_Vector,RelativeVelocity),SHIP:FACING:STARVECTOR).

    set TargetDirection to LOS_Vector:normalized.
    set TPN to vcrs(RelativeVelocity:normalized, vcrs(TargetDirection:normalized, RelativeVelocity:normalized)).
    // FIRING SOLUTION DECIDING

    set Missile_DeltaV to SHIP:STAGEDELTAV(SHIP:STAGENUM):CURRENT+SHIP:STAGEDELTAV(SHIP:STAGENUM-1):CURRENT+SHIP:STAGEDELTAV(SHIP:STAGENUM-2):VACUUM+SHIP:STAGEDELTAV(SHIP:STAGENUM-3):VACUUM.

    if target:apoapsis>110000 {
        set high_suborbit_type to true.
    } else {
        set high_suborbit_type to false.
    }

    if (not high_suborbit_type) and (cyclogram=0) and (VXCL(LOS_Vector,RelativeVelocity):mag <= Missile_DeltaV) and (vdot(RelativeVelocity,LOS_Vector:normalized)<-1600) { 
        set cyclogram to 1.
    }
    if high_suborbit_type and cyclogram=0 and (vdot(RelativeVelocity,LOS_Vector:normalized)<-600) {
        set cyclogram to 4.
    }
    //-------------------------------
    // MODES SWITCHING

    if cyclogram = 0 {
        set mode to "WAITING FOR SOLUTION".
    }   else if cyclogram = 1 {
        set mode to "START".
    }   else if cyclogram = 2{
        set mode to "ON TRAJECTORY".
    } else if cyclogram = 3 {
        set mode to "INTERCEPTING".
    } else if cyclogram = 4{
        set mode to "START. TNG.".
    }

    //-------------------------------
    // AUTO-STAGING
    List Engines In elist.
        For E In elist {
            If (E:Flameout and E:ignition and stage:ready) or (E:ignition and stage:ready and (E:thrust=0)) { stage. }
    }.
    if (stage:deltav:current=0 and (not cyclogram=0) and stage:ready) {stage.}
    //-------------------------------
    // INFORMATION OUTPUT FOR TERMINAL
    set center_width to terminal:width/4.
    print "STATUS:     " at(center_width,2).
    print mode at(center_width,3).
    print "CLOSING VEL:" + round(-1*vdot(RelativeVelocity,LOS_Vector:normalized)) at(center_width,6).
    print "DISTANCE:   " + round(LOS_Vector:mag) at(center_width,7).
    print "fi(up^top): " + round(vang(ship:facing:topvector,ship:up:vector)) at(center_width,8).
    print "ksi(v^los): " + round(vang(ship:velocity:orbit,LOS_Vector)) at(center_width,9).
    print "NORM RV:    " + round(VXCL(LOS_Vector,RelativeVelocity):mag) at (center_width,10).
    print "DELTAV:     " + round(Missile_DeltaV) at(center_width,11).
    print "VELOCITY:   " + round(ship:velocity:surface:mag) at(center_width,12).
    if mode = "INTERCEPTING" {
        print "TTI:        " + round(LOS_Vector:mag/RelativeVelocity:mag) at(center_width,13).
    } else if mode = "WAITING FOR SOLUTION" {
        print "TTL:        " + round(VXCL(LOS_Vector,RelativeVelocity):mag/Missile_DeltaV) at(center_width,13).
    }
    //-------------------------------
    // MAIN SEQUENCE
    set LoftVector to (old_LOS_Vector - LOS_Vector) + (ship:up:vector:normalized*210).
    set old_LOS_Vector to LOS_Vector.
    set counter to VCRS(ship:up:vector:normalized,TargetDirection) * VDOT(old_LOS_Vector - LOS_Vector,VCRS(ship:up:vector:normalized,TargetDirection)).
    if cyclogram = 1 {
        sas on.
        lock throttle to 1.
        if ship:altitude>=3000 {
            sas off.
            rcs on.
            set cyclogram to 2.
        }
    }
    if cyclogram = 2 {
        lock steering to TPN.
        if (VXCL(LOS_Vector,RelativeVelocity):mag)<=5 {
            lock throttle to 0.
            wait 1.
            set cyclogram to 3.
        }
    }
    if cyclogram = 3 {
        lock steering to lookDirUp(LOS_Vector,ship:up:vector).
        if (vang(ship:facing:topvector,ship:up:vector) < 25) or ag2{
            set ship:control:translation to V(horizontal_relVel_Vector,vertical_relVel_Vector,0).
        }
        if LOS_Vector:mag < 500 {
            set mode to "OH AIGHT BYE".
            set SHIP:CONTROL:NEUTRALIZE to true.
            unset mode.
            unset TPN.
            unset TargetDirection.
            unset RelativeVelocity.
            unset cyclogram.
        }
    }
    if cyclogram = 4 {
        lock throttle to 1.
        sas off.
        rcs on.
        lock steering to VXCL(LOS_Vector,RelativeVelocity)*10 + LoftVector + counter*(LOS_Vector:mag/600).
        if (ship:velocity:surface:mag >= 800) and target:altitude>=70000 {
            set cyclogram to 2.
        } else if target:altitude<70000 {
            set mode to "I CANT DO ANYTHING ABOUT IT".
        }
    }
    set LOSShow:vec to LOS_Vector:normalized*(LOS_Vector:mag/600).
    set RV:vec to VXCL(LOS_Vector,RelativeVelocity)*10.
    set LOFT:vec to LoftVector*10 + counter*(LOS_Vector:mag/600).
    set steeringVec:vec to VXCL(LOS_Vector,RelativeVelocity)*10 + LoftVector + counter*(LOS_Vector:mag/600).
    //-----------------------------
    wait 0.
}