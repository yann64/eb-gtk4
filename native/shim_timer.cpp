#include "shim_timer.h"

#include <glib.h>

namespace {

struct GtkTimerData {
    guint intervalMs = 0;
    bool singleShot = false;
    EbGtk4TimerCallback callback = nullptr;
    void* userData = nullptr;
    guint sourceId = 0;
};

gboolean TimeoutTrampoline(gpointer p) {
    auto* data = static_cast<GtkTimerData*>(p);
    if (data->callback) data->callback(data->userData);
    if (data->singleShot) {
        data->sourceId = 0;
        return G_SOURCE_REMOVE;
    }
    return G_SOURCE_CONTINUE;
}

} // namespace

extern "C" {

void* eb_gtk4_timer_create() { return new GtkTimerData(); }

void eb_gtk4_timer_set_interval(void* timer, unsigned int milliseconds) {
    static_cast<GtkTimerData*>(timer)->intervalMs = milliseconds;
}

void eb_gtk4_timer_set_single_shot(void* timer, int singleShot) {
    static_cast<GtkTimerData*>(timer)->singleShot = (singleShot != 0);
}

void eb_gtk4_timer_connect_timeout(void* timer, EbGtk4TimerCallback cb, void* userData) {
    auto* data = static_cast<GtkTimerData*>(timer);
    data->callback = cb;
    data->userData = userData;
}

void eb_gtk4_timer_start(void* timer) {
    auto* data = static_cast<GtkTimerData*>(timer);
    if (data->sourceId != 0) g_source_remove(data->sourceId); // restart, matching QTimer::start()
    data->sourceId = g_timeout_add(data->intervalMs, TimeoutTrampoline, data);
}

void eb_gtk4_timer_stop(void* timer) {
    auto* data = static_cast<GtkTimerData*>(timer);
    if (data->sourceId != 0) {
        g_source_remove(data->sourceId);
        data->sourceId = 0;
    }
}

int eb_gtk4_timer_is_active(void* timer) { return static_cast<GtkTimerData*>(timer)->sourceId != 0 ? 1 : 0; }

void eb_gtk4_timer_destroy(void* timer) {
    eb_gtk4_timer_stop(timer);
    delete static_cast<GtkTimerData*>(timer);
}

}
