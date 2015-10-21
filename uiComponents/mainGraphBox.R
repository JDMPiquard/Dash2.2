#  JD for Portr, June 2015
#  UI for the main graph box
# 

div(
  fluidRow(       
      ##Main
      column(12,
        div(class="card",
          h6("Month by month performance"),
          htmlOutput("MAIN")
        )
      ),

      
      column(6,
        div(class="card",
          h6("Cummulative performance"),
          htmlOutput("yearCum")
        )
      ),

      column(6,
        div(class="card",
          h6("Report"),
          div(style="padding: 10px;",
            uiOutput("copyPasteReport")
          )
        )
      )
      
     
  )  
)