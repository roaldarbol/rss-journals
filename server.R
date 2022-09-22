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

      xml2tibble(file$datapath) %>%
        select(title, xmlUrl, htmlUrl) %>%
        rename(
          journal = title,
          xml_url = xmlUrl,
          html_url = htmlUrl,
          )
    })

    output$fileUploaded <- reactive({
      if(!is.null(input$user_opml))
        return(TRUE)
    })

    outputOptions(output, 'fileUploaded', suspendWhenHidden=FALSE)

    output$user_table <- DT::renderDataTable(server = FALSE, {
      user_data() %>%
          select(journal, xml_url) %>%
          rename(
            Journal = journal,
            RSS = xml_url
          ) %>%
      datatable(
        selection = "none",
        filter="top",
        rownames = FALSE,
        extensions = c("Buttons", "Select"),

        options = list(
          select = TRUE,
          dom = 'Blfrtip',
          buttons =
            list('copy')#, 'print')
              #    list(
              # extend = 'collection',
              # buttons = list(
              #   # list(extend = 'opml', filename = "File", title = NULL,
              #   #      exportOptions = list(modifier = list(selected = TRUE))),
              #   list(extend = 'csv', filename = "File", title = NULL,
              #        exportOptions = list(modifier = list(selected = TRUE))),
              #   list(extend = 'excel', filename = "File", title = NULL,
              #        exportOptions = list(modifier = list(selected = TRUE)))),
              # text = 'Download'
            # )
        # )
        ),
        class = "display"
      )


      # user_data() %>%
      #   select(journal, xml_url) %>%
      #   rename(
      #     Journal = journal,
      #     RSS = xml_url
      #   ) %>%
      #   DT::datatable() %>%
      #   formatStyle("Journal", "white-space" = "nowrap")
    })

  output$table <- DT::renderDataTable(server = FALSE, {
    db %>%
      select(journal, xml_url) %>%
      rename(
        Journal = journal,
        RSS = xml_url
      ) %>%
      DT::datatable(
        selection = "none",
        filter="top",
        rownames = FALSE,
        extensions = c("Buttons", "Select"),

        options = list(
          select = TRUE,
          dom = 'Blfrtip',
          buttons =
            list('copy')
        ),
        class = "display"
      )
  })

  output$downloadCSV <- downloadHandler(
    filename = function() {
      paste('journal-rss-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      if (!is.null(input$table_rows_selected)){
        selection <- db[input$table_rows_selected, -1]
      } else {
        selection <- db[,-1]
      }
      write.csv(selection, con)
    }
  )

  output$downloadUserCSV <- downloadHandler(
    filename = function() {
      paste('user-journal-rss-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      user_db <- user_data()
      if (!is.null(input$user_table_rows_selected)){
        selection <- user_db[input$user_table_rows_selected, ]
      } else {
        selection <- user_db
      }
      write.csv(selection, con)
    }
  )


  output$downloadOPML <- downloadHandler(
    filename = function() {
      paste('journal-rss-', Sys.Date(), '.opml', sep='')
    },
    content = function(con) {
      if (!is.null(input$table_rows_selected)){
        selection <- db[input$table_rows_selected, ]
      } else {
        selection <- db
      }
      opml <- generate_opml(selection)
      cat(saveXML(opml), file = con)
    }
  )

})
