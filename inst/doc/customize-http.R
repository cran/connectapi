## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## -----------------------------------------------------------------------------
#  library(httr)
#  library(connectapi)
#  
#  client <- connect()
#  
#  # notice that TLS verification fails
#  get_users(client)
#  
#  # use a custom Certificate Authority to verify SSL/TLS requests
#  httr::set_config(httr::config(cainfo = "/path/to/my.pem"))
#  
#  # now it should succeed!
#  get_users(client)

## -----------------------------------------------------------------------------
#  # disabling certificate trust (can allow man-in-the-middle attacks, etc.)
#  httr::set_config(httr::config(ssl_verifypeer = 0, ssl_verifyhost = 0))
#  
#  # should work
#  client <- connect()
#  get_users(client)

## -----------------------------------------------------------------------------
#  httr::with_config(
#    httr::config(ssl_verifypeer = 0, ssl_verifyhost = 0),
#    {
#      client <- connect()
#      get_users(client)
#    }
#  )

## -----------------------------------------------------------------------------
#  # for instance, to set custom headers (i.e. to get through a proxy)
#  client$httr_config(httr::add_headers(MY_MAGIC_HEADER = "value"))
#  
#  # or to clear sticky cookies if you want to switch nodes in an HA cluster
#  client <- connect()
#  client$server_settings()$hostname
#  client$httr_config(handle = httr::handle(""))
#  
#  # now you have a chance to get a new host
#  client$server_settings()$hostname
#  
#  # use an outbound proxy
#  client$httr_config(httr::use_proxy("http://myproxy.example.com"))

## -----------------------------------------------------------------------------
#  # disables authentication header that is included by default
#  client$using_auth <- FALSE
#  
#  # use Kerberos authentication mechanism (requires local credential cache)
#  client$httr_config(httr::authenticate(":", "", type = "gssnegotiate"))

