# JD for Portr LTD, June 2015
# UI and Graph output for Product Statistics tab
# 


div(
  # CC&D Summary Data
  fluidRow(
    div(class="statsContainer",
      fluidRow(
        column(8,
               h4("BA Carousel Collections")),
        column(4,
               downloadButton('downloadCCnD', 'Download extended version'))  #  Download BA report style
      ),
      
      # Summary Boxes: NOT IN USE
      fluidRow(
        column(4,
               htmlOutput("CC1")
        ),
        column(4,
               htmlOutput("CC2")
        ),
        column(4,
               htmlOutput("CC3")
        )
      ),
  
      # TABLE: CC&D Summary Stats
      fluidRow(style="margin-top:10px;",
        dataTableOutput(outputId="CCnD")
      )
    )
  ),

  # LGW EPOS REPORTS
  fluidRow(
    div(class="statsContainer",
      p(" "),
      fluidRow(
        column(8,
               h4("LGW EPOS Report")),
        column(4,
               downloadButton('downloadEPOS', 'Download EPOS report'))  #  Download BA report style
      )
  
  
  #     fluidRow(
  #       dataTableOutput(outputId="EPOS")
  #     )
    )
  ),

  # DOWNLOAD DEBUG REPORTS
  fluidRow(
    div(class="statsContainer",
      p(" "),
      fluidRow(
        column(8,
               h4("Download filtered bookings (DEBUG)")),
        column(4,
               downloadButton('downloadDEBUG', 'Download Filtered Bookings'))  #  Download BA report style
      )
  
  
  #     fluidRow(
  #       dataTableOutput(outputId="EPOS")
  #     )
    )
  )
)