' Exercises Menu/Toolbar/StatusBar coexisting in one window via the new
' WindowContentBox mechanism (window.bas) - the real problem this
' solves: a plain GTK4 window has exactly one direct child, unlike
' Qt's QMainWindow (independent menu bar/tool bar/central widget/status
' bar slots), so MenuBar/ToolBar/main content/StatusBar all need to
' share ONE box, stacked in the right order regardless of request order
' (menu bar and tool bar requested first here, per the documented
' convention).
'
' Run with `ebpm run` from this directory (needs a real GTK4 display
' backend).

#include "gtk4.iface.bas"

DIM statusLabel AS StatusBar

SUB OnOpenAction(action AS GObj PTR, parameter AS ANY PTR, userData AS ANY PTR)
    CALL StatusBarShowMessage(statusLabel, "Open action triggered")
END SUB

SUB OnQuitAction(action AS GObj PTR, parameter AS ANY PTR, userData AS ANY PTR)
    PRINT "quit action triggered"
END SUB

SUB OnToolbarButtonClicked(btn AS GObj PTR, data AS ANY PTR)
    CALL StatusBarShowMessage(statusLabel, "Toolbar button clicked")
END SUB

SUB OnActivate(rawApp AS GObj PTR, data AS ANY PTR)
    DIM app AS Application
    app = WrapApplication(rawApp)

    DIM win AS Window
    win = NewApplicationWindow(app)
    CALL WindowSetTitle(win, "Menu + Toolbar + StatusBar demo")
    CALL WindowSetDefaultSize(win, 400, 250)

    ' 1. Menu bar first - a "File" menu with two actions.
    DIM bar AS MenuBar
    bar = WindowMenuBar(win)
    DIM fileMenu AS Menu
    fileMenu = MenuBarAddMenu(bar, "File")

    DIM openAction AS Action
    openAction = NewAction(win, "open")
    CALL ObjConnect(openAction, "activate", @OnOpenAction, 0)
    CALL MenuAddAction(fileMenu, openAction, "Open")

    DIM quitAction AS Action
    quitAction = NewAction(win, "quit")
    CALL ObjConnect(quitAction, "activate", @OnQuitAction, 0)
    CALL MenuAddAction(fileMenu, quitAction, "Quit")

    ' 2. Toolbar second - lands just below the menu bar.
    DIM winToolbar AS ToolBar
    winToolbar = WindowToolBar(win)
    DIM toolBtn AS Button
    toolBtn = ToolBarAddButton(winToolbar, "Action")
    CALL ObjConnect(toolBtn, "clicked", @OnToolbarButtonClicked, 0)

    ' 3. Main content - appended into the same shared content box.
    DIM contentBox AS Box
    contentBox = WindowContentBox(win)
    DIM lbl AS Label
    lbl = NewLabel("Main content area")
    CALL BoxAppend(contentBox, lbl)

    ' 4. Status bar last - always lands at the current end.
    statusLabel = NewStatusBar()
    CALL BoxAppend(contentBox, statusLabel)
    CALL StatusBarShowMessage(statusLabel, "Ready")

    CALL WindowPresent(win)
END SUB

DIM app AS Application
app = NewApplication("io.github.yann64.ebgtk4.menutoolbar")
CALL ObjConnect(app, "activate", @OnActivate, 0)
CALL ApplicationRun(app)
CALL ObjDestroy(app)
