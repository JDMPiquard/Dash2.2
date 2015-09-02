# JD for Portr LTD, June 2015
# List storing all KPI information
#

# KPI always shows the data as reflected 
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
  
  # the following use bookingsRange() instead of 
  preBook <- sum(grepl("prebook",df2$Department))/length(df2$Department)
  
  rtn <- ddply (df2, "Single_return", summarize, count = length(Cancelled))
  rtn$Single_return  <- as.character(rtn$Single_return)
  returnBookings <- paste(rtn[2,2])
  
  ccndBookings <- length(Carousel()$Booking_reference)
  
  # AVG BOOKING TIME
  IP.df <- IPs()[!(IPs()$ip_address %in% ipExclude),]  # exclude certain IPs
  preBookTime  <- median(IP.df$BookingTime, na.rm = T)

  
  return(
    list(
      bookings=bookings,
      bags=bags,
      netRevenue=netRevenue,
      grossRevenue=grossRevenue,
      avgBags=avgBags,
      netRevBooking=netRevBooking,
      preBook=preBook,
      returnBookings=returnBookings,
      ccndBookings=ccndBookings,
      preBookTime=preBookTime,
      otherDiscounts=otherDiscounts,
      promoDiscounts=promoDiscounts,
      potentialBookValue=potentialBookValue))
})