kevin = User.create(username: "Kevin", password: "Kevin")

kevin.flight_records << FlightRecord.create(
  date: Date.today - 5, aircraft_type: "DA20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

kevin.flight_records << FlightRecord.create(
  date: Date.today - 4, aircraft_type: "DA20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

kevin.flight_records << FlightRecord.create(
  date: Date.today - 3, aircraft_type: "DA20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

kevin.flight_records << FlightRecord.create(
  date: Date.today - 1, aircraft_type: "DA20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

kevin.flight_records << FlightRecord.create(
  date: Date.today, aircraft_type: "DA20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)



tanya = User.create(username: "Tanya", password: "Tanya")

tanya.flight_records << FlightRecord.create(
  date: Date.today - 5, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

tanya.flight_records << FlightRecord.create(
  date: Date.today - 4, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

tanya.flight_records << FlightRecord.create(
  date: Date.today - 3, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

tanya.flight_records << FlightRecord.create(
  date: Date.today - 1, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

tanya.flight_records << FlightRecord.create(
  date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)
