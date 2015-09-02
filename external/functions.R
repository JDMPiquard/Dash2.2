# JD for Portr LTD
# Generic functions for use with MI


# Subset by airport

# ISOLATE AND MATCH STORAGE BOOKINGS: Not Complete
storageMerge <- function(df){
  # Generates a unique bookings table, combining storage bookings into a single row

  toStorage <- df[
    (grepl('luggage storage',  # find "Luggage Storage locations"
      df$Outward_Journey_Luggage_drop_off_location_Name, ignore.case=TRUE)
      &df$Single_return!="Return")  # exclude Return bookings since  should already be correct
    ,]
  rownames(toStorage) <- NULL

  fromStorage <- df[
    (grepl('luggage storage',
      df$Outward_Journey_Luggage_collection_location_Name, ignore.case=TRUE)
      &df$Single_return!="Return")
    ,]
  rownames(fromStorage) <- NULL

  # Most definitely not foolproof
  toStorage$uqID  <- paste(toStorage$Booking_date,
    toStorage$Outward_Journey_Luggage_drop_off_location_Name,
    toStorage$Hand_luggage_No,
    toStorage$Hold_luggage_No)
  fromStorage$uqID  <- paste(fromStorage$Booking_date,
    fromStorage$Outward_Journey_Luggage_collection_location_Name,
    fromStorage$Hand_luggage_No,
    fromStorage$Hold_luggage_No)

  # 
  matchStore <- match(toStorage$uqID,fromStorage$uqID)  # find any matches
  matchNA <- which(is.na(matchStore)) # find the indices of the ones returning NA
  tempDuplicate <- (duplicated(matchStore)|duplicated(matchStore, fromLast=TRUE))
  matchDuplicates <- matchStore[tempDuplicate]
  matchStore <- matchStore[-tempDuplicate]

  # Idea would be to:
  # - find matches between toStorage and fromStorage
  # - remove NA and duplicates, and apply different filters to it
  #   > factors to use for match: 'booking date + storage location + luggage Nos', pax e-mail, pax name, calculate total number of matches for each 
  # - use the cleaned version of the above to find which bookings refer to each Other
  # - refactor list with new collection and delivery dates

  # >> this can then be used to
  # - identify booking as storage
  # - calculate correct transaction value
  # - calculate average number of days in storage
  # etc.

}

# MAIN FILTER FUNCTION
bookFilter <- function(df, airports, range, onlyNonZero = F, rangeMode = F, excludeInternal = F){
  # Subsets data frame by airport and booking dates (optional)
  #
  # Args:
  #   df: MI data.frame, may require to be cleaned up
  #   airports: vector of airports to show (a string may be used if only one airport is required)
  #   range: optional vector with dates range to show (only used if rangeMode is set to True)
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
summarizeMI <- function(df, index, pretty = F){
  # applies ddply, summarizing df over index
  #
  # Args:
  #
  # Returns:
  # 
  # Note that totalDiscounts was disabled since its value is non reliable


  temp <- ddply(df, index, summarize,
    bookings = length(Cancelled), 
    totalBags = sum(Total_luggage_No), 
    meanBags = round(mean(Total_luggage_No),digits=1), 
    netRevenue = round((sum(Booking_value_gross_total) - sum(Transaction_payment_credit))/1.2, digits=2),
    promoDiscounts = -(sum(Booking_value_total_promotional_discount) + sum(AirPortr_user_booking_value_price_adjustment)),
    otherDiscounts = -(-sum(AirPortr_user_booking_value_price_adjustment) + sum(Transaction_payment_credit))
  )
  temp$meanNetRevenue <- round(temp$netRevenue/temp$bookings, digits = 2)
  temp$meanGrossRevenue <- round(temp$meanNetRevenue*1.2, digits = 2)

  if (pretty){  # cleans up temp into a compact data frame for use with summary tables
    temp <- temp[c(index,"bookings","totalBags","meanBags","netRevenue","promoDiscounts","meanGrossRevenue")]
    temp$netRevenue <- sapply(temp$netRevenue*1.2,toCurrency)
    temp$promoDiscounts <- sapply(temp$promoDiscounts,toCurrency)
    #temp$meanGrossRevenue <- sapply(temp$meanGrossRevenue,toCurrency)

    # use shorter names for a more compact table
    colnames(temp) <- c(index,"bkgs","bags","avgBag","Revenue","promos","avgRevenue")

    # reorder according to relevance
    temp <- temp[with(temp,order(-bkgs,-avgRevenue)), ]
    rownames(temp) <- NULL
  }
  
  return(temp)
}

# PRETTIFY CURRENCY NUMBERS 
toCurrency <- function(num, currency = 'GBP', compact=T, round=2){
  
  if (is.null(ready())) return('...')

  # Determine the currency format
  if (currency == 'GBP'){
    pre <- '£'
    suf <- ' GBP'
  }
  else {
    pre <- '$'
    suf <- paste(' ', currency, collapse = '')
  }

  # Determine how it should be formatted
  if (compact){
    pre <- pre
    suf <- ''
  }
  else {
    pre <- ''
    suf <- suf
  }

  if(num<0){
    pre <- paste('-',pre)
    num <- -1*num
  }

  # Generate the prettified string
  paste(pre,
    format(
      round(num, round), 
      big.mark=','),
    suf, collapse = '')

}
