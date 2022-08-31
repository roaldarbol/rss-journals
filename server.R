#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    user_data <- eventReactive(input$user_opml, {
      file <- input$user_opml
      ext <- tools::file_ext(file$datapath)

      req(file)
      validate(need(ext == "opml", "Please upload an OPML file"))
      cat(file$datapath)

      xml2tibble(file$datapath)
    })

    output$user_table <- renderTable({
      user_data() %>%
        mutate(Journal = title) %>%
        select(Journal)
    })

  output$table <- renderDataTable({
    db %>%
      select(journal) %>%
      DT::datatable() %>%
      formatStyle("journal", "white-space" = "nowrap")
  })

  output$downloadCSV <- downloadHandler(
    filename = function() {
      paste('journal-rss-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      write.csv(db, con)
    }
  )

  output$downloadOPML <- downloadHandler(
    filename = function() {
      paste('journal-rss-', Sys.Date(), '.opml', sep='')
    },
    content = function(con) {
      opml <- generate_opml(db)
      cat(saveXML(opml), file = con)
    }
  )

})
