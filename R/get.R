

#' Get user information from the Posit Connect server
#'
#' @param src The source object
#' @param page_size the number of records to return per page (max 500)
#' @param prefix Filters users by prefix (username, first name, or last name).
#' The filter is case insensitive.
#' @param limit The max number of records to return
#'
#' @return
#' A tibble with the following columns:
#' \itemize{
#'   \item{\strong{email}}{The user's email}
#'   \item{\strong{username}}{The user's username}
#'   \item{\strong{first_name}}{The user's first name}
#'   \item{\strong{last_name}}{The user's last name}
#'   \item{\strong{user_role}}{The user's role. It may have a value of
#'   administrator, publisher or viewer.}
#'   \item{\strong{created_time}}{The timestamp (in RFC3339 format) when the
#'   user was created in the Posit Connect server}
#'   \item{\strong{updated_time}}{The timestamp (in RFC3339 format) when the
#'   user was last updated in the Posit Connect server}
#'   \item{\strong{active_time}}{The timestamp (in RFC3339 format) when the
#'   user was last active on the Posit Connect server}
#'   \item{\strong{confirmed}}{When false, the created user must confirm their
#'   account through an email. This feature is unique to password
#'   authentication.}
#'   \item{\strong{locked}}{Whether or not the user is locked}
#'   \item{\strong{guid}}{The user's GUID, or unique identifier, in UUID RFC4122 format}
#' }
#'
#' @details
#' Please see https://docs.posit.co/connect/api/#getUsers for more information
#'
#' @examples
#' \dontrun{
#' library(connectapi)
#' client <- connect()
#'
#' # get all users
#' get_users(client, limit = Inf)
#' }
#'
#' @export
get_users <- function(src, page_size = 20, prefix = NULL, limit = 25) {
  validate_R6_class(src, "Connect")

  res <- page_offset(
    src,
    src$users(page_size = page_size, prefix = prefix),
    limit = limit
  )

  out <- parse_connectapi_typed(res, !!!connectapi_ptypes$users)

  return(out)
}

#' Get group information from the Posit Connect server
#'
#' @param src The source object
#' @param page_size the number of records to return per page (max 500)
#' @param prefix Filters groups by prefix (group name).
#' The filter is case insensitive.
#' @param limit The max number of groups to return
#'
#' @return
#' A tibble with the following columns:
#' \itemize{
#'   \item{\strong{guid}}{The unique identifier of the group}
#'   \item{\strong{name}}{The group name}
#'   \item{\strong{owner_guid}}{The group owner's unique identifier.
#'   When using LDAP, or Proxied authentication with group provisioning
#'   enabled this property will always be null.}
#' }
#'
#' @details
#' Please see https://docs.posit.co/connect/api/#getGroups for more information
#'
#' @examples
#' \dontrun{
#' library(connectapi)
#' client <- connect()
#'
#' # get all groups
#' get_groups(client, limit = Inf)
#' }
#'
#' @export
get_groups <- function(src, page_size = 20, prefix = NULL, limit = 25) {
  validate_R6_class(src, "Connect")

  res <- page_offset(src, src$groups(page_size = page_size, prefix = prefix), limit = limit)

  out <- parse_connectapi_typed(res, !!!connectapi_ptypes$groups)

  return(out)
}

#' Get users within a specific group
#'
#' @param src The source object
#' @param guid A group GUID identifier
#'
#' @return
#' A tibble with the following columns:
#' \itemize{
#'   \item{\strong{email}}{The user's email}
#'   \item{\strong{username}}{The user's username}
#'   \item{\strong{first_name}}{The user's first name}
#'   \item{\strong{last_name}}{The user's last name}
#'   \item{\strong{user_role}}{The user's role. It may have a value of
#'   administrator, publisher or viewer.}
#'   \item{\strong{created_time}}{The timestamp (in RFC3339 format) when the
#'   user was created in the Posit Connect server}
#'   \item{\strong{updated_time}}{The timestamp (in RFC3339 format) when the
#'   user was last updated in the Posit Connect server}
#'   \item{\strong{active_time}}{The timestamp (in RFC3339 format) when the
#'   user was last active on the Posit Connect server}
#'   \item{\strong{confirmed}}{When false, the created user must confirm their
#'   account through an email. This feature is unique to password
#'   authentication.}
#'   \item{\strong{locked}}{Whether or not the user is locked}
#'   \item{\strong{guid}}{The user's GUID, or unique identifier, in UUID RFC4122 format}
#' }
#'
#' @details
#' Please see https://docs.posit.co/connect/api/#getGroupMembers for more information
#'
#' @examples
#' \dontrun{
#' library(connectapi)
#' client <- connect()
#'
#' # get the first 20 groups
#' groups <- get_groups(client)
#'
#' group_guid <- groups$guid[1]
#'
#' get_group_members(client, guid = group_guid)
#' }
#'
#' @export
get_group_members <- function(src, guid) {
  validate_R6_class(src, "Connect")

  res <- src$group_members(guid)

  out <- parse_connectapi(res$results)

  return(out)
}

#' Get information about content on the Posit Connect server
#'
#' @param src A Connect object
#' @param guid The guid for a particular content item
#' @param owner_guid The unique identifier of the user who owns the content
#' @param name The content name specified when the content was created
#' @param ... Extra arguments. Currently not used
#' @param .p Optional. A predicate function, passed as-is to `purrr::keep()` before turning the response into a tibble. Can be useful for performance
#'
#' @return
#' A tibble with the following columns:
#' \itemize{
#'    \item{\strong{guid}}{The unique identifier of this content item.}
#'    \item{\strong{name}}{A simple, URL-friendly identifier. Allows
#'    alpha-numeric characters, hyphens ("-"), and underscores ("_").}
#'    \item{\strong{title}}{The title of this content.}
#'    \item{\strong{description}}{A rich description of this content}
#'    \item{\strong{access_type}}{Access type describes how this content manages
#'    its viewers. The value all is the most permissive; any visitor to Posit
#'    Connect will be able to view this content. The value logged_in indicates
#'    that all Posit Connect accounts may view the content. The acl value
#'    lets specifically enumerated users and groups view the content. Users
#'    configured as collaborators may always view content. It may have a
#'    value of all, logged_in or acl.}
#'    \item{\strong{connection_timeout}}{Maximum number of seconds allowed
#'    without data sent or received across a client connection. A value of 0
#'    means connections will never time-out (not recommended). When null, the
#'    default Scheduler.ConnectionTimeout is used. Applies only to content
#'    types that are executed on demand.}
#'    \item{\strong{read_timeout}}{Maximum number of seconds allowed without
#'    data received from a client connection. A value of 0 means a lack of client
#'    (browser) interaction never causes the connection to close. When null,
#'    the default Scheduler.ReadTimeout is used. Applies only to content types
#'    that are executed on demand.}
#'    \item{\strong{init_timeout}}{The maximum number of seconds allowed for an
#'    interactive application to start. Posit Connect must be able to connect
#'    to a newly launched Shiny application, for example, before this threshold
#'    has elapsed. When null, the default Scheduler.InitTimeout is used. Applies
#'    only to content types that are executed on demand.}
#'    \item{\strong{idle_timeout}}{The maximum number of seconds a worker process
#'    for an interactive application to remain alive after it goes idle (no
#'    active connections). When null, the default Scheduler.IdleTimeout is used.
#'    Applies only to content types that are executed on demand.}
#'    \item{\strong{max_processes}}{Specifies the total number of concurrent
#'    processes allowed for a single interactive application. When null, the
#'    default Scheduler.MaxProcesses is used. Applies only to content types
#'    that are executed on demand.}
#'    \item{\strong{min_processes}}{Specifies the minimum number of concurrent
#'    processes allowed for a single interactive application. When null, the
#'    default Scheduler.MinProcesses is used. Applies only to content types
#'    that are executed on demand.}
#'    \item{\strong{max_conns_per_process}}{Specifies the maximum number of
#'    client connections allowed to an individual process. Incoming connections
#'    which will exceed this limit are routed to a new process or rejected.
#'    When null, the default Scheduler.MaxConnsPerProcess is used. Applies
#'    only to content types that are executed on demand.}
#'    \item{\strong{load_factor}}{Controls how aggressively new processes are spawned.
#'    When null, the default Scheduler.LoadFactor is used. Applies only to
#'    content types that are executed on demand.}
#'    \item{\strong{created_time}}{The timestamp (RFC3339) indicating when this
#'    content was created.}
#'    \item{\strong{last_deployed_time}}{The timestamp (RFC3339) indicating when
#'    this content last had a successful bundle deployment performed.}
#'    \item{\strong{bundle_id}}{The identifier for the active deployment bundle.
#'    Automatically assigned upon the successful deployment of that bundle.}
#'    \item{\strong{app_mode}}{The runtime model for this content. Has a value
#'    of unknown before data is deployed to this item. Automatically assigned
#'    upon the first successful bundle deployment. Allowed: api, jupyter-static,
#'    python-api, python-bokeh, python-dash, python-streamlit, rmd-shiny,
#'    rmd-static, shiny, static, tensorflow-saved-model, unknown}
#'    \item{\strong{content_category}}{Describes the specialization of the content
#'    runtime model. Automatically assigned upon the first successful bundle
#'    deployment.}
#'    \item{\strong{parameterized}}{True when R Markdown rendered content
#'    allows parameter configuration. Automatically assigned upon the first
#'    successful bundle deployment. Applies only to content with an app_mode
#'    of rmd-static.}
#'    \item{\strong{r_version}}{The version of the R interpreter associated
#'    with this content. The value null represents that an R interpreter is
#'    not used by this content or that the R package environment has not been
#'    successfully restored. Automatically assigned upon the successful
#'    deployment of a bundle.}
#'    \item{\strong{py_version}}{The version of the Python interpreter
#'    associated with this content. The value null represents that a Python
#'    interpreter is not used by this content or that the Python package
#'    environment has not been successfully restored. Automatically assigned
#'    upon the successful deployment of a bundle.}
#'    \item{\strong{run_as}}{The UNIX user that executes this content.
#'    When null, the default Applications.RunAs is used. Applies
#'    only to executable content types - not static.}
#'    \item{\strong{run_as_current_user}}{Indicates if this content is allowed
#'    to execute as the logged-in user when using PAM authentication.
#'    Applies only to executable content types - not static.}
#'    \item{\strong{owner_guid}}{The unique identifier for the owner}
#'    \item{\strong{content_url}}{The URL associated with this content. Computed
#'    from the associated vanity URL or GUID for this content.}
#'    \item{\strong{dashboard_url}}{The URL within the Connect dashboard where
#'    this content can be configured. Computed from the GUID for this content.}
#'    \item{\strong{role}}{The relationship of the accessing user to this
#'    content. A value of owner is returned for the content owner. editor
#'    indicates a collaborator. The viewer value is given to users who are
#'    permitted to view the content. A none role is returned for
#'    administrators who cannot view the content but are permitted to view
#'    its configuration. Computed at the time of the request.}
#'    \item{\strong{id}}{The internal numeric identifier of this content item}
#'  }
#'
#' @details
#' Please see https://docs.posit.co/connect/api/#get-/v1/content for more information
#'
#' @examples
#' \dontrun{
#' library(connectapi)
#' client <- connect()
#'
#' get_content(client)
#' }
#'
#' @export
get_content <- function(src, guid = NULL, owner_guid = NULL, name = NULL, ..., .p = NULL) {
  validate_R6_class(src, "Connect")

  res <- src$content(guid = guid, owner_guid = owner_guid, name = name)

  if (!is.null(guid)) {
    # convert a single item to a list
    res <- list(res)
  }

  if (!is.null(.p)) {
    res <- res %>% purrr::keep(.p = .p)
  }

  out <- parse_connectapi_typed(res, !!!connectapi_ptypes$content)

  return(out)
}

.make_predicate <- function(.expr) {
  function(.x) {
    masked_expr <- rlang::enexpr(.expr)

  }
}

.get_content_permission_with_progress <- function(src, guid, .pb = NULL) {
  if (!is.null(.pb)) {
    if (!.pb$finished) .pb$tick()
  }
  get_content_permissions(content_item(src, guid))
}

#' Get Content List with Permissions
#'
#' \lifecycle{experimental} These functions are experimental placeholders until the API supports
#' this behavior.
#'
#' `content_list_with_permissions` loops through content and retrieves
#' permissions for each item (with a progress bar). This can take a long time
#' for lots of content! Make sure to use the optional `.p` argument as a predicate
#' function that filters the content list before it is transformed.
#'
#' `content_list_guid_has_access` works with a `content_list_with_permissions`
#' dataset by checking whether a given GUID (either user or group) has access to
#' the content by:
#' - checking if the content has access_type == "all"
#' - checking if the content has access_type == "logged_in"
#' - checking if the provided guid is the content owner
#' - checking if the provided guid is in the list of content permissions (in the "permissions" column)
#'
#' @param src A Connect R6 object
#' @param ... Extra arguments. Currently not used
#' @param .p Optional. A predicate function, passed as-is to `purrr::keep()`. See
#'   `get_content()` for more details. Can greatly help performance by reducing
#'   how many items to get permissions for
#' @param content_list A "content list with permissions" as returned by `content_list_with_permissions()`
#' @param guid A user or group GUID to filter the content list by whether they have access
#'
#' @rdname content_list_with_permissions
#'
#' @export
content_list_with_permissions <- function(src, ..., .p = NULL) {
  warn_experimental("content_list_with_permissions")

  message("Getting content list")
  content_list <- get_content(src, .p = .p)

  message("Getting permission list")
  pb <- progress::progress_bar$new(total = nrow(content_list), format="[:bar] :percent :eta")
  updated_list <- content_list %>% dplyr::mutate(
    permission = purrr::map(guid, function(.x) .get_content_permission_with_progress(src, .x, pb))
  )

  return(updated_list)
}

#' Content List
#'
#' \lifecycle{experimental} Get a content list
#'
#' `content_list_by_tag()` retrieves a content list by tag
#'
#' @param src An R6 Connect object
#' @param tag A `connect_tag_tree` object or tag ID
#'
#' @rdname content_list
#' @export
content_list_by_tag <- function(src, tag) {
  validate_R6_class(src, "Connect")
  tag_id <- .get_tag_id(tag)

  res <- src$GET(glue::glue("v1/tags/{tag_id}/content"))

  out <- parse_connectapi_typed(res, !!!connectapi_ptypes$content)
  return(out)
}

#' @rdname content_list_with_permissions
#' @export
content_list_guid_has_access <- function(content_list, guid) {
  warn_experimental("content_list_filter_by_guid")
  filtered <- content_list %>% dplyr::filter(
    access_type == "all" |
      access_type == "logged_in" |
      owner_guid == {{guid}} |
      purrr::map_lgl(permission, ~ {{guid}} %in% .x$principal_guid)
  )
  return(filtered)
}

#' Get information about content on the Posit Connect server
#'
#' @param src The source object
#' @param filter a named list of filter options, e.g. list(name = 'appname')
#' @param limit the maximum number of records to return
#' @param page_size the number of records to return per page
#'
#' @return
#' A tibble with the following columns:
#' \itemize{
#'   \item{\strong{id}}{The application ID}
#'   \item{\strong{guid}}{The unique identifier of this content item.}
#'   \item{\strong{access_type}}{Access type describes how this content manages
#'    its viewers. The value all is the most permissive; any visitor to Posit
#'    Connect will be able to view this content. The value logged_in indicates
#'    that all Posit Connect accounts may view the content. The acl value
#'    lets specifically enumerated users and groups view the content. Users
#'    configured as collaborators may always view content. It may have a
#'    value of all, logged_in or acl.}
#'    \item{\strong{connection_timeout}}{Maximum number of seconds allowed
#'    without data sent or received across a client connection. A value of 0
#'    means connections will never time-out (not recommended). When null, the
#'    default Scheduler.ConnectionTimeout is used. Applies only to content
#'    types that are executed on demand.}
#'    \item{\strong{read_timeout}}{Maximum number of seconds allowed without
#'    data received from a client connection. A value of 0 means a lack of client
#'    (browser) interaction never causes the connection to close. When null,
#'    the default Scheduler.ReadTimeout is used. Applies only to content types
#'    that are executed on demand.}
#'    \item{\strong{init_timeout}}{The maximum number of seconds allowed for an
#'    interactive application to start. Posit Connect must be able to connect
#'    to a newly launched Shiny application, for example, before this threshold
#'    has elapsed. When null, the default Scheduler.InitTimeout is used. Applies
#'    only to content types that are executed on demand.}
#'    \item{\strong{idle_timeout}}{The maximum number of seconds a worker process
#'    for an interactive application to remain alive after it goes idle (no
#'    active connections). When null, the default Scheduler.IdleTimeout is used.
#'    Applies only to content types that are executed on demand.}
#'    \item{\strong{max_processes}}{Specifies the total number of concurrent
#'    processes allowed for a single interactive application. When null, the
#'    default Scheduler.MaxProcesses is used. Applies only to content types
#'    that are executed on demand.}
#'    \item{\strong{min_processes}}{Specifies the minimum number of concurrent
#'    processes allowed for a single interactive application. When null, the
#'    default Scheduler.MinProcesses is used. Applies only to content types
#'    that are executed on demand.}
#'    \item{\strong{max_conns_per_process}}{Specifies the maximum number of
#'    client connections allowed to an individual process. Incoming connections
#'    which will exceed this limit are routed to a new process or rejected.
#'    When null, the default Scheduler.MaxConnsPerProcess is used. Applies
#'    only to content types that are executed on demand.}
#'    \item{\strong{load_factor}}{Controls how aggressively new processes are spawned.
#'    When null, the default Scheduler.LoadFactor is used. Applies only to
#'    content types that are executed on demand.}
#'    \item{\strong{url}}{The URL associated with this content. Computed from
#'    the associated vanity URL or the identifiers for this content.}
#'    \item{\strong{vanity_url}}{The vanity url assigned to this app by an
#'    administrator}
#'    \item{\strong{name}}{A simple, URL-friendly identifier. Allows
#'    alpha-numeric characters, hyphens ("-"), and underscores ("_").}
#'    \item{\strong{title}}{The title of this content.}
#'    \item{\strong{bundle_id}}{The identifier for the active deployment bundle.
#'    Automatically assigned upon the successful deployment of that bundle.}
#'    \item{\strong{app_mode}}{The runtime model for this content. Has a value
#'    of unknown before data is deployed to this item. Automatically assigned
#'    upon the first successful bundle deployment.}
#'    \item{\strong{content_category}}{Describes the specialization of the content
#'    runtime model. Automatically assigned upon the first successful bundle
#'    deployment.}
#'    \item{\strong{has_parameters}}{True when R Markdown rendered content
#'    allows parameter configuration. Automatically assigned upon the first
#'    successful bundle deployment. Applies only to content with an app_mode
#'    of rmd-static.}
#'    \item{\strong{created_time}}{The timestamp (RFC3339) indicating when this
#'    content was created.}
#'    \item{\strong{last_deployed_time}}{The timestamp (RFC3339) indicating when
#'    this content last had a successful bundle deployment performed.}
#'    \item{\strong{r_version}}{The version of the R interpreter associated
#'    with this content. The value null represents that an R interpreter is
#'    not used by this content or that the R package environment has not been
#'    successfully restored. Automatically assigned upon the successful
#'    deployment of a bundle.}
#'    \item{\strong{py_version}}{The version of the Python interpreter
#'    associated with this content. The value null represents that a Python
#'    interpreter is not used by this content or that the Python package
#'    environment has not been successfully restored. Automatically assigned
#'    upon the successful deployment of a bundle.}
#'    \item{\strong{build_status}}{}
#'    \item{\strong{run_as}}{The UNIX user that executes this content.
#'    When null, the default Applications.RunAs is used. Applies
#'    only to executable content types - not static.}
#'    \item{\strong{run_as_current_user}}{Indicates if this content is allowed
#'    to execute as the logged-in user when using PAM authentication.
#'    Applies only to executable content types - not static.}
#'    \item{\strong{description}}{A rich description of this content}
#'    \item{\strong{app_role}}{The relationship of the accessing user to this
#'    content. A value of owner is returned for the content owner. editor
#'    indicates a collaborator. The viewer value is given to users who are
#'    permitted to view the content. A none role is returned for
#'    administrators who cannot view the content but are permitted to view
#'    its configuration. Computed at the time of the request.}
#'    \item{\strong{owner_first_name}}{The first name of the owner of the
#'    content.}
#'    \item{\strong{owner_last_name}}{The last name of the owner of the
#'    content.}
#'    \item{\strong{owner_username}}{The username of the owner of the
#'    content.}
#'    \item{\strong{owner_guid}}{The unique identifier for the owner}
#'    \item{\strong{owner_email}}{The email of the content owner}
#'    \item{\strong{owner_locked}}{Is the owners user account locked?}
#'    \item{\strong{is_scheduled}}{Is this content scheduled?}
#'    \item{\strong{git}}{Is this content deployed via git or GitHub?}
#' }
#'
#' @details
#' Please see https://docs.posit.co/connect/api/#getContent for more information
#'
#' @examples
#' \dontrun{
#' library(connectapi)
#' client <- connect()
#'
#' get_content_old(client, limit = 20)
#' }
#'
#' @export
get_content_old <- function(src, filter = NULL, limit = 25, page_size = 25) {
  validate_R6_class(src, "Connect")

  lifecycle::deprecate_warn("0.1.0.9023", "get_content_old()", "get_content()", details = "The filter argument is deprecated and the structure of the response has changed with the public API")

  ## TODO Add more arguments that can build the filter function for users
  ## so that they know explicitly what arguments that can pass

  res <- src$get_apps(
    filter = filter,
    .limit = limit,
    page_size = page_size
  )

  out <- parse_connectapi_typed(res, !!!connectapi_ptypes$content_old)

  return(out)
}


#' Get usage information for deployed shiny applications
#'
#' @param src the source object
#' @param content_guid Filter results by content GUID
#' @param min_data_version Filter by data version. Records with a data version
#' lower than the given value will be excluded from the set of results.
#' @param from The timestamp that starts the time window of interest. Any usage
#' information that ends prior to this timestamp will not be returned.
#' Individual records may contain a starting time that is before this if they
#' end after it or have not finished. Must be of class Date or POSIX
#' @param to The timestamp that ends the time window of interest. Any usage
#' information that starts after this timestamp will not be returned.
#' Individual records may contain an ending time that is after this
#' (or no ending time) if they start before it. Must be of class Date or
#' POSIX
#' @param limit The number of records to return.
#' @param previous Retrieve the previous page of Shiny application usage
#' logs relative to the provided value. This value corresponds to an internal
#' reference within the server and should be sourced from the appropriate
#' attribute within the paging object of a previous response.
#' @param nxt Retrieve the next page of Shiny application usage logs
#' relative to the provided value. This value corresponds to an internal
#' reference within the server and should be sourced from the appropriate
#' attribute within the paging object of a previous response.
#' @param asc_order Defaults to TRUE; Determines if the response records
#' should be listed in ascending or descending order within the response.
#' Ordering is by the started timestamp field.
#'
#'
#' @return
#' A tibble with the following columns:
#' \itemize{
#'   \item{\strong{content_guid}}{The GUID, in RFC4122 format, of the
#'   Shiny application this information pertains to.}
#'   \item{\strong{user_guid}}{The GUID, in RFC4122 format, of the user
#'   that visited the application.}
#'   \item{\strong{started}}{The timestamp, in RFC3339 format, when the
#'   user opened the application.}
#'   \item{\strong{ended}}{The timestamp, in RFC3339 format, when the
#'   user left the application.}
#'   \item{\strong{data_version}}{The data version the record was recorded
#'   with. The Shiny Application Events section of the Posit Connect Admin
#'   Guide explains how to interpret data_version values.}
#' }
#'
#' @details
#' Please see https://docs.posit.co/connect/api/#getShinyAppUsage for more information
#'
#' @examples
#' \dontrun{
#' library(connectapi)
#' client <- connect()
#'
#' from <- Sys.Date() - lubridate::days(5)
#' get_usage_shiny(client, limit = 20, from = from)
#' }
#'
#' @export
get_usage_shiny <- function(src, content_guid = NULL,
                            min_data_version = NULL,
                            from = NULL,
                            to = NULL,
                            limit = 20,
                            previous = NULL,
                            nxt = NULL,
                            asc_order = TRUE) {
  validate_R6_class(src, "Connect")

  res <- src$inst_shiny_usage(
    content_guid = content_guid,
    min_data_version = min_data_version,
    from = from,
    to = to,
    limit = limit,
    previous = previous,
    nxt = nxt,
    asc_order = asc_order
  )

  res <- page_cursor(src, res, limit = limit)

  out <- parse_connectapi_typed(res, !!!connectapi_ptypes$usage_shiny)

  return(out)
}

#' Get usage information from deployed static content
#'
#' This function retrieves usage information from static content
#' on the Posit Connect server (e.g. Rmarkdown, Jupyter Notebooks)
#'
#' @param src the source object
#' @param content_guid Filter results by content GUID
#' @param min_data_version Filter by data version. Records with a data version
#' lower than the given value will be excluded from the set of results.
#' @param from The timestamp that starts the time window of interest. Any usage
#' information that ends prior to this timestamp will not be returned.
#' Individual records may contain a starting time that is before this if they
#' end after it or have not finished. Must be of class Date or POSIX
#' @param to The timestamp that ends the time window of interest. Any usage
#' information that starts after this timestamp will not be returned.
#' Individual records may contain an ending time that is after this
#' (or no ending time) if they start before it. Must be of class Date or
#' POSIX
#' @param limit The number of records to return.
#' @param previous Retrieve the previous page of Shiny application usage
#' logs relative to the provided value. This value corresponds to an internal
#' reference within the server and should be sourced from the appropriate
#' attribute within the paging object of a previous response.
#' @param nxt Retrieve the next page of Shiny application usage logs
#' relative to the provided value. This value corresponds to an internal
#' reference within the server and should be sourced from the appropriate
#' attribute within the paging object of a previous response.
#' @param asc_order Defaults to TRUE; Determines if the response records
#' should be listed in ascending or descending order within the response.
#' Ordering is by the started timestamp field.
#'
#'
#' @return
#' A tibble with the following columns:
#' \itemize{
#'   \item{\strong{content_guid}}{The GUID, in RFC4122 format, of the Shiny
#'   application this information pertains to.}
#'   \item{\strong{user_guid}}{The GUID, in RFC4122 format, of the user that
#'   visited the application.}
#'   \item{\strong{variant_key}}{The key of the variant the user visited.
#'   This will be null for static content.}
#'   \item{\strong{time}}{The timestamp, in RFC3339 format, when the user
#'   visited the content.}
#'   \item{\strong{rendering_id}}{The ID of the rendering the user visited.
#'   This will be null for static content.}
#'   \item{\strong{bundle_id}}{The ID of the particular bundle used.}
#'   \item{\strong{data_version}}{The data version the record was recorded
#'   with. The Rendered and Static Content Visit Events section of the
#'   Posit Connect Admin Guide explains how to interpret data_version
#'   values.}
#' }
#'
#'
#' @details
#' Please see https://docs.posit.co/connect/api/#getContentVisits for more
#' information
#'
#' @examples
#' \dontrun{
#' library(connectapi)
#' client <- connect()
#'
#' from <- Sys.Date() - lubridate::days(5)
#' get_usage_static(client, limit = 20, from = from)
#' }
#'
#' @export
get_usage_static <- function(src, content_guid = NULL,
                             min_data_version = NULL,
                             from = NULL,
                             to = NULL,
                             limit = 20,
                             previous = NULL,
                             nxt = NULL,
                             asc_order = TRUE) {
  validate_R6_class(src, "Connect")

  res <- src$inst_content_visits(
    content_guid = content_guid,
    min_data_version = min_data_version,
    from = from,
    to = to,
    limit = limit,
    previous = previous,
    nxt = nxt,
    asc_order = asc_order
  )

  res <- page_cursor(src, res, limit = limit)

  out <- parse_connectapi_typed(res, !!!connectapi_ptypes$usage_static)

  return(out)
}


#' Get Audit Logs from Posit Connect Server
#'
#' @param src The source object
#' @param limit The number of records to return.
#' @param previous Retrieve the previous page of Shiny application usage
#' logs relative to the provided value. This value corresponds to an internal
#' reference within the server and should be sourced from the appropriate
#' attribute within the paging object of a previous response.
#' @param nxt Retrieve the next page of Shiny application usage logs
#' relative to the provided value. This value corresponds to an internal
#' reference within the server and should be sourced from the appropriate
#' attribute within the paging object of a previous response.
#' @param asc_order Defaults to TRUE; Determines if the response records
#' should be listed in ascending or descending order within the response.
#' Ordering is by the started timestamp field.
#'
#' @return
#' A tibble with the following columns:
#' \itemize{
#'   \item{\strong{id}}{ID of the audit action}
#'   \item{\strong{time}}{Timestamp in RFC3339 format when action was taken}
#'   \item{\strong{user_id}}{User ID of the actor who made the audit action}
#'   \item{\strong{user_description}}{Description of the actor}
#'   \item{\strong{action}}{Audit action taken}
#'   \item{\strong{event_description}}{Description of action}
#' }
#'
#' @details
#' Please see https://docs.posit.co/connect/api/#getAuditLogs for more
#' information
#'
#' @examples
#' \dontrun{
#' library(connectapi)
#' client <- connect()
#'
#' # get the last 20 audit logs
#' get_audit_logs(client, limit = 20, asc_order = FALSE)
#' }
#'
#' @export
get_audit_logs <- function(src, limit = 20L, previous = NULL,
                           nxt = NULL, asc_order = TRUE) {
  validate_R6_class(src, "Connect")

  res <- src$audit_logs(
    limit = limit,
    previous = previous,
    nxt = nxt,
    asc_order = asc_order
  )

  res <- page_cursor(src, res, limit = limit)

  out <- parse_connectapi_typed(res, !!!connectapi_ptypes$audit_logs)

  return(out)
}

#' Get Real-Time Process Data
#'
#' \lifecycle{experimental}
#' This returns real-time process data from the Posit Connect API. It requires
#' administrator privileges to use. NOTE that this only returns data for the
#' server that responds to the request (i.e. in a Highly Available cluster)
#'
#' @param src The source object
#'
#' @return
#' A tibble with the following columns:
#' \itemize{
#'   \item{\strong{pid}}{The PID of the current process}
#'   \item{\strong{appId}}{The application ID}
#'   \item{\strong{appGuid}}{The application GUID}
#'   \item{\strong{appName}}{The application name}
#'   \item{\strong{appUrl}}{The application URL}
#'   \item{\strong{appRunAs}}{The application RunAs user}
#'   \item{\strong{type}}{The type of process}
#'   \item{\strong{cpuCurrent}}{The current CPU usage}
#'   \item{\strong{cpuTotal}}{The total CPU usage}
#'   \item{\strong{ram}}{The current RAM usage}
#' }
#'
#' @export
get_procs <- function(src) {
  validate_R6_class(src, "Connect")
  warn_experimental("get_procs")

  scoped_experimental_silence()
  raw_proc_data <- src$procs()

  proc_prep <- purrr::imap(
    raw_proc_data,
    function(x, y) {
      c(list(pid = y), x)
    }
  )
  tbl_data <- parse_connectapi_typed(proc_prep, !!!connectapi_ptypes$procs)

  return(tbl_data)
}
