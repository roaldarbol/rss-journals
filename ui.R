#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(
  navbarPage(
    "Journal RSS",
    theme = shinytheme("spacelab"),

    # Application title
    tabPanel(
      "Download",
      sidebarLayout(
        sidebarPanel(
          downloadButton('downloadOPML', 'Download as OPML'),
          downloadButton('downloadCSV', 'Download as CSV')
        ),
        mainPanel(
          DT::dataTableOutput('table')
        )
      )
    ),

    tabPanel(
      "Convert",
      sidebarLayout(
        sidebarPanel(
          fileInput("user_opml", "Choose OPML File", accept = c(".opml", ".xml")),
          conditionalPanel(condition = "output.fileUploaded",
            downloadButton('downloadUserCSV', 'Download as CSV')
          )
        ),

        mainPanel(
          DT::dataTableOutput('user_table')
        )
      )
    ),

    tabPanel(
      "About",
      fluidRow(
        column(9,
               htmltools::includeMarkdown("README.md")
        )
      )
    )
  )
)
