set parts to ship:parts.
set modulelist to parts[25]:getmodule("BDExplosivePart"):doevent("detonate").
for var in parts {
    print var.
}