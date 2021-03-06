#  JD for Portr, June 2015
#  Shiny UI page for Internal Dashboard
#  /Users/JD/OneDrive/AirPortr/Analytics/ShinyDashOne/Dash2.2

require(shiny)
require(rCharts)
require(plyr)
require(lubridate)
require(ggmap)
require(ggplot2)
require(googleVis)

shinyUI(fluidPage(
  
  tags$head(
  	# set tab title
    HTML("<title>Portr Operations Dash</title>"),
    # add custom CSS
    tags$link(rel="stylesheet", type="text/css", href="stylePortr.css"),
    tags$link(href='https://fonts.googleapis.com/css?family=Arimo:400,700', rel='stylesheet', type='text/css')
  ),
  
  div(class="mainBody", 
      
	# INPUTS BOX
	source("uiComponents/inputsBox.R",local=T)$value,
      
    ##LINE BREAK INTO SELECTED PERIOD DATA
    fluidRow(
      p(" ")
    ),

    column(12,
      div(class="sectionTitle",
        style="margin-bottom: 25px;
        text-align: center",
        h4(textOutput("selectedAirports"), style="color: #36648B")
      )
    ),
      
    # TABS!!!
    tabsetPanel(id='main',
                  
      # TAB 1: Standard Dashboard
      tabPanel('Dashboard',

        fluidRow(p(" ")),

        # MAIN TOP CHARTS
        source("uiComponents/mainGraphBox.R",local=T)$value,

        # SUMMARY OUTPUT BOXES
        source("uiComponents/statBoxes.R",local=T)$value

      ),

      # TAB 2: Summary View
      tabPanel('Summary',
        source("uiComponents/Tab1Summary.R",local=T)$value   
      ),

      # TAB 2: KPI Analysis
      # tabPanel('KPI Analysis',
      #   source("",local=T)$value   
      # ),

      # TAB 3: General Statistics
      tabPanel('General Statistics',
      	source("uiComponents/TabStatistics.R",local=T)$value                    
      ),
   
      #  TAB 4: Produt Statistics & Downloads
      tabPanel('Download Summaries and Reports',
      	source("uiComponents/TabProdStats.R",local=T)$value
      )
                  
    )#closing tabs altogether

  )
))