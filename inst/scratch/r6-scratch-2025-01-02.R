
client <- connect()
all_envs <- client$GET("/v1/environments")

envs <- list()

for (env in all_envs) {
  envs <- append(envs, Environment$new(client, env))
}

purrr::keep(envs, ~ .x$data$id == 1)

purrr::keep(envs, ~ .x$id == 1)

Filter(function(x) x$id == 1, envs)

all_envs[all_envs$id == 1]


e <- Environment$new(client, all_envs[[2]])

e[["id"]]

e$all_runtimes


client <- connect()
all_envs <- get_execution_envs(client)
e <- all_envs[[2]]
e$title
e$connect
e$data
e
