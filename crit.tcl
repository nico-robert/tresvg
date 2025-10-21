# Copyright (c) 2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

if {![catch {package require critcl}]} {

    if {[catch {package present Tk}]} {return}

    namespace eval tresvg {}

    # Tcl version
    set tcl_version [info tclversion]
    if {($tcl_version eq "8.6") &&
        ([package vcompare [package present critcl] "3.3"] < 0)
    } {
        critcl::tcl 8.6
    }

    if {([package vcompare $tcl_version "9.0"] >= 0) &&
        ([package vcompare [package present critcl] "3.3"] < 0)
    } {
        error "'critcl' version 3.3 or higher is required with Tcl9."
    }

    set platform [platform::generic]

    critcl::tk
    critcl::config I [list $::tresvg::packageDirectory/resvg/crates/c-api/]
    critcl::clibraries $platform/libresvg.a

    if {$platform eq "win32-x86_64"} {
        critcl::clibraries -lws2_32 -luserenv -ladvapi32 -lbcrypt -lntdll
    }

    critcl::ccode {
        #include <resvg.h>
        #include <string.h>
        #include <math.h>
    }

    critcl::cproc tresvg::toTkImg {Tcl_Interp* interp, Tcl_Obj* fileObj, Tcl_Obj* photoObj} ok {

        Tk_PhotoHandle source;
        Tk_PhotoImageBlock block;
        unsigned char *data = NULL;

        source = Tk_FindPhoto(interp, Tcl_GetString(photoObj));
        if (source == NULL) {
            Tcl_SetResult(interp, "photo not found.", TCL_STATIC);
            return TCL_ERROR;
        }
        // resvg_init_log;

        char *sp = Tcl_GetString(fileObj);
        resvg_options *opt = resvg_options_create();
        resvg_options_load_system_fonts(opt);
        resvg_render_tree *tree;
        int err = resvg_parse_tree_from_file(sp, opt, &tree);

        resvg_options_destroy(opt);

        if (err != RESVG_OK) {
            Tcl_SetObjResult(interp, Tcl_ObjPrintf("Error id: %i\n", err));
            return TCL_ERROR;
        }

        resvg_size size = resvg_get_image_size(tree);
        int width = (int)size.width;
        int height = (int)size.height;

        int len = width * height * 4;
        data = (unsigned char *)Tcl_Alloc(len);

        if (data == NULL) {
            Tcl_SetResult(interp, "cannot alloc image buffer.", TCL_STATIC);
            return TCL_ERROR;
        }

        memset(data, 0, len);

        resvg_transform tr = {1.0, 0.0, 0.0, 1.0, 0.0, 0.0};
        resvg_render(tree, tr, width, height, (char*)data);

        // Unpremultiply
        for (int i = 0; i < len; i += 4) {
            unsigned char alpha = data[i + 3];
            if (alpha != 0 && alpha != 255) {
                unsigned int multiplier = (unsigned int)round((255.0f / (float)alpha) * 255.0f);
                data[i + 0] = (unsigned char)(((unsigned int)data[i + 0] * multiplier + 127) / 255);
                data[i + 1] = (unsigned char)(((unsigned int)data[i + 1] * multiplier + 127) / 255);
                data[i + 2] = (unsigned char)(((unsigned int)data[i + 2] * multiplier + 127) / 255);
            }
        }

        block.pixelPtr   = data;
        block.width      = width;
        block.height     = height;
        block.pitch      = width * 4;
        block.pixelSize  = 4;
        block.offset[0]  = 0;
        block.offset[1]  = 1;
        block.offset[2]  = 2;
        block.offset[3]  = 3;

        if (Tk_PhotoSetSize(interp, source, width, height) != TCL_OK) {
            Tcl_Free(data);
            resvg_tree_destroy(tree);
            return TCL_ERROR;
        }

        if (Tk_PhotoPutBlock(interp, source, &block, 0, 0, width, height, TK_PHOTO_COMPOSITE_SET) != TCL_OK) {
            Tcl_Free(data);
            resvg_tree_destroy(tree);
            return TCL_ERROR;
        }

        resvg_tree_destroy(tree);
        Tcl_Free(data);

        return TCL_OK;
    }

}