#  JD for Portr Ltd, June 2015
#  Source this file when running Shiny dashboard
#  Includes main reactive functions to user with App.R 

# I/O CHECKS AND CLEAN UP
  #  Determine what Time Span for data analysis 
  range  <-  reactive({
    if(input$radio==1){
      return(c(as.Date(startDate$LCY, format= "%Y-%m-%d"),Sys.Date()))
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
    vec <- gsub("Storage","Other",vec)
    vec <- gsub("LCY","London City Airport",vec)
    vec
  })

# DATA FRAMES

  # MAIN DATA IMPORT AND CLEAN UP
    original  <- reactive({
      temp  <- input$file
      
      if (is.null(temp))
        return(NULL) #returns NULL if there is no file yet
      
      bookings <- read.csv(temp$datapath)
      
      # start cleaning up data
      colnames(bookings)[1] <- "Booking_reference"  # Seems to solve corrupted header name
      
      # remember conversion into date, considering format
      bookings$day <- weekdays(as.Date(bookings$Outward_Journey_Luggage_drop_off_date, format = "%d/%m/%Y"))
      bookings$month <- month(as.Date(bookings$Outward_Journey_Luggage_drop_off_date, format = "%d/%m/%Y"))
      bookings$year <- year(as.Date(bookings$Outward_Journey_Luggage_drop_off_date, format = "%d/%m/%Y"))
      bookings$date  <- as.Date(bookings$Outward_Journey_Luggage_drop_off_date, format = "%d/%m/%Y")
      bookings$week <- strftime(bookings$date,format="%W")
      bookings$rank  <- as.Date(paste0(bookings$year,'-',bookings$month,'-01'),"%Y-%m-%d")
      
      bookings$Outward_Journey_Luggage_Collection_date <- as.Date(bookings$Outward_Journey_Luggage_Collection_date, format = "%d/%m/%Y")
      
      # Cleaning up postCodes
      bookings$from <- as.character(bookings$Outward_Journey_Luggage_collection_location_addresss_Postcode)
      bookings$to <- as.character(bookings$Outward_Journey_Luggage_drop_off_location_addresss_Postcode)
      
      # Cleaning up flight codes
      bookings$In.bound_flt_code <- gsub(" ", "", bookings$In.bound_flt_code, fixed = TRUE)
      bookings$In.bound_flt_code  <- toupper(bookings$In.bound_flt_code)
      bookings$Out.bound_flt_code <- gsub(" ", "", bookings$Out.bound_flt_code, fixed = TRUE)
      bookings$Out.bound_flt_code  <- toupper(bookings$Out.bound_flt_code)
      
      bookings
    })

  # APPLY FILTERING CONDITIONS
    all <- reactive({
      bookFilter(original(), filter(), range(), onlyNonZero = input$showAll, rangeMode = input$reportMode)
      # see function under functions.R
    })


  # SUMMARIZE BY MONTH (AND YEAR)
    sumMonth <- reactive({
      sumBookings <- ddply (all(), c("month","year"), summarize, 
        bookings = length(Cancelled), 
        totalBags = sum(Total_luggage_No), 
        meanBags = mean(Total_luggage_No), 
        netRevenue = sum(Transaction_payment)/1.2)
      sumBookings$meanNetRevenue <- sumBookings$netRevenue/sumBookings$bookings
      sumBookings$monthName  <- month.abb[sumBookings$month] #getting the month name fo plotting purposes
      
      #sumBookings$order  <- paste0(sumBookings$year,'-',sumBookings$month,'-01'),"%Y-%m-%d")
      
      #sumBookings <- sumBookings[order(c(sumBookings$year,sumBookings$month)),]
      sumBookings
    })

    # CALCULATE CUMMULATIVE
      sumCum  <- reactive({
        sumBookings  <- sumMonth()
        sumBookings$rank  <- as.Date(paste0(sumBookings$year,'-',sumBookings$month,'-01'),"%Y-%m-%d")
        sumBookings <- sumBookings[order(sumBookings$rank),]
        sumBookings  <- within(sumBookings, cum  <- cumsum(netRevenue)) #calculating cummulatives
        
      })

  # SUBSET BOOKINGS WITHIN INPUT DATE RANGE
    bookingsRange  <- reactive({
      bookings  <- all()
      subset(bookings, date>=range()[1]&date<=range()[2])
    })

  # SUMMARIZE BY DATE
    sumDate <- reactive({
      # Note that it acts on bookingsRange()
      sumBookings <- ddply (bookingsRange(), c("date","Outward_Journey_Luggage_drop_off_date"), summarize, 
        bookings = length(Cancelled), 
        totalBags = sum(Total_luggage_No), 
        meanBags = mean(Total_luggage_No), 
        netRevenue = sum(Transaction_payment)/1.2)
      sumBookings$meanNetRevenue <- sumBookings$netRevenue/sumBookings$bookings
      sumBookings$day  <- weekdays(as.Date(sumBookings$Outward_Journey_Luggage_drop_off_date, format = "%d/%m/%Y"))
      sumBookings <- sumBookings[c("date","Outward_Journey_Luggage_drop_off_date","day","bookings","totalBags","meanBags","netRevenue","meanNetRevenue")]
      sumBookings <- sumBookings[order(sumBookings$date, decreasing = TRUE),]
    })

  # GENERATE CONTINUOUS DATA FRAME BY DATE
    # For use in day graph
    contDate <- reactive({
      sumBookings <- sumDate()
      
      timeMax <- range()[2]
      timeMin <- range()[1]
      allDates  <- seq(timeMin,timeMax,by="day")
      # can easily be swapped to by "week"
      
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

  # GENERATE POPULAR CC&D FLIGHTS DATA TABLE
    # Inbound flight data only, requires CSV file to convert flight codes to destniation names
    InFlights <- reactive({
      df <- read.csv('data/BAFlights.csv')  # Read CSV
      df$BA.Flight <- gsub(" ", "", df$BA.Flight, fixed = TRUE)
      df <- df[df$Inbound...Outbound=="Inbound",]
      df <- df[,c("BA.Flight","Origin")]
      df <- unique(df)
      rownames(df) <- NULL
      
      df
    })

  # REPEAT USERS DATA TABLE
    # 
    reUser <- reactive({
      allData <- bookingsRange()
      #   if(grep("bagstorage@portr.com",allData$customer_email)){
      #     allData <- allData[- grep("bagstorage@portr.com",allData$customer_email), ]
      #   }
      
      # Summarize by customer e-mail
      reUser.df <- ddply (allData, "customer_email", summarize, 
        bookings = length(Cancelled), 
        totalBags = sum(Total_luggage_No), 
        meanBags = round(mean(Total_luggage_No),digits=1), 
        netRevenue = round(sum(Transaction_payment)/1.2))
      reUser.df$avgRevenue <- round(reUser.df$netRevenue/reUser.df$bookings, 
        digits=2)
      reUser.df <- reUser.df[with(reUser.df,order(-bookings,-avgRevenue)), ]
      reUser.df <- reUser.df[reUser.df$bookings>1,]
      rownames(reUser.df) <- NULL
      
      reUser.df
    })

  # SUMMARIZE CAROUSEL COLLECTIONS
    # LONG FORM BA FORMAT
      # Used only for download function
      Carousel <- reactive({
        
        bookings <- bookingsRange()
        
        df <- bookings[bookings$Product_ID_numbers == "AP0002", 
          c("Booking_reference", "Department", "Booking_lead_time", "Hand_luggage_No",
            "Hold_luggage_No", "Total_luggage_No","Customer_Firstname","customer_surname","country_origin", "Reason_for_travel",
            "Zone", "Outward_Journey_Luggage_drop_off_location_addresss_Postcode", "Outward_Journey_Luggage_drop_off_location_Type",
            "Outward_Journey_Luggage_Collection_date", "Outward_Journey_Luggage_Collection_time", "Outward_Journey_Luggage_drop_off_time",
            "Transaction_payment","In.bound_flt_code"
          )]
        
        merged <- merge(df,InFlights(), all.x=T, by.x = "In.bound_flt_code", by.y = "BA.Flight")
        merged <- merged[with(merged, order(Outward_Journey_Luggage_Collection_date, decreasing = T)),]
        rownames(merged) <- NULL
        merged
      })
    
    # SHORT FORM BA FORMAT
    CarouselShort <- reactive({
      
      bookings <- Carousel()
      df <- bookings[, c("Booking_reference", "Department", "Booking_lead_time", "Hand_luggage_No",
                         "Hold_luggage_No", "Total_luggage_No","Customer_Firstname","customer_surname","country_origin", "Reason_for_travel",
                         "Zone", "Outward_Journey_Luggage_drop_off_location_addresss_Postcode", "Outward_Journey_Luggage_drop_off_location_Type",
                         "Outward_Journey_Luggage_Collection_date", "Outward_Journey_Luggage_Collection_time", "Outward_Journey_Luggage_drop_off_time",
                         "Transaction_payment","In.bound_flt_code","Origin")]
    })

  # POPULAR IP ADDRESSES
    IPs <- reactive({

      IPtemp <- ddply(bookingsRange(),c("ip_address", "Department"), summarize,
        books=length(Total_product_number),
        BookingTime=round(mean(Booking_completion_time[Booking_completion_time!=0])/60,2)
      )
      # Reorder
      IPtemp[with(IPtemp,order(-books)),]
      # Exclude Blanks
      IPtemp <- IPtemp[IPtemp$ip_address!='',]

      rownames(IPtemp) <- NULL

      IPtemp

    })
     

    # lgwEPOS <- reactive({
    #   data <- bookingsRange()
    #   l <- length(data$Cancelled)

    # Retailer <- matrix(ncol=1,nrow=l)
    # Retailer <- "AP"



    #   df <- bookings[, c()]
    # })

