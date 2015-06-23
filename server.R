



#  load up the header file
source('external/serverHead.R', local=T)

# load up main file with all the required server R script for clarity
shinyServer(function(input,output, clientData, session){
  source('external/app.R', local = T)
  })