# JD for Portr LTD, June 2015
# Display map with delivery locations
#

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
