/**
 * @file extended.h
 * @brief Extensions to the resvg C API
 * 
 * Additional functions for the resvg C API that provide XML export functionality.
 */

#ifndef RESVG_EXTENDED_H
#define RESVG_EXTENDED_H

#include "resvg.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Converts the render tree to simplified SVG XML.
 * 
 * This function takes a parsed SVG tree and converts it back to XML format.
 * The output is a simplified, normalized SVG where (I guess...):
 * - All paths are normalized
 * - Transformations are applied
 * - Styles are inline
 * - References are resolved
 * 
 * @param tree Pointer to a render tree. Must not be NULL.
 * @return A newly allocated string containing the XML, or NULL on error.
 *         The string must be freed with resvg_free_string().
 * 
 * @note The returned string is UTF-8 encoded.
 * 
 * Example:
 * @code
 * resvg_options *opt = resvg_options_create();
 * resvg_render_tree *tree = resvg_parse_tree_from_file("input.svg", opt);
 * 
 * if (tree) {
 *     char *xml = resvg_tree_to_xml(tree);
 *     if (xml) {
 *         printf("%s\n", xml);
 *         resvg_free_string(xml);
 *     }
 *     resvg_tree_destroy(tree);
 * }
 * resvg_options_destroy(opt);
 * @endcode
 */
char* resvg_tree_to_xml(const resvg_render_tree *tree);

/**
 * @brief Frees a string returned by resvg_tree_to_xml.
 * 
 * @param str Pointer to a string returned by resvg_tree_to_xml.
 *            Can be NULL (in which case this function does nothing).
 * 
 * @warning The pointer must have been returned by resvg_tree_to_xml.
 * @warning The pointer must not be used after this call.
 */
void resvg_free_string(char *str);

/**
 * @brief Get the resvg version as a string.
 * @return Version string (e.g., "0.45.1"). 
 *         Valid for program lifetime. Must NOT be freed.
 * 
 * Example:
 * @code
 * printf("resvg version: %s\n", resvg_version_string());
 * @endcode
 */
const char* resvg_version_string(void);

#ifdef __cplusplus
}
#endif

#endif /* RESVG_EXTENDED_H */