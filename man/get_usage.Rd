% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get.R
\name{get_usage}
\alias{get_usage}
\title{Get usage information for deployed content}
\usage{
get_usage(client, from = NULL, to = NULL)
}
\arguments{
\item{client}{A \code{Connect} R6 client object.}

\item{from}{Optional date-time (\code{POSIXct} or \code{POSIXlt}). Only
records after this time are returned. If not provided, records
are returned back to the first record available.}

\item{to}{Optional date-time (\code{POSIXct} or \code{POSIXlt}). Only records
before this time are returned. If not provided, all records up to
the most recent are returned.}
}
\value{
A list of usage records. Each record is a list with all elements
as character strings unless otherwise specified.
\itemize{
\item \code{id}: An integer identifier for the hit.
\item \code{user_guid}: The user GUID if the visitor is logged-in, \code{NULL} for
anonymous hits.
\item \code{content_guid}: The GUID of the visited content.
\item \code{timestamp}: The time of the hit in RFC3339 format.
\item \code{data}: A nested list with optional fields:
\itemize{
\item \code{path}: The request path (if recorded).
\item \code{user_agent}: The user agent string (if available).
}
}

Use \code{\link[=as.data.frame]{as.data.frame()}} or \code{\link[tibble:as_tibble]{tibble::as_tibble()}} to convert to a flat
table with parsed types. In the resulting data frame:
\itemize{
\item \code{timestamp} is parsed to \code{POSIXct}.
\item \code{path} and \code{user_agent} are extracted from the nested \code{data} field.
}

By default, \code{\link[=as.data.frame]{as.data.frame()}} attempts to extract the nested fields using
the \pkg{tidyr} package. If \pkg{tidyr} is not available, or if you want to
skip unnesting, call \code{as.data.frame(x, unnest = FALSE)} to leave \code{data} as
a list-column.
}
\description{
Retrieve content hits for all available content on the server. Available
content depends on the user whose API key is in use. Administrator accounts
will receive data for all content on the server. Publishers will receive data
for all content they own or collaborate on.

If no date-times are provided, all usage data will be returned.
}
\details{
The data returned by \code{get_usage()} includes all content types. For Shiny
content, the \code{timestamp} indicates the \emph{start} of the Shiny session.
Additional fields for Shiny and non-Shiny are available respectively from
\code{\link[=get_usage_shiny]{get_usage_shiny()}} and \code{\link[=get_usage_static]{get_usage_static()}}. \code{get_usage_shiny()} includes a
field for the session end time; \code{get_usage_static()} includes variant,
rendering, and bundle identifiers for the visited content.

When possible, however, we recommend using \code{get_usage()} over
\code{get_usage_static()} or \code{get_usage_shiny()}, as it is faster and more efficient.
}
\examples{
\dontrun{
client <- connect()

# Fetch the last 2 days of hits
usage <- get_usage(client, from = Sys.Date() - 2, to = Sys.Date())

# Fetch usage after a specified date and convert to a data frame.
usage <- get_usage(
  client,
  from = as.POSIXct("2025-05-02 12:40:00", tz = "UTC")
)

# Fetch all usage
usage <- get_usage(client)

# Convert to tibble or data frame
usage_df <- tibble::as_tibble(usage)

# Skip unnesting if tidyr is not installed
usage_df <- as.data.frame(usage, unnest = FALSE)
}

}
\seealso{
\code{\link[=as.data.frame.connect_list_hits]{as.data.frame.connect_list_hits()}}, \code{\link[=as_tibble.connect_list_hits]{as_tibble.connect_list_hits()}}
}
