cast <- asciicast::record("data-raw/make_asciicast.R",
  title = "ruODK walkthough",
  start_wait = 1,
  end_wait = 5,
  typing_speed = 0.1,
  echo = TRUE
)

asciicast::write_json(cast, "data-raw/odata.json")
asciicast::write_svg(cast, "data-raw/odata.svg", window = TRUE)
