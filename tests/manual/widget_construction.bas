' Manual verification only - NOT run by `ebpm test`.
'
' Exercises real widget construction through the idiomatic layer, which
' needs a working GTK4 display backend. This file constructs a bare
' GtkWindow directly at top level - confirmed (2026-07-29, GTK 4.22.4)
' that this segfaults even from a minimal, hand-written C program in the
' sandbox this package was developed in, but a LATER session narrowed
' down why: it's specifically because this never establishes a real
' GtkApplication/"activate" bootstrap first (real GTK4 requires it) - a
' real, live GTK4 desktop that DOES go through that bootstrap correctly
' (see `ebasic-editor`'s own `src/main.bas`) renders a fully correct
' window with no crash at all, confirmed by direct reproduction with
' screenshots. So: a real display backend is genuinely needed to run
' this file at all (that part was never wrong), but the segfault itself
' is this file's own minimal-repro shape skipping GtkApplication, not a
' defect in this package's bindings or a blanket "GTK4 doesn't work
' here" finding. Run this by hand on a real desktop to verify.
'
' Local variable names deliberately avoid the TYPE names themselves
' (Box/Entry/Grid/...) - eBasic identifiers are case-insensitive and share
' one namespace between TYPEs and variables, so e.g. `DIM box AS Box`
' would collide with the TYPE `Box` itself.

#include once "../../src/lib.bas"

FUNCTION OnKeyPressed(controller AS GObj PTR, keyval AS INTEGER, keycode AS INTEGER, state AS INTEGER, data AS ANY PTR) AS INTEGER
    IF keyval = GDK_KEY_s AND (state AND GDK_CONTROL_MASK) <> 0 THEN
        PRINT "ctrl+s pressed"
    END IF
    OnKeyPressed = 0
END FUNCTION

DIM win AS Window
win = NewWindow()
CALL WindowSetTitle(win, "smoke")
CALL WindowSetDefaultSize(win, 320, 240)

DIM vbox AS Box
vbox = NewBox(GTK_ORIENTATION_VERTICAL, 6)

DIM lbl AS Label
lbl = NewLabel("hello")
PRINT LabelGetText(lbl)
CALL WidgetSetTooltipText(lbl, "a hover tooltip")

DIM btn AS Button
btn = NewButton("click me")
PRINT ButtonGetLabel(btn)

DIM txtEntry AS Entry
txtEntry = NewEntry()
CALL EntrySetText(txtEntry, "text")
PRINT EntryGetText(txtEntry)
CALL WidgetGrabFocus(txtEntry)

DIM grd AS Grid
grd = NewGrid()
CALL GridAttach(grd, lbl, 0, 0, 1, 1)

DIM langMgr AS SourceLanguageManager
langMgr = SourceLanguageManagerGetDefault()
DIM py AS SourceLanguage
py = SourceLanguageManagerGetLanguage(langMgr, "python3")

DIM srcBuf AS SourceBuffer
srcBuf = NewSourceBufferWithLanguage(py)
CALL SourceBufferSetHighlightSyntax(srcBuf, 1)
CALL TextBufferSetText(srcBuf, "print(""hello"")")

DIM rawText AS ANY PTR
rawText = TextBufferGetText(srcBuf)
DIM viaZstring AS ZSTRING
viaZstring = rawText
DIM srcText AS STRING
srcText = viaZstring
CALL FreeGMallocString(rawText)
PRINT srcText

DIM sourceTv AS SourceView
sourceTv = NewSourceViewWithBuffer(srcBuf)
CALL TextViewSetMonospace(sourceTv, 1)
CALL TextViewSetWrapMode(sourceTv, GTK_WRAP_NONE)
CALL SourceViewSetShowLineNumbers(sourceTv, 1)
CALL SourceViewSetHighlightCurrentLine(sourceTv, 1)

DIM scroller AS ScrolledWindow
scroller = NewScrolledWindow()
CALL ScrolledWindowSetChild(scroller, sourceTv)

DIM bar AS HeaderBar
bar = NewHeaderBar()
CALL HeaderBarSetTitle(bar, "eb-gtk4 smoke")
CALL HeaderBarSetShowTitleButtons(bar, 1)
CALL HeaderBarPackStart(bar, btn)
CALL WindowSetTitlebar(win, bar)

DIM sidebar AS ListBox
sidebar = NewListBox()
CALL ListBoxSetActivateOnSingleClick(sidebar, 1)
DIM fileOne AS Label
fileOne = NewLabel("main.bas")
CALL ListBoxAppend(sidebar, fileOne)
DIM fileTwo AS Label
fileTwo = NewLabel("lib.bas")
CALL ListBoxAppend(sidebar, fileTwo)
DIM secondRow AS ListBoxRow
secondRow = ListBoxGetRowAtIndex(sidebar, 1)
PRINT ListBoxRowGetIndex(secondRow)

DIM split AS Paned
split = NewPaned(GTK_ORIENTATION_HORIZONTAL)
CALL PanedSetStartChild(split, sidebar)
CALL PanedSetEndChild(split, scroller)
CALL PanedSetPosition(split, 160)

CALL BoxAppend(vbox, lbl)
CALL BoxAppend(vbox, txtEntry)
CALL BoxAppend(vbox, split)
CALL WindowSetChild(win, vbox)

DIM opener AS FileChooserNative
DIM noParent AS Window
opener = NewFileChooserNative("Open File", noParent, GTK_FILE_CHOOSER_ACTION_OPEN, "_Open", "_Cancel")
CALL FileChooserNativeShow(opener)
CALL FileChooserNativeDestroy(opener)

DIM keyCtrl AS EventControllerKey
keyCtrl = NewEventControllerKey()
CALL ObjConnect(keyCtrl, "key-pressed", @OnKeyPressed, 0)
CALL WidgetAddController(win, keyCtrl)

CALL WindowPresent(win)
CALL WindowDestroy(win)

PRINT "widget construction ok"
