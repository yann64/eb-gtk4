' Headless(-ish) verification of Menu/Action/WindowContentBox - every
' check is a direct function call + printed result, not a synthetic
' mouse/keyboard event (matches this package's own established
' discipline: xdotool clicking a real menu proved exactly as unreliable
' here as everywhere else this session - one retry, then this).
'
' Run with `ebpm run` from this directory (needs a real GTK4 display
' backend - GtkApplicationWindow/GSimpleAction both require a real,
' connected display even though nothing is ever clicked).

#include "gtk4.iface.bas"

DIM activateCount AS INTEGER

SUB OnActionActivate(action AS GObj PTR, parameter AS ANY PTR, userData AS ANY PTR)
    activateCount = activateCount + 1
    PRINT "action activated, count: ", activateCount
END SUB

SUB OnActivate(rawApp AS GObj PTR, data AS ANY PTR)
    DIM app AS Application
    app = WrapApplication(rawApp)

    DIM win AS Window
    win = NewApplicationWindow(app)
    activateCount = 0

    ' 1. WindowContentBox: same handle on repeated calls, and correctly
    ' reused underneath WindowMenuBar/WindowToolBar/StatusBar (they're
    ' all built on top of it, so if it were wrong, everything below
    ' would already have failed).
    DIM box1 AS Box
    box1 = WindowContentBox(win)
    DIM box2 AS Box
    box2 = WindowContentBox(win)
    PRINT "WindowContentBox returns the same handle both times: ", (box1.handle = box2.handle)

    ' 2. Action creation, enable/disable, and - the real check - a
    ' programmatic activation genuinely reaching the connected handler.
    DIM act AS Action
    act = NewAction(win, "test_action")
    CALL ObjConnect(act, "activate", @OnActionActivate, 0)
    PRINT "before activate: ", activateCount
    CALL ActionActivate(act)
    PRINT "after activate: ", activateCount
    CALL ActionSetEnabled(act, 0)
    CALL ActionSetEnabled(act, 1)
    PRINT "enable/disable did not crash"

    ' 3. Menu/MenuBar construction and WindowMenuBar's own auto-create-
    ' once behavior.
    DIM bar1 AS MenuBar
    bar1 = WindowMenuBar(win)
    DIM bar2 AS MenuBar
    bar2 = WindowMenuBar(win)
    PRINT "WindowMenuBar returns the same handle both times: ", (bar1.handle = bar2.handle)

    DIM fileMenu AS Menu
    fileMenu = MenuBarAddMenu(bar1, "File")
    CALL MenuAddAction(fileMenu, act, "Test")
    PRINT "menu construction did not crash"

    ' 4. Second activation, now that the action is also referenced from
    ' a real menu item - confirms adding it to a menu doesn't disturb
    ' its own activate wiring.
    CALL ActionActivate(act)
    PRINT "after second activate: ", activateCount

    ' 5. ToolBar, sharing the same content box - and its own
    ' auto-create-once behavior.
    DIM tb1 AS ToolBar
    tb1 = WindowToolBar(win)
    DIM tb2 AS ToolBar
    tb2 = WindowToolBar(win)
    PRINT "WindowToolBar returns the same handle both times: ", (tb1.handle = tb2.handle)
    DIM btn AS Button
    btn = ToolBarAddButton(tb1, "Go")
    PRINT "toolbar construction did not crash"

    CALL ApplicationQuit(app)
END SUB

DIM app AS Application
app = NewApplication("io.github.yann64.ebgtk4.menuverify")
CALL ObjConnect(app, "activate", @OnActivate, 0)
CALL ApplicationRun(app)
PRINT "ApplicationRun returned"
CALL ObjDestroy(app)
