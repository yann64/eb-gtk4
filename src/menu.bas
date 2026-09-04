' Idiomatic layer: GMenu/GSimpleAction/GtkPopoverMenuBar - real GTK4's
' own modern, declarative-model-based menu architecture. Real GTK4
' removed GtkMenuBar/GtkMenuItem entirely; there is no direct
' equivalent to (for example) eb-qt6's QMenuBar/QMenu/QAction shape,
' though this layer mirrors it as closely as GTK4's own real
' architecture allows:
'   - Menu wraps a plain GMenu (a GMenuModel/GObject, NOT a GtkWidget -
'     unlike a real QMenu, a GTK4 submenu is never independently
'     visible; it only ever appears nested inside a MenuBar's own
'     popover).
'   - Action wraps a GSimpleAction, registered on a WINDOW's own action
'     map (v1 scope: window-scoped actions only, referenced internally
'     as "win.<name>" - see native/shim_menu.h). A menu item never
'     carries a callback directly - it references an action by name,
'     and the action's own real "activate" signal (wired via the
'     already-generic ObjConnect - no new native code needed for this
'     part, since GSimpleAction is an ordinary GObject and "activate"
'     is an ordinary signal) is what actually fires. Real signal shape:
'     `SUB YourName(action AS GObj PTR, parameter AS ANY PTR, userData
'     AS ANY PTR)` - `parameter` is always 0 for the plain, stateless
'     actions this package creates.
'   - MenuBar wraps the real GtkPopoverMenuBar widget, auto-created and
'     installed at the top of the window's own shared content box (see
'     WindowContentBox, window.bas) the first time WindowMenuBar is
'     called for a given window - never constructed directly.

#include once "widget.bas"
#include once "window.bas"
#include once "raw/gtk_menu.bas"

TYPE Menu EXTENDS Obj
END TYPE

TYPE MenuBar EXTENDS Widget
END TYPE

TYPE Action EXTENDS Obj
END TYPE

''' Registers a new, window-scoped action - `name` should be a plain
''' identifier ("open", "save_as"), not already prefixed; referenced in
''' menus (MenuAddAction) as "win.<name>" internally.
FUNCTION NewAction(BYVAL win AS Window, name AS ZSTRING) AS Action
    DIM a AS Action
    a.handle = g_simple_action_new(name, 0)
    CALL g_action_map_add_action(win.handle, a.handle)
    NewAction = a
END FUNCTION

SUB ActionSetEnabled(BYVAL a AS Action, enabled AS INTEGER)
    CALL g_simple_action_set_enabled(a.handle, enabled)
END SUB

''' Activates `a` directly, the same path a real menu-item click goes
''' through - lets a connected "activate" handler (ObjConnect) be
''' exercised/tested programmatically, without needing a real click.
SUB ActionActivate(BYVAL a AS Action)
    CALL g_action_activate(a.handle, 0)
END SUB

''' A fresh, standalone menu model - not independently visible (see
''' this file's own top comment) until appended into a MenuBar (via
''' MenuBarAddMenu) or another Menu (via MenuAddSubmenu).
FUNCTION NewMenu() AS Menu
    DIM m AS Menu
    m.handle = g_menu_new()
    NewMenu = m
END FUNCTION

''' Appends a menu item labeled `text`, referencing `action` - `action`
''' must have been created (NewAction) on the SAME window this menu
''' ends up attached to, or its "win.<name>" reference won't resolve.
SUB MenuAddAction(BYVAL m AS Menu, BYVAL action AS Action, text AS ZSTRING)
    CALL eb_gtk4_menu_append_window_action(m.handle, text, action.handle)
END SUB

''' Nests `submenu` inside `m` as a labeled sub-item (e.g. "File" > "Recent Files").
SUB MenuAddSubmenu(BYVAL m AS Menu, BYVAL submenu AS Menu, text AS ZSTRING)
    CALL g_menu_append_submenu(m.handle, text, submenu.handle)
END SUB

''' Returns the window's own menu bar - auto-created (an empty
''' GtkPopoverMenuBar backed by a fresh GMenu) and installed at the top
''' of the window's shared content box the first time this is called
''' for `win` (see WindowContentBox's own doc comment, window.bas) -
''' never constructed directly, matching the eb-qt6 sibling package's
''' own MainWindowMenuBar auto-created-per-window convention.
FUNCTION WindowMenuBar(BYVAL win AS Window) AS MenuBar
    DIM existing AS ANY PTR
    existing = g_object_get_data(win.handle, "eb-gtk4-menubar")
    IF existing <> 0 THEN
        DIM existingBar AS MenuBar
        existingBar.handle = existing
        WindowMenuBar = existingBar
        EXIT FUNCTION
    END IF

    DIM model AS Menu
    model = NewMenu()
    DIM bar AS MenuBar
    bar.handle = SinkHandle(gtk_popover_menu_bar_new_from_model(model.handle))

    DIM contentBox AS Box
    contentBox = WindowContentBox(win)
    CALL BoxPrepend(contentBox, bar)

    CALL g_object_set_data(win.handle, "eb-gtk4-menubar", bar.handle)
    CALL g_object_set_data(bar.handle, "eb-gtk4-menubar-model", model.handle)
    WindowMenuBar = bar
END FUNCTION

''' Appends a new top-level menu (e.g. "File") to the menu bar.
FUNCTION MenuBarAddMenu(BYVAL bar AS MenuBar, title AS ZSTRING) AS Menu
    DIM model AS Menu
    model.handle = g_object_get_data(bar.handle, "eb-gtk4-menubar-model")
    DIM submenu AS Menu
    submenu = NewMenu()
    CALL g_menu_append_submenu(model.handle, title, submenu.handle)
    MenuBarAddMenu = submenu
END FUNCTION
