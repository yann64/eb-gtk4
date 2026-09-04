' Headless(-ish) verification of the four window-lifecycle primitives
' added alongside the universal eb-gui Application/Window API -
' programmatic round-trips and gtk_window_close()-driven signal firing,
' rather than relying on a real click (this package's own examples/
' window_lifecycle demonstrates the interactive shape; this program
' exists to actually PROVE each primitive works, independent of
' xdotool's own well-known unreliability). Still needs a real, connected
' GTK4 display (GtkApplication can't activate without one), but performs
' no synthetic mouse/keyboard input - every check is a direct function
' call + printed result.
'
' Run with `ebpm run` from this directory.

#include "gtk4.iface.bas"

FUNCTION OnCloseRequestVeto(win AS GObj PTR, data AS ANY PTR) AS INTEGER
    PRINT "close-request fired (veto-path)"
    OnCloseRequestVeto = 1
END FUNCTION

FUNCTION OnCloseRequestAllow2(win AS GObj PTR, data AS ANY PTR) AS INTEGER
    PRINT "close-request fired (allow-path)"
    OnCloseRequestAllow2 = 0
END FUNCTION

SUB OnActivate(rawApp AS GObj PTR, data AS ANY PTR)
    DIM app AS Application
    app = WrapApplication(rawApp)

    ' 1. WidgetSetEnabled/WidgetIsEnabled round trip.
    DIM btn AS Button
    btn = NewButton("test")
    PRINT "enabled by default: ", WidgetIsEnabled(btn)
    CALL WidgetSetEnabled(btn, 0)
    PRINT "enabled after SetEnabled(0): ", WidgetIsEnabled(btn)
    CALL WidgetSetEnabled(btn, 1)
    PRINT "enabled after SetEnabled(1): ", WidgetIsEnabled(btn)

    ' 2. WindowSetModal/WindowIsModal/WindowClearModal round trip.
    DIM parentWin AS Window
    parentWin = NewApplicationWindow(app)
    DIM childWin AS Window
    childWin = NewWindow()
    PRINT "modal by default: ", WindowIsModal(childWin)
    CALL WindowSetModal(childWin, parentWin)
    PRINT "modal after SetModal: ", WindowIsModal(childWin)
    CALL WindowClearModal(childWin)
    PRINT "modal after ClearModal: ", WindowIsModal(childWin)

    ' 3. close-request: veto keeps the window open (WindowPresent still
    ' works afterward, proving it wasn't destroyed), allow lets it
    ' proceed - both driven by WindowClose (the same signal path a real
    ' titlebar-X click uses), not a synthetic mouse event.
    DIM vetoWin AS Window
    vetoWin = NewWindow()
    CALL ObjConnect(vetoWin, "close-request", @OnCloseRequestVeto, 0)
    CALL WindowPresent(vetoWin)
    CALL WindowClose(vetoWin)
    CALL WindowPresent(vetoWin)
    PRINT "window still usable after a vetoed close-request"

    DIM allowWin AS Window
    allowWin = NewWindow()
    CALL ObjConnect(allowWin, "close-request", @OnCloseRequestAllow2, 0)
    CALL WindowPresent(allowWin)
    CALL WindowClose(allowWin)

    ' 4. ApplicationQuit: if this program prints the line below and
    ' exits promptly rather than hanging, ApplicationRun genuinely
    ' returned control - g_application_quit really works.
    PRINT "calling ApplicationQuit..."
    CALL ApplicationQuit(app)
END SUB

DIM app AS Application
app = NewApplication("io.github.yann64.ebgtk4.windowlifecycleverify")
CALL ObjConnect(app, "activate", @OnActivate, 0)
CALL ApplicationRun(app)
PRINT "ApplicationRun returned - quit worked"
CALL ObjDestroy(app)
