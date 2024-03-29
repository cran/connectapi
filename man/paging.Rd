% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/page.R
\name{page_cursor}
\alias{page_cursor}
\alias{page_offset}
\title{Paging}
\usage{
page_cursor(client, req, limit = Inf)

page_offset(client, req, limit = Inf)
}
\arguments{
\item{client}{A Connect client object}

\item{req}{The request that needs to be paged}

\item{limit}{A row limit}
}
\value{
The aggregated results from all requests

The aggregated results from all requests
}
\description{
Helper functions that make paging easier in
the Posit Connect Server API.

Helper functions that make paging easier in
the Posit Connect Server API.
}
