' Raw FFI layer: GtkScale/GtkRange (`gtk-4`). GtkScale IS a GtkRange
' (single inheritance) - the value/range functions below are real
' GtkRange API, inherited by GtkScale, confirmed against this host's
' own gtkrange.h (not assumed).

#include once "gobject.bas"

Extern "C" Lib "gtk-4"
    Declare Function gtk_scale_new_with_range(ByVal orientation AS INTEGER, ByVal minVal AS DOUBLE, ByVal maxVal AS DOUBLE, ByVal stepSize AS DOUBLE) AS GObj PTR
    Declare Sub gtk_range_set_range(ByVal rangeWidget AS GObj PTR, ByVal minVal AS DOUBLE, ByVal maxVal AS DOUBLE)
    Declare Sub gtk_range_set_value(ByVal rangeWidget AS GObj PTR, ByVal value AS DOUBLE)
    Declare Function gtk_range_get_value(ByVal rangeWidget AS GObj PTR) AS DOUBLE
End Extern
