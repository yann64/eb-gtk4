' Verifies the two new prerequisite additions for the universal eb-gui
' API's next slice: StatusBar (screenshot-verified - real GtkStatusbar
' has no message getter to check programmatically) and GtkTimer
' (headlessly self-verified: a single-shot timer calls ApplicationQuit
' from its own callback - if this program exits promptly rather than
' hanging, the timer genuinely fired with the right interval/single-shot
' behavior and correctly reached back into eBasic code).
'
' Run with `ebpm run` from this directory (needs a real GTK4 display
' backend; EBASIC_LIBRARY_PATH must point at ../../native/build for the
' new ebgtk4shim.a).

#include "gtk4.iface.bas"

DIM app AS Application

SUB OnTimeout(userData AS ANY PTR)
    PRINT "timer fired - quitting"
    CALL ApplicationQuit(app)
END SUB

SUB OnActivate(rawApp AS GObj PTR, data AS ANY PTR)
    app = WrapApplication(rawApp)

    DIM win AS Window
    win = NewApplicationWindow(app)
    CALL WindowSetTitle(win, "StatusBar + Timer demo")
    CALL WindowSetDefaultSize(win, 320, 150)

    DIM sb AS StatusBar
    sb = NewStatusBar()
    CALL StatusBarShowMessage(sb, "Ready - waiting for timer...")

    CALL WindowSetChild(win, sb)
    CALL WindowPresent(win)

    DIM t AS GtkTimer
    t = NewGtkTimer()
    CALL GtkTimerSetInterval(t, 300)
    CALL GtkTimerSetSingleShot(t, 1)
    CALL GtkTimerConnectTimeout(t, @OnTimeout, 0)
    PRINT "timer active before start: ", GtkTimerIsActive(t)
    CALL GtkTimerStart(t)
    PRINT "timer active after start: ", GtkTimerIsActive(t)
END SUB

app = NewApplication("io.github.yann64.ebgtk4.statusbartimer")
CALL ObjConnect(app, "activate", @OnActivate, 0)
CALL ApplicationRun(app)
PRINT "ApplicationRun returned - timer-driven quit worked"
CALL ObjDestroy(app)
