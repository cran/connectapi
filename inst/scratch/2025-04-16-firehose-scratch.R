
from_timestamp <- as.POSIXct(Sys.Date() - 1)
to_timestamp <- Sys.time()

from_date <- Sys.Date() - 1
to_date <- Sys.Date()

client <- connect()

u1 <- get_usage(client, from = from_timestamp, to = to_timestamp)
u2 <- get_usage(client, from = from_date, to = to_date)

min(u1$timestamp)
max(u1$timestamp)

min(u2$timestamp)
max(u2$timestamp)
