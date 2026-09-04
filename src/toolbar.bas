' Idiomatic layer: ToolBar. Real GTK4 removed GtkToolbar entirely - the
' modern replacement pattern upstream itself recommends is exactly
' this: a plain horizontal Box holding regular Buttons. No new raw/
' native bindings needed at all - this file is pure composition over
' box.bas/button.bas.

#include once "widget.bas"
#include once "window.bas"
#include once "box.bas"
#include once "button.bas"

TYPE ToolBar EXTENDS Widget
END TYPE

''' Returns the window's own tool bar (a plain horizontal Box under the
''' hood) - auto-created and installed near the top of the window's
''' shared content box the first time this is called for `win` (see
''' WindowContentBox's own doc comment, window.bas), just below the
''' menu bar if WindowMenuBar (menu.bas) was already requested for the
''' same window, or at the very top otherwise. Never constructed
''' directly.
'''
''' Convention (not enforced): request WindowMenuBar before
''' WindowToolBar if an application wants both, so this ordering
''' heuristic places them correctly - this package does not implement
''' general child reordering.
FUNCTION WindowToolBar(BYVAL win AS Window) AS ToolBar
    DIM existing AS ANY PTR
    existing = g_object_get_data(win.handle, "eb-gtk4-toolbar")
    IF existing <> 0 THEN
        DIM existingBar AS ToolBar
        existingBar.handle = existing
        WindowToolBar = existingBar
        EXIT FUNCTION
    END IF

    DIM bar AS ToolBar
    DIM barAsBox AS Box
    barAsBox = NewBox(GTK_ORIENTATION_HORIZONTAL, 6)
    bar.handle = barAsBox.handle

    DIM contentBox AS Box
    contentBox = WindowContentBox(win)
    DIM menuBarExists AS ANY PTR
    menuBarExists = g_object_get_data(win.handle, "eb-gtk4-menubar")
    IF menuBarExists <> 0 THEN
        CALL BoxAppend(contentBox, bar)
    ELSE
        CALL BoxPrepend(contentBox, bar)
    END IF

    CALL g_object_set_data(win.handle, "eb-gtk4-toolbar", bar.handle)
    WindowToolBar = bar
END FUNCTION

''' Creates a new Button labeled `text`, appends it to the tool bar, and
''' returns it - wire it up with the usual `ObjConnect(btn, "clicked",
''' @Handler, data)`, exactly like any other button (a tool bar button
''' has no special connection to the Action/menu system in this
''' package - unlike a menu item, a plain GtkButton never needed one to
''' begin with).
FUNCTION ToolBarAddButton(BYVAL bar AS ToolBar, text AS ZSTRING) AS Button
    DIM btn AS Button
    btn = NewButton(text)
    DIM barBox AS Box
    barBox.handle = bar.handle
    CALL BoxAppend(barBox, btn)
    ToolBarAddButton = btn
END FUNCTION
