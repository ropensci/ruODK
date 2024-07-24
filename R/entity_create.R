#' Creates exactly one Entity in the Dataset.
#'
#' `r lifecycle::badge("experimental")`
#'
#' ### Creating a single Entity
#'
#' For creating a single Entity, include
#'
#' - An optional `uuid`. If skipped, Central will create a UUID for the Entity.
#' - The Entity `label` must be non-empty.
#' - A named list `data` representing the Entity's fields. The value type of
#'   all properties is string.
#'
#' `uuid = "..."`
#' `label = "John Doe"`
#' `data = list("firstName" = "John", "age" = "22")`
#'
#' This translates to JSON
#'
#' `{ "label": "John Doe", "data": { "firstName": "John", "age": "22" } }`
#'
#' ### Creating multiple Entities
#'
#' For creating multiple Entities in bulk, the request body takes an array
#' entities containing a list of Entity objects as described above.
#' The bulk entity version also takes a source property with a required name
#' field and optional size, for example to capture the file name and size of a
#' bulk upload source (in MB).
#'
#' ```
#' data=list(
#'     "entities" = c(
#'       list("label" = "Entity 1", "data" = list("field1" = "value1")),
#'       list("label" = "Entity 2", "data" = list("field1" = "value2"))
#'     ),
#'     "source" = list("name" = "file.csv", "size" = 100)
#'   )
#' ```
#'
#' This translates to JSON
#'
#' `{ "entities": [...], "source": {"name": "file.csv", "size": 100} }`
#'
#'
#' You can provide `notes` to store the metadata about the request.
#' The metadata is included in the POST request as header `X-Action-Notes` and
#' can retrieved using Entity Audit Log.
#'
#'
#' @template tpl-structure-nested
#' @template tpl-names-cleaned-top-level
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @param label (character) The Entity label which must be a non-empty string.
#'   If the label is given, a single entity is created using `data`, `notes`,
#'   and `uuid` if given.
#'   If the label is kept at the default (or omitted), multiple entities are
#'   created using `data` and `notes` and ignoring `uuid`.
#'   Default: `""`.
#' @param uuid (character) A single UUID to assign to the entity.
#'   Default: `""`. With the default, Central will create and assign a UUID.
#'   This parameter is only used when creating a single entity (`label`
#'   non-empty) and ignored when creating multiple entities (`label` empty).
#' @param notes (character) Metadata about the request which can be retrieved
#'   using the entity audit log.
#'   Default: `""`.
#' @param data (list) A named list of Entity properties to create a single
#'    Entity, or a nested list with an array of Entity data to create multiple
#'    Entities. The nested lists representing individual entities must be valid
#'    as in they must contain a label, valid data for the respective entity
#'    properties, and can contain an optional UUID.
#'    See details and the ODK documentation for the exact format.
#'    Default: `list()`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A nested list identical to the return value of `entity_detail`.
#'   See <https://docs.getodk.org/central-api-entity-management/#creating-entities>
#'   for the full schema.
#'   Top level list elements are renamed from ODK's `camelCase` to `snake_case`.
#'   Nested list elements have the original `camelCase`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-entity-management/#creating-entities}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' el <- entitylist_list()
#'
#' # Entity List name (dataset ID, did)
#' did <- el$name[1]
#'
#' # All Entities of Entity List
#' en <- entity_list(did = did)
#'
#' # Create a single entity
#' ec <- entity_create(
#'   did = did,
#'   label = "Entity label",
#'   notes = "Metadata about the created entity",
#'   data = list("field1" = "value1", "field2" = "value1")
#' )
#' ec
#'
#' # Create multiple entities, example: test form "problems"
#' label <- c(
#'   glue::glue(
#'     "Entity {nrow(en) + 1} created by ruODK package test on {Sys.time()}"
#'   ),
#'   glue::glue(
#'     "Entity {nrow(en) + 2} created by ruODK package test on {Sys.time()}"
#'   )
#' )
#' notes <- glue::glue("Two entities created by ruODK package test on {Sys.time()}")
#' status <- c("needs_followup", "needs_followup")
#' details <- c("ruODK package test", "ruODK package test")
#' geometry <- c("-33.2 115.0 0.0 0.0", "-33.2 115.0 0.0 0.0")
#' data <- data.frame(status, details, geometry, stringsAsFactors = FALSE)
#' request_data <- list(
#'   "entities" = data.frame(label, data = I(data), stringsAsFactors = FALSE),
#'   "source" = list("name" = "file.csv", "size" = 100)
#' )
#'
#' # Compare request_data to the schema expected by Central
#' # https://docs.getodk.org/central-api-entity-management/#creating-entities
#' # jsonlite::toJSON(request_data, pretty = TRUE, auto_unbox = TRUE)
#'
#' ec <- entity_create(
#'   did = did,
#'   notes = notes,
#'   data = request_data
#' )
#' }
entity_create <- function(pid = get_default_pid(),
                          did = "",
                          label = "",
                          uuid = "",
                          notes = "",
                          data = list(),
                          url = get_default_url(),
                          un = get_default_un(),
                          pw = get_default_pw(),
                          retries = get_retries(),
                          odkc_version = get_default_odkc_version(),
                          orders = c(
                            "YmdHMS",
                            "YmdHMSz",
                            "Ymd HMS",
                            "Ymd HMSz",
                            "Ymd",
                            "ymd"
                          ),
                          tz = get_default_tz()) {
  yell_if_missing(url, un, pw, pid = pid, did = did)

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entity_create is supported from v2022.3")
  }

  # Triage whether data is single or multiple entity
  body <- list()

  if (label == "") {
    ru_msg_info("Empty label: creating multiple entities.")

    # Gate check: data must have key "entities"
    if (!("entities" %in% names(data))) {
      ru_msg_abort("Malformed argument 'data': Must include 'entities'.")
    }

    body <- data
  } else {
    ru_msg_info("Non-empty label: creating single entity.")
    # If uuid is not NULL, include in body
    if (uuid != "") {
      body <- list("uuid" = uuid, "label" = label, "data" = data)
    } else {
      body <- list("label" = label, "data" = data)
    }
  }

  pth <- glue::glue(
    "v1/projects/{pid}/datasets/{URLencode(did, reserved = TRUE)}/",
    "entities/"
  )

  httr::RETRY(
    "POST",
    httr::modify_url(url, path = pth),
    httr::add_headers("Accept" = "application/json", "X-Action-Notes" = notes),
    encode = "json",
    body = body,
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("entity_create")  # nolint
