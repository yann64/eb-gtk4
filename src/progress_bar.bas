' Idiomatic layer: GtkProgressBar. Real GTK4 has no integer min/max/
' value model at all, just a 0.0-1.0 fraction - this package exposes
' that real shape directly; eb-gui-gtk4's own adapter is what
' translates the universal contract's richer integer range model on
' top of it (tracking min/max/value itself, see eb-gui-gtk4's README).

#include once "widget.bas"
#include once "raw/gtk_progress_bar.bas"

TYPE ProgressBar EXTENDS Widget
END TYPE

FUNCTION NewProgressBar() AS ProgressBar
    DIM p AS ProgressBar
    p.handle = SinkHandle(gtk_progress_bar_new())
    NewProgressBar = p
END FUNCTION

''' `fraction` is clamped to 0.0-1.0 by real GTK4 itself.
SUB ProgressBarSetFraction(p AS ProgressBar, fraction AS DOUBLE)
    CALL gtk_progress_bar_set_fraction(p.handle, fraction)
END SUB

FUNCTION ProgressBarGetFraction(p AS ProgressBar) AS DOUBLE
    ProgressBarGetFraction = gtk_progress_bar_get_fraction(p.handle)
END FUNCTION
