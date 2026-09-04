# Standalone build for eb-gtk4's small pieces of native code
# (shim_timer, shim_menu) - not ebpm/ebc-driven, matching eb-qt6/
# eb-haiku/eb-gui-gtk4's own native/CMakeLists.txt precedent. Produces
# libebgtk4shim.a.
#
# Build:
#   cmake -S native -B native/build
#   cmake --build native/build
#
# See this package's own README "Building" section for why each shim
# exists: shim_timer bridges real GLib's fire-and-forget `g_timeout_add`
# to a richer Start/Stop/SetSingleShot object model; shim_menu builds a
# "win.<name>" detailed-action string (real string concatenation, not
# expressible across the eBasic/C FFI boundary). Neither is a signal/
# callback bridge - eBasic itself has no way to call through an
# arbitrary stored function pointer, but that's not what either shim is
# for here.

cmake_minimum_required(VERSION 3.16)
project(ebgtk4shim CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0)

add_library(ebgtk4shim STATIC
    shim_timer.cpp
    shim_menu.cpp
)
target_include_directories(ebgtk4shim PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(ebgtk4shim PUBLIC PkgConfig::GLIB PkgConfig::GIO)
