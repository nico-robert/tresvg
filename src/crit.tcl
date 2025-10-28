# Copyright (c) 2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tresvg {}

if {![catch {package require critcl}] && ![catch {package present Tk}]} {

    # Tcl version
    if {[package vsatisfies [package provide Tcl] 8.6] &&
        ([package vcompare [package provide critcl] "3.3"] < 0)
    } {
        critcl::tcl 8.6
    }

    if {([package vsatisfies [package provide Tcl] 9.0-]) &&
        ([package vcompare [package provide critcl] "3.3"] < 0)
    } {
        error "'critcl' version 3.3 or higher is required with Tcl9."
    }

    if {[package vsatisfies [package provide Tcl] 9.0-]} {
        critcl::tcl 9
    }

    critcl::tk
    critcl::config I [list [file join $::tresvg::libDirectory include]]
    critcl::clibraries [file join $::tresvg::libDirectory libresvg.a]

    if {$::tresvg::platform eq "win32-x86_64"} {
        critcl::clibraries -lws2_32 -luserenv -ladvapi32 -lbcrypt -lntdll
    }

    if {![critcl::compiling]} {
        error "tresvg(error): Unable to build project, no proper compiler found."
    }

    critcl::ccode {
        #include <resvg.h>
        #include <string.h>
        #include <math.h>

        #if TCL_MAJOR_VERSION == 8
            #ifndef TCL_SIZE_MAX
                typedef int Tcl_Size;
                # define Tcl_GetSizeIntFromObj Tcl_GetIntFromObj
                # define Tcl_NewSizeIntObj Tcl_NewIntObj
                # define TCL_SIZE_MAX      INT_MAX
                # define TCL_SIZE_MODIFIER ""
            #endif
        #endif

        const char* resvg_error_to_string(resvg_error err) {
            switch(err) {
                case RESVG_OK:
                    return "RESVG_OK";
                case RESVG_ERROR_NOT_AN_UTF8_STR:
                    return "Only UTF-8 content are supported.";
                case RESVG_ERROR_FILE_OPEN_FAILED:
                    return "Failed to open the provided file.";
                case RESVG_ERROR_MALFORMED_GZIP:
                    return "Compressed SVG must use the GZip algorithm.";
                case RESVG_ERROR_ELEMENTS_LIMIT_REACHED:
                    return "We do not allow SVG with more than 1_000_000 elements for security reasons.";
                case RESVG_ERROR_INVALID_SIZE:
                    return "SVG doesn't have a valid size.";
                case RESVG_ERROR_PARSING_FAILED:
                    return "Failed to parse an SVG data.";
                default: return "RESVG_ERROR_UNKNOWN";
            }
        }

        resvg_shape_rendering shapeRenderingMode(int mode) {
            switch(mode) {
                case 0: return RESVG_SHAPE_RENDERING_OPTIMIZE_SPEED;
                case 1: return RESVG_SHAPE_RENDERING_CRISP_EDGES;
                case 2: return RESVG_SHAPE_RENDERING_GEOMETRIC_PRECISION;
                default: return RESVG_SHAPE_RENDERING_GEOMETRIC_PRECISION;
            }
        }

        resvg_text_rendering textRenderingMode(int mode) {
            switch(mode) {
                case 0: return RESVG_TEXT_RENDERING_OPTIMIZE_SPEED;
                case 1: return RESVG_TEXT_RENDERING_OPTIMIZE_LEGIBILITY;
                case 2: return RESVG_TEXT_RENDERING_GEOMETRIC_PRECISION;
                default: return RESVG_TEXT_RENDERING_OPTIMIZE_LEGIBILITY;
            }
        }

        resvg_image_rendering imageRenderingMode(int mode) {
            switch(mode) {
                case 0: return RESVG_IMAGE_RENDERING_OPTIMIZE_QUALITY;
                case 1: return RESVG_IMAGE_RENDERING_OPTIMIZE_SPEED;
                default: return RESVG_IMAGE_RENDERING_OPTIMIZE_QUALITY;
            }
        }
    }

    critcl::ccommand tresvg::toTkImg {cd interp objc objv} {
        /**
        * Convert a rendered SVG image to a Tk Photo image.
        *
        * interp - The Tcl interpreter.
        * objc   - The number of arguments passed to the command.
        * objv   - The array of Tcl_Obj which are the arguments passed to the command.
        *
        * Returns : TCL_OK if the command was successful, TCL_ERROR otherwise.
        */
        if (objc < 3) {
            Tcl_WrongNumArgs(interp, 1, objv, "svgfile photo ?args?");
            return TCL_ERROR;
        }

        Tk_PhotoHandle source = NULL;
        uint8_t *data = NULL;
        resvg_options *opt = NULL;
        resvg_render_tree *tree = NULL;
        int result = TCL_ERROR;

        source = Tk_FindPhoto(interp, Tcl_GetString(objv[2]));

        if (source == NULL) {
            Tcl_SetResult(interp, "tresvg(error): Photo not found.", TCL_STATIC);
            return TCL_ERROR;
        }

        opt = resvg_options_create();
        resvg_transform tr = resvg_transform_identity();
        double scale = 0;
        int hasScale = 0;
        int hasMtx = 0;
        int hasTargetWidth = 0;
        int hasTargetHeight = 0;
        int target_width = 0;
        int target_height = 0;
        const char *mode_scale = NULL;

        // Parse the arguments.
        if (objc > 3) {
            for (int i = 3; i < objc; i += 2) {
                if ((i + 1) >= objc) {
                    Tcl_SetResult(interp, "tresvg(error): Missing argument.", TCL_STATIC);
                    goto cleanup;
                }
                const char* key = Tcl_GetString(objv[i]);
                /**
                 * Initialize the log of the library.
                 * If true, the log of the library will be initialized.
                 */
                if (!strcmp(key, "-initLog")) {
                    int init_log = 0;
                    if (Tcl_GetBooleanFromObj(interp, objv[i+1], &init_log) != TCL_OK) {
                        goto cleanup;
                    }
                    if (init_log) {resvg_init_log();}
                /**
                 * Sets the DPI of the rendering.
                 * DPI is used to scale the rendering.
                 * The default DPI is 96.
                 */
                } else if (!strcmp(key, "-dpi")) {
                    double dpi = 0;
                    if (Tcl_GetDoubleFromObj(interp, objv[i+1], &dpi) != TCL_OK) {
                        goto cleanup;
                    }
                    resvg_options_set_dpi(opt, (float)dpi);
                /**
                 * Sets the matrix of the rendering.
                 * The matrix must have 6 values.
                 */
                } else if (!strcmp(key, "-mtx")) {
                    Tcl_Obj **mtx;
                    Tcl_Size count;
                    if (Tcl_ListObjGetElements(interp, objv[i+1], &count, &mtx) != TCL_OK) {
                        goto cleanup;
                    }

                    if (count != 6) {
                        Tcl_SetResult(interp, "-mtx must have 6 values", TCL_STATIC);
                        goto cleanup;
                    }

                    double temp[6];
                    for (Tcl_Size j = 0; j < 6; j++) {
                        if (Tcl_GetDoubleFromObj(interp, mtx[j], &temp[j]) != TCL_OK) {
                            goto cleanup;
                        }
                    }

                    tr.a = (float)temp[0];
                    tr.b = (float)temp[1];
                    tr.c = (float)temp[2];
                    tr.d = (float)temp[3];
                    tr.e = (float)temp[4];
                    tr.f = (float)temp[5];

                    hasMtx = 1;
                /**
                 * Sets the resources directory.
                 * The resources directory contains the fonts and images needed for the SVG rendering.
                 */
                } else if (!strcmp(key, "-resourcesDir")) {

                    const char *path = Tcl_GetString(objv[i+1]);

                    resvg_options_set_resources_dir(opt, path);
                /**
                 * Sets the style sheet.
                 * The style sheet defines the CSS styles used by the SVG rendering.
                 */
                } else if (!strcmp(key, "-styleSheet")) {

                    const char *content = Tcl_GetString(objv[i+1]);

                    resvg_options_set_stylesheet(opt, content);

                /**
                 * Sets the serif font family.
                 * The serif font family is the font family used for serif fonts.
                 */
                } else if (!strcmp(key, "-serifFontFamily")) {
                    const char *family = Tcl_GetString(objv[i+1]);

                    resvg_options_set_serif_family(opt, family);

                /**
                 * Sets the sans serif font family.
                 * The sans serif font family is the font family used for sans serif fonts.
                 */
                } else if (!strcmp(key, "-sansSerifFontFamily")) {
                    const char *family = Tcl_GetString(objv[i+1]);

                    resvg_options_set_sans_serif_family(opt, family);

                /**
                 * Sets the cursive font family.
                 * The cursive font family is the font family used for cursive fonts.
                 */
                } else if (!strcmp(key, "-cursiveFontFamily")) {
                    const char *family = Tcl_GetString(objv[i+1]);

                    resvg_options_set_cursive_family(opt, family);

                /**
                 * Sets the fantasy font family.
                 * The fantasy font family is the font family used for fantasy fonts.
                 */
                } else if (!strcmp(key, "-fantasyFontFamily")) {
                    const char *family = Tcl_GetString(objv[i+1]);

                    resvg_options_set_fantasy_family(opt, family);

                /**
                 * Sets the monospace font family.
                 * The monospace font family is the font family used for monospace fonts.
                 */
                } else if (!strcmp(key, "-monospaceFontFamily")) {
                    const char *family = Tcl_GetString(objv[i+1]);

                    resvg_options_set_monospace_family(opt, family);

                /**
                 * Sets the font family.
                 * The font family is the font family used for all fonts.
                 */
                } else if (!strcmp(key, "-fontFamily")) {
                    const char *family = Tcl_GetString(objv[i+1]);

                    resvg_options_set_font_family(opt, family);

                /**
                 * Sets the languages.
                 * The languages are the languages used for the SVG rendering.
                 */
                } else if (!strcmp(key, "-languages")) {
                    const char *languages = Tcl_GetString(objv[i+1]);

                    resvg_options_set_languages(opt, languages);

                /**
                 * Sets the shape rendering mode.
                 * The shape rendering mode is used to determine how to render shapes.
                 * The values are:
                 * 0: RESVG_SHAPE_RENDERING_OPTIMIZE_SPEED
                 * 1: RESVG_SHAPE_RENDERING_CRISP_EDGES
                 * 2: RESVGSHAPE_RENDERING_GEOMETRIC_PRECISION
                 */
                } else if (!strcmp(key, "-shapeRenderingMode")) {
                    int mode = 0;
                    if (Tcl_GetIntFromObj(interp, objv[i+1], &mode) != TCL_OK) {
                        goto cleanup;
                    }

                    resvg_options_set_shape_rendering_mode(opt, shapeRenderingMode(mode));

                /**
                 * Sets the width of the SVG image.
                 * The width is the width of the SVG image in pixels.
                 * If the width is not set, the SVG image will be rendered with its natural size.
                 */
                } else if (!strcmp(key, "-width")) {
                    if (Tcl_GetIntFromObj(interp, objv[i+1], &target_width) != TCL_OK) {
                        goto cleanup;
                    }

                    if (target_width <= 0) {
                        Tcl_SetResult(interp, "iresvg(error): -width must be > 0", TCL_STATIC);
                        goto cleanup;
                    }

                    hasTargetWidth = 1;

                /**
                 * Sets the height of the SVG image.
                 * The height is the height of the SVG image in pixels.
                 * If the height is not set, the SVG image will be rendered with its natural size.
                 */
                } else if (!strcmp(key, "-height")) {
                    if (Tcl_GetIntFromObj(interp, objv[i+1], &target_height) != TCL_OK) {
                        goto cleanup;
                    }

                    if (target_height <= 0) {
                        Tcl_SetResult(interp, "iresvg(error): -height must be > 0", TCL_STATIC);
                        goto cleanup;
                    }

                    hasTargetHeight = 1;

                /**
                 * Sets the mode scale.
                 * The mode scale is used to determine how to scale the SVG image.
                 * The value is:
                 * "fit": best fit.
                 */
                } else if (!strcmp(key, "-modeScale")) {
                    mode_scale = Tcl_GetString(objv[i+1]);

                /**
                 * Sets the text rendering mode.
                 * The text rendering mode is used to determine how to render text.
                 * The values are:
                 * 0: RESVGTEXT_RENDERING_OPTIMIZE_SPEED
                 * 1: RESVGTEXT_RENDERING_OPTIMIZE_LEGIBILITY
                 * 2: RESVGTEXT_RENDERING_GEOMETRIC_PRECISION
                 */
                } else if (!strcmp(key, "-textRenderingMode")) {
                    int mode = 0;
                    if (Tcl_GetIntFromObj(interp, objv[i+1], &mode) != TCL_OK) {
                        goto cleanup;
                    }

                    resvg_options_set_text_rendering_mode(opt, textRenderingMode(mode));

                /**
                 * Sets the image rendering mode.
                 * The image rendering mode is used to determine how to render images.
                 * The values are:
                 * 0: RESVGIMAGE_RENDERING_OPTIMIZE_QUALITY
                 * 1: RESVGIMAGE_RENDERING_OPTIMIZE_SPEED
                 */
                } else if (!strcmp(key, "-imageRenderingMode")) {
                    int mode = 0;
                    if (Tcl_GetIntFromObj(interp, objv[i+1], &mode) != TCL_OK) {
                        goto cleanup;
                    }

                    resvg_options_set_image_rendering_mode(opt, imageRenderingMode(mode));

                /**
                 * Sets the scale of the SVG image.
                 * The scale is the scale of the SVG image in pixels.
                 * If the scale is not set, the SVG image will be rendered with its natural size.
                 */
                } else if (!strcmp(key, "-scale")) {
                    if (Tcl_GetDoubleFromObj(interp, objv[i+1], &scale) != TCL_OK) {
                        goto cleanup;
                    }
                    if (scale <= 0) {
                        Tcl_SetResult(interp, "iresvg(error): -scale must be > 0", TCL_STATIC);
                        goto cleanup;
                    }

                    hasScale = 1;

                /**
                 * Load a font file.
                 */
                } else if (!strcmp(key, "-loadFontFile")) {
                    const char *file_path = Tcl_GetString(objv[i+1]);
                    int err = resvg_options_load_font_file(opt, file_path);

                    if (err != RESVG_OK) {
                        Tcl_SetObjResult(interp,
                            Tcl_ObjPrintf("iresvg(error): %s", resvg_error_to_string(err))
                        );
                        goto cleanup;
                    }

                /**
                 * Sets the font size of the SVG image.
                 * The font size is the size of the fonts used by the SVG image.
                 * If the font size is not set, the SVG image will be rendered with its natural size.
                 */
                } else if (!strcmp(key, "-fontSize")) {
                    double fontSize = 0;
                    if (Tcl_GetDoubleFromObj(interp, objv[i+1], &fontSize) != TCL_OK) {
                        goto cleanup;
                    }
                    resvg_options_set_font_size(opt, (float)fontSize);

                /**
                 * Sets the system fonts of the SVG image.
                 */
                } else if (!strcmp(key, "-loadSystemFonts")) {
                    int load = 0;
                    if (Tcl_GetBooleanFromObj(interp, objv[i+1], &load) != TCL_OK) {
                        goto cleanup;
                    }
                    if (load) {resvg_options_load_system_fonts(opt);}
                } else {
                    Tcl_SetObjResult(interp,
                        Tcl_ObjPrintf("tresvg(error): key '%s' not supported.", key)
                    );
                    goto cleanup;
                }
            }
        }

        if (hasMtx && hasScale) {
            Tcl_SetResult(interp,
            "tresvg(error): Cannot use both '-mtx' and '-scale'.", TCL_STATIC);
            goto cleanup;
        }

        if (hasScale && (hasTargetHeight || hasTargetWidth)) {
            Tcl_SetResult(interp,
            "tresvg(error): Cannot use both '-scale' and '-height or -width'.", TCL_STATIC);
            goto cleanup;
        }

        Tcl_Size svgLen;
        const char *svgData = Tcl_GetStringFromObj(objv[1], &svgLen);
        int err = resvg_parse_tree_from_file(svgData, opt, &tree);

        if (err == RESVG_ERROR_FILE_OPEN_FAILED) {
            err = resvg_parse_tree_from_data(svgData, (uintptr_t)svgLen, opt, &tree);
        }

        if (err != RESVG_OK) {
            Tcl_SetObjResult(interp,
                Tcl_ObjPrintf("tresvg(error): %s", resvg_error_to_string(err))
            );
            goto cleanup;
        }

        resvg_options_destroy(opt);
        opt = NULL;

        resvg_size size = resvg_get_image_size(tree);
        int width = (int)size.width;
        int height = (int)size.height;

        if (width <= 0 || height <= 0) {
            Tcl_SetResult(interp, "tresvg(error): SVG has invalid dimensions.", TCL_STATIC);
            goto cleanup;
        }

        if (hasTargetHeight || hasTargetWidth) {

            if (!hasTargetHeight) {target_height = height;}
            if (!hasTargetWidth) {target_width = width;}

            double scale_x = (double)target_width / size.width;
            double scale_y = (double)target_height / size.height;

            if (mode_scale != NULL) {
                if (!strcmp(mode_scale, "fit")) {
                    scale = (scale_x < scale_y) ? scale_x : scale_y;
                    scale_x = scale_y = scale;

                    float offset_x = (target_width - (width * scale)) / 2.0f;
                    float offset_y = (target_height - (height * scale)) / 2.0f;

                    tr.e = offset_x;
                    tr.f = offset_y;
                } else {
                    Tcl_SetObjResult(interp,
                        Tcl_ObjPrintf(
                            "tresvg(error): -modeScale '%s' not supported. Use 'fit'.",
                            mode_scale
                        )
                    );
                    goto cleanup;
                }
            }

            tr.a = (float)scale_x;
            tr.d = (float)scale_y;
            width = target_width;
            height = target_height;
        }

        if (hasScale) {
            width = (int)(size.width * scale);
            height = (int)(size.height * scale);
            tr.a = tr.d = (float)scale;
        }

        if (hasMtx) {
            width = (int)(size.width * tr.a);
            height = (int)(size.height * tr.d);
        }

        if (width <= 0 || height <= 0) {
            Tcl_SetResult(interp, "tresvg(error): Calculated dimensions are invalid.", TCL_STATIC);
            goto cleanup;
        }

        size_t len = (size_t)width * (size_t)height * 4;

        if (len > INT_MAX) {
            Tcl_SetResult(interp, "tresvg(error): Image too large.", TCL_STATIC);
            goto cleanup;
        }

        data = (uint8_t *)Tcl_Alloc(len);

        if (data == NULL) {
            Tcl_SetResult(interp, "tresvg(error): Cannot alloc image buffer.", TCL_STATIC);
            goto cleanup;
        }

        memset(data, 0, len);
        resvg_render(tree, tr, width, height, (char*)data);

        // Unpremultiply
        for (size_t i = 0; i < len; i += 4) {
            uint8_t alpha = data[i + 3];
            if (alpha != 0 && alpha != 255) {
                unsigned int multiplier = (unsigned int)round((255.0f / (float)alpha) * 255.0f);
                data[i + 0] = (uint8_t)(((unsigned int)data[i + 0] * multiplier + 127) / 255);
                data[i + 1] = (uint8_t)(((unsigned int)data[i + 1] * multiplier + 127) / 255);
                data[i + 2] = (uint8_t)(((unsigned int)data[i + 2] * multiplier + 127) / 255);
            }
        }

        Tk_PhotoImageBlock block;

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
            goto cleanup;
        }

        if (Tk_PhotoPutBlock(interp, source, &block, 0, 0, width, height, TK_PHOTO_COMPOSITE_SET) != TCL_OK) {
            goto cleanup;
        }

        result = TCL_OK;

        cleanup:
            if (data != NULL) {
                Tcl_Free((char*)data);
            }
            if (tree != NULL) {
                resvg_tree_destroy(tree);
            }
            if (opt != NULL) {
                resvg_options_destroy(opt);
            }
            return result;
    }

}