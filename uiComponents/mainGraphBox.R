#  JD for Portr, June 2015
#  UI for the main graph box
# 

div(
  fluidRow(
    column(12,  
      ##Title
      fluidRow(
        div(class="sectionTitle",
          h4(textOutput("selectedAirports"), style="color: #36648B")
        )
      ),
          
      ##Main
      fluidRow(
        htmlOutput("MAIN")
      )
    ) 
  )  
)