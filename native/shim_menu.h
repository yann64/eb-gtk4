// eb-gtk4 native shim - one small helper, for the same reason
// shim_timer.h exists: something eBasic's own FFI can't express
// directly, not a signal/callback bridge.
//
// Real GTK4/GIO menus reference an action by a "detailed name" string
// like "win.open" (the "win"/"app" prefix identifies which action map
// the plain name "open" should be looked up in - GtkApplicationWindow
// and GApplication each automatically expose themselves as the "win"/
// "app" action-map prefix respectively, no manual wiring needed for
// those two). Building that prefixed string needs real string
// concatenation, which the eBasic/C FFI boundary has no way to express
// (STRING is a BString, not compatible; ZSTRING is a fixed value handed
// in, not something to build up piecemeal on this side) - so this
// package does it in C++ instead.
#pragma once

extern "C" {

// Appends a menu item labeled `label` to `menu`, referencing `action`
// (a GSimpleAction already registered on some window's own action map
// via g_action_map_add_action - see menu.bas's NewAction) as
// "win.<action's own name>". Only ever resolves correctly if `menu`
// ends up attached (directly or via a GtkPopoverMenuBar) inside the
// SAME window `action` was registered on - v1 scope is window-scoped
// actions only, no "app."-prefixed actions yet.
void eb_gtk4_menu_append_window_action(void* menu, const char* label, void* action);

}
