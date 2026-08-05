' Idiomatic layer: the GObject/GtkWidget base types every wrapped class
' extends.
'
' A TYPE's own METHODS aren't exported across an ebpm --lib package
' boundary (only top-level SUB/FUNCTION and plain-data/opaque TYPE/UNION
' are - see ebc's own docs/guide/ebc.md) - so this package's public API is
' free functions taking/returning these plain-data handle-wrapper TYPEs,
' not method-call syntax. EXTENDS is still used for the TYPEs themselves
' (Window/Box/Button/... EXTENDS Widget EXTENDS Obj), since a value of a
' derived TYPE is still implicitly usable wherever the base is expected
' (e.g. passing a Button to BoxAppend's Widget parameter) even without
' method dispatch.

#include once "raw/gobject.bas"
#include once "raw/gtk_widget.bas"

''' The base for every wrapped GObject-derived instance (Widgets,
''' GtkApplication, ...).
TYPE Obj
    handle AS GObj PTR
END TYPE

''' The base for every wrapped GtkWidget - Widget-specific operations
''' (Show, Connect's own signal namespace, ...) live at this level, not
''' GtkApplication's (a GObject/GApplication, never a GtkWidget).
TYPE Widget EXTENDS Obj
END TYPE

''' Sinks a just-created GObject's floating reference (see
''' GInitiallyUnowned) and returns it unchanged - every wrapper
''' constructor in this package calls this exactly once, right after
''' creating the real widget, so this package's own handle always holds a
''' real, counted reference from the moment a caller gets it back. Call
''' ObjDestroy exactly once when done with it (matches ordinary manual
''' GObject reference-counting discipline - this package has no
''' automatic RAII destructor tied to it, since a plain TYPE assignment
''' is a memberwise copy of the handle, not a new reference).
FUNCTION SinkHandle(h AS ANY PTR) AS ANY PTR
    CALL g_object_ref_sink(h)
    SinkHandle = h
END FUNCTION

''' Drops this package's own reference (see SinkHandle) - call exactly
''' once per wrapped value you own, when you're done with it. Safe to
''' call after a widget has also been added to a container (the
''' container holds its own separate reference).
SUB ObjDestroy(o AS Obj)
    CALL g_object_unref(o.handle)
END SUB

''' Connects a signal handler - `handler` is `@YourSubName` (see the
''' language's own `@ProcName` docs for the C-ABI-compatibility rules
''' this implies: no STRING parameters/return). `data` is delivered back
''' to the handler as its own trailing parameter (eBasic has no
''' closures, so this is the only way a handler gets extra context) -
''' pass 0 if unneeded.
SUB ObjConnect(o AS Obj, signal AS ZSTRING, handler AS ANY PTR, data AS ANY PTR)
    CALL g_signal_connect_data(o.handle, signal, handler, data, 0, 0)
END SUB

''' Shows a widget (see also WidgetSetVisible for a toggle-able form).
SUB WidgetShow(w AS Widget)
    CALL gtk_widget_show(w.handle)
END SUB

''' Sets a widget's visibility.
SUB WidgetSetVisible(w AS Widget, visible AS INTEGER)
    CALL gtk_widget_set_visible(w.handle, visible)
END SUB

''' Requests a minimum size for a widget.
SUB WidgetSetSizeRequest(w AS Widget, width AS INTEGER, height AS INTEGER)
    CALL gtk_widget_set_size_request(w.handle, width, height)
END SUB

''' Sets (or clears, with "") a plain-text tooltip shown on hover -
''' the natural fit for e.g. an LSP client rendering hover text.
SUB WidgetSetTooltipText(w AS Widget, text AS ZSTRING)
    CALL gtk_widget_set_tooltip_text(w.handle, text)
END SUB

''' Moves real keyboard focus to `w` - a no-op (best-effort, matching
''' WidgetShow/WidgetSetVisible's own fire-and-forget shape) if `w`
''' can't currently accept it (not focusable, not visible/mapped yet).
SUB WidgetGrabFocus(w AS Widget)
    CALL gtk_widget_grab_focus(w.handle)
END SUB

''' Wraps an existing, already-owned raw handle (e.g. the instance/data
''' pointer a signal handler receives) into a value of this package's
''' own Widget TYPE - does NOT take a new reference (unlike a New*
''' constructor's SinkHandle), since the caller doesn't own a new one
''' here, it's just naming a handle it already has some other way.
FUNCTION WrapWidget(h AS ANY PTR) AS Widget
    DIM w AS Widget
    w.handle = h
    WrapWidget = w
END FUNCTION
