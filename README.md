# tresvg - Tcl SVG rendering

Tcl wrapper around [resvg](https://github.com/linebender/resvg)

From **resvg** repository :  
***resvg** is an [SVG](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics) rendering library.*  
*It can be used as a Rust library, as a C library, and as a CLI application to render static SVG files.*  
*The core idea is to make a fast, small, portable SVG library with the goal to support the whole SVG spec.*

## Compatibility :
- [Tcl](https://www.tcl.tk/) 8.6 or higher

## Dependencies :

- [tcl-cffi](https://github.com/apnadkarni/tcl-cffi) >= 2.0 and/or [critcl](https://andreas-kupries.github.io/critcl/) (see note below)
> [!NOTE]  
> [critcl](https://andreas-kupries.github.io/critcl/) and [Tk](https://www.tcl.tk/) are optional for rendering SVG image to **photo** command.

## Cross-Platform :
- Windows, Linux, macOS support.

## Example :
### `tcl-cffi` demo :
```tcl
package require tresvg

set svg hello.svg

# Initialize log (optional)
tresvg::initLog

# Create options
set opt [tresvg::optionsCreate]

# Parse svg file
set tree [tresvg::parseTreeFromFile $svg $opt]

# Apply transform
set transform [tresvg::transformIdentity]

# Get image size
set size [tresvg::getImageSize $tree]
set width  [expr {int([dict get $size width])}]
set height [expr {int([dict get $size height])}]

# Render
set pixmap [tresvg::render $tree $transform $width $height]

# Save to PNG
tresvg::toPNG $pixmap $width $height "/Users/nico/temp/output.png"

# Cleanup
tresvg::optionsDestroy $opt
tresvg::treeDestroy $tree
```
### `critcl` demo :
```tcl
package require Tk ; # Important to load Tk before 'tresvg' package.
package require tresvg

set svg hello.svg
set img [image create photo]

# Others args are optional (see listing commands below)
tresvg::toTkImg $svg $img

# Others examples of 'tresvg::toTkImg' command :
tresvg::toTkImg $svg $img -width 100 -height 50
tresvg::toTkImg $svg $img -scale 2 -dpi 300
tresvg::toTkImg $svg $img -mtx {1 0 0 1 0 0}
tresvg::toTkImg $svg $img -width 100 -height 50 -modeScale "fit"
tresvg::toTkImg $svg $img -initLog "true"

label .l -image $img
pack .l
```

## Commands :

| Tcl/Tk commands | help
| ------          | ------
tresvg::toPNG     | pixmap width height filename
tresvg::toBase64  | pixmap width height     
tresvg::toTkImg   | 'svgFile or svgData' tkImage ?args?`

---
     
resvg-c                                 |tcl-cffi                                    | critcl args                       | help
| ------                                | ------                                     | ------                            | ------
| resvg_transform_identity              | _tresvg::transformIdentity_                | _default matrix_                  | _-_
| resvg_init_log                        | _tresvg::initLog_                          | _-initLog `"bool_value"`_         | Use it if you want to see any warnings.
| resvg_options_create                  | _tresvg::optionsCreate_                    | _-_                               | Creates a new #resvg_options object.
| resvg_options_destroy                 | _tresvg::optionsDestroy_                   | _-_                               | Destroys a #resvg_options object.
| resvg_tree_destroy                    | _tresvg::treeDestroy_                      | _-_                               | Destroys a #resvg_tree object.
| resvg_options_set_resources_dir       | _tresvg::optionsSetResourcesDir_           | _-resourcesDir `$path`_           | Sets the path to the resources directory.
| resvg_options_set_dpi                 | _tresvg::optionsSetDpi_                    | _-dpi `$dpi`_                     | Sets the DPI of the rendering.
| resvg_options_set_stylesheet          | _tresvg::optionsSetStylesheet_             | _-styleSheet `$css`_              | Sets the CSS styles used by the SVG rendering.     
| resvg_options_set_font_family         | _tresvg::optionsSetFontFamily_             | _-fontFamily `$family`_           | Sets the font family.
| resvg_options_set_font_size           | _tresvg::optionsSetFontSize_               | _-fontSize `$size`_               | Sets the font size.
| resvg_options_set_serif_family        | _tresvg::optionsSetSerifFamily_            | _-serifFontFamily `$family`_      | Sets the serif font family.
| resvg_options_set_sans_serif_family   | _tresvg::optionsSetSansSerifFamily_        | _-sansSerifFontFamily `$family`_  | Sets the sans-serif font family.
| resvg_options_set_cursive_family      | _tresvg::optionsSetCursiveFamily_          | _-cursiveFontFamily `$family`_    | Sets the cursive font family.
| resvg_options_set_fantasy_family      | _tresvg::optionsSetFantasyFamily_          | _-fantasyFontFamily `$family`_    | Sets the fantasy font family.
| resvg_options_set_monospace_family    | _tresvg::optionsSetMonospaceFamily_        | _-monospaceFontFamily `$family`_  | Sets the monospace font family.
| resvg_options_set_languages           | _tresvg::optionsSetLanguages_              | _-languages `$languages`_         | Sets the languages.
| resvg_options_set_shape_rendering_mode| _tresvg::optionsSetShapeRenderingMode_     | _-shapeRenderingMode `$mode`_     | Sets the shape rendering mode.
| resvg_options_set_text_rendering_mode | _tresvg::optionsSetTextRenderingMode_      | _-textRenderingMode `$mode`_      | Sets the text rendering mode.
| resvg_options_set_image_rendering_mode| _tresvg::optionsSetImageRenderingMode_     | _-imageRenderingMode `$mode`_     | Sets the image rendering mode.
| resvg_options_load_font_data          | _tresvg::optionsLoadFontData_              | _❌ not implemented yet_          | -
| resvg_options_load_font_file          | _tresvg::optionsLoadFontFile_              | _-loadFontFile `$fontfile`_.      | Loads a font file.
| resvg_options_load_system_fonts       | _tresvg::optionsLoadSystemFonts_           | _-loadSystemFonts `"bool_value"`_ | Loads the system fonts.
| resvg_parse_tree_from_file            | _tresvg::parseTreeFromFile_                | _-_                               | Parses a SVG file.
| resvg_parse_tree_from_data            | _tresvg::parseTreeFromData_                | _tresvg::toTkImg `$svgString`_    | Parses a SVG data.
| resvg_is_image_empty                  | _tresvg::isImageEmpty_                     | _❌ not implemented yet_          | Gets if an image is empty.
| resvg_get_image_size                  | _tresvg::getImageSize_                     | _❌ not implemented yet_          | Gets the size of an image.
| resvg_get_object_bbox                 | _tresvg::getObjectBbox_                    | _❌ not implemented yet_          | Gets the bounding box of an object.
| resvg_get_image_bbox                  | _tresvg::getImageBbox_                     | _❌ not implemented yet_          | Gets the bounding box of an image.
| resvg_node_exists                     | _tresvg::nodeExists_                       | _❌ not implemented yet_          | Gets if a node exists.
| resvg_get_node_transform              | _tresvg::getNodeTransform_                 | _❌ not implemented yet_          | Gets the transform of a node.
| resvg_get_node_bbox                   | _tresvg::getNodeBBox_                      | _❌ not implemented yet_          | Gets the bounding box of a node.
| resvg_get_node_stroke_bbox            | _tresvg::getNodeStrokeBBox_                | _❌ not implemented yet_          | Gets the stroke bounding box of a node.
| resvg_tree_destroy                    | _tresvg::treeDestroy_                      | _-_                               | Destroys a #resvg_tree object.
| resvg_render                          | _tresvg::render_                           | _tresvg::toTkImg `$svg`_          | Renders a SVG file or data to Tk image photo.
| resvg_render_node                     | _tresvg::renderNode_                       | _❌ not implemented yet_          | Renders a node.
| `struct` resvg_transform              | _[list `a b c d e f`]_                     | _-mtx `{a b c d e f}`_            | Sets the transform matrix.
| _-_                                   | _-_                                        | _-width  `$width`_                | Sets the width of the image.
| _-_                                   | _-_                                        | _-height `$height`_               | Sets the height of the image.
| _-_                                   | _-_                                        | _-scale  `$scale`_                | Sets the scale of the image.
| _-_                                   | _-_                                        | _-modeScale `"fit"`_              | Sets the mode scale of the image.



## Building :
You can either **build the library yourself** (if you have Rust installed or if you want to install it), or **use this repository’s GitHub Actions** to automatically build platform-specific binaries for you.

---

### Option 1 — Build locally (Rust required)

If you already have [Rust](https://www.rust-lang.org/tools/install) installed, you can build the C library directly from source:
```bash
cd resvg-X.XX.X/crates/c-api
cargo build --release
```

This command compiles the `resvg` C API and produces the libraries under:
```
target/release/
```

After building, copy the generated dynamic or static libraries into your **tresvg** package directory under one of the following platform-specific folders:

- **Linux:** `your/path/to/lib/tresvg/linux-x86_64`
- **Windows:** `your/path/to/lib/tresvg/win32-x86_64`
- **macOS (Intel):** `your/path/to/lib/tresvg/macosx-x86_64`
- **macOS (ARM):** `your/path/to/lib/tresvg/macosx-arm`

#### ⚠️ Compilation under Windows to work with critcl: :
```bash
# Rust toolchain with GNU target
rustup target add x86_64-pc-windows-gnu
cargo build --release --target x86_64-pc-windows-gnu
```
This will produce dynamic libraries in `/target/x86_64-pc-windows-gnu/release`

---

### Option 2 — Use prebuilt binaries (no Rust required)

If you prefer not to install or compile Rust yourself, you can simply **use this GitHub repository (fork it)**.  
It includes a **GitHub Actions workflow** that automatically builds and uploads binaries for all supported platforms whenever changes are pushed.

You can enable the workflow in your own fork to generate them automatically.

> [!TIP]    
> Make sure to match your platform architecture (e.g. `x86_64` vs `arm64`).   
> The header file `resvg.h` is included in each build under the `your_platform/include/` directory.

## License : 
[MIT](LICENSE).

## Acknowledgments :
To [RazrFalcon](https://github.com/RazrFalcon), the author of **resvg**, who helped me understand his library a few years ago.

## Release :
*  **21-Oct-2025** : 0.1
    - Initial release.
*  **26-Oct-2025** : 0.15
    - Adds a better support for **critcl** backend.
    - Adds others commands for **tcl-cffi** backend.
    - Adds gitHub Actions workflow to build **resvg** binaries.
    - Cosmetic changes.