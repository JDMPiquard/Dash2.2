# JD for Portr LTD, June 2015
# Boxed Number Outputs
#

# bookings
output$W  <- renderText({
  KPI()$bookings
})
# bags
output$X  <- renderText({
  KPI()$bags
})
# Gross revenue
output$Y  <- renderText({
  paste(round(KPI()$netRevenue*1.2),"GBP")
})
# avg bags
output$mX  <- renderText({
  KPI()$avgBags
})
# gross revenue per booking
output$mY  <- renderText({
  paste(round(KPI()$netRevBooking*1.2, digits = 2),"GBP")
})
# Pre-bookings
output$preBook <- renderText({
  paste(round(KPI()$preBook*100, digits=2),"%")
})
# Return Journeys
output$txtRtn <- renderText({
  KPI()$returnBookings
})
# Carousel Collections
output$txtCCnD <- renderText({
  paste(KPI()$ccndBookings)
})
# Pre Booking Time, excluding Airport and office IP addresses
output$preBookTime <- renderText({
  paste(KPI()$preBookTime,"mins")
})
