' eb-gtk4's canonical hello-world: a window, a label, and a button whose
' "clicked" signal updates the label - demonstrates construction, layout,
' and a real signal handler (@ProcName) all together.
'
' Run with `ebpm run` from this directory (needs a real GTK4 display
' backend - see the package README for why this isn't part of `ebpm
' test`).

#include "gtk4.iface.bas"

DIM clickCount AS INTEGER
clickCount = 0

SUB OnButtonClicked(btn AS ANY PTR, data AS ANY PTR)
    DIM lbl AS Label
    lbl = WrapLabel(data)
    clickCount = clickCount + 1
    CALL LabelSetText(lbl, "Clicked!")
END SUB

SUB OnActivate(rawApp AS ANY PTR, data AS ANY PTR)
    DIM app AS Application
    app = WrapApplication(rawApp)

    DIM win AS Window
    win = NewApplicationWindow(app)
    CALL WindowSetTitle(win, "eb-gtk4 Hello")
    CALL WindowSetDefaultSize(win, 320, 200)

    DIM vbox AS Box
    vbox = NewBox(GTK_ORIENTATION_VERTICAL, 12)

    DIM lbl AS Label
    lbl = NewLabel("Hello, eb-gtk4!")

    DIM btn AS Button
    btn = NewButton("Click me")
    CALL ObjConnect(btn, "clicked", @OnButtonClicked, lbl.handle)

    CALL BoxAppend(vbox, lbl)
    CALL BoxAppend(vbox, btn)
    CALL WindowSetChild(win, vbox)
    CALL WindowPresent(win)
END SUB

DIM app AS Application
app = NewApplication("io.github.yann64.ebgtk4.hellowindow")
CALL ObjConnect(app, "activate", @OnActivate, 0)
CALL ApplicationRun(app)
CALL ObjDestroy(app)
