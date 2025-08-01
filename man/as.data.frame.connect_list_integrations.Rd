% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/integrations.R
\name{as.data.frame.connect_list_integrations}
\alias{as.data.frame.connect_list_integrations}
\title{Convert integrations data to a data frame}
\usage{
\method{as.data.frame}{connect_list_integrations}(x, row.names = NULL, optional = FALSE, ...)
}
\arguments{
\item{x}{A \code{connect_list_integrations} object (from \code{\link[=get_integrations]{get_integrations()}}).}

\item{row.names}{Passed to \code{\link[base:as.data.frame]{base::as.data.frame()}}.}

\item{optional}{Passed to \code{\link[base:as.data.frame]{base::as.data.frame()}}.}

\item{...}{Passed to \code{\link[base:as.data.frame]{base::as.data.frame()}}.}
}
\value{
A \code{data.frame} with one row per integration.
}
\description{
Converts an list returned by \code{\link[=get_integrations]{get_integrations()}} into a data frame.
}
