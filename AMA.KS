clearVecDraws().
clearScreen.
PRINT "WAITING FOR TARGET " + ALT:RADAR.
WAIT UNTIL HASTARGET.
clearScreen.
PRINT "TARGET ACQ".
SET ATMOSPHERIC_DESCENT TO FALSE.
local LOS to vecDraw(v(0,0,0), v(0,0,0), RGB(1,0,0), "LOS", 1.2, true, 0.2).
local REFLECT to vecDraw(v(0,0,0), v(0,0,0), RGB(0,0,1), "REFLECT", 1.2, true, 0.2).
local CORRECT to vecDraw(v(0,0,0), v(0,0,0), RGB(1,1,0), "CORRECT", 1.2, true, 0.2).
set SteeringManager:PITCHTS to 0.3.
set SteeringManager:YAWTS to 0.3.
SET SteeringManager:TORQUEEPSILONMIN TO 0.00005.
SET SteeringManager:TORQUEEPSILONMAX TO 0.0005.
SET SteeringManager:MAXSTOPPINGTIME TO 6.
SET STEERINGMANAGER:PITCHPID:KD TO 2.
SET STEERINGMANAGER:YAWPID:KD TO 2.
SET PRE_DENSE TO TRUE.
SET throt TO 0.
LOCK THROTTLE TO throt.
SET done TO FALSE.
SET gravAcc TO body("Kerbin"):MU / (SHIP:BODY:RADIUS^2).
SET CHECKED TO FALSE.
UNTIL FALSE {
    clearScreen.

    IF PRE_DENSE {
        SET ATMOSPHERIC_DESCENT TO TRUE.
        SET PRE_DENSE TO FALSE.
    }

    IF ATMOSPHERIC_DESCENT = TRUE {
        IF CHECKED = FALSE {
            SET WET_MASS TO SHIP:MASS.
            SET CHECKED TO TRUE.
        }
        SAS OFF.
        AG2 ON.
        SET LOS_VECTOR TO target:position - ship:position.
        SET DOWN_VECTOR TO -SHIP:UP:VECTOR.
        SET DOWN_VECTOR_REFLECTED TO 2*(DOWN_VECTOR - LOS_VECTOR:NORMALIZED * VDOT(DOWN_VECTOR,LOS_VECTOR:NORMALIZED)) - DOWN_VECTOR.
        SET DOWN_VECTOR_CORRECTED TO -SHIP:VELOCITY:SURFACE - 3*(-SHIP:VELOCITY:SURFACE + DOWN_VECTOR_REFLECTED:NORMALIZED * VDOT(-SHIP:VELOCITY:SURFACE,-DOWN_VECTOR_REFLECTED:NORMALIZED)).


        //IF (VANG(DOWN_VECTOR_CORRECTED,-LOS_VECTOR)<5) AND (ALT:RADAR<=5000){
        //    LOCK STEERING TO -SHIP:VELOCITY:SURFACE.
        //    GEAR ON.
        //} ELSE
        //IF (VANG(DOWN_VECTOR_CORRECTED,-LOS_VECTOR)>=5) AND (ALT:RADAR>5000){
        //    LOCK STEERING TO DOWN_VECTOR_CORRECTED.
        //}

        IF ALT:RADAR<300 {
            LOCK STEERING TO -SHIP:VELOCITY:SURFACE.
            GEAR ON.
        } ELSE {
            SET YAW_ERROR TO SteeringManager:YAWERROR.
            SET PITCH_ERROR TO SteeringManager:PITCHERROR.
            //SET SteeringManager:PITCHTORQUEFACTOR TO PITCH_ERROR.
            //SET SteeringManager:YAWTORQUEFACTOR TO YAW_ERROR.
            LOCK STEERING TO DOWN_VECTOR_CORRECTED.
        }

        SET dist TO ALT:RADAR - (16.5).
        SET acc TO -SHIP:AVAILABLETHRUST / SHIP:MASS + gravAcc. //(SHIP:DRYMASS + 0.76*(WET_MASS-SHIP:DRYMASS)) + gravAcc.
        SET initalVel TO SQRT( abs(- 2 * acc * dist)).
        SET throt TO (-SHIP:VERTICALSPEED) - initalVel.

        //IF ((ALT:RADAR-4.6) <= BURN_ALTITUDE+10) AND (ABS(SHIP:VERTICALSPEED) > 1) AND (SHIP:STATUS = "FLYING") {
        //    LOCK THROTTLE TO ENG_THROTTLE.
        //} ELSE {
        //    LOCK THROTTLE TO 0.
        //}

        SET LOS:VEC TO LOS_VECTOR.
        SET REFLECT:VEC TO DOWN_VECTOR_REFLECTED*10.
        SET CORRECT:VEC TO DOWN_VECTOR_CORRECTED*10.

        PRINT "BURN H - " + dist.
        PRINT "ALT - " + ALT:RADAR.
        PRINT "Accel - " + acc.
        PRINT "THRT - " + throt.
        
        IF SHIP:STATUS = "LANDED" {
            PRINT "LANDED".
            SET ATMOSPHERIC_DESCENT TO FALSE.
        }
    }

    WAIT 0.
}