# Gatwick Download function
# NOT IN USE!! See Reactives



# Gatwick-defined codes: NOW DEFINED WITHIN SERVER.HEAD > does that make sense? unlikely to be used anywhere else
  # retailer <- "*AP*"
  # shopCode <- "*ShopCOde*"
  # shopText <- "*Shop Text*"
  # # the following will be product dependent
  # catCode <- "*advised by GAL - Product Dependent*"
  # catText <- "*advised by GAL - Product Dependent*"
  # subCatCode <- "*advised by GAL - Product Dependent*"
  # subCatText <- "*advised by GAL - Product Dependent*"

# FILTER
  dates <- c(as.Date("2014-05-22", format= "%Y-%m-%d"),Sys.Date())
  bookLGW <- bookFilter(bookings,("Gatwick"),dates,onlyNonZero=T,rangeMode=T,includeServiceCenters=input$incStorage)

# CLEAN UP
  # finding the correct flights
  bookLGW$flightLGW <- ifelse(bookLGW$filterCollect,
   bookLGW$In.bound_flt_code,
   bookLGW$Out.bound_flt_code)
  # converting time and date to necessary format
  bookLGW$transactionTime <- strftime(strptime(bookLGW$transactionTime, format="%H:%M:%S"), "%H%M%S")
  bookLGW$date <- strftime(strptime(bookLGW$date,format="%Y-%m-%d"),"%Y%m%d")
  
  l <- length(bookLGW$Cancelled)
# initial strings
info1 <- as.data.frame(matrix(nrow=l,ncol=2))
info1[,1] <- retailer
info1[,2] <- shopCode
info1[,3] <- shopText
names(info1) <- c("Retailer","Shop Code","Shop Text")

# initial data
  # NEED TO ADD CORRECT TRANSACTION TIME
data1 <- bookLGW[,c("date","transactionTime","Booking_reference")]
names(data1) <- c("Transaction Date","Transaction Time","Transaction ID")

# second set of strings
info2 <- as.data.frame(matrix(nrow=l,ncol=2))
info2[,1] <- catCode
info2[,2] <- catText
names(info2) <- c("Category Code", "Category Text")

# second set of data
data2 <- bookLGW[,c("Transaction_payment","Total_product_number","flightLGW","Product_ID_numbers","Product_name")]
names(data2) <- c("Net Value","Quantity","Flight Number","Product Code","Product Text")

# third set of strings
info3 <- as.data.frame(matrix(nrow=l,ncol=2))
info3[,1] <- subCatCode
info3[,2] <- subCatText
names(info3) <- c("Sub Category Code", "Sub Category Text")

# combine columns
lgwEposReport <- cbind(info1,data1,info2,data2,info3)
rownames(lgwEposReport) <- NULL
