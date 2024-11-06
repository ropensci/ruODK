#' Get the Metadata Document from the OData Dataset Service.
#'
#' `r lifecycle::badge("experimental")`
#'
#' The Metadata Document describes, in
#' [EDMX CSDL](https://docs.oasis-open.org/odata/odata-csdl-xml/v4.01/odata-csdl-xml-v4.01.html),
#' the schema of all the data you can retrieve from the OData Dataset Service
#' in question. Essentially, these are the Dataset properties, or the schema of
#' each Entity, translated into the OData format.
#'
#' @template tpl-structure-nested
#' @template tpl-def-entitylist
#' @template tpl-entitylist-dataset
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return An S3 class `odata_entitylist_metadata_get` and `list` containing
#'   the Metadata document following the DDMX CSDL standard
#'
#'  * `version` The EDMX version, e.g. "4.0"
#'  * `complex_types`
#'  * `entity_types`
#'  * `containers`
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-odata-endpoints/#id2}
#' @seealso \url{https://docs.oasis-open.org/odata/odata-csdl-xml/v4.01/odata-csdl-xml-v4.01.html}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' ds <- entitylist_list(pid = get_default_pid())
#'
#' dm1 <- odata_entitylist_metadata_get(pid = get_default_pid(), did = ds$name[1])
#'
#' # Overview
#' print(dm1)
#'
#' # Get all property names for an entity type
#' names(dm1$entity_types$Entities$properties)
#'
#' # Check what properties are non-filterable
#' dm1$containers$trees$entity_sets$Entities$capabilities
#'
#' # Get complex type definitions
#' dm1$complex_types$metadata$properties
#' }
odata_entitylist_metadata_get <- function(pid = get_default_pid(),
                                          did = "",
                                          url = get_default_url(),
                                          un = get_default_un(),
                                          pw = get_default_pw(),
                                          retries = get_retries(),
                                          odkc_version = get_default_odkc_version(),
                                          orders = get_default_orders(),
                                          tz = get_default_tz()) {
  yell_if_missing(url, un, pw, pid = pid, did = did)

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("odata_entitylist_service_get is supported from v2022.3")
  }

  doc <- httr::RETRY(
    "GET",
    httr::modify_url(url,
      path = glue::glue(
        "v1/projects/{pid}/datasets/",
        "{URLencode(did, reserved = TRUE)}.svc/$metadata"
      )
    ),
    httr::add_headers(
      "Accept" = "application/xml"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")

  # Convert EDMX XML Document to structured R object

  # Define the namespaces explicitly
  ns <- c(
    edmx = "http://docs.oasis-open.org/odata/ns/edmx",
    edm = "http://docs.oasis-open.org/odata/ns/edm"
  )

  # Helper function to extract property information
  extract_properties <- function(type_node) {
    props <- xml2::xml_find_all(type_node, "./edm:Property", ns)
    property_list <- lapply(props, function(prop) {
      list(
        name = xml2::xml_attr(prop, "Name"),
        type = xml2::xml_attr(prop, "Type")
      )
    })
    names(property_list) <- sapply(property_list, `[[`, "name")
    property_list
  }

  # Extract complex types
  complex_types <- xml2::xml_find_all(doc, "//edm:ComplexType", ns)
  complex_types_list <- lapply(complex_types, function(type) {
    list(
      name = xml2::xml_attr(type, "Name"),
      properties = extract_properties(type)
    )
  })
  names(complex_types_list) <- sapply(complex_types_list, `[[`, "name")

  # Extract entity types
  entity_types <- xml2::xml_find_all(doc, "//edm:EntityType", ns)
  entity_types_list <- lapply(entity_types, function(type) {
    # Extract key properties
    keys <- xml2::xml_find_all(type, ".//edm:PropertyRef", ns)
    key_names <- sapply(keys, xml2::xml_attr, "Name")

    list(
      name = xml2::xml_attr(type, "Name"),
      keys = key_names,
      properties = extract_properties(type)
    )
  })
  names(entity_types_list) <- sapply(entity_types_list, `[[`, "name")

  # Extract entity container information
  containers <- xml2::xml_find_all(doc, "//edm:EntityContainer", ns)
  container_list <- lapply(containers, function(container) {
    entity_sets <- xml2::xml_find_all(container, "./edm:EntitySet", ns)
    sets_list <- lapply(entity_sets, function(set) {
      # Extract capabilities from annotations
      annotations <- xml2::xml_find_all(set, "./edm:Annotation", ns)
      capabilities <- lapply(annotations, function(anno) {
        term <- xml2::xml_attr(anno, "Term")
        if (grepl("ConformanceLevel$", term)) {
          list(
            capability = "conformance_level",
            value = xml2::xml_attr(anno, "EnumMember")
          )
        } else if (grepl("BatchSupported$", term)) {
          list(
            capability = "batch_supported",
            value = as.logical(xml2::xml_attr(anno, "Bool"))
          )
        } else if (grepl("FilterRestrictions$", term)) {
          # Extract non-filterable properties
          non_filterable <- xml2::xml_find_all(anno, ".//edm:PropertyPath", ns)
          if (length(non_filterable) > 0) {
            list(
              capability = "filter_restrictions",
              non_filterable_properties = xml2::xml_text(non_filterable)
            )
          } else {
            NULL
          }
        } else {
          NULL
        }
      })
      capabilities <- Filter(Negate(is.null), capabilities)

      list(
        name = xml2::xml_attr(set, "Name"),
        type = xml2::xml_attr(set, "EntityType"),
        capabilities = capabilities
      )
    })
    names(sets_list) <- sapply(sets_list, `[[`, "name")

    list(
      name = xml2::xml_attr(container, "Name"),
      entity_sets = sets_list
    )
  })
  names(container_list) <- sapply(container_list, `[[`, "name")

  # Get the root Edmx node to extract version
  edmx_root <- xml2::xml_find_first(doc, "//edmx:Edmx", ns)
  version <- xml2::xml_attr(edmx_root, "Version")

  # Create the final structure
  structure(list(
    version = version,
    complex_types = complex_types_list,
    entity_types = entity_types_list,
    containers = container_list
  ), class = c("odata_entitylist_metadata_get", "list"))
}

#' @export
print.odata_entitylist_metadata_get <- function(x, ...) {
  cat("<ruODK OData EntityList Metadata>", sep = "\n")
  cat("  Complex Types:  ")
  print(names(x$complex_types))
  cat("  Entity Types:  ")
  print(names(x$entity_types))
  cat("  Containers:  ")
  print(names(x$containers))
}


# usethis::use_test("odata_entitylist_metadata_get") # nolint
