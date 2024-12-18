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



Job <- R6::R6Class(
  "Job",

  public = list(
    #' @field connect An R6 Connect object
    connect = NULL,
    #' @field content The content details from Posit Connect
    content = NULL,
  )
)
