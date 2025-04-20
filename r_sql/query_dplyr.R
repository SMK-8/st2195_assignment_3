library(DBI)
library(RSQLite)
library(dplyr)
library(dbplyr)

# Connect to the SQLite database
conn <- dbConnect(RSQLite::SQLite(), "/Users/joanneodannell/Desktop/st_2195/st2195_assignment_3_database/dataverse_files/airline.db")

# Reference to tables in the database using dbplyr
ontime <- tbl(conn, "ontime")
planes <- tbl(conn, "planes")
airports <- tbl(conn, "airports")
carriers <- tbl(conn, "carriers")

# Query 1: Average Departure Delay by Plane Model
result_q1 <- ontime %>%
  inner_join(planes, by = c("TailNum" = "tailnum")) %>%
  filter(Cancelled == 0, Diverted == 0, !is.na(DepDelay), 
         model %in% c('737-230','ERJ 190-100 IGW','A330-223','737-282')) %>%
  group_by(model) %>%
  summarise(avg_dep_delay = mean(DepDelay, na.rm = TRUE)) %>%
  arrange(avg_dep_delay)

# Collect result and save to CSV
result_q1 <- collect(result_q1)
print(result_q1)
write.csv(result_q1, "/Users/joanneodannell/Desktop/st_2195/st2195_assignment_3/r_sql/q1_output.csv", row.names = FALSE)

# Query 3: Number of Arrivals to Specific Airports
result_q3 <- ontime %>%
  inner_join(airports, by = c("Dest" = "iata")) %>%
  filter(Cancelled == 0, city %in% c('Chicago', 'Atlanta', 'New York', 'Houston')) %>%
  group_by(city) %>%
  summarise(num_arrivals = n()) %>%
  arrange(desc(num_arrivals))

# Collect result and save to CSV
result_q3 <- collect(result_q3)
print(result_q3)
write.csv(result_q3, "/Users/joanneodannell/Desktop/st_2195/st2195_assignment_3/r_sql/q3_output.csv", row.names = FALSE)

# Query 4: Number of Cancelled Flights by Airline
result_q4 <- ontime %>%
  inner_join(carriers, by = c("UniqueCarrier" = "Code")) %>%
  filter(Cancelled == 1, Description %in% c('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')) %>%
  group_by(Description) %>%
  summarise(num_cancelled = n()) %>%
  arrange(desc(num_cancelled))

# Collect result and save to CSV
result_q4 <- collect(result_q4)
print(result_q4)
write.csv(result_q4, "/Users/joanneodannell/Desktop/st_2195/st2195_assignment_3/r_sql/q4_output.csv", row.names = FALSE)

# Query 5: Flight Cancellation Rate by Airline
result5 <- ontime %>%
  inner_join(carriers, by = c("UniqueCarrier" = "Code")) %>%
  filter(Description %in% c("United Air Lines Inc.", "American Airlines Inc.",
                            "Pinnacle Airlines Inc.", "Delta Air Lines Inc.")) %>%
  group_by(airline = Description) %>%
  summarise(
    total_flights = n(),
    cancelled_flights = sum(Cancelled == 1, na.rm = TRUE)
  ) %>%
  mutate(
    cancel_rate = round(cancelled_flights / total_flights, 4)
  ) %>%
  arrange(desc(cancel_rate)) %>%
  collect()
# Close the connection
dbDisconnect(conn)