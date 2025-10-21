# Copyright (c) 2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

package ifneeded tresvg 0.1 [list apply {dir {
    source [file join $dir tresvg.tcl]
    source [file join $dir ffi.tcl]
    source [file join $dir crit.tcl]
    source [file join $dir png.tcl]
}} $dir]