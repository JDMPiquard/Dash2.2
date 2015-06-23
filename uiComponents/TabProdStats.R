# JD for Portr LTD, June 2015
# UI and Graph output for Product Statistics tab
# 

# CC&D Summary Data
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
    fluidRow(class = "statsContainer",
      dataTableOutput(outputId="CCnD")
    )
)