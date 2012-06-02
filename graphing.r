require(graphics)
library(DBI)
library(RSQLite)

drv <- dbDriver("SQLite")
conn <- dbConnect(drv, dbname = "s.sqlite3")

query <- function(con, query) {
  rs <- dbSendQuery(con, query)
  data <- fetch(rs, n = -1)
  dbClearResult(rs)
  data
}

to_fahrenheit <- function(c) { ((c * 9) / 5) + 32 }

box <- query(conn, "
SELECT id,
       humidity / 10.0 as humidity,
       temp / 10.0 as temp,
       ambient_temp / 10.0 as ambient_temp,
       ambient_humidity / 10.0 as ambient_humidity,
       created_at
FROM measurements ORDER BY id DESC LIMIT 3600
")

box$x <- as.POSIXct(box$created_at, tz = "UTC")

box$temp.f <- to_fahrenheit(box$temp)

png(filename = "out.png", height = 750, width = 1000, bg = "white")

plot(box$x,  box$temp.f, type="l", ylim=c(50, 65), col="red", ylab="Degrees F", xlab="Time")

title("Sausage Box")
legend("topleft", c("Box Temp"), lty = c(1), col = c("red"))

dev.off()

