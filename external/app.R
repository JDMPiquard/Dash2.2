#  JD for Portr Ltd, Junde 2015
#  Takes care of most of the plot rendering 
#  

#  source reactive expressions and other code
source('external/appSourceFiles/reactives.R', local=T)  #  reactives

  
  ##OUTPUTS###################################################
  #CHARTS
  
  output$MAIN <- renderGvis({
    if (is.null(ready())) return(NULL)
    df <- sumCum()
    Combo <- gvisComboChart(df, xvar="rank",
                            yvar=c("netRevenue", "cum"),
                            #options=list(seriesType="bars",series='{1: {type:"line"}}')
                            options=list(height=300,
                                         series="[{
                                         type:'bars', targetAxisIndex:0
  },{
                                         type:'line', targetAxisIndex:1
  }]",
                                          vAxes="[{title:'GBP/month'}, {title:'GBP/cumulative'}]",
                                         title= "bookings net revenue month by month"
                            )
    )
})



#######TAB1#######################################################################################

##Detailed Day Plot########################################################

output$dayPlot <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  sumBookings <- sumDate()
  
  timeMax <- range()[2]
  timeMin <- range()[1]
  allDates  <- seq(timeMin,timeMax,by="day")
  
  allDates.frame <- data.frame(list(date=allDates))
  
  mergeDates <- merge(allDates.frame,sumBookings,all=T)
  
  mergeDates$bookings[which(is.na(mergeDates$bookings))] <- 0
  mergeDates$netRevenue[which(is.na(mergeDates$netRevenue))] <- 0
  
  #df <- mergeDates
  df <- contDate()
  
  Combo <- gvisComboChart(df, xvar="date",
                          yvar=c("netRevenue", "bookings"),
                          #options=list(seriesType="bars",series='{1: {type:"line"}}')
                          options=list(series="[{
                                       type:'line', targetAxisIndex:0
},{
                                       type:'line', targetAxisIndex:1
}]",
                                       vAxes="[{title:'net revenue in GBP'}, {title:'number of bookings'}]",
                                       title= "daily bookings and net revenue",
                                       width = 800
                          )
  )
})


#SUMMARY TEXT#
#show selected date range in title
output$textDates  <- renderText({
  paste("Summary for",range()[1]," to ",range()[2])
})
#show selected airports
output$selectedAirports <- renderText({
  paste("Portr Ltd Performance Dashboard for ",paste(input$checkAirport,collapse=" + "))
})

##BOXED NUMBERS: TAB 1######################################################
#bookings
output$W  <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- sumDate()
  sum(df$bookings)
})
#bags
output$X  <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- sumDate()
  sum(df$totalBags)
})
#net revenue
output$Y  <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- sumDate()
  paste(round(sum(df$netRevenue*1.2)),"GBP")
})
#avg bags
output$mX  <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- sumDate()
  round(sum(df$totalBags)/sum(df$bookings), digits = 1)
})
#net revenue per booking
output$mY  <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- sumDate()
  paste(round(sum(df$netRevenue)/sum(df$bookings)*1.2, digits = 2),"GBP")
})
#ne
output$preBook <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- bookingsRange()
  preBook <- round(sum(grepl("prebook",df$Department))/length(df$Department), digits=2)*100
  paste(preBook,"%")
})

#Return Journeys
output$txtRtn <- renderText({
  if(is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  tit <- ddply (allData, "Single_return", summarize, count = length(Cancelled))
  tit$Single_return  <- as.character(tit$Single_return)
  paste(tit[2,2])
})

#Carousel Collections
output$txtCCnD <- renderText({
  if(is.null(ready())) return(NULL)
  
  df <- Carousel()
  paste(length(df$Booking_reference))
})

##MAP: TAB 1#################################################################################
output$mapContainer <- renderMap({
  if (is.null(ready())) return(NULL)
  
  if(input$showMap == F)
    return(NULL)
  
  bookings <- bookingsRange()
  
  #restricting the number
  #bookings <- head(bookings, n= 20)
  
  # creating a sample data.frame with your lat/lon points
  #df  <- geocode(bookings$to)
  
  lon  <- as.numeric(gsub(".*\\:", "",bookings$Outward.Journey.Geo.code.for.drop.off.postcode))
  lat  <- as.numeric(gsub("\\:.*", "",bookings$Outward.Journey.Geo.code.for.drop.off.postcode))
  df <- data.frame(lon, lat)
  
  #create leaflet map
  map <- Leaflet$new()
  map$setView(c(51.507341, -0.127680), zoom = 10)
  map$tileLayer(provider = 'Stamen.TonerLite')
  #other interesting layers: Stamen.Watercolor, Esri.WorldStreetMap, Esri.NatGeoWorldMap
  #see all available tile layers @ http://leaflet-extras.github.io/leaflet-providers/preview/
  #loop through postcode markers
  for(i in 1:dim(df)[1]){
    map$marker(c(df[i,2],df[i,1]), bindPopup = paste(h3(bookings$Booking_reference[i]), 
                                                     as.character(bookings$Outward_Journey_Luggage_drop_off_location_Name[i]),
                                                     "<br>", as.character(em("items:")), as.character(bookings$Total_luggage_No[i]),
                                                     "<br>", as.character(em("delivery date:")), as.character(bookings$date[i]),
                                                     "<br>", as.character(em("scheduled:")), as.character(bookings$Outward_Journey_Luggage_drop_off_time[i]),
                                                     "<br>", as.character(em("booking value:")), as.character(bookings$Transaction_payment[i]), "GBP"
    ))
  }
  
  map
})

##GENERATING TABLES!!##############################################

#SUMMARY TABLE (TAB 1: SUMMARY)
output$contents  <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  sumBookings  <- contDate()
  #manipulating for prettyness
  #   sumBookings$Outward_Journey_Luggage_drop_off_date <- NULL
  #   sumBookings$meanBags  <- round(sumBookings$meanBags,1)
  #   sumBookings$netRevenue <- round(sumBookings$netRevenue,2)
  #   sumBookings$meanNetRevenue <- round(sumBookings$meanNetRevenue,2)
  
  sumBookings
  
}, options = list(pageLength = 10))

########TAB2##################################################

output$sumStats  <- renderText({
  if(input$radio==1){
    return("All time Summary")
  }
  else if(input$radio==2){
    return(paste("Summary for",range()[1]," to ",range()[2]))
  }
  else if(input$radio==3){
    return("Data for today only")
  }
})

#PIE CHARTS###############################################

#pie chart dimensions
WI <- 300 #set width
HI <- 300 #set height

#Sex
output$sex <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  tit <- ddply (allData, "Title", summarize, count = length(Cancelled))
  tit$Title  <- as.character(tit$Title)
  
  doughnut <- gvisPieChart(tit, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Sex (using title)',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.5),
                           chartid="doughnutSex")
  return(doughnut)
})

#Luggage Type
output$luggage <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  lug <- as.data.frame(matrix(ncol=2,nrow=2))
  lug[1,1] <- "Hand" 
  lug[1,2]  <- sum(allData$Hand_luggage_No)
  lug[2,1] <- "Hold"
  lug[2,2]  <- sum(allData$Hold_luggage_No)
  
  #inserting % into field name
  temp <- lug
  temp[,2] <- round(lug[,2]/sum(lug[,2]), digits = 2)*100
  temp[,1] <- paste(lug[,1], ': ',temp[,2],'%', sep='')
  lug[,1] <- temp[,1]
  
  doughnut <- gvisPieChart(lug, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Luggage type',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.5),
                           chartid="doughnutLug")
  return(doughnut)
})

#Journey Type
output$journey <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  tit <- ddply (allData, "Single_return", summarize, count = length(Cancelled))
  tit$Single_return  <- as.character(tit$Single_return)
  
  #inserting % into field name
  temp <- tit
  temp[,2] <- round(tit[,2]/sum(tit[,2]), digits = 2)*100
  temp[,1] <- paste(tit[,1], ': ',temp[,2],'%', sep='')
  tit[,1] <- temp[,1]
  
  doughnut <- gvisPieChart(tit, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Journey type',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.5),
                           chartid="doughnutJourney")
  return(doughnut)
})

#Delivery Type
output$type <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  #NOTE: REVISIT THIS AS IT IS CURRENTLY NOT CORRECT
  
  lug <- as.data.frame(matrix(ncol=2,nrow=3))
  lug[1,1] <- "Home" 
  lug[1,2]  <- sum(allData$Outward_Journey_Luggage_drop_off_location_Type=="Residential")
  lug[2,1] <- "Hotel"
  lug[2,2]  <- sum(allData$Outward_Journey_Luggage_drop_off_location_Type=="Hotel")
  lug[3,1] <- "Biz"
  lug[3,2] <- sum(allData$Outward_Journey_Luggage_drop_off_location_Type=="Business")
  lug[4,1] <- "Apt"
  lug[4,2] <- sum(allData$Outward_Journey_Luggage_drop_off_location_Type=="AirportTerminal")
  
  #inserting % into field name
  temp <- lug
  temp[,2] <- round(lug[,2]/sum(lug[,2]), digits = 2)*100
  temp[,1] <- paste(lug[,1], ':',temp[,2],'%', sep='')
  lug[,1] <- temp[,1]
  
  doughnut <- gvisPieChart(lug, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Deliveries by type (Airport is faulty)',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.3),
                           chartid="doughnutType")
  return(doughnut)
})

output$ZONE <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  dat <- ddply (allData, "Zone", summarize, count = length(Cancelled))
  dat$Zone  <- as.character(dat$Zone)
  
  dat2 <- dat
  dat2$count <- round(dat$count/sum(dat$count), digits = 2)*100
  dat2$Zone <- paste(dat$Zone, ': ',dat2$count,'%', sep='')
  dat$Zone <- dat2$Zone
  
  doughnut <- gvisPieChart(dat, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Zone Breakdown',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.5),
                           chartid="doughnut")
  return(doughnut)
})

output$DAY <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  dat <- ddply (allData, "day", summarize, count = length(Cancelled))
  #dat <- dat[order(as.Date(dat$day, format="%d"),]
  dat$day <- substring((as.character(dat$day)),1,3) 
  
  #inserting pct into name fields
  dat2 <- dat
  dat2$count <- round(dat$count/sum(dat$count), digits = 2)*100
  dat2$day <- paste(dat$day, ': ',dat2$count,'%', sep='')
  dat$day <- dat2$day
  
  doughnut <- gvisPieChart(dat, 
                           options=list(
                             width=WI,
                             height=HI,
                             title='Day Breakdown',
                             legend='none',
                             pieSliceText='label',
                             pieHole=0.35),
                           chartid="doughnut2")
  
})

##DELIVERIES/COLLECTIONS BY HOUR############################
output$hourPlot <- renderGvis({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  allData$Collection.Slot  <- strftime(strptime(allData$Outward_Journey_Luggage_Collection_time, format="%H:%M"), "%H")
  allData$Delivery.Slot  <- strftime(strptime(allData$Outward_Journey_Luggage_drop_off_time, format="%H:%M"), "%H")
  allData$Created.Time  <- strftime(strptime(allData$Booking_time, format="%H:%M"), "%H")
  
  time1.df <- ddply (allData, c("Collection.Slot"), summarize, collections = length(Cancelled))
  #time1.df$collectionsPCT <- time1.df/length(allData$Cancelled)*100
  names(time1.df)[1] <- "time"
  time2.df <- ddply (allData, c("Delivery.Slot"), summarize, deliveries = length(Cancelled))
  #time2.df$collectionsPCT <- time2.df/length(allData$Cancelled)*100
  names(time2.df)[1] <- "time"
  time3.df <- ddply (allData, c("Created.Time"), summarize, created = length(Cancelled))
  #time2.df$collectionsPCT <- time2.df/length(allData$Cancelled)*100
  names(time3.df)[1] <- "time"
  
  timeMin <- strptime("00:00", format="%H")
  timeMax <- strptime("23:00", format="%H")
  allTime  <- strftime(seq(timeMin,timeMax,by="hour"), "%H")
  
  allTime.df <- data.frame(list(time=allTime))
  
  Times <- merge(allTime.df,time1.df, all=T)
  Times <- merge(Times,time2.df, all=T)
  Times <- merge(Times,time3.df, all=T)
  Times$collections[which(is.na(Times$collections))] <- 0
  Times$deliveries[which(is.na(Times$deliveries))] <- 0
  Times$created[which(is.na(Times$created))] <- 0
  Times$time <- strftime(strptime(Times$time, format="%H"), "%H:%M")
  
  gvisLineChart(Times, options=list(
    title='Deliveries, collections and bookings created by hour slot', height=400, vAxis="{title:'no of bookings'}",
    hAxis="{title:'hour slot'}"))
  
})


#NATIONALITIES TABLE (TAB 2: STATISTICS)

output$nation  <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  nat.df <- ddply (allData, "country_origin", summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1), netRevenue = round(sum(Transaction_payment)/1.2))
  nat.df$avgRevenue <- round(nat.df$netRevenue/nat.df$bookings, digits=2)
  nat.df <- nat.df[with(nat.df,order(-bookings,-avgRevenue)), ]
  rownames(nat.df) <- NULL
  
  nat.df
}, options = list(pageLength = 5))

#REPEAT CUSTOMERS TABLE (TAB 2: STATISTICS)
reUser <- reactive({
  allData <- bookingsRange()
  #   if(grep("bagstorage@portr.com",allData$customer_email)){
  #     allData <- allData[- grep("bagstorage@portr.com",allData$customer_email), ]
  #   }
  
  reUser.df <- ddply (allData, "customer_email", summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1), netRevenue = round(sum(Transaction_payment)/1.2))
  reUser.df$avgRevenue <- round(reUser.df$netRevenue/reUser.df$bookings, digits=2)
  reUser.df <- reUser.df[with(reUser.df,order(-bookings,-avgRevenue)), ]
  reUser.df <- reUser.df[reUser.df$bookings>1,]
  rownames(reUser.df) <- NULL
  
  reUser.df
  
})

output$reUser  <- renderText({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  reUser.df <- reUser()
  
  reUser <- length(reUser.df$bookings)
  reUserpct <- round(reUser/length(allData$Cancelled),digits=3)*100
  paste("Repeat Users: ", reUser, "total, so about ",reUserpct,"%")
  
})

output$custom <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  reUser()
  
}, options = list(pageLength = 5))

#TABLE MAIN DELIVERY DESTINATIONS

output$loc <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  allData <- bookingsRange()
  
  loc.df <- ddply (allData, "Outward_Journey_Luggage_drop_off_location_Name", summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1), netRevenue = round(sum(Transaction_payment)/1.2))
  loc.df$avgRevenue <- round(loc.df$netRevenue/loc.df$bookings, digits=2)
  loc.df <- loc.df[with(loc.df,order(-bookings,-avgRevenue)), ]
  #loc.df <- loc.df[loc.df$bookings>1,]
  loc.df <- loc.df[loc.df$netRevenue>0,]
  #loc.df <- loc.df[- grep("Residential",loc.df$Outward_Journey_Luggage_drop_off_location_Name), ]
  #loc.df <- loc.df[- grep("Airportr",loc.df$Outward_Journey_Luggage_drop_off_location_Name), ]
  rownames(loc.df) <- NULL
  
  loc.df
  
}, options = list(pageLength = 10))

#Inbound Flights data table
output$inFlights <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  bookings <- bookingsRange()
  
  df <- ddply (bookings, "In.bound_flt_code", summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1), netRevenue = round(sum(Booking_value_gross_total)/1.2))
  df <- df[with(df, order(bookings, decreasing=T)),]
  
}, options = list(pageLength = 10))

#Inbound Flights data table
output$outFlights <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  bookings <- bookingsRange()
  
  df <- ddply (bookings, "Out.bound_flt_code", summarize, bookings = length(Cancelled), totalBags = sum(Total_luggage_No), meanBags = round(mean(Total_luggage_No),digits=1), netRevenue = round(sum(Booking_value_gross_total)/1.2))
  df <- df[with(df, order(bookings, decreasing=T)),]
  
}, options = list(pageLength = 10))

########TAB3##################################################


#TABLE CC&D BOOKINGS
output$CCnD <- renderDataTable({
  if (is.null(ready())) return(NULL)
  
  bookings <- Carousel()
  
  CC <- bookings[, c("Booking_reference", "Hand_luggage_No","Hold_luggage_No",
                     "Total_luggage_No","Customer_Firstname","customer_surname","country_origin", 
                     "Outward_Journey_Luggage_Collection_date", "Transaction_payment","In.bound_flt_code","Origin")]
  rownames(CC) <- NULL
  names(CC) <- c("Booking","Hand","Hold","Total","Name","Surname","Nat","Date","Value","Flight","Origin")
  
  CC
})
#Download Button
output$downloadCCnD <- downloadHandler(
  filename = function() { paste("CCnD",range()[1]," to ",range()[2], '.csv', sep='') },
  content = function(file) {
    write.csv(CarouselShort(), file)
  }
)