clearscreen.
stage.
print "Launch!".
lock throttle to 1.
toggle RCS.
lock steering to target.
when target:distance<35 then { toggle GEAR. }

set t to 10.
until 0
{
	set rpos to (0-1)*(target:Position).
	set rvel to (ship:velocity:surface-target:velocity:orbit).
	if target:loaded {set rvel to ship:velocity:surface-target:velocity:surface.}.
	if altitude>35000 or target:altitude>35000 {set rvel to ship:velocity:orbit-target:velocity:orbit.}.
	set amag to ship:maxthrust/(ship:mass*9.81).
 
	//коэф.уравнения
	set a to 0-((amag)^2)/4.
	set b to (rvel:sqrmagnitude).
	set c to 2*(rvel*rpos).
	set d to (rpos:sqrmagnitude).
 
	//ньютон-рафсон:
	set timeguesses to list().
	set timeguesses:add to initialguess.
	set position to 0.
	until position>=iterations
	{
	set timeguesses:add to timeguesses[position]-(a*timeguesses[position]^4+b*timeguesses[position]^2+c*timeguesses[position]+d)/(4*a*timeguesses[position]^3+2*b*timeguesses[position]+c).
	set position to position+1.
	}.
	set initialguess to abs(timeguesses[iterations]).
 
	//рассчет упреждения
	set t to abs(timeguesses[iterations])/1.15.
	if altitude>35000 {set t to abs(timeguesses[iterations]).}.
	print t at (22,10).
	print target:distance at (20,12).
	set steeringvector to (v((0-2)*(rpos:x+(rvel:x)*t)/(t^2),(0-2)*(rpos:y+(rvel:y)*t)/(t^2),(0-2)*(rpos:z+(rvel:z)*t)/(t^2))+6*(up:vector)).
	set steeringangle to steeringvector:direction.
	print vectorangle(steeringvector,ship:facing:vector) at (16,14).
	wait 0.01.
}.