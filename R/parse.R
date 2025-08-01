# because format(NULL, "%Y-%m") == "NULL"
safe_format <- function(expr, ...) {
  if (is.null(expr)) {
    return(NULL)
  } else {
    return(format(expr, ...))
  }
}

datetime_to_rfc3339 <- function(input) {
  tmp <- format(input, format = "%Y-%m-%dT%H:%M:%OS5%z")
  ln <- nchar(tmp)
  paste0(substr(tmp, 0, ln - 2), ":", substr(tmp, ln - 1, ln))
}

make_timestamp <- function(input) {
  if (is.character(input)) {
    # TODO: make sure this is the right timestamp format
    return(input)
  }

  # In the call to `safe_format`:
  # - The format specifier adds a literal "Z" to the end of the timestamp, which
  #   tells Connect "This is UTC".
  # - The `tz` argument tells R to produce times in the UTC time zone.
  # - The `usetz` argument says "Don't concatenate ' UTC' to the end of the string".
  safe_format(input, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC", usetz = FALSE)
}

ensure_columns <- function(.data, ptype, strict = FALSE) {
  # Given a prototype, ensure that all columns are present and cast to the correct type.
  # If a column is missing in .data, it will be created with all missing values of the correct type.
  # If a column is present in both, it will be cast to the correct type.
  # If a column is present in .data but not in ptype, it will be left as is.
  # If `strict == TRUE`, include only columns present in the ptype, in the order they occur.
  for (i in names(ptype)) {
    .data <- ensure_column(.data, ptype[[i]], i)
  }

  if (strict) {
    .data <- .data[, names(ptype), drop = FALSE]
  }

  .data
}

ensure_column <- function(data, default, name) {
  stopifnot(length(default) == 1)
  col <- data[[name]]
  scoped_experimental_silence()
  if (rlang::is_null(col)) {
    col <- vctrs::vec_rep(default, nrow(data))
    col <- vctrs::vec_cast(col, default)
  } else {
    if (
      vctrs::vec_is(default, NA_datetime_) && !vctrs::vec_is(col, NA_datetime_)
    ) {
      # manual fix because vctrs::vec_cast cannot cast double -> datetime or char -> datetime
      col <- coerce_datetime(col, default, name = name)
    }

    if (inherits(default, "fs_bytes") && !inherits(col, "fs_bytes")) {
      col <- coerce_fsbytes(col, default)
    }

    if (inherits(default, "integer64") && !inherits(col, "integer64")) {
      col <- bit64::as.integer64(col)
    }

    if (inherits(default, "list") && !inherits(col, "list")) {
      col <- list(col)
    }

    col <- vctrs::vec_cast(col, default, x_arg = name)
  }
  data[[name]] <- col
  data
}

parse_connectapi_typed <- function(data, ptype, strict = FALSE) {
  ensure_columns(parse_connectapi(data), ptype, strict)
}

parse_connectapi <- function(data) {
  tibble::as_tibble(purrr::map_df(
    data,
    function(x) {
      purrr::map(
        .x = x,
        .f = function(y) {
          if (is.list(y)) {
            # empty list object gets null
            prep <- purrr::pluck(y, .default = NULL)
          } else {
            # otherwise NA
            prep <- purrr::pluck(y, .default = NA)
          }
          if (length(prep) > 1) {
            prep <- list(prep)
          }
          return(prep)
        }
      )
    }
  ))
}


coerce_fsbytes <- function(x, to, ...) {
  if (is.numeric(x)) {
    fs::as_fs_bytes(x)
  } else {
    vctrs::stop_incompatible_cast(x = x, to = to, x_arg = "x", to_arg = "to")
  }
}

# name - optional. Must be named, the name of the variable / column being converted
coerce_datetime <- function(x, to, ...) {
  tmp_name <- rlang::dots_list(...)[["name"]]
  if (is.null(tmp_name) || is.na(tmp_name) || !is.character(tmp_name)) {
    tmp_name <- "x"
  }

  if (is.null(x)) {
    as.POSIXct(character(), tz = tzone(to))
  } else if (is.numeric(x)) {
    vctrs::new_datetime(as.double(x), tzone = tzone(to))
  } else if (is.character(x)) {
    parse_connect_rfc3339(x)
  } else if (inherits(x, "POSIXct")) {
    x
  } else if (
    all(is.logical(x) & is.na(x)) && length(is.logical(x) & is.na(x)) > 0
  ) {
    NA_datetime_
  } else {
    vctrs::stop_incompatible_cast(
      x = x,
      to = to,
      x_arg = tmp_name,
      to_arg = "to"
    )
  }
}

# nolint start: commented_code_linter
# Parses a character vector of dates received from Connect, using use RFC 3339,
# returning a vector of POSIXct datetimes.
#
# R parses character timestamps as ISO 8601. When specifying %z, it expects time
# zones to be specified as `-1400` to `+1400`.
#
# Connect's API sends times in a specific RFC 3339 format: indicating time zone
# offsets with `-14:00` to `+14:00`, and zero offset with `Z`.
# https://github.com/golang/go/blob/54fe0fd43fcf8609666c16ae6d15ed92873b1564/src/time/format.go#L86
# For example:
# - "2023-08-22T14:13:14Z"
# - "2023-08-22T15:13:14+01:00"
# - "2020-01-01T00:02:03-01:00"
# nolint end
parse_connect_rfc3339 <- function(x) {
  # Convert timestamps with offsets to a format recognized by `strptime`.
  x <- gsub("([+-]\\d\\d):(\\d\\d)$", "\\1\\2", x)
  x <- gsub("Z$", "+0000", x)

  # Parse with an inner call to `strptime()`, which returns a POSIXlt object,
  # and convert that to `POSIXct`.
  #
  # We must specify `tz` in the inner call to correctly compute date math.
  # Specifying `tz` when in the outer call just changes the time zone without
  # doing any date math!
  #
  # > xlt [1] "2024-08-29 16:36:33 EDT" tzone(xlt) [1] "America/New_York"
  # as.POSIXct(xlt, tz = "UTC") [1] "2024-08-29 16:36:33 UTC"
  format_string <- "%Y-%m-%dT%H:%M:%OS%z"
  as.POSIXct(x, format = format_string, tz = Sys.timezone())
}

vec_cast.POSIXct.double <- # nolint: object_name_linter
  function(x, to, ...) {
    warn_experimental("vec_cast.POSIXct.double")
    vctrs::new_datetime(x, tzone = tzone(to))
  }

vec_cast.POSIXct.character <- # nolint: object_name_linter
  function(x, to, ...) {
    as.POSIXct(x, tz = tzone(to))
  }

tzone <- function(x) {
  attr(x, "tzone")[[1]] %||% ""
}

vec_cast.character.integer <- # nolint: object_name_linter
  function(x, to, ...) {
    as.character(x)
  }

new_datetime <- function(x = double(), tzone = "") {
  tzone <- tzone %||% ""
  if (is.integer(x)) {
    x <- as.double(x)
  }
  stopifnot(is.double(x))
  stopifnot(is.character(tzone))
  structure(x, tzone = tzone, class = c("POSIXct", "POSIXt"))
}
