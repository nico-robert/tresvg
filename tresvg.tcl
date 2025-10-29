# Copyright (c) 2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# tresvg - Tcl SVG rendering

# 21-Oct-2025 : v0.1 Initial release
# 25-Oct-2025 : v0.15 
              # Adds a better support for critcl backend.
              # Adds others commands for tcl-cffi backend.
              # Adds gitHub Actions workflow to build resvg binaries.
              # Cosmetic changes.
# 29-Oct-2025 : v0.17
              # Uses `critcl` if present to replace the `tresvg::encodePNG` command for tcl-cffi backend,   
              # by using `stbi_write_png_to_mem` function from `stb_image_write.h` header file if also exists.
              # Cosmetic changes.

package require Tcl 8.6-
package require platform

namespace eval tresvg {
    variable version          0.17
    variable packageDirectory [file dirname [file normalize [info script]]]
    variable platform         [::platform::generic]
    variable libDirectory     [file join $packageDirectory $platform]
}

package provide tresvg $::tresvg::version