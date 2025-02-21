
clearScreen.
clearVecDraws().
PRINT "WAITING FOR TARGET".
WAIT UNTIL HASTARGET.
LOCAL OLD_TARGET_POS IS LIST(TARGET:GEOPOSITION:LAT,TARGET:GEOPOSITION:LNG,TARGET:ALTITUDE).

LOCAL BODY_PERIOD IS BODY("Kerbin"):ROTATIONPERIOD.
LOCAL NORMAL_SECTION_RADIUS IS ABS(SIN(OLD_TARGET_POS[1]) * (TARGET:ALTITUDE+BODY("Kerbin"):RADIUS)).
LOCAL FUCK_KOS IS ((2*CONSTANT:PI/BODY_PERIOD) * NORMAL_SECTION_RADIUS).
LOCAL LOS_VECTOR IS target:position - ship:position.
SET APOAP TO SHIP:APOAPSIS.
SET EPSILON TO 1.

SET TARGET_VEL TO -VCRS(NORTH:VECTOR,UP:VECTOR)*FUCK_KOS..
local VEL to vecDraw(v(0,0,0), v(0,0,0), RGB(1,0,0), "VEL", 1.2, true, 0.2).
local RELVEL to vecDraw(v(0,0,0), v(0,0,0), RGB(0,1,0), "RELVEL", 1.2, true, 0.2).
RCS ON.
SET THROTTLE_VAR TO 0.
SET STEERING_VECTOR TO VXCL(SHIP:UP:VECTOR,TARGET_VEL-SHIP:velocity:surface).
LOCK STEERING TO STEERING_VECTOR.
LOCK THROTTLE TO THROTTLE_VAR.
SET SUCCEED TO FALSE.

PRINT "WAITING FOR APOAPSIS".
WAIT UNTIL SHIP:verticalspeed<1.
SET LOS_VECTOR TO target:position - ship:position.
SET VELOCITY_AT_APOAPSIS TO VXCL(SHIP:UP:VECTOR,SHIP:velocity:ORBIT).
SET STEERING_VECTOR TO TARGET_VEL + (VXCL(SHIP:UP:VECTOR,LOS_VECTOR)*(1/(SQRT(2*APOAP/CONSTANT:g0))))-VELOCITY_AT_APOAPSIS.
SET MODE TO 1.
UNTIL SUCCEED = TRUE {
  clearScreen.
  SET VEL:VEC TO (VXCL(SHIP:UP:VECTOR,LOS_VECTOR):normalized*(1/(SQRT(2*APOAP/CONSTANT:g0)))).
  SET RELVEL:VEC TO VXCL(SHIP:UP:VECTOR,LOS_VECTOR).
  SET LOS_VECTOR TO target:position - ship:position.
  SET DESIRED_DELTAV TO (VELOCITY_AT_APOAPSIS + STEERING_VECTOR):MAG.
  IF MODE = 1 {
    IF VANG(SHIP:FACING:forevector,STEERING_VECTOR) < 10 {
      SET THROTTLE_VAR TO 0.75.
    }
    IF ABS(DESIRED_DELTAV-VXCL(SHIP:UP:VECTOR,SHIP:velocity:ORBIT):MAG) <= EPSILON  {
      SET THROTTLE_VAR TO 0.
      SET MODE TO 2.
    }
  }
  IF MODE = 2 {
    LOCK STEERING_VECTOR TO -SHIP:VELOCITY:SURFACE.
    IF (VXCL(SHIP:UP:VECTOR,LOS_VECTOR):MAG < SHIP:groundspeed*4) OR (THROTTLE_VAR = 1) OR (SHIP:altitude<30000) {
      SET THROTTLE_VAR TO 1.
      IF VANG(LOS_VECTOR,SHIP:VELOCITY:SURFACE) < 10 {
        SET THROTTLE_VAR TO 0.
        SET SUCCEED TO TRUE.
      }
    } 
  }
  if SUCCEED {
    runpath("0:/ama").
  }
  PRINT "DESIRED VEL - " + STEERING_VECTOR:MAG.
  PRINT "TARGET_VEL - " + TARGET_VEL:MAG.
  PRINT "PREDICTED VEL - " + VELOCITY_AT_APOAPSIS:MAG.
  PRINT "COMPONENT - " + VXCL(SHIP:UP:VECTOR,LOS_VECTOR):MAG.
  PRINT "DELTA VEL - " + (DESIRED_DELTAV-VXCL(SHIP:UP:VECTOR,SHIP:velocity:ORBIT):MAG).
  WAIT 0.
}

