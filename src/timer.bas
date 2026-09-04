' Idiomatic layer: GtkTimer, backed by this package's own small native
' shim (native/shim_timer.h) - not a GObject at all (unlike every other
' handle in this package), so it does NOT extend Obj/Widget and has its
' own dedicated GtkTimerDestroy rather than the usual ObjDestroy.
'
' Named GtkTimer, not Timer - eBasic's own stdlib already defines a
' top-level `Timer()` function (seconds elapsed, see the Date/Time
' Library reference) and identifiers are case-insensitive, so a bare
' `TYPE Timer` collides with it (the same reason eb-qt6's own timer.bas
' is named QTimer, not Timer).

#include once "raw/gtk_timer.bas"

TYPE GtkTimer
    handle AS ANY PTR
END TYPE

''' Creates a new, stopped timer.
FUNCTION NewGtkTimer() AS GtkTimer
    DIM t AS GtkTimer
    t.handle = eb_gtk4_timer_create()
    NewGtkTimer = t
END FUNCTION

SUB GtkTimerSetInterval(t AS GtkTimer, milliseconds AS INTEGER)
    CALL eb_gtk4_timer_set_interval(t.handle, milliseconds)
END SUB

''' If set, the timer fires once, then stops - matching real Qt's
''' QTimer::setSingleShot semantics (this package's own eb-gui
''' contract reuses the same shape).
SUB GtkTimerSetSingleShot(t AS GtkTimer, singleShot AS INTEGER)
    CALL eb_gtk4_timer_set_single_shot(t.handle, singleShot)
END SUB

''' Connects `handler` (a top-level `SUB YourName(userData AS ANY
''' PTR)`) to the timer's timeout - replaces any previously connected
''' handler (only one at a time, matching this package's other
''' single-callback-slot primitives).
SUB GtkTimerConnectTimeout(t AS GtkTimer, handler AS ANY PTR, userData AS ANY PTR)
    CALL eb_gtk4_timer_connect_timeout(t.handle, handler, userData)
END SUB

''' Starts (or restarts) the timer using its currently-set interval.
SUB GtkTimerStart(t AS GtkTimer)
    CALL eb_gtk4_timer_start(t.handle)
END SUB

SUB GtkTimerStop(t AS GtkTimer)
    CALL eb_gtk4_timer_stop(t.handle)
END SUB

FUNCTION GtkTimerIsActive(t AS GtkTimer) AS INTEGER
    GtkTimerIsActive = eb_gtk4_timer_is_active(t.handle)
END FUNCTION

''' Stops (if running) and frees the timer - call exactly once when
''' done with it (this package's own plain heap allocation, not a
''' GObject, so ObjDestroy doesn't apply).
SUB GtkTimerDestroy(t AS GtkTimer)
    CALL eb_gtk4_timer_destroy(t.handle)
END SUB
