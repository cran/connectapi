client <- connect()

item <- content_item(client, "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0")

jobs <- get_jobs(item)

key <- "uJhnmtV11bLS66kk"

job_old <- client$GET(unversioned_url("applications", item$content$guid, "job", key), parser = NULL)
job_new <- client$GET(v1_url("content", item$content$guid, "jobs", key), parser = NULL)

parse_connectapi_typed(list(httr::content(job_old)), connectapi_ptypes$jobs, strict = TRUE)

log <- client$GET(v1_url("content", item$content$guid, "jobs", key, "log"), parser = NULL)
log_content <- httr::content(log)
str(log_content)

parse_connectapi(log_content$entries)
parse_connectapi_typed(log_content$entries, connectapi_ptypes$job_log)

#-------


jl <- get_job_list(item)




jl2 <- map(jl, ~ list_modify(.x, app_guid = self$content$guid))


#-------

Job <- R6::R6Class(
  "Job",

  public = list(
    connect = NULL,
    content = NULL,
    data = NULL,

    initialize = function(content, data) {
      validate_R6_class(content, "Content")
      self$connect <- content$connect
      self$content <- content
      self$data <- data
    }
  ),

  active = list(
    id = function() self$data$id,
    ppid = function() self$data$ppid,
    pid = function() self$data$pid,
    key = function() self$data$key,
    remote_id = function() self$data$remote_id,
    app_id = function() self$data$app_id,
    variant_id = function() self$data$variant_id,
    bundle_id = function() self$data$bundle_id,
    start_time = function() self$data$start_time,
    end_time = function() self$data$end_time,
    last_heartbeat_time = function() self$data$last_heartbeat_time,
    queued_time = function() self$data$queued_time,
    queue_name = function() self$data$queue_name,
    tag = function() self$data$tag,
    exit_code = function() self$data$exit_code,
    status = function() self$data$status,
    hostname = function() self$data$hostname,
    cluster = function() self$data$cluster,
    image = function() self$data$image,
    run_as = function() self$data$run_as
  )
)

jobs2 <- list()

for (job in item$jobs()) {
  jobs2 <- append(jobs2, Job$new(item, job))
}

jobs[is.na(jobs$end_time), ]
purrr::keep(jobs2, ~ is.null(.x$end_time))

item_with_error <- content_item(client, "c40b4a3f-d00a-4829-985c-37ecadf88464")

j2 <- get_jobs(item_with_error)

key <- j2$key[1]

err <- client$GET(v1_url("content", item_with_error$content$guid, "jobs", key, "error"))
