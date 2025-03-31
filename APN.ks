clearScreen.
//print("waiting for target").
//wait until hasTarget.
//lock throttle to 1.
//sas on.
//wait until ship:airspeed>70.
//sas off.
set Xvector to vecDraw(v(0,0,0), v(0,0,0), RGB(1,0,0), "X", 1, true, 0.2).
set Yvector to vecDraw(v(0,0,0), v(0,0,0), RGB(1,0,0), "Y", 1, true, 0.2).
set Zvector to vecDraw(v(0,0,0), v(0,0,0), RGB(1,0,0), "Z", 1, true, 0.2).
set GuidanceV to vecDraw(v(0,0,0), v(0,0,0), RGB(1,1,0), "G", 1, true, 0.2).

until false {
    //Proportional Navigation.
    Local NavConstant is 1.
    print("TargetPosMAG " + target:position:mag).
    print("Tx-Mx " + VDOT(NORTH:VECTOR,TARGET:POSITION)).

//    Local LOSX is VANG(FACING:VECTOR,NORTH:VECTOR*VDOT(NORTH:VECTOR,TARGET:POSITION)). // X - Latitude
//   Local LOSY is VANG(FACING:VECTOR,VCRS(NORTH:VECTOR,UP:VECTOR)*VDOT(VCRS(NORTH:VECTOR,UP:VECTOR),TARGET:POSITION)). // Y - Longitude
//    Local LOSZ is VANG(FACING:VECTOR,UP:VECTOR*VDOT(UP:VECTOR,TARGET:POSITION)). // Z - Altitude
    Local LOSX is arcCos(VDOT(NORTH:VECTOR,TARGET:POSITION)/target:distance).
    Local LOSZ is arcTan(Target:altitude - ship:altitude/VDOT(UP:VECTOR,TARGET:POSITION)).
    set Xvector:vec to North:vector*10.
    set Yvector:vec to VCRS(NORTH:VECTOR,UP:VECTOR)*10.
    set Zvector:vec to UP:VECTOR*10.

    Local GuidanceVector is up:vector * R(LOSZ,LOSX,0).
    set GuidanceV:vec to GuidanceVector * 100.
}