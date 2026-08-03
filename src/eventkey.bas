' Idiomatic layer: GtkEventControllerKey.

#include once "widget.bas"
#include once "raw/gtk_eventkey.bas"

''' A key-press listener, attached to a widget via WidgetAddController.
TYPE EventControllerKey EXTENDS Obj
END TYPE

''' Creates a new key-press listener - not attached to anything yet, see
''' WidgetAddController.
FUNCTION NewEventControllerKey() AS EventControllerKey
    DIM c AS EventControllerKey
    c.handle = SinkHandle(gtk_event_controller_key_new())
    NewEventControllerKey = c
END FUNCTION

''' Attaches any event controller (e.g. an EventControllerKey) to a
''' widget - connect the controller's own signal(s) (via ObjConnect)
''' *before* attaching it, matching GTK's own recommended order.
''' `controller` is `Obj`, not a specific controller TYPE, since this
''' works identically for any of them.
SUB WidgetAddController(w AS Widget, controller AS Obj)
    CALL gtk_widget_add_controller(w.handle, controller.handle)
END SUB

''' See WrapWidget's own doc comment.
FUNCTION WrapEventControllerKey(h AS ANY PTR) AS EventControllerKey
    DIM c AS EventControllerKey
    c.handle = h
    WrapEventControllerKey = c
END FUNCTION
