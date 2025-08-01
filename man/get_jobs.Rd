% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/content.R
\name{get_jobs}
\alias{get_jobs}
\alias{get_job_list}
\title{Get Jobs}
\usage{
get_jobs(content)

get_job_list(content)
}
\arguments{
\item{content}{A Content object, as returned by \code{content_item()}}
}
\value{
\itemize{
\item \code{get_jobs()}: A data frame with a row representing each job.
\item \code{get_job_list()}: A list with each element representing a job.
}

Jobs contain the following fields:
\itemize{
\item \code{id}: The job identifier.
\item \code{ppid}: The job's parent process identifier (see Note 1).
\item \code{pid}: The job's process identifier.
\item \code{key}: The job's unique key identifier.
\item \code{remote_id}: The job's identifier for off-host execution configurations
(see Note 1).
\item \code{app_id}: The job's parent content identifier; deprecated in favor of \code{content_id}.
\item \code{app_guid}: The job's parent content GUID; deprecated in favor of \code{content_guid}.
\item \code{content_id}: The job's parent content identifier.
\item \code{content_guid}: The job's parent content GUID.
\item \code{variant_id}: The identifier of the variant owning this job.
\item \code{bundle_id}: The identifier of a content bundle linked to this job.
\item \code{start_time}: The timestamp (RFC3339) indicating when this job started.
\item \code{end_time}: The timestamp (RFC3339) indicating when this job finished.
\item \code{last_heartbeat_time}: The timestamp (RFC3339) indicating the last time
this job was observed to be running (see Note 1).
\item \code{queued_time}: The timestamp (RFC3339) indicating when this job was added
to the queue to be processed. Only scheduled reports will present a value
for this field (see Note 1).
\item \code{queue_name}: The name of the queue which processes the job. Only
scheduled reports will present a value for this field (see Note 1).
\item \code{tag}: A tag to identify the nature of the job.
\item \code{exit_code}: The job's exit code. Present only when job is finished.
\item \code{status}: The current status of the job. On Connect 2022.10.0 and newer,
one of Active: 0, Finished: 1, Finalized: 2; on earlier versions, Active:
0, otherwise \code{NA}.
\item \code{hostname}: The name of the node which processes the job.
\item \code{cluster}: The location where this content runs. Content running on the
same server as Connect will have either a null value or the string Local.
Gives the name of the cluster when run external to the Connect host
(see Note 1).
\item \code{image}: The location where this content runs. Content running on
the same server as Connect will have either a null value or the string
Local. References the name of the target image when content runs in
a clustered environment such as Kubernetes (see Note 1).
\item \code{run_as}: The UNIX user that executed this job.
}
}
\description{
Retrieve details about server processes associated with a \code{content_item},
such as a FastAPI app or a Quarto render.
}
\details{
Note that Connect versions below 2022.10.0 use a legacy endpoint, and will
not return the complete set of information provided by newer versions.

\code{get_jobs()} returns job data as a data frame, whereas \code{get_jobs_list()}
returns job data in a list.

You might get job data as a data frame if you want to perform some
calculations about job data (e.g. counting server processes over time), or if
you want to filter jobs to find a specific key.

The objects in list returned by \code{get_jobs_list()} are useful if you want to
take an action on a job, such as getting its process log with
\code{get_log()}.
}
\note{
\enumerate{
\item On Connect instances earlier than 2022.10.0, these fields will contain \code{NA} values.
}
}
\examples{
\dontrun{
client <- connect()
item <- content_item(client, "951bf3ad-82d0-4bca-bba8-9b27e35c49fa")
jobs <- get_jobs(item)
job_list <- get_job_list(item)
}

}
\seealso{
Other job functions: 
\code{\link{get_job}()},
\code{\link{get_log}()},
\code{\link{terminate_jobs}()}

Other content functions: 
\code{\link{content_delete}()},
\code{\link{content_item}()},
\code{\link{content_title}()},
\code{\link{content_update}()},
\code{\link{create_random_name}()},
\code{\link{dashboard_url}()},
\code{\link{delete_thumbnail}()},
\code{\link{delete_vanity_url}()},
\code{\link{deploy_repo}()},
\code{\link{get_bundles}()},
\code{\link{get_environment}()},
\code{\link{get_image}()},
\code{\link{get_job}()},
\code{\link{get_log}()},
\code{\link{get_thumbnail}()},
\code{\link{get_vanity_url}()},
\code{\link{git}},
\code{\link{has_thumbnail}()},
\code{\link{permissions}},
\code{\link{set_image_path}()},
\code{\link{set_run_as}()},
\code{\link{set_thumbnail}()},
\code{\link{set_vanity_url}()},
\code{\link{swap_vanity_url}()},
\code{\link{swap_vanity_urls}()},
\code{\link{terminate_jobs}()},
\code{\link{verify_content_name}()}
}
\concept{content functions}
\concept{job functions}
