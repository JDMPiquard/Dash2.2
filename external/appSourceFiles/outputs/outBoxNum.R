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
output$grossRev  <- renderText({
  toCurrency(KPI()$netRevenue*1.2, round=0)
})
# Net revenue
output$netRev <- renderText({
  toCurrency(KPI()$netRevenue, compact=F)
})
# Total Poptential Booking Value
output$bookValue <- renderText({
  toCurrency(KPI()$potentialBookValue)
})
# Other Discounts
output$bookDiscounts <- renderText({
  toCurrency(KPI()$otherDiscounts)
})
# Promo Discounts
output$bookPromos <- renderText({
  toCurrency(KPI()$promoDiscounts)
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
