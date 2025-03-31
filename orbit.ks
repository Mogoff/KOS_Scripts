@lazyglobal off.

clearscreen.
lock throttle to 0.5.
local MySteer is up.
lock steering to MySteer.

until SHIP:MAXTHRUST > 0 {
    stage.
}
print "Stage activated.". // только после фактического появления тяги

// пока апоцентр не станет выше 20к - держим направление вверх
until ship:APOAPSIS > 20000 {
    set MySteer to heading(90,90).
    wait 0.
}
// от 20к до 50к - держим тангаж 50 градусов
until ship:APOAPSIS > 50000 {
    set MySteer to heading(90,50).
    wait 0.
}
until ship:APOAPSIS > 60000 {
    set MySteer to heading(90,20).
    wait 0.
}
until ship:APOAPSIS > 75000 {
    set MySteer to heading(90,0).
    wait 0.
}
until ship:APOAPSIS > 80000 {
    set MySteer to heading(90,0).
    lock throttle to 0.
    wait until ETA:APOAPSIS = 0.5.
    lock throttle to 0.5.
    wait 0.
}

until ship:PERIAPSIS > 80000 {
    set MySteer to heading(90,0).
    wait 0.
}
lock throttle to 0.
set ship:control:pilotmainthrottle to 0.
unlock steering.
SAS on.