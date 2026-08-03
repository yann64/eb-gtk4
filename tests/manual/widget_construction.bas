' Manual verification only - NOT run by `ebpm test`.
'
' Exercises real widget construction through the idiomatic layer, which
' needs a working GTK4 display backend. Confirmed (2026-07-29, GTK 4.22.4)
' that gtk_window_new() segfaults even from a minimal, hand-written C
' program in the sandbox this package was developed in - a real GTK4
' display-backend/environment limitation there, not a defect in this
' package's bindings. Run this by hand on a real desktop to verify.
'
' Local variable names deliberately avoid the TYPE names themselves
' (Box/Entry/Grid/...) - eBasic identifiers are case-insensitive and share
' one namespace between TYPEs and variables, so e.g. `DIM box AS Box`
' would collide with the TYPE `Box` itself.

#include once "../../src/lib.bas"

DIM win AS Window
win = NewWindow()
CALL WindowSetTitle(win, "smoke")
CALL WindowSetDefaultSize(win, 320, 240)

DIM vbox AS Box
vbox = NewBox(GTK_ORIENTATION_VERTICAL, 6)

DIM lbl AS Label
lbl = NewLabel("hello")
PRINT LabelGetText(lbl)

DIM btn AS Button
btn = NewButton("click me")
PRINT ButtonGetLabel(btn)

DIM txtEntry AS Entry
txtEntry = NewEntry()
CALL EntrySetText(txtEntry, "text")
PRINT EntryGetText(txtEntry)

DIM grd AS Grid
grd = NewGrid()
CALL GridAttach(grd, lbl, 0, 0, 1, 1)

DIM sourceTv AS TextView
sourceTv = NewTextView()
CALL TextViewSetMonospace(sourceTv, 1)
CALL TextViewSetWrapMode(sourceTv, GTK_WRAP_NONE)

DIM tvBuf AS TextBuffer
tvBuf = TextViewGetBuffer(sourceTv)
CALL TextBufferSetText(tvBuf, "PRINT ""hello""")
PRINT TextBufferGetText(tvBuf)

DIM scroller AS ScrolledWindow
scroller = NewScrolledWindow()
CALL ScrolledWindowSetChild(scroller, sourceTv)

CALL BoxAppend(vbox, lbl)
CALL BoxAppend(vbox, txtEntry)
CALL BoxAppend(vbox, btn)
CALL BoxAppend(vbox, scroller)
CALL WindowSetChild(win, vbox)

CALL WindowPresent(win)
CALL WindowDestroy(win)

PRINT "widget construction ok"
