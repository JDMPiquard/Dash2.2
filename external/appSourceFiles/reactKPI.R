# JD for Portr LTD, June 2015
# List storing all KPI information
#

# KPI always shows the data as reflected 
# convert the below into a function, for all time ?
KPI <- reactive({
  if(is.null(ready())) return(list(NULL))

  # Note that it is now possible to create an alltime baseline KPI by calling the Summary Function
  
  df  <- sumDate() # used where possible
  # where chages in calculation methods are required, please refer to the summarizeMI function
  df2 <- bookingsRange() # used where sumDate does not provide the calculation
  
  # booking totals
  bookings <- sum(df$bookings)
  # total bags
  bags <- sum(df$totalBags)
  # net revenue - note the subtraction of payment credit is handled within summarizeMI function
  netRevenue <- sum(df$netRevenue)
  # 
  grossRevenue <- netRevenue*1.2
  #
  avgBags <- round(sum(df$totalBags)/sum(df$bookings), digits = 1)
  #
  netRevBooking <- sum(df$netRevenue)/sum(df$bookings)
  #
  promoDiscounts <- sum(df$promoDiscounts)
  #
  otherDiscounts <- sum(df$otherDiscounts)
  #
  potentialBookValue <- grossRevenue - promoDiscounts - otherDiscounts
  
  # the following use bookingsRange()/df2 instead of sumDate()/df


  # All time repeat users (with more than one booking)
  reUser.alltime <- summarizeMI(all(), "customer_email", pretty=T)
  reUser.alltime <- reUser.alltime[reUser.alltime$bkgs>1,]

  # Repeat Users within date range
  customerEmails <- ddply(df2, "customer_email", summarize, inThisRange=length(Cancelled))
  customerTotal <- length(customerEmails[,1])

  # repeat users within range()
  reUser.alltime$inRange <- (grepl(paste(customerEmails[,1], collapse='|'),
      reUser.alltime$customer_email,ignore.case=TRUE)
    &!grepl(paste(eMailExclude, collapse='|'),
      reUser.alltime$customer_email,ignore.case=TRUE))
  reUser.df <- merge(reUser.alltime[reUser.alltime$inRange==1,],customerEmails,all.x=TRUE, sort=FALSE)
  reUser.df$inRange <- NULL

  # repeat user stats
  reUserTotal <- length(reUser.df[,1])
  reUserPct <- reUserTotal/customerTotal

  #
  preBook <- sum(grepl("prebook",df2$Department))/length(df2$Department)
  #
  rtn <- ddply (df2, "Single_return", summarize, count = length(Cancelled))
  rtn$Single_return  <- as.character(rtn$Single_return)
  returnBookings <- paste(rtn[2,2])
  #
  directionToApt <- sum(grepl("GeneralLocationToAirport",df2$Journey_direction))/length(df2$Journey_direction)
  #
  ccndBookings <- length(Carousel()$Booking_reference)
  
  # AVG time taken to book online - excluding known Portr IPs
  IP.df <- IPs()[!(IPs()$ip_address %in% ipExclude),]  # exclude certain IPs
  completeBookTime  <- median(IP.df$BookingTime, na.rm = T)

  # On Time Delivery ratings
  # df2$actualDelivery <- ifelse(
  #   df2$Outward.Journey.Actual.drop.off.individual>df2$Outward.Journey.Actual.drop.off.trunk,
  #   df2$Outward.Journey.Actual.drop.off.individual,
  #   df2$Outward.Journey.Actual.drop.off.trunk)
  

  # Avg PreBook Lead time
  preBooks.df <- subset(df2, Department=="prebook")
  preBookLeadTime <- mean(preBooks.df$Booking_lead_time, na.rm = T)

  
  return(
    list(
      bookings=bookings,
      bags=bags,
      netRevenue=netRevenue,
      grossRevenue=grossRevenue,
      avgBags=avgBags,
      netRevBooking=netRevBooking,
      preBook=preBook,
      preBookLeadTime=preBookLeadTime,
      returnBookings=returnBookings,
      directionToApt=directionToApt,
      ccndBookings=ccndBookings,
      completeBookTime=completeBookTime,
      otherDiscounts=otherDiscounts,
      promoDiscounts=promoDiscounts,
      potentialBookValue=potentialBookValue,
      reUserTotal=reUserTotal,
      reUserPct=reUserPct,
      reUser.df=reUser.df,
      customerTotal=customerTotal
      ))
})

#  KPI2() can potentially be added to enable comparison of KPIs

#  Repeat users