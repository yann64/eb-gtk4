' Exercises the four window-lifecycle primitives added alongside the
' universal eb-gui Application/Window API: ApplicationQuit,
' WidgetSetEnabled/WidgetIsEnabled, WindowSetModal, and the
' "close-request" signal (already wireable via the existing generic
' ObjConnect - this is its first real example/test in this package).
'
' Run with `ebpm run` from this directory (needs a real GTK4 display
' backend).

#include "gtk4.iface.bas"

DIM otherBtn AS Button

SUB OnToggleClicked(btn AS GObj PTR, data AS ANY PTR)
    IF WidgetIsEnabled(otherBtn) THEN
        CALL WidgetSetEnabled(otherBtn, 0)
    ELSE
        CALL WidgetSetEnabled(otherBtn, 1)
    END IF
END SUB

SUB OnOtherClicked(btn AS GObj PTR, data AS ANY PTR)
    PRINT "other button clicked"
END SUB

SUB OnModalClicked(btn AS GObj PTR, data AS ANY PTR)
    DIM mainWin AS Window
    mainWin = WrapWindow(data)

    DIM modalWin AS Window
    modalWin = NewWindow()
    CALL WindowSetTitle(modalWin, "Modal child")
    CALL WindowSetDefaultSize(modalWin, 200, 100)
    CALL WindowSetModal(modalWin, mainWin)
    CALL WindowPresent(modalWin)
END SUB

SUB OnQuitClicked(btn AS GObj PTR, data AS ANY PTR)
    DIM app AS Application
    app = WrapApplication(data)
    CALL ApplicationQuit(app)
END SUB

' Real GTK4 "close-request" convention: return TRUE (1) to veto the
' close, FALSE (0) to allow the default handling to proceed - the
' opposite polarity from eb-haiku's own QuitRequested (nonzero =
' allow), a detail the eb-gui-gtk4 adapter will need to translate.
FUNCTION OnCloseRequest(win AS GObj PTR, data AS ANY PTR) AS INTEGER
    PRINT "close-request received - allowing close"
    OnCloseRequest = 0
END FUNCTION

SUB OnActivate(rawApp AS GObj PTR, data AS ANY PTR)
    DIM app AS Application
    app = WrapApplication(rawApp)

    DIM win AS Window
    win = NewApplicationWindow(app)
    CALL WindowSetTitle(win, "Window lifecycle demo")
    CALL WindowSetDefaultSize(win, 320, 200)
    CALL ObjConnect(win, "close-request", @OnCloseRequest, 0)

    DIM vbox AS Box
    vbox = NewBox(GTK_ORIENTATION_VERTICAL, 12)

    DIM toggleBtn AS Button
    toggleBtn = NewButton("Toggle other button")
    CALL ObjConnect(toggleBtn, "clicked", @OnToggleClicked, 0)

    otherBtn = NewButton("Other button")
    CALL ObjConnect(otherBtn, "clicked", @OnOtherClicked, 0)

    DIM modalBtn AS Button
    modalBtn = NewButton("Open modal window")
    CALL ObjConnect(modalBtn, "clicked", @OnModalClicked, win.handle)

    DIM quitBtn AS Button
    quitBtn = NewButton("Quit")
    CALL ObjConnect(quitBtn, "clicked", @OnQuitClicked, app.handle)

    CALL BoxAppend(vbox, toggleBtn)
    CALL BoxAppend(vbox, otherBtn)
    CALL BoxAppend(vbox, modalBtn)
    CALL BoxAppend(vbox, quitBtn)
    CALL WindowSetChild(win, vbox)
    CALL WindowPresent(win)
END SUB

DIM app AS Application
app = NewApplication("io.github.yann64.ebgtk4.windowlifecycle")
CALL ObjConnect(app, "activate", @OnActivate, 0)
CALL ApplicationRun(app)
CALL ObjDestroy(app)
