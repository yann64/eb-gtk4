#include "shim_menu.h"

#include <gio/gio.h>

#include <string>

extern "C" {

void eb_gtk4_menu_append_window_action(void* menu, const char* label, void* action) {
    GAction* a = G_ACTION(action);
    std::string detailed = std::string("win.") + g_action_get_name(a);
    g_menu_append(G_MENU(menu), label, detailed.c_str());
}

}
