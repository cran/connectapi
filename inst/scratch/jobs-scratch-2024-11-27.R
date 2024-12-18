client <- connect()

item <- content_item(client, "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0")

jobs_old <- client$GET(unversioned_url("applications", item$content$guid, "jobs"), parser = NULL)
jobs_new <- client$GET(v1_url("content", item$content$guid, "jobs"), parser = NULL)

str(httr::content(jobs_old))
str(httr::content(jobs_new))

single_job_old <- client$GET(unversioned_url("applications", item$content$guid, "job", "QBZ5jkKfmf9iT9k8"), parser = NULL)
single_job_new <- client$GET(v1_url("content", item$content$guid, "jobs", "QBZ5jkKfmf9iT9k8"), parser = NULL)



get_job(item, "QBZ5jkKfmf9iT9k8")

# TODO
# Go through and audit the fields. Transform from old to new. Write a test

old <- list(
  list(
    id = 40097386L, pid = 2516505L, key = "mxPGVOMVk6f8dso2",
    app_id = 52389L, app_guid = "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0",
    variant_id = 0L, bundle_id = 127015L, start_time = 1732573574L,
    end_time = 1732577139L, tag = "run_app", exit_code = 0L,
    finalized = TRUE, hostname = "dogfood02"
  ), list(
    id = 40096649L,
    pid = 2509199L, key = "QBZ5jkKfmf9iT9k8", app_id = 52389L,
    app_guid = "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0", variant_id = 0L,
    bundle_id = 127015L, start_time = 1732573062L, end_time = NULL,
    tag = "run_app", exit_code = NULL, finalized = TRUE, hostname = "dogfood02"
  ),
  list(
    id = 40080413L, pid = 2321354L, key = "EzxM4sBYJrLSMHg9",
    app_id = 52389L, app_guid = "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0",
    variant_id = 0L, bundle_id = 127015L, start_time = 1732553145L,
    end_time = 1732556770L, tag = "run_app", exit_code = 0L,
    finalized = TRUE, hostname = "dogfood02"
  ), list(
    id = 39368207L,
    pid = 2434200L, key = "HbdzgOJrMmMTq6vu", app_id = 52389L,
    app_guid = "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0", variant_id = 0L,
    bundle_id = 127015L, start_time = 1731690180L, end_time = 1731690383L,
    tag = "run_app", exit_code = 0L, finalized = TRUE, hostname = "dogfood02"
  ),
  list(
    id = 39368207L,
    pid = 2434200L, key = "asfg", app_id = 52389L,
    app_guid = "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0", variant_id = 0L,
    bundle_id = 127015L, start_time = 1731690180L, end_time = 1731690383L,
    tag = "run_app", exit_code = 0L, finalized = FALSE, hostname = "dogfood02"
  )
)

new <- list(
  list(
    id = "40097386", ppid = "2516489", pid = "2516505",
    key = "mxPGVOMVk6f8dso2", remote_id = NULL, app_id = "52389",
    variant_id = "0", bundle_id = "127015", start_time = "2024-11-25T22:26:14Z",
    end_time = "2024-11-25T23:25:39Z", last_heartbeat_time = "2024-11-25T23:25:36Z",
    queued_time = NULL, queue_name = NULL, tag = "run_app", exit_code = 0L,
    status = 2L, hostname = "dogfood02", cluster = NULL, image = NULL,
    run_as = "rstudio-connect"
  ), list(
    id = "40096649", ppid = "2509183",
    pid = "2509199", key = "QBZ5jkKfmf9iT9k8", remote_id = NULL,
    app_id = "52389", variant_id = "0", bundle_id = "127015",
    start_time = "2024-11-25T22:17:42Z", end_time = NULL, last_heartbeat_time = "2024-11-25T22:20:23Z",
    queued_time = NULL, queue_name = NULL, tag = "run_app", exit_code = NULL,
    status = 2L, hostname = "dogfood02", cluster = NULL, image = NULL,
    run_as = "rstudio-connect"
  ), list(
    id = "40080413", ppid = "2321337",
    pid = "2321354", key = "EzxM4sBYJrLSMHg9", remote_id = NULL,
    app_id = "52389", variant_id = "0", bundle_id = "127015",
    start_time = "2024-11-25T16:45:45Z", end_time = "2024-11-25T17:46:10Z",
    last_heartbeat_time = "2024-11-25T17:46:08Z", queued_time = NULL,
    queue_name = NULL, tag = "run_app", exit_code = 0L, status = 2L,
    hostname = "dogfood02", cluster = NULL, image = NULL, run_as = "rstudio-connect"
  ),
  list(
    id = "39368207", ppid = "2434183", pid = "2434200",
    key = "HbdzgOJrMmMTq6vu", remote_id = NULL, app_id = "52389",
    variant_id = "0", bundle_id = "127015", start_time = "2024-11-15T17:03:00Z",
    end_time = "2024-11-15T17:06:23Z", last_heartbeat_time = "2024-11-15T17:06:20Z",
    queued_time = NULL, queue_name = NULL, tag = "run_app",
    exit_code = 0L, status = 2L, hostname = "dogfood02",
    cluster = NULL, image = NULL, run_as = "rstudio-connect"
  )
)


old_df <- parse_connectapi_typed(old, connectapi_ptypes$jobs)
old_df_untyped <- parse_connectapi(old)

vctrs::vec_ptype(old_df)



new_df <- parse_connectapi(new)

old_ptype <- connectapi_ptypes$jobs

new_ptype <- tibble::tibble(
  id = NA_character_,
  ppid = NA_character_,
  pid = NA_character_,
  key = NA_character_,
  remote_id = NA_character_,
  app_id = NA_character_,
  variant_id = NA_character_,
  bundle_id = NA_character_,
  start_time = NA_datetime_,
  end_time = NA_datetime_,
  last_heartbeat_time = NA_datetime_,
  queued_time = NA_datetime_,
  queue_name = NA_character_,
  tag = NA_character_,
  exit_code = NA_integer_,
  status = NA_integer_,
  hostname = NA_character_,
  cluster = NA_character_,
  image = NA_character_,
  run_as = NA_character_,
)

new_old_ptype <- cbind(new_ptype, tibble::tibble(finalized = NA))


# Make the old one have all of the new columns, but also maintain
# In the docs, put a column saying
# Idea: Having a v0 ptypes list separate from v1
# Consider moving the parse logic inside the `content$job()` method.
# Store the result of content > 99 in a var

# Could memoize

new_df_typed <- parse_connectapi_typed(new, new_ptype)

x <- parse_connectapi_typed(old, new_ptype)
identical(x, old_df)
waldo::compare(x, old_df, x_arg = "new_ptype", y_arg = "old_ptype")





new_df_untyped <- parse_connectapi(new)
old_df_untyped <- parse_connectapi(old)

new_df <- parse_connectapi_typed(new, new_ptype, strict = TRUE)
old_df <- parse_connectapi_typed(old, new_ptype, strict = TRUE)


old2 <- purrr::modify_if(old, ~ isFALSE(.x$finalized), function(x) {
  x$status = 0
  x
})
old2_df <- parse_connectapi_typed(old2, new_ptype, strict = TRUE)
old2_df



ensure_columns(old_df_untyped, new_ptype)



single_job_old <- client$GET(unversioned_url("applications", item$content$guid, "job", "QBZ5jkKfmf9iT9k8"), parser = NULL)
single_job_new <- client$GET(v1_url("content", item$content$guid, "jobs", "QBZ5jkKfmf9iT9k8"), parser = NULL)

httr::content(single_job_old, as = "parsed")

parse_connectapi_typed(httr::content(single_job_old, as = "parsed"), strict = FALSE)


non_existent <- client$GET(v1_url("content", item$content$guid, "jorbs"), parser = NULL)
other_404 <- client$GET(v1_url("content", "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd1", "jobs"), parser = NULL)






# Test code

setwd("tests/testthat")

with_mock_api({
  client <- Connect$new(server = "http://connect.example", api_key = "not-a-key")
  item <- content_item(client, "8f37d6e0")
  jobs_v1 <- get_jobs(item)
  TRUE
})

with_mock_dir("2024.07.0", {
  jobs_v0 <- get_jobs(item)
  TRUE
})

setwd("../..")


start_capturing("2024.05.0")

client <- connect()

item <- content_item(client, "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0")

content_render(item)

client$GET(unversioned_url("applications", item$content$guid, "jobs"))
client$GET(v1_url("content", item$content$guid, "jobs"))



stop_capturing()



# -----


res_mixed_content <- list(list(guid = "b0ab9d47-f0f2-4745-8783-ce692194ddcd", app_id = 52389L,
    app_guid = "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0", job_id = 40793914L,
    job_key = "IuzpAzG329zvnt9s", result = "Order to kill job registered"),
    list(code = 163L, error = "The specified job cannot be terminated because it is not active",
        payload = NULL))

res_good_content <- list(list(guid = "b0ab9d47-f0f2-4745-8783-ce692194ddcd", app_id = 52389L,
app_guid = "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0", job_id = 40793914L,
job_key = "IuzpAzG329zvnt9s", result = "Order to kill job registered"),
list(guid = "35e42c5b-ba21-498d-898d-bb18a35b10dd", app_id = 52389L,
    app_guid = "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0", job_id = 40793542L,
    job_key = "waaTO7v75I84S1hQ", result = "Order to kill job registered"))

res_bad_content <- list(list(code = 163L, error = "The specified job cannot be terminated because it is not active",
    payload = NULL), list(code = 163L, error = "The specified job cannot be terminated because it is not active",
    payload = NULL))

res_mixed2_content <- list(list(guid = "b0ab9d47-f0f2-4745-8783-ce692194ddcd", app_id = 52389L,
    app_guid = "8f37d6e0-3395-4a2c-aa6a-d7f2fe1babd0", job_id = 40793914L,
    job_key = "IuzpAzG329zvnt9s", result = "Order to kill job registered"),
    list(code = 163L, error = "The specified job cannot be terminated because it is not active",
        payload = NULL), "404 page not found")


job_termination_ptype <- tibble::tibble(
  # guid = NA_character,
  app_id = NA_integer_,
  app_guid = NA_character_,
  job_id = NA_character_,
  # job_key = NA_character_,
  result = NA_character_,
  code = NA_integer_,
  error = NA_character_
)

parse_connectapi(res_mixed_content)
parse_connectapi(res_good_content)
parse_connectapi(res_bad_content)

parse_connectapi_typed(res_mixed_content, job_termination_ptype, strict = TRUE)
parse_connectapi_typed(res_good_content, job_termination_ptype, strict = TRUE)
parse_connectapi_typed(res_bad_content, job_termination_ptype, strict = TRUE)
parse_connectapi_typed(res_mixed2_content, job_termination_ptype, strict = TRUE)

purrr::map(res_mixed2, endpoint_does_not_exist)
