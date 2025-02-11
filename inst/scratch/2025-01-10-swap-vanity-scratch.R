
client <- connect()

green <- content_item(client, "4652dec5-cbda-47f7-9737-0c06c556dc7c")
blue <- content_item(client, "951bf3ad-82d0-4bca-bba8-9b27e35c49fa")

swap_vanity_urls(green, blue)

set_vanity_url(blue, "new")
delete_vanity_url(blue)
set_vanity_url(blue, "old")
