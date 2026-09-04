' Raw FFI layer: GMenu/GSimpleAction/GActionMap (`gio-2.0`) and
' GtkPopoverMenuBar (`gtk-4`) - real GTK4's own modern, declarative-
' model-based menu architecture (GtkMenuBar/GtkMenuItem were removed
' upstream entirely) - plus this package's own tiny native helper for
' building a "win.<name>" detailed-action string.

#include once "gobject.bas"

Extern "C" Lib "gio-2.0"
    Declare Function g_menu_new() AS GObj PTR
    Declare Sub g_menu_append_submenu(ByVal menu AS GObj PTR, ByVal label AS ZSTRING, ByVal submenu AS GObj PTR)
    ' `parameter_type` is a `const GVariantType*` - always 0 here (a
    ' plain, stateless, parameterless action; v1 scope doesn't expose
    ' GTK4's own richer stateful/parameterized action support).
    Declare Function g_simple_action_new(ByVal name AS ZSTRING, ByVal parameter_type AS ANY PTR) AS GObj PTR
    Declare Sub g_simple_action_set_enabled(ByVal action AS GObj PTR, ByVal enabled AS INTEGER)
    ' `action_map` is a GtkApplicationWindow (real GTK4: implements
    ' GActionMap directly, registering under the "win." prefix
    ' automatically) - v1 scope doesn't expose app-scoped ("app.")
    ' actions.
    Declare Sub g_action_map_add_action(ByVal action_map AS GObj PTR, ByVal action AS GObj PTR)
    ' Activates an action directly (the same path a real menu-item click
    ' goes through) - `parameter` is 0 for the plain, stateless actions
    ' this package creates. Lets ActionConnectTriggered's own "activate"
    ' handler be exercised/tested programmatically, the same role
    ' WindowClose plays for "close-request".
    Declare Sub g_action_activate(ByVal action AS GObj PTR, ByVal parameter AS ANY PTR)
End Extern

Extern "C" Lib "gtk-4"
    Declare Function gtk_popover_menu_bar_new_from_model(ByVal model AS GObj PTR) AS GObj PTR
End Extern

Extern "C" Lib "ebgtk4shim"
    Declare Sub eb_gtk4_menu_append_window_action(ByVal menu AS ANY PTR, ByVal label AS ZSTRING, ByVal action AS ANY PTR)
End Extern
