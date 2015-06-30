# JD for Portr LTD
# Generic functions for use with MI


# MAIN FILTER FUNCTION
bookFilter <- function(df, airports, range, onlyNonZero = F, rangeMode = F){
  # Subsets data frame by airport and booking dates (optional)
  #
  # Args:
  #   df: MI data.frame, may require to be cleaned up
  #   airports: vector of airports to show (a string may be used if only one airport is required)
  #   range: optional vector with dates range to show (only used if Range is set)
  #   onlyNonZero: if True, only shows bookings with value above zero
  #   rangeMode: if True, also filters data frame by booking date, requires range argument to be set
  #
  # Returns:
  #   Data frame with only the relevant rows
  
  # allow toggling of showing zero value bookings
  if(onlyNonZero){
    df <- subset(df, Transaction_payment > 0) #exclude promotional or internal deliveries
  }
  else{df <- subset(df, Transaction_payment >= 0)}
  
  # REPORT MODE OPTION
  if(rangeMode){
    df <- subset(df, date>=range[1]&date<=range[2])
  }
  
  # filtering by airport
  # THIS VERSION OF THE FILTER NOW SEEMS TO BE WORKING
  df$filter  <- 
    (grepl(paste(airports,collapse="|"),  # Find airport names
      df$Outward_Journey_Luggage_collection_location_Name,ignore.case=TRUE)
     &grepl("airportterminal",  # Only accept those marked as airports
      df$Outward_Journey_Luggage_collection_location_Type,ignore.case=TRUE)
     &!grepl("storage",  # Ignore luggage storage options
      df$Outward_Journey_Luggage_collection_location_Name,ignore.case=TRUE)
    )|(
      grepl(paste(airports,collapse="|"),
        df$Outward_Journey_Luggage_drop_off_location_Name,ignore.case=TRUE)
      &grepl("airportterminal",
        df$Outward_Journey_Luggage_drop_off_location_Type,ignore.case=TRUE)
      &!grepl("storage",
        df$Outward_Journey_Luggage_drop_off_location_Name,ignore.case=TRUE)
    )|(
      grepl("storage",
        df$Outward_Journey_Luggage_collection_location_Name,ignore.case=TRUE)
      &sum(grepl('Other',
        airports,ignore.case=T))
    )|(
      grepl("storage",
        df$Outward_Journey_Luggage_drop_off_location_Name,ignore.case=TRUE)
      &sum(grepl('Other',
        airports,ignore.case=T)))

  df <- df[df$filter == 1,]
  
  return(df)
}