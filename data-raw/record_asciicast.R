cast <- asciicast::record(here::here("data-raw/make_asciicast.R"))
asciicast::write_json(cast, here::here("data-raw/odata.json"))
asciicast::write_svg(cast, here::here("man", "figures", "odata.svg"))
asciicast::play(cast)
