# Standalone build for eb-gtk4's one small piece of native code
# (shim_timer) - not ebpm/ebc-driven, matching eb-qt6/eb-haiku/
# eb-gui-gtk4's own native/CMakeLists.txt precedent. Produces
# libebgtk4shim.a.
#
# Build:
#   cmake -S native -B native/build
#   cmake --build native/build
#
# See this package's own README "Building" section for why: real GLib
# has no persistent, configurable timer object, only a fire-and-forget
# `g_timeout_add` primitive whose own callback decides repeat-vs-stop
# per firing - bridging that to eb-gui's (and this package's own)
# richer Start/Stop/SetSingleShot object model needs a real trampoline,
# since eBasic itself has no way to call through an arbitrary stored
# function pointer.

cmake_minimum_required(VERSION 3.16)
project(ebgtk4shim CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0)

add_library(ebgtk4shim STATIC
    shim_timer.cpp
)
target_include_directories(ebgtk4shim PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(ebgtk4shim PUBLIC PkgConfig::GLIB)
