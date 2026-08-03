' Idiomatic layer: GtkHeaderBar.

#include once "widget.bas"
#include once "label.bas"
#include once "raw/gtk_headerbar.bas"

''' A GtkHeaderBar - a modern window title bar, holding arbitrary
''' widgets (buttons, a title, ...) rather than just plain text.
TYPE HeaderBar EXTENDS Widget
END TYPE

''' Creates a new, empty GtkHeaderBar.
FUNCTION NewHeaderBar() AS HeaderBar
    DIM b AS HeaderBar
    b.handle = SinkHandle(gtk_header_bar_new())
    NewHeaderBar = b
END FUNCTION

''' Packs a widget at the bar's start (left, in LTR locales).
SUB HeaderBarPackStart(bar AS HeaderBar, child AS Widget)
    CALL gtk_header_bar_pack_start(bar.handle, child.handle)
END SUB

''' Packs a widget at the bar's end (right, in LTR locales).
SUB HeaderBarPackEnd(bar AS HeaderBar, child AS Widget)
    CALL gtk_header_bar_pack_end(bar.handle, child.handle)
END SUB

''' Shows/hides the window's own minimize/maximize/close buttons.
SUB HeaderBarSetShowTitleButtons(bar AS HeaderBar, show AS INTEGER)
    CALL gtk_header_bar_set_show_title_buttons(bar.handle, show)
END SUB

''' Sets the bar's title text - GTK4 itself has no plain-string title
''' setter (a title is any widget), so this creates a Label internally.
SUB HeaderBarSetTitle(bar AS HeaderBar, title AS ZSTRING)
    DIM lbl AS Label
    lbl = NewLabel(title)
    CALL gtk_header_bar_set_title_widget(bar.handle, lbl.handle)
END SUB

''' See WrapWidget's own doc comment.
FUNCTION WrapHeaderBar(h AS ANY PTR) AS HeaderBar
    DIM b AS HeaderBar
    b.handle = h
    WrapHeaderBar = b
END FUNCTION
