# Manage Tags ------------------------------------------

# TODO: this definitely needs some cleanup... there are several disparate data structures:
# 1 - the raw "table" of JSON data returned from the public API
# 2 - the "tag-tree" of JSON data returned from the "old" / private API
# 3 - the output of `tag_tree()` that is optimized for usage by R
# 4 - the output of `connect_tag_tree()`, which has the same data structure, but has classes associated

# TODO: we should see if we can cut out 2 and 3 as intermediate states that exist...
# - see if (2) can be skipped now by refactoring...
# - see if (3) can be lumped into (4)?

#' Get all Tags on the server
#'
#' Tag manipulation and assignment functions
#'
#' @param src The source object
#' @param name The name of the tag to create
#' @param parent optional. A `connect_tag_tree` object (as returned by `get_tags()`) pointed at the parent tag
#' @param content An R6 Content object, as returned by `content_item()`
#' @param tag A `connect_tag_tree` object (as returned by `get_tags()`)
#' @param tags A `connect_tag_tree` object (as returned by `get_tags()`)
#' @param ids A list of `id`s to filter the tag tree by
#' @param pattern A regex to filter the tag tree by (it is passed to `grepl`)
#' @param ... Additional arguments
#'
#' Manage tags (requires Administrator role):
#' - `get_tags()` - returns a "tag tree" object that can be traversed with `tag_tree$tag1$childtag`
#' - `get_tag_data()` - returns a tibble of tag data
#' - `create_tag()` - create a tag by specifying the Parent directly
#' - `create_tag_tree()` - create tag(s) by specifying the "desired" tag tree
#' hierarchy
#' - `delete_tag()` - delete a tag (and its children). WARNING: will
#' disassociate any content automatically
#'
#' Manage content tags:
#' - `get_content_tags()` - return a `connect_tag_tree` object corresponding to
#' the tags for a piece of content.
#' - `set_content_tag_tree()` - attach a tag to content by specifying the
#' desired tag tree
#' - `set_content_tags()` - Set multiple tags at once by providing
#' `connect_tag_tree` objects
#'
#' Search a tag tree:
#' - `filter_tag_tree_chr()` - filters a tag tree based on a regex
#' - `filter_tag_tree_id()` - filters a tag tree based on an id
#'
#' @export
#' @rdname tags
get_tags <- function(src) {
  validate_R6_class(src, "Connect")

  connect_tag_tree(tag_tree(src$get_tag_tree()), NULL)
}

#' @export
#' @rdname tags
get_tag_data <- function(src) {
  validate_R6_class(src, "Connect")

  res <- src$get_tag_tree()

  tag_tbl <- parse_tags_tbl(res)

  return(tag_tbl)
}

# TODO: this is hard to "use" directly because what it returns is not a tag... maybe create a Tag R6 class?
#' @export
#' @rdname tags
create_tag <- function(src, name, parent = NULL) {
  validate_R6_class(src, "Connect")
  if (is.null(parent) || is.numeric(parent)) {
    parent_id <- parent
  } else if (inherits(parent, "connect_tag_tree")) {
    if (is.null(parent[["id"]])) {
      stop("must specify a `parent` tag, and not the entire tag tree")
    }
    parent_id <- parent[["id"]]
  } else {
    stop("`parent` must be an ID or a connect_tag_tree object")
  }
  res <- src$tag_create(name = name, parent_id = parent_id)
  print(filter_tag_tree_id(get_tags(src), res))
  cat("\n")
  return(src)
}

# TODO: try without quotes...
#' @export
#' @rdname tags
create_tag_tree <- function(src, ...) {
  validate_R6_class(src, "Connect")

  params <- rlang::list2(...)

  results <- purrr::reduce(
    params,
    function(.parent, .x, con) {
      res <- con$tag_create_safe(.x, .parent)
      return(res[["id"]])
    },
    con = src,
    .init = NULL
  )
  print(filter_tag_tree_id(get_tags(src), results))
  cat("\n")
  return(src)
}

#' @export
#' @rdname tags
delete_tag <- function(src, tag) {
  if (is.numeric(tag)) {
    tag_id <- tag
  } else if (inherits(tag, "connect_tag_tree")) {
    if (is.null(tag[["id"]])) {
      stop(
        "`tag` must reference some tag specifically, and not the entire tag tree"
      )
    }
    tag_id <- tag[["id"]]
  } else {
    stop("`tag` must be an ID or a connect_tag_tree object")
  }
  src$tag_delete(id = tag_id)
  return(src)
}

# connect_tag_tree S3 object --------------------------------------------

# TODO: Need to find a way to denote categories...?
# error  : chr "Cannot assign a category to an app"
# TODO: Need to protect against a bad data structure...
# TODO: possible that you could decouple this from a connect server and get strange results
#       (i.e. build a tag tree from server A, use it to "set_content_tags" for server B - ids would not match)
connect_tag_tree <- function(tag_data, filter = "filtered") {
  structure(tag_data, class = c("connect_tag_tree", "list"), filter = filter)
}

#' @export
print.connect_tag_tree <- function(x, ...) {
  if (!is.null(attr(x, "filter"))) {
    cat(glue::glue("Posit Connect Tag Tree ({attr(x, 'filter')})"))
    cat("\n")
  } else {
    cat("Posit Connect Tag Tree\n")
  }
  if (length(x) > 0) {
    recursive_tag_print(x, "")
  } else {
    cat("  < No tags >\n")
  }
}

#' @export
`$.connect_tag_tree` <- function(x, y) {
  res <- NextMethod("$")
  if (is.list(res)) {
    connect_tag_tree(res)
  } else {
    res
  }
}

#' @export
`[[.connect_tag_tree` <- function(x, ...) {
  res <- NextMethod("[[")
  if (is.list(res)) {
    connect_tag_tree(res)
  } else {
    res
  }
}

#' @export
`[.connect_tag_tree` <- function(x, i, j) {
  res <- NextMethod("[")
  warn_once(
    "`[` drops the `connect_tag_tree` class. Use `$` or `[[` instead",
    id = "[.connect_tag_tree"
  )
  res
}

# Content Tags ----------------------------------------------------

#' @export
#' @rdname tags
get_content_tags <- function(content) {
  validate_R6_class(content, "Content")
  ctags <- content$tags()
  # TODO: find a way to build a tag tree from a list of tags

  tagtree <- get_tags(content$get_connect())
  res <- filter_tag_tree_id(
    tagtree,
    purrr::map_chr(ctags, ~ as.character(.x$id))
  )
  attr(res, "filter") <- "content"
  res
}

#' @export
#' @rdname tags
set_content_tag_tree <- function(content, ...) {
  validate_R6_class(content, "Content")

  params <- rlang::list2(...)
  if (length(params) == 1) {
    stop(
      "cannot assign a category to an app. Please specify an additional tag level"
    )
  }

  tags <- get_tags(content$get_connect())

  # check that tags exist
  tmp <- purrr::pluck(tags, !!!params)
  if (!is.null(tmp[["id"]])) {
    # only use the "bottom most" ID to tag
    content$tag_set(tmp[["id"]])
  } else {
    stop("the tag tree specified was not found")
  }
  print(get_content_tags(content))
  cat("\n")
  return(content)
}

#' @export
#' @rdname tags
set_content_tags <- function(content, ...) {
  validate_R6_class(content, "Content")
  new_tags <- rlang::list2(...)
  purrr::map(
    new_tags,
    function(.x) {
      content$tag_set(.get_tag_id(.x))
    }
  )
  print(get_content_tags(content))
  cat("\n")
  content
}

.get_tag_id <- function(.x) {
  if (inherits(.x, "connect_tag_tree") && !"id" %in% names(.x)) {
    print(.x)
    stop("this tag does not have an 'id'. Is it a tag list?")
  }
  if (inherits(.x, "connect_tag_tree")) {
    return(.x[["id"]])
  } else {
    return(.x)
  }
}

set_content_tags_remove <- function() {
  # TODO
}

set_content_tag_tree_remove <- function() {
  # TODO
}

# Filter ----------------------------------------------------

#' @export
#' @rdname tags
filter_tag_tree_id <- function(tags, ids) {
  stopifnot(inherits(tags, "connect_tag_tree"))
  flt <- recursive_filter_id(tags = tags, ids = ids)
  if (!is.null(flt)) {
    flt
  } else {
    connect_tag_tree(list())
  }
}

#' @export
#' @rdname tags
filter_tag_tree_chr <- function(tags, pattern) {
  stopifnot(inherits(tags, "connect_tag_tree"))

  flt <- recursive_filter_chr(tags = tags, pattern = pattern)
  if (!is.null(flt)) {
    flt
  } else {
    connect_tag_tree(list())
  }
}

# Tree Structure Creation ----------------------------------

# input is the output of `get_tag_data()` or `con$tag()`
tag_tree_from_data <- function(tag_data) {
  parsed <- tag_tree_parse_data(tag_data)

  connect_tag_tree(tag_tree(parsed))
}

tag_tree_parse_data <- function(tag_data) {
  if (tibble::is_tibble(tag_data)) {
    tag_data <- purrr::transpose(tag_data)
  }
  base_categories <- purrr::keep(
    tag_data,
    ~ is.null(.x[["parent_id"]]) || is.na(.x[["parent_id"]])
  )

  output <- purrr::map(
    base_categories,
    tag_tree_parse_data_impl,
    tag_data = tag_data
  )

  return(output)
}

tag_tree_parse_data_impl <- function(target, tag_data) {
  filtered_data <- purrr::keep(
    tag_data,
    ~ !is.null(.x[["parent_id"]]) &&
      !is.na(.x[["parent_id"]]) &&
      .x[["parent_id"]] == target[["id"]]
  )

  # recurse through the tree
  output <- purrr::map(
    filtered_data,
    tag_tree_parse_data_impl,
    tag_data = tag_data
  )

  # what we get back needs to become "children"
  target[["children"]] <- output

  return(target)
}

# Utils ----------------------------------------------------

recursive_filter_id <- function(tags, ids) {
  tags_noname <- tags
  tags_noname$name <- NULL
  tags_noname$id <- NULL
  recurse_res <- purrr::map(tags_noname, ~ recursive_filter_id(.x, ids))
  rr_nonull <- purrr::keep(recurse_res, ~ !is.null(.x))
  if ((!is.null(tags$id) && tags$id %in% ids) || length(rr_nonull) > 0) {
    if (!is.null(tags[["name"]])) {
      name_add <- list(name = tags$name, id = tags$id)
    } else {
      name_add <- list()
    }
    connect_tag_tree(c(name_add, rr_nonull))
  } else {
    NULL
  }
}

recursive_filter_chr <- function(tags, pattern) {
  tags_noname <- tags
  tags_noname$name <- NULL
  tags_noname$id <- NULL
  recurse_res <- purrr::map(tags_noname, ~ recursive_filter_chr(.x, pattern))
  rr_nonull <- purrr::keep(recurse_res, ~ !is.null(.x))
  if (!is.null(tags[["name"]])) {
    name_match <- any(purrr::map_lgl(pattern, ~ grepl(.x, tags$name)))
  } else {
    name_match <- FALSE
  }
  if (name_match || length(rr_nonull) > 0) {
    if (!is.null(tags[["name"]])) {
      name_add <- list(name = tags$name, id = tags$id)
    } else {
      name_add <- list()
    }
    connect_tag_tree(c(name_add, rr_nonull))
  } else {
    NULL
  }
}

recursive_find_tag <- function(tags, tag, parent_id = NULL) {
  tags_noname <- tags
  tags_noname$name <- NULL
  tags_noname$id <- NULL
  recurse_res <- purrr::map_chr(
    tags_noname,
    ~ as.character(recursive_find_tag(.x, tag, parent_id))
  )
  recurse_res_any <- recurse_res[!is.na(recurse_res)]
  if (length(recurse_res_any) == 0) {
    recurse_res_any <- NA_real_
  }
  names(recurse_res_any) <- NULL

  if (!is.na(recurse_res_any)) {
    return(recurse_res_any)
  } else if (is.null(parent_id) && !is.null(tags$name) && tags$name == tag) {
    res <- tags$id
    names(res) <- NULL
    return(res)
  } else if (
    !is.null(parent_id) && tags$id == parent_id && tag %in% names(tags_noname)
  ) {
    res <- tags[[tag]]$id
    names(res) <- NULL
    return(res)
  } else {
    return(NA_real_)
  }
}


recursive_tag_print <- function(x, indent) {
  x_noname <- x
  x_noname$name <- NULL
  x_noname$id <- NULL
  ch <- box_chars()
  # print a "single level tag"
  if (length(x_noname) == 0 && nchar(indent) == 0) {
    if (!is.null(x$name)) {
      cat(indent, pc(ch$l, ch$h, ch$h, " "), x$name, "\n", sep = "")
    }
  } else if (nchar(indent) == 0) {
    if (!is.null(x$name)) {
      cat(x$name, "\n", sep = "")
    }
  }
  purrr::map2(
    x_noname,
    seq_along(x_noname),
    function(.y, .i, list_length) {
      if (.i == list_length) {
        cat(indent, pc(ch$l, ch$h, ch$h, " "), .y$name, "\n", sep = "")
        recursive_tag_print(.y, paste0(indent, "   "))
      } else {
        cat(indent, pc(ch$j, ch$h, ch$h, " "), .y$name, "\n", sep = "")
        recursive_tag_print(.y, paste0(indent, pc(ch$v, "   ")))
      }
    },
    list_length = length(x_noname)
  )
  invisible(x)
}

recursive_tag_restructure <- function(.x) {
  if (length(.x$children) > 0) {
    rlang::set_names(
      list(c(
        purrr::flatten(purrr::map(
          .x$children,
          recursive_tag_restructure
        )),
        id = as.character(.x$id),
        name = .x$name
      )),
      .x$name
    )
  } else {
    rlang::set_names(
      list(list(id = as.character(.x$id), name = .x$name)),
      .x$name
    )
  }
}

tag_tree <- function(.x) {
  purrr::flatten(purrr::map(.x, recursive_tag_restructure))
}

parse_tags_tbl <- function(x) {
  parsed_tags <- purrr::map_dfr(
    x,
    ~ {
      out <- tibble::tibble(
        id = as.character(.x$id),
        name = .x$name,
        created_time = .x$created_time,
        updated_time = .x$updated_time,
        parent_id = ifelse(is.null(.x$parent_id), NA_character_, .x$parent_id)
      )

      if (length(.x$children) > 0) {
        child <- parse_tags_tbl(.x$children)
        out <- rbind(out, child)
      }

      return(out)
    }
  )

  return(parsed_tags)
}


# HELPER FUNCTIONS FOR tag_tree FROM fs
pc <- function(...) {
  paste0(..., collapse = "")
}

is_latex_output <- function() {
  if (!("knitr" %in% loadedNamespaces())) {
    return(FALSE)
  }
  get("is_latex_output", asNamespace("knitr"))()
}

is_utf8_output <- function() {
  opt <- getOption("cli.unicode", NULL)
  if (!is.null(opt)) {
    isTRUE(opt)
  } else {
    l10n_info()$`UTF-8` && !is_latex_output()
  }
}

# These are derived from https://github.com/r-lib/cli/blob/e9acc82b0d20fa5c64dd529400b622c0338374ed/R/tree.R#L111
box_chars <- function() {
  if (is_utf8_output()) {
    list(
      "h" = "\u2500", # horizontal
      "v" = "\u2502", # vertical
      "l" = "\u2514",
      "j" = "\u251C"
    )
  } else {
    list(
      "h" = "-", # horizontal
      "v" = "|", # vertical
      "l" = "\\",
      "j" = "+"
    )
  }
}
