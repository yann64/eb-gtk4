' Smoke test: exercises the idiomatic wrapper layer's display-independent
' parts (Application, and ObjConnect's @ProcName wiring) - real widget
' construction (Button/Window/...) needs a working GTK4 display backend,
' same limitation as tests/raw_smoke.bas; see tests/manual/ for that.

#include once "../src/lib.bas"

SUB OnActivate(app AS ANY PTR, data AS ANY PTR)
    PRINT "activated"
END SUB

DIM app AS Application
app = NewApplication("io.github.yann64.ebgtk4.idiomaticsmoketest")
CALL ObjConnect(app, "activate", @OnActivate, 0)
CALL ObjDestroy(app)

PRINT "idiomatic smoke ok"
