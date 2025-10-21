# Copyright (c) 2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# tresvg - Tcl SVG rendering

# 21-Oct-2025 : v0.1 Initial release

package require Tcl 8.6-
package require platform

namespace eval tresvg {
    variable version 0.1
    variable packageDirectory [file dirname [file normalize [info script]]]
}

package provide tresvg $::tresvg::version