#  JD for Portr Ltd, June 2015
#  Source this file when running Shiny dashboard
#  Inputs and Outputs: 

#  Determine what Time Span for data analysis 
range  <-  reactive({
  if(input$radio==1){
    return(c(as.Date("2014-05-22", format= "%Y-%m-%d"),Sys.Date()))
  }else if(input$radio==2){
    return(input$dates)
  }else if(input$radio==3){
    return(c(Sys.Date(),Sys.Date()))
  }
})

#  Check if a bookings.csv file has been uploaded. Returns Null if not, 1 if yes
ready <- reactive({
  temp  <- input$file
  if (is.null(temp))
    return(NULL)
  else return(1)
})

#  Set up filtering options based on user checkbox input
filter <- reactive({
  vec <- input$checkAirport
  vec <- gsub("LHR","Heathrow",vec)
  vec <- gsub("LGW","Gatwick",vec)
  vec <- gsub("STN","Stansted",vec)
  vec <- gsub("Storage","Storage",vec)
  vec <- gsub("LCY","London City Airport",vec)
  vec
})


#  Create the main
all  <- reactive({
  temp  <- input$file
  
  if (is.null(temp))
    return(NULL) #returns NULL if there is no file yet
  
  allData <- read.csv(temp$datapath)
  
  #start cleaning up data
  colnames(allData)[1] <- "Booking_reference"
  #NOTE: ALLOW TO TURN ON OR OFF TH FILTER FOR VALUE-LESS BOOKINGS
  if(input$showAll == T){
    bookings <- subset(allData, Transaction_payment > 0) #exclude promotional or internal deliveries
  }
  else{bookings <- subset(allData, Transaction_payment >= 0)}
  #remember conversion into date, considering format
  bookings$day <- weekdays(as.Date(bookings$Outward_Journey_Luggage_drop_off_date, format = "%d/%m/%Y"))
  bookings$month <- month(as.Date(bookings$Outward_Journey_Luggage_drop_off_date, format = "%d/%m/%Y"))
  bookings$year <- year(as.Date(bookings$Outward_Journey_Luggage_drop_off_date, format = "%d/%m/%Y"))
  bookings$date  <- as.Date(bookings$Outward_Journey_Luggage_drop_off_date, format = "%d/%m/%Y")
  bookings$rank  <- as.Date(paste0(bookings$year,'-',bookings$month,'-01'),"%Y-%m-%d")
  
  bookings$Outward_Journey_Luggage_Collection_date <- as.Date(bookings$Outward_Journey_Luggage_Collection_date, format = "%d/%m/%Y")
  
  bookingsKeep <- bookings
  
  #REPORT MODE OPTION
  if(input$reportMode==1){
    bookings <- subset(bookings, date>=range()[1]&date<=range()[2])
  }
  else{bookings <- bookingsKeep}
  
  #Cleaning up postCodes
  bookings$from <- as.character(bookings$Outward_Journey_Luggage_collection_location_addresss_Postcode)
  bookings$to <- as.character(bookings$Outward_Journey_Luggage_drop_off_location_addresss_Postcode)
  
  #Cleaning up flight codes
  bookings$In.bound_flt_code <- gsub(" ", "", bookings$In.bound_flt_code, fixed = TRUE)
  bookings$In.bound_flt_code  <- toupper(bookings$In.bound_flt_code)
  bookings$Out.bound_flt_code <- gsub(" ", "", bookings$Out.bound_flt_code, fixed = TRUE)
  bookings$Out.bound_flt_code  <- toupper(bookings$Out.bound_flt_code)
  
  #FILTERING
  bookings$filter  <- grepl(paste(filter(),collapse="|"),bookings$Outward_Journey_Luggage_collection_location_Name,ignore.case=TRUE)|grepl(paste(filter(),collapse="|"),bookings$Outward_Journey_Luggage_drop_off_location_Name,ignore.case=TRUE)
  bookings <- bookings[bookings$filter == 1,]
  
  bookings
})

sumMonth <- reactive({
  sumBookings <- ddply (all(), c("month","year"), summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = mean(Total_luggage_No), netRevenue = sum(Transaction_payment)/1.2)
  sumBookings$meanNetRevenue <- sumBookings$netRevenue/sumBookings$bookings
  sumBookings$monthName  <- month.abb[sumBookings$month] #getting the month name fo plotting purposes
  
  #sumBookings$order  <- paste0(sumBookings$year,'-',sumBookings$month,'-01'),"%Y-%m-%d")
  
  #sumBookings <- sumBookings[order(c(sumBookings$year,sumBookings$month)),]
  sumBookings
})

sumCum  <- reactive({
  sumBookings  <- sumMonth()
  sumBookings$rank  <- as.Date(paste0(sumBookings$year,'-',sumBookings$month,'-01'),"%Y-%m-%d")
  sumBookings <- sumBookings[order(sumBookings$rank),]
  sumBookings  <- within(sumBookings, cum  <- cumsum(netRevenue)) #calculating cummulatives
  
})

bookingsRange  <- reactive({
  bookings  <- all()
  subset(bookings, date>=range()[1]&date<=range()[2])
})

sumDate <- reactive({
  sumBookings <- ddply (bookingsRange(), c("date","Outward_Journey_Luggage_drop_off_date"), summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = mean(Total_luggage_No), netRevenue = sum(Transaction_payment)/1.2)
  sumBookings$meanNetRevenue <- sumBookings$netRevenue/sumBookings$bookings
  sumBookings$day  <- weekdays(as.Date(sumBookings$Outward_Journey_Luggage_drop_off_date, format = "%d/%m/%Y"))
  sumBookings <- sumBookings[c("date","Outward_Journey_Luggage_drop_off_date","day","bookings","totalBags","meanBags","netRevenue","meanNetRevenue")]
  sumBookings <- sumBookings[order(sumBookings$date, decreasing = TRUE),]
})

contDate <- reactive({
  sumBookings <- sumDate()
  
  timeMax <- range()[2]
  timeMin <- range()[1]
  allDates  <- seq(timeMin,timeMax,by="day")
  
  allDates.frame <- data.frame(list(date=allDates))
  
  mergeDates <- merge(allDates.frame,sumBookings,all=T)
  
  mergeDates$bookings[which(is.na(mergeDates$bookings))] <- 0
  mergeDates$netRevenue[which(is.na(mergeDates$netRevenue))] <- 0
  
  sumBookings <- mergeDates
  
  sumBookings$day  <- weekdays(as.Date(sumBookings$Outward_Journey_Luggage_drop_off_date, format = "%d/%m/%Y"))
  sumBookings$Outward_Journey_Luggage_drop_off_date <- NULL
  sumBookings$meanBags  <- round(sumBookings$meanBags,1)
  sumBookings$netRevenue <- round(sumBookings$netRevenue,2)
  sumBookings$meanNetRevenue <- round(sumBookings$meanNetRevenue,2)
  
  sumBookings <- sumBookings[order(sumBookings$date, decreasing = TRUE),]
  
  sumBookings
  
})

#Inbound flight data
InFlights <- reactive({
  df <- read.csv('data/BAFlights.csv')
  df$BA.Flight <- gsub(" ", "", df$BA.Flight, fixed = TRUE)
  df <- df[df$Inbound...Outbound=="Inbound",]
  df <- df[,c("BA.Flight","Origin")]
  df <- unique(df)
  rownames(df) <- NULL
  
  df
})

#Carousel Collections
Carousel <- reactive({
  
  bookings <- bookingsRange()
  
  df <- bookings[bookings$Product_ID_numbers == "AP0002", c("Booking_reference", "Department", "Booking_lead_time", "Hand_luggage_No",
                                                            "Hold_luggage_No", "Total_luggage_No","Customer_Firstname","customer_surname","country_origin", "Reason_for_travel",
                                                            "Zone", "Outward_Journey_Luggage_drop_off_location_addresss_Postcode", "Outward_Journey_Luggage_drop_off_location_Type",
                                                            "Outward_Journey_Luggage_Collection_date", "Outward_Journey_Luggage_Collection_time", "Outward_Journey_Luggage_drop_off_time",
                                                            "Transaction_payment","In.bound_flt_code")]
  
  merged <- merge(df,InFlights(), all.x=T, by.x = "In.bound_flt_code", by.y = "BA.Flight")
  merged <- merged[with(merged, order(Outward_Journey_Luggage_Collection_date, decreasing = T)),]
  rownames(merged) <- NULL
  merged
})

CarouselShort <- reactive({
  
  bookings <- Carousel()
  df <- bookings[, c("Booking_reference", "Department", "Booking_lead_time", "Hand_luggage_No",
                     "Hold_luggage_No", "Total_luggage_No","Customer_Firstname","customer_surname","country_origin", "Reason_for_travel",
                     "Zone", "Outward_Journey_Luggage_drop_off_location_addresss_Postcode", "Outward_Journey_Luggage_drop_off_location_Type",
                     "Outward_Journey_Luggage_Collection_date", "Outward_Journey_Luggage_Collection_time", "Outward_Journey_Luggage_drop_off_time",
                     "Transaction_payment","In.bound_flt_code","Origin")]
})