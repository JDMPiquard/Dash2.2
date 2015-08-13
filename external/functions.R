# JD for Portr LTD
# Generic functions for use with MI


# MAIN FILTER FUNCTION
bookFilter <- function(df, airports, range, onlyNonZero = F, rangeMode = F, excludeInternal = F){
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
  #   Data frame with only the relevant rows. Also adds new "filter" columns to data.frame
  
  if(excludeInternal){
  	df$notInternal  <- (  #  creates a list of TRUE for every internal booking
     !grepl(paste(internalAddresses,collapse="|"),  # Find internal address names
      df$Outward_Journey_Luggage_collection_location_Name,ignore.case=TRUE)
     |!grepl(paste(internalAddresses,collapse="|"),  # Find internal address names
      df$Outward_Journey_Luggage_drop_off_location_Name,ignore.case=TRUE)
     &ifelse(df$Transaction_payment == 0,0,1)
    )

    df <- df[df$notInternal == 1,]
  }
  
  # allow toggling of showing zero value bookings NOTE: Issue
  if(onlyNonZero){
    df <- subset(df, Booking_value_gross_total > 0) #exclude promotional or internal deliveries
  }
  else{df <- subset(df, Booking_value_gross_total >= 0)}
  
  # REPORT MODE OPTION
  if(rangeMode){
    df <- subset(df, date>=range[1]&date<=range[2])
  }
  
  # filtering by airport
  # THIS VERSION OF THE FILTER NOW SEEMS TO BE WORKING
  df$filterCollect  <- 
    (grepl(paste(airports,collapse="|"),  # Find airport names
      df$Outward_Journey_Luggage_collection_location_Name,ignore.case=TRUE)
     &grepl("airportterminal",  # Only accept those marked as airports
      df$Outward_Journey_Luggage_collection_location_Type,ignore.case=TRUE)
     &!grepl("storage",  # Ignore luggage storage options
      df$Outward_Journey_Luggage_collection_location_Name,ignore.case=TRUE)
    )|(
      grepl("storage",
        df$Outward_Journey_Luggage_collection_location_Name,ignore.case=TRUE)
      &sum(grepl('Other',
        airports,ignore.case=T))
    )
  
  df$filterDrop <- 
    (
      grepl(paste(airports,collapse="|"),
            df$Outward_Journey_Luggage_drop_off_location_Name,ignore.case=TRUE)
      &grepl("airportterminal",
             df$Outward_Journey_Luggage_drop_off_location_Type,ignore.case=TRUE)
      &!grepl("storage",
              df$Outward_Journey_Luggage_drop_off_location_Name,ignore.case=TRUE)
    )|(
      grepl("storage",
            df$Outward_Journey_Luggage_drop_off_location_Name,ignore.case=TRUE)
      &sum(grepl('Other',
                 airports,ignore.case=T)))
  
  df$filter <- df$filterDrop|df$filterCollect

  df <- df[df$filter == 1,]
  
  return(df)
}

#  SUMMARIZE FUNCTION

