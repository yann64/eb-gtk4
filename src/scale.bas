' Idiomatic layer: GtkScale (a real GtkRange subclass - see
' raw/gtk_scale.bas). Real GTK4's "value-changed" signal is inherited
' from GtkRange and reuses the same generic ObjConnect mechanism every
' other plain signal in this package already uses.

#include once "widget.bas"
#include once "raw/gtk_scale.bas"

TYPE Scale EXTENDS Widget
END TYPE

''' `orientation` matches GTK4's own GTK_ORIENTATION_HORIZONTAL(0)/
''' VERTICAL(1) values directly (see box.bas's own NewBox for the same
''' convention).
FUNCTION NewScale(orientation AS INTEGER, minVal AS DOUBLE, maxVal AS DOUBLE, stepSize AS DOUBLE) AS Scale
    DIM s AS Scale
    s.handle = SinkHandle(gtk_scale_new_with_range(orientation, minVal, maxVal, stepSize))
    NewScale = s
END FUNCTION

SUB ScaleSetRange(s AS Scale, minVal AS DOUBLE, maxVal AS DOUBLE)
    CALL gtk_range_set_range(s.handle, minVal, maxVal)
END SUB

SUB ScaleSetValue(s AS Scale, value AS DOUBLE)
    CALL gtk_range_set_value(s.handle, value)
END SUB

FUNCTION ScaleGetValue(s AS Scale) AS DOUBLE
    ScaleGetValue = gtk_range_get_value(s.handle)
END FUNCTION

''' See WrapWidget's own doc comment - e.g. for a "value-changed"
''' signal handler's own `s AS ANY PTR` parameter.
FUNCTION WrapScale(h AS ANY PTR) AS Scale
    DIM s AS Scale
    s.handle = h
    WrapScale = s
END FUNCTION
