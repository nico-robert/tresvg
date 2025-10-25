# Copyright (c) 2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

if {![catch {package require cffi 2.0}]} {

    namespace eval tresvg {
        variable supportedResvgVersions [list 0.45.1 0451]

        proc transformIdentity {} {
            # Gets the identity transform.
            #
            # Returns the identity transform.
            return [resvg_transform_identity]
        }

        proc initLog {} {
            # Initialize the resvg log.
            #
            # Returns nothing.
            resvg_init_log
        }

        proc optionsCreate {} {
            # Create resvg options.
            #
            # Returns the options.
            return [resvg_options_create]
        }

        proc optionsSetResourcesDir {opt path} {
            # Sets the resources directory.
            #
            # opt  - The options.
            # path - The resources directory.
            #
            # Returns nothing.
            resvg_options_set_resources_dir $opt $path

            return {}
        }

        proc optionsSetDpi {opt dpi} {
            # Sets the DPI.
            #
            # opt  - The options.
            # dpi - The DPI.
            #
            # Returns nothing.
            resvg_options_set_dpi $opt $dpi

            return {}
        }

        proc optionsSetStylesheet {opt content} {
            # Sets the stylesheet.
            #
            # opt  - The options.
            # content - The stylesheet.
            #
            # Returns nothing.
            resvg_options_set_stylesheet $opt $content

            return {}
        }

        proc optionsSetFontFamily {opt family} {
            # Sets the font family.
            #
            # opt  - The options.
            # family - The font family.
            #
            # Returns nothing.
            resvg_options_set_font_family $opt $family

            return {}
        }

        proc optionsSetFontSize {opt size} {
            # Sets the font size.
            #
            # opt  - The options.
            # size - The font size.
            #
            # Returns nothing.
            resvg_options_set_font_size $opt $size

            return {}
        }

        proc optionsSetSansSerifFamily {opt family} {
            # Sets the sans serif family.
            #
            # opt  - The options.
            # family - The sans serif family.
            #
            # Returns nothing.
            resvg_options_set_sans_serif_family $opt $family

            return {}
        }

        proc optionsSetCursiveFamily {opt family} {
            # Sets the cursive font family.
            #
            # opt  - The options.
            # family - The cursive family.
            #
            # Returns nothing.
            resvg_options_set_cursive_family $opt $family

            return {}
        }

        proc optionsSetFantasyFamily {opt family} {
            # Sets the fantasy font family.
            #
            # opt  - The options.
            # family - The fantasy family.
            #
            # Returns nothing.
            resvg_options_set_fantasy_family $opt $family

            return {}
        }

        proc optionsSetMonospaceFamily {opt family} {
            # Sets the monospace font family.
            #
            # opt  - The options.
            # family - The monospace family.
            #
            # Returns nothing.
            resvg_options_set_monospace_family $opt $family

            return {}
        }

        proc optionsSetLanguages {opt family} {
            # Sets a comma-separated list of languages.
            #
            # opt       - The options.
            # languages - list of languages separated by commas.
            #
            # Returns nothing.
            resvg_options_set_languages $opt $languages

            return {}
        }

        proc optionsSetSerifFamily {opt family} {
            # Sets the serif family.
            #
            # opt  - The options.
            # family - The serif family.
            #
            # Returns nothing.
            resvg_options_set_serif_family $opt $family

            return {}
        }

        proc optionsSetShapeRenderingMode {opt mode} {
            # Sets the shape rendering mode.
            #
            # opt  - The options.
            # mode - The shape rendering mode.
            #
            # Returns nothing.
            resvg_options_set_shape_rendering_mode $opt $mode

            return {}
        }

        proc optionsSetTextRenderingMode {opt mode} {
            # Sets the text rendering mode.
            #
            # opt  - The options.
            # mode - The text rendering mode.
            #
            # Returns nothing.
            resvg_options_set_text_rendering_mode $opt $mode

            return {}
        }

        proc optionsSetImageRenderingMode {opt mode} {
            # Sets the image rendering mode.
            #
            # opt  - The options.
            # mode - The image rendering mode.
            #
            # Returns nothing.
            resvg_options_set_image_rendering_mode $opt $mode

            return {}
        }

        proc optionsLoadFontData {opt data size} {
            # Load font data.
            #
            # opt  - The options.
            # data - The font data.
            # size - The size of the font data.
            #
            # Returns nothing.
            resvg_options_load_font_data $opt $data $size

            return {}
        }

        proc optionsLoadFontFile {opt file_path} {
            # Load a font file.
            #
            # opt - The options.
            # file_path - The path to the font file.
            #
            # Returns nothing.
            resvg_options_load_font_file $opt $file_path

            return {}
        }

        proc optionsLoadSystemFonts {opt} {
            # Load system fonts.
            #
            # opt - The options.
            #
            # Returns nothing.
            resvg_options_load_system_fonts $opt

            return {}
        }

        proc optionsDestroy {opt} {
            # Destroy the resvg options
            #
            # opt - The options.
            #
            # Returns nothing.
            resvg_options_destroy $opt

            return {}
        }

        proc parseTreeFromFile {file opt} {
            # Parse the resvg tree from a file.
            #
            # file - The file.
            # opt  - The options.
            #
            # Returns the resvg tree.
            resvg_parse_tree_from_file $file $opt tree
            return $tree
        }

        proc parseTreeFromData {data opt} {
            # Parse the resvg tree from data.
            #
            # data - The data.
            # opt  - The options.
            #
            # Returns the resvg tree.
            return [resvg_parse_tree_from_data $data $opt]
        }

        proc render {tree transform width height} {
            # Render the resvg tree.
            #
            # tree      - The resvg tree.
            # transform - The transform of the image.
            # width     - The width of the image.
            # height    - The height of the image.
            #
            # Returns the pixmap.
            set N [expr {$width * $height * 4}]
            resvg_render $tree $transform $width $height pixmap $N

            return $pixmap
        }

        proc renderNode {tree id transform width height} {
            # Render a node.
            #
            # tree      - The resvg tree.
            # id        - The node id.
            # transform - The transform of the node.
            # width     - The width of the image.
            # height    - The height of the image.
            #
            # Returns the pixmap or an empty value if the node has no content.
            set N [expr {$width * $height * 4}]
            if {![resvg_render_node $tree $id $transform $width $height pixmap $N]} {
                return {}
            }
            return $pixmap
        }

        proc getNodeBBox {tree id} {
            # Gets the bounding box of the node.
            #
            # tree - The resvg tree.
            # id - The node id.
            #
            # Returns a list with the x, y, width and height of the bounding box
            # or an empty value if the node has no bounding box according to the ID.
            if {![resvg_get_node_bbox $tree $id bbox]} {
                return {}
            }
            return $bbox
        }

        proc getNodeTransform {tree id} {
            # Gets the transform of the node.
            #
            # tree - The resvg tree.
            # id - The node id.
            #
            # Returns the transform of the node in dict format or
            # an empty value if the node has no transform.
            if {![resvg_get_node_transform $tree $id transform]} {
                return {}
            }
            return $transform
        }

        proc getNodeStrokeBBox {tree id} {
            # Gets the stroke bounding box of the node.
            #
            # tree - The resvg tree.
            # id - The node id.
            #
            # Returns a list with the x, y, width and height of the bounding box
            # or an empty value if the node has no stroke bounding box according to the ID.
            if {![resvg_get_node_stroke_bbox $tree $id bbox]} {
                return {}
            }

            return $bbox
        }

        proc getImageSize {tree} {
            # Gets the width and height of the image in dict format.
            return [resvg_get_image_size $tree]
        }

        proc treeDestroy {tree} {
            # Destroy the resvg tree
            #
            # tree - The resvg tree
            # 
            # Returns nothing
            resvg_tree_destroy $tree

            return {}
        }

        proc isImageEmpty {tree} {
            # Check if the image is empty.
            #
            # tree - The resvg tree.
            #
            # Returns 1 if the image is empty, 0 otherwise.
            return [resvg_is_image_empty $tree]
        }

        proc getObjectBbox {tree} {
            # Gets the bounding box of the object.
            #
            # tree - The resvg tree.
            #
            # Returns a list with the x, y, width and height of the bounding box or empty
            # if the image has no bounding box.
            if {![resvg_get_object_bbox $obj bbox]} {
                return {}
            }
            return $bbox
        }

        proc getImageBbox {tree} {
            # Gets the bounding box of the image.
            #
            # tree - The resvg tree.
            #
            # Returns a list with the x, y, width and height of the bounding box or empty
            # if the image has no elements.
            if {![resvg_get_image_bbox $obj bbox]} {
                return {}
            }
            return $bbox
        }

        proc nodeExists {tree id} {
            # Check if the node exists.
            #
            # tree - The resvg tree.
            # id - The node id.
            #
            # Returns 1 if the node exists, 0 otherwise.
            return [resvg_node_exists $tree $id]
        }

        proc error {dict} {
            # Throw an error based on the resvg error code.
            # 
            # dict - dictionary
            #
            # Returns nothing
            set seq [dict get $dict Result]
            set enum [cffi::enum name resvg_error $seq]

            switch -exact $enum {
                RESVG_ERROR_NOT_AN_UTF8_STR {
                    set msg "String is not valid UTF-8"
                }
                RESVG_ERROR_FILE_OPEN_FAILED {
                    set msg "Failed to open the provided file"
                }
                RESVG_ERROR_MALFORMED_GZIP {
                    set msg "Compressed SVG must use the GZip algorithm"
                }
                RESVG_ERROR_ELEMENTS_LIMIT_REACHED {
                    set msg "We do not allow SVG with more than 1_000_000 elements for security reasons"
                }
                RESVG_ERROR_INVALID_SIZE {
                    set msg "SVG doesn't have a valid size"
                }
                RESVG_ERROR_PARSING_FAILED {
                    set msg "Failed to parse an SVG data"
                }
                default {set msg "RESVG_ERROR_UNKNOWN"}
            }

            throw TRESVG_ERROR "tresvg(error): $msg"
        }

        proc load_resvg {} {
            # Locates and loads the resvg shared library
            #
            # Tries in order
            #   - the system default search path
            #   - platform specific subdirectories under the package directory
            #   - the toplevel package directory
            #   - the directory where the main program is installed
            # If all fail, simply tries the name as is in which case the
            # system will look up in the standard shared library search path.
            #
            # On success, creates the resvg cffi::Wrapper object in the global
            # namespace.

            variable packageDirectory
            variable supportedResvgVersions

            set resvgPath {}
            # First make up list of possible shared library names depending
            # on platform and supported shared library versions.
            set ext [info sharedlibextension]
            if {$::tcl_platform(platform) eq "windows"} {
                # Names depend on compiler (mingw/vc). VC -> resvg, mingw -> libresvg
                # Examples: resvg.dll, libresvg.dll, resvgVERSION.dll, resvg-VERSION.dll
                foreach baseName {resvg resvg-1 libresvg} {
                    foreach resvgVersion $supportedResvgVersions {
                        lappend fileNames \
                            $baseName$resvgVersion$ext \
                            $baseName-$resvgVersion$ext
                    }
                    lappend fileNames $baseName$ext
                }
            } else {
                # Unix: libresvg.so, libresvgVERSION.so, libresvg-VERSION.so, libresvg.so.VERSION
                foreach resvgVersion $supportedResvgVersions {
                    lappend fileNames \
                        libresvg$resvgVersion$ext \
                        libresvg.$resvgVersion$ext \
                        libresvg-$resvgVersion$ext
                }
                lappend fileNames libresvg$ext
            }

            set attempts {}

            # First try the system default search paths by no explicitly
            # specifying the full path
            foreach fileName $fileNames {
                if {![catch {
                    cffi::Wrapper create ::RESVG $fileName
                } err]} {
                    return
                }
                append attempts $fileName : $err \n
            }

            # Not on default search path. Look under platform specific directories
            # under the package directory.
            set searchPaths [lmap platform [platform::patterns [platform::identify]] {
                if {$platform eq "tcl"} {
                    continue
                }
                file join $packageDirectory $platform
            }]
            # Also look in package directory and location of main executable.
            # On Windows, the latter is probably redundant but...
            lappend searchPaths $packageDirectory
            lappend searchPaths [file dirname [info nameofexecutable]]
            # Specific case for macOS where the shared library is installed
            # under '/usr/local/lib'.
            if {$::tcl_platform(platform) eq "unix"} {
                set searchPaths [linsert $searchPaths 0 "/usr/local/lib"]
            }
            # Now do the actual search over search path for each possible name
            foreach searchPath $searchPaths {
                foreach fileName $fileNames {
                    set path [file join $searchPath $fileName]
                    if {![catch {
                        cffi::Wrapper create ::RESVG $path
                    } err]} {
                        return
                    }
                    append attempts $path : $err \n
                }
            }
            return -code error "Failed to load libresvg:\n$attempts"
        }
    }

    tresvg::load_resvg

    cffi::alias load C

    # Structure:
    # resvg_transform struct:
    #   a: scale x
    #   b: skew x
    #   c: skew y
    #   d: scale y
    #   e: translate x
    #   f: translate y
    cffi::Struct create resvg_transform {
        a float
        b float
        c float
        d float
        e float
        f float
    }

    cffi::Struct create resvg_size {
        width float
        height float
    }

    cffi::Struct create resvg_rect {
        x float
        y float
        width float
        height float
    }

    # Enum:
    # resvg_error enum:
    #
    # RESVG_OK                           - No error, parsing was successful.
    # RESVG_ERROR_NOT_AN_UTF8_STR        - The input string is not a valid UTF-8 string.
    # RESVG_ERROR_FILE_OPEN_FAILED       - The file could not be opened.
    # RESVG_ERROR_MALFORMED_GZIP         - The input string is not a valid GZIP stream.
    # RESVG_ERROR_ELEMENTS_LIMIT_REACHED - The SVG document contains more than the maximum allowed number of elements.
    # RESVG_ERROR_INVALID_SIZE           - The width or height of the output image is invalid.
    # RESVG_ERROR_PARSING_FAILED         - The SVG document could not be parsed.
    cffi::enum sequence resvg_error {
        RESVG_OK
        RESVG_ERROR_NOT_AN_UTF8_STR
        RESVG_ERROR_FILE_OPEN_FAILED
        RESVG_ERROR_MALFORMED_GZIP
        RESVG_ERROR_ELEMENTS_LIMIT_REACHED
        RESVG_ERROR_INVALID_SIZE
        RESVG_ERROR_PARSING_FAILED
    }
    # resvg_image_rendering enum:
    #
    # RESVG_IMAGE_RENDERING_OPTIMIZE_QUALITY
    #   - Optimize the rendering for quality. This will make the rendering slower
    #     but produce a higher quality image.
    # RESVG_IMAGE_RENDERING_OPTIMIZE_SPEED
    #   - Optimize the rendering for speed. This will make the rendering
    #     faster but produce a lower quality image.
    cffi::enum sequence resvg_image_rendering {
        RESVG_IMAGE_RENDERING_OPTIMIZE_QUALITY
        RESVG_IMAGE_RENDERING_OPTIMIZE_SPEED
    }

    # Enum:
    # resvg_shape_rendering enum:
    #
    # RESVG_SHAPE_RENDERING_OPTIMIZE_SPEED:
    #   - Optimize the rendering for speed. This will make the rendering faster but 
    #     produce a lower quality image.
    # RESVGSHAPE_RENDERING_CRISP_EDGES:
    #   - Use crisp edges for shape rendering. This will make the rendering slower but 
    #     produce a higher quality image with crisp edges.
    # RESVGSHAPE_RENDERING_GEOMETRIC_PRECISION:
    #   - Use geometric precision for shape rendering. This will make the rendering slower 
    #     but produce a higher quality image with geometric precision.
    cffi::enum sequence resvg_shape_rendering {
        RESVGSHAPE_RENDERING_OPTIMIZE_SPEED
        RESVGSHAPE_RENDERING_CRISP_EDGES
        RESVGSHAPE_RENDERING_GEOMETRIC_PRECISION
    }

    # Enum:
    # resvg_text_rendering enum:
    #
    # RESVG_TEXT_RENDERING_OPTIMIZE_SPEED:
    #   - Optimize the rendering for speed. This will make the rendering faster 
    #     but produce a lower quality image.
    # RESVG_TEXT_RENDERING_GEOMETRIC_PRECISION:
    #   - Use geometric precision for text rendering. This will make the rendering slower 
    #     but produce a higher quality image with geometric precision.
    cffi::enum sequence resvg_text_rendering {
        RESVG_TEXT_RENDERING_OPTIMIZE_SPEED
        RESVG_TEXT_RENDERING_GEOMETRIC_PRECISION
    }

    # Alias
    cffi::alias define RESVG_SHAPE_RENDERING {int {enum resvg_shape_rendering}}
    cffi::alias define RESVG_TEXT_RENDERING  {int {enum resvg_text_rendering}}
    cffi::alias define RESVG_IMAGE_RENDERING {int {enum resvg_image_rendering}}
    cffi::alias define RESVG_RESULT          {int32_t zero {onerror tresvg::error}}

    # Functions:
    RESVG functions {
        resvg_transform_identity struct.resvg_transform {}
        resvg_init_log           void {}
        resvg_options_create     pointer.resvg_options {}

        resvg_options_set_resources_dir void {
            opt  pointer.resvg_options
            path string
        }
        resvg_options_set_dpi void {
            opt pointer.resvg_options
            dpi float
        }

        resvg_options_set_stylesheet void {
            opt     pointer.resvg_options
            content string
        }

        resvg_options_set_font_family void {
            opt    pointer.resvg_options
            family string
        }

        resvg_options_set_font_size void {
            opt  pointer.resvg_options
            size float
        }

        resvg_options_set_serif_family void {
            opt    pointer.resvg_options
            family string
        }

        resvg_options_set_sans_serif_family void {
            opt    pointer.resvg_options
            family string
        }

        resvg_options_set_cursive_family void {
            opt pointer.resvg_options
            family string
        }

        resvg_options_set_fantasy_family void {
            opt    pointer.resvg_options
            family string
        }

        resvg_options_set_monospace_family void {
            opt    pointer.resvg_options
            family string
        }

        resvg_options_set_languages void {
            opt       pointer.resvg_options
            languages string
        }

        resvg_options_set_shape_rendering_mode void {
            opt  pointer.resvg_options
            mode RESVG_SHAPE_RENDERING
        }

        resvg_options_set_text_rendering_mode void {
            opt  pointer.resvg_options
            mode RESVG_TEXT_RENDERING
        }

        resvg_options_set_image_rendering_mode void {
            opt  pointer.resvg_options
            mode RESVG_IMAGE_RENDERING
        }

        resvg_options_load_font_data void {
            opt  pointer.resvg_options
            data string
            size size_t
        }

        resvg_options_load_font_file RESVG_RESULT {
            opt pointer.resvg_options
            file_path string
        }

        resvg_options_load_system_fonts void {
            opt pointer.resvg_options
        }

        resvg_options_destroy void {
            opt pointer.resvg_options
        }

        resvg_parse_tree_from_file RESVG_RESULT {
            path string
            opt  pointer.resvg_options
            tree {pointer.resvg_render_tree out}
        }

        resvg_is_image_empty bool {
            tree pointer.resvg_render_tree
        }

        resvg_get_image_size struct.resvg_size {
            tree pointer.resvg_render_tree
        }

        resvg_get_object_bbox bool {
            tree pointer.resvg_render_tree
            bbox {struct.resvg_rect out}
        }

        resvg_get_image_bbox bool {
            tree pointer.resvg_render_tree
            bbox {struct.resvg_rect out}
        }

        resvg_node_exists bool {
            tree pointer.resvg_render_tree
            id   string
        }

        resvg_get_node_transform bool {
            tree      pointer.resvg_render_tree
            id        string
            transform {struct.resvg_transform out}
        }

        resvg_get_node_bbox bool {
            tree pointer.resvg_render_tree
            id   string
            bbox {struct.resvg_rect out}
        }

        resvg_get_node_stroke_bbox bool {
            tree pointer.resvg_render_tree
            id   string
            bbox {struct.resvg_rect out}
        }

        resvg_tree_destroy void {
            tree pointer.resvg_render_tree
        }

        resvg_render void {
            tree      pointer.resvg_render_tree
            transform struct.resvg_transform
            width     uint32_t
            height    uint32_t
            pixmap    {uchar[N] out}
            N         uint32_t
        }

        resvg_render_node bool {
            tree      pointer.resvg_render_tree
            id        string
            transform struct.resvg_transform
            width     uint32_t
            height    uint32_t
            pixmap    {uchar[N] out}
            N         uint32_t
        }
    }

}