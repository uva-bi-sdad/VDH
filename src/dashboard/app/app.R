# VDH Dashboard prototype - using random data

# read details of ?selectizeInput for speedup

library(shiny)
library(shinydashboard)
library(dashboardthemes)
library(shinydashboardPlus)
library(shinyWidgets)
library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
#library(gganimate)
library(leaflet)
#library(DT)
library(RColorBrewer)
library(formattable)
library(plotly)
library(stringr)
library(openxlsx)
library(sf)
library(data.table)

#
# DATA INGESTION -------------------------------------------------------
#

# random test data
tract_data <- readRDS("prototype_data.rds")
#cty_data <- readRDS("test_cty_data.rds")



# color palettes -------------------

oranges <- brewer.pal(n=6, name = 'Oranges')


#
# USER INTERFACE ---------------------------------------------------------------------------
#

ui <- dashboardPage(
  title = "Virginia Department of Health",
  
  # header menu -----------------------------------------------------------------
  
  header = dashboardHeader(
    title = span("Virginia Department of Health", style = "font-size: 14px"),
    #titleWidth = 350,
    #leftUi = tagList(
      
      # dropdownBlock(
      #   id = "county",
      #   title = strong("Choose County"),
      #   #icon = icon("sliders"),
      #   badgeStatus = NULL,
      #   #pickerInput(
      #   selectInput(
      #     inputId = "cty",
      #     label = "Choose a County",
      #     choices = c("All Counties", unique(tract_data$county_name)[sort.list(unique(tract_data$county_name))]),
      #     selected = "Accomack"
      #     #selectize = TRUE)
      #   )
      # ),
      
      dropdownBlock(
        id = "download",
        title = strong("Data Download"),
        #icon = icon("sliders"),
        badgeStatus = NULL,
        prettyRadioButtons(
          inputId = "download_choice",
          label = "Choose Download:",
          choices = c("Health Access")
        ),
        downloadButton("downloadData", "Download") 
      )
      
    #)
  ),
  
  # sidebar menu ------------------------------------------------------
  
  sidebar = dashboardSidebar(
    sidebarMenu(
      hr(),
      menuItem(text = "Community Capital Areas", tabName = "capitals", icon = icon("list-ol")),
      menuItem(text = "Financial", tabName = "financial", icon = icon("money-check-alt")),
      menuItem(text = "Human", tabName = "human", icon = icon("child"),
               menuSubItem("Health Care Access", tabName = "health_access")),
      menuItem(text = "Social", tabName = "social", icon = icon("handshake")),
      menuItem(text = "Natural", tabName = "natural", icon = icon("tree")),
      menuItem(text = "Built", tabName = "built", icon = icon("home")),
      menuItem(text = "Political", tabName = "political", icon = icon("landmark")),
      menuItem(text = "Cultural", tabName = "cultural", icon = icon("theater-masks")), 
      hr(),
      menuItem(text = "Data and Methods", tabName = "data", icon = icon("info-circle"),
               menuSubItem(text = "Measures Table", tabName = "datamethods"),
               menuSubItem(text = "Data Descriptions", tabName = "datadescription")),
      menuItem(text = "Resources", tabName = "resources", icon = icon("book-open"),
               menuSubItem(text = "Bibliography", tabName = "biblio")),
      menuItem(text = "About Us", tabName = "contact", icon = icon("address-card"))
    )
  ),
  
  
  # dashboard body ----------------------------------------------------
  
  body = dashboardBody(
    
    tabItems(
      
      
      #
      # HEALTH ACCESS ----------------------------------------------
      #
      
      tabItem(
        tabName = "health_access",
        
        tabsetPanel(
          type = "tabs",
          
          # Home Tab ------------------
          tabPanel(
            "Home", 
            br(),
            p("landing page. maybe some overall state data, explanation of measures, etc.")),
          
          # Local Health Districts -------------------
          tabPanel(
            "Local Health District Data", 
            br(),
            p("composite and measures. state map in local health districts. compare across health districst.")),
          
          # County ------------------------------
          tabPanel(
            "County Data", 
            br(),
            p("composite and measures. state map in counties. compare across counties")),
          
          # Census Tract ------------------------------
          tabPanel(
            "Census Tract Data",
            br(),
            p("composite and measures. county map by tracts. compare within county"),
              
              # Composite Map ---------------------
              
            fluidRow(
              column(
                width = 4,
                  selectInput(
                    inputId = "cty",
                    label = "Choose a County",
                    choices = c(unique(tract_data$county_name)[sort.list(unique(tract_data$county_name))]),
                    selected = "Accomack"
                    #selectize = TRUE)
                  )
              )
            ),
            
              fluidRow(
                
                column(
                  width = 12,
                  
                  box(
                    title = "Health Care Access Composite Measure",
                    width = 12,
                    collapsible = TRUE,
                    leafletOutput("health_access_comp_map")
                  )
                )
              ),
              
              
              # Measure Plots ------------------
              
              # row 1 --------------------------
              
              fluidRow(
                
                column(
                  width = 4,
                  
                  box(
                    title = "Unemployment Percentage",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m1_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
    
                  box(
                    title = "Percentage Living Under Poverty Line",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m2_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
                  
                  box(
                    title = "Median Household Income",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m3_plot", height = "250px")
                  )
                )
              
              ),
              
              
              # row 2 --------------------------
              
              fluidRow(
                
                column(
                  width = 4,
                  
                  box(
                    title = "Percentage Household with Internet Subscription",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m4_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
                  
                  box(
                    title = "Percentage Acres of Park Land",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m5_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
                  
                  box(
                    title = "Gini Coefficient",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m6_plot", height = "250px")
                  )
                )
                
              ),
              
              
              # row 3 -----------------------------
              
              fluidRow(
                
                column(
                  width = 4,
                  
                  box(
                    title = "Percentage with Health Insurance Coverage",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m7_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
                  
                  box(
                    title = "Percentage Having Poor Mental Health More Than 14 Days Per Month",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m8_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
                  
                  box(
                    title = "Percentage Having Poor Physical Health More Than 14 Days Per Month",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m9_plot", height = "250px")
                  )
                )
                
              ),
              
              # row 4 ----------------------------------
              
              fluidRow(
                
                column(
                  width = 4,
                  
                  box(
                    title = "Total Jobs",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m10_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
                  
                  box(
                    title = "Percentage of Jobs in Young Firms",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m11_plot", height = "250px")
                  )
                )
                
              )
          )
        )
              
              
              
      )
      
      
      # Next tab here
    )
  )
)




#
# SERVER ----------------------------------------------------------------------------------------------------
#

server <- function(input, output, session) {
  
  # map events
  
  observeEvent(input$health_access_comp_map_shape_click, {
    click <- input$health_access_comp_map_shape_click
    print(click$id)
  })
  
  
  # reactive data filter for chosen year and installation
  
  county_data <- reactive({
    
    if(input$cty == "All Counties")
    {
      #cty_data
    }
    else
    {
      tract_data %>%
        filter(county_name == input$cty)
    }
    
  })  
  
  
  # leaflet map for health access composite ------------------------------------------
  
  output$health_access_comp_map <- renderLeaflet({
    
      map_data <- county_data() %>%
        filter(year == 2019)
      
      labels <- lapply(
        paste("<strong>County: </strong>",
              map_data$county_name,
              "<br />",
              "<strong>Census Tract: </strong>",
              map_data$tract_name,
              "<br />",
              "<strong>Health Access Score: </strong>",
              paste0(100*round(map_data$health_access, 2), "%") 
        ),
        htmltools::HTML
      )
      
      # I think the problem is in the palette
      pal <- colorQuantile(palette ="Oranges", domain = tract_data[tract_data$year == 2019, ]$health_access, 
                           probs = seq(0, 1, length = 6), na.color = oranges[6], right = FALSE)

    
    leaflet(data = map_data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = ~pal(health_access), 
        fillOpacity = 0.7, 
        stroke = TRUE, smoothFactor = 0.7, weight = 0.5, color = "#202020",
        popup = ~labels,
        layerId = ~census_tract_fips
        #   labelOptions = labelOptions(
        #     direction = "bottom",
        #     style = list(
        #       "font-size" = "12px",
        #       "border-color" = "rgba(0,0,0,0.5)",
        #       direction = "auto"
        #       )
        #   )
      ) %>%
      addLegend(
        position = "bottomleft",
        pal = pal,
        values =  ~health_access,
        title = "Health Access Score",
        opacity = 0.7,
        na.label = "Not Available")
    
  })
  
  
  output$m1_plot <- renderPlotly({

    # line plot of all tracts in county
    p <- plot_ly(
      type = 'scatter',
      x = county_data()$year,
      y = county_data()$pct_pop_unemploy,
      text = paste0("Tract ", county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = county_data()$tract_name
        )
      ),
      showlegend = FALSE
    ) %>% layout(
        #title = "Measure 1 Over Time",
        #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
        xaxis = list(
          title = "Year",
          zeroline = FALSE
          #showticklabels = FALSE
        ),
        yaxis = list(
          title = "Value",
          type = "numeric", hoverformat = ".2f",
          zeroline = FALSE
          #showticklabels = FALSE
        )
        #autosize = F, height = 500
      )
    
    p
    
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
   
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("m1_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 1)
      
      click_data <- county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m1_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$pct_pop_unemploy,
            text = paste0("Tract ", click_data$tract_name),
            hoverinfo = 'text',
            mode = 'markers+lines',
            marker = list(color = 'steelblue'),
            line = list(color = 'steelblue')
            #inherit = FALSE,
            #showlegend = FALSE
          )
        )
    } 
    
  })
      
      
  output$m2_plot <- renderPlotly({
    
    # line plot of all tracts in county
    p <- plot_ly(
      type = 'scatter',
      x = county_data()$year,
      y = county_data()$pct_pop_under_pov_line,
      text = paste0("Tract ", county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = county_data()$tract_name
        )
      ),
      showlegend = FALSE
    ) %>% layout(
      #title = "Measure 1 Over Time",
      #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
      xaxis = list(
        title = "Year",
        zeroline = FALSE
        #showticklabels = FALSE
      ),
      yaxis = list(
        title = "Value",
        type = "numeric", hoverformat = ".2f",
        zeroline = FALSE
        #showticklabels = FALSE
      )
      #autosize = F, height = 500
    )
    
    p
    
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
    
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("m2_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 1)
      
      click_data <- county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m2_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$pct_pop_under_pov_line,
            text = paste0("Tract ", click_data$tract_name),
            hoverinfo = 'text',
            mode = 'markers+lines',
            marker = list(color = 'steelblue'),
            line = list(color = 'steelblue')
            #inherit = FALSE,
            #showlegend = FALSE
          )
        )
    } 
    
  })
  
  
  output$m3_plot <- renderPlotly({
    
    # line plot of all tracts in county
    p <- plot_ly(
      type = 'scatter',
      x = county_data()$year,
      y = county_data()$median_hh_income,
      text = paste0("Tract ", county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = county_data()$tract_name
        )
      ),
      showlegend = FALSE
    ) %>% layout(
      #title = "Measure 1 Over Time",
      #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
      xaxis = list(
        title = "Year",
        zeroline = FALSE
        #showticklabels = FALSE
      ),
      yaxis = list(
        title = "Value",
        type = "numeric", hoverformat = ".2f",
        zeroline = FALSE
        #showticklabels = FALSE
      )
      #autosize = F, height = 500
    )
    
    p
    
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
    
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("m3_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 1)
      
      click_data <- county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m3_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$median_hh_income,
            text = paste0("Tract ", click_data$tract_name),
            hoverinfo = 'text',
            mode = 'markers+lines',
            marker = list(color = 'steelblue'),
            line = list(color = 'steelblue')
            #inherit = FALSE,
            #showlegend = FALSE
          )
        )
    } 
    
  })
  
  
  # row 2--------------------
  
  output$m4_plot <- renderPlotly({
    
    # line plot of all tracts in county
    p <- plot_ly(
      type = 'scatter',
      x = county_data()$year,
      y = county_data()$pct_hh_with_internet_sub,
      text = paste0("Tract ", county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = county_data()$tract_name
        )
      ),
      showlegend = FALSE
    ) %>% layout(
      #title = "Measure 1 Over Time",
      #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
      xaxis = list(
        title = "Year",
        zeroline = FALSE
        #showticklabels = FALSE
      ),
      yaxis = list(
        title = "Value",
        type = "numeric", hoverformat = ".2f",
        zeroline = FALSE
        #showticklabels = FALSE
      )
      #autosize = F, height = 500
    )
    
    p
    
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
    
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("m4_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 1)
      
      click_data <- county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m4_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$pct_hh_with_internet_sub,
            text = paste0("Tract ", click_data$tract_name),
            hoverinfo = 'text',
            mode = 'markers+lines',
            marker = list(color = 'steelblue'),
            line = list(color = 'steelblue')
            #inherit = FALSE,
            #showlegend = FALSE
          )
        )
    } 
    
  })
  
  
  output$m5_plot <- renderPlotly({
    
    # line plot of all tracts in county
    p <- plot_ly(
      type = 'scatter',
      x = county_data()$year,
      y = county_data()$pct_acres_of_park_land,
      text = paste0("Tract ", county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = county_data()$tract_name
        )
      ),
      showlegend = FALSE
    ) %>% layout(
      #title = "Measure 1 Over Time",
      #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
      xaxis = list(
        title = "Year",
        zeroline = FALSE
        #showticklabels = FALSE
      ),
      yaxis = list(
        title = "Value",
        type = "numeric", hoverformat = ".2f",
        zeroline = FALSE
        #showticklabels = FALSE
      )
      #autosize = F, height = 500
    )
    
    p
    
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
    
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("m5_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 1)
      
      click_data <- county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m5_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$pct_acres_of_park_land,
            text = paste0("Tract ", click_data$tract_name),
            hoverinfo = 'text',
            mode = 'markers+lines',
            marker = list(color = 'steelblue'),
            line = list(color = 'steelblue')
            #inherit = FALSE,
            #showlegend = FALSE
          )
        )
    } 
    
  })
  
  
  output$m6_plot <- renderPlotly({
    
    # line plot of all tracts in county
    p <- plot_ly(
      type = 'scatter',
      x = county_data()$year,
      y = county_data()$gini_coefficient,
      text = paste0("Tract ", county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = county_data()$tract_name
        )
      ),
      showlegend = FALSE
    ) %>% layout(
      #title = "Measure 1 Over Time",
      #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
      xaxis = list(
        title = "Year",
        zeroline = FALSE
        #showticklabels = FALSE
      ),
      yaxis = list(
        title = "Value",
        type = "numeric", hoverformat = ".2f",
        zeroline = FALSE
        #showticklabels = FALSE
      )
      #autosize = F, height = 500
    )
    
    p
    
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
    
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("m6_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 1)
      
      click_data <- county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m6_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$gini_coefficient,
            text = paste0("Tract ", click_data$tract_name),
            hoverinfo = 'text',
            mode = 'markers+lines',
            marker = list(color = 'steelblue'),
            line = list(color = 'steelblue')
            #inherit = FALSE,
            #showlegend = FALSE
          )
        )
    } 
    
  })
  
  # row 3 --------------------------
  
  output$m7_plot <- renderPlotly({
    
    # line plot of all tracts in county
    p <- plot_ly(
      type = 'scatter',
      x = county_data()$year,
      y = county_data()$pct_health_insurance_coverage,
      text = paste0("Tract ", county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = county_data()$tract_name
        )
      ),
      showlegend = FALSE
    ) %>% layout(
      #title = "Measure 1 Over Time",
      #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
      xaxis = list(
        title = "Year",
        zeroline = FALSE
        #showticklabels = FALSE
      ),
      yaxis = list(
        title = "Value",
        type = "numeric", hoverformat = ".2f",
        zeroline = FALSE
        #showticklabels = FALSE
      )
      #autosize = F, height = 500
    )
    
    p
    
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
    
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("m7_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 1)
      
      click_data <- county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m7_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$pct_health_insurance_coverage,
            text = paste0("Tract ", click_data$tract_name),
            hoverinfo = 'text',
            mode = 'markers+lines',
            marker = list(color = 'steelblue'),
            line = list(color = 'steelblue')
            #inherit = FALSE,
            #showlegend = FALSE
          )
        )
    } 
    
  })
  
  
  output$m8_plot <- renderPlotly({
    
    # line plot of all tracts in county
    p <- plot_ly(
      type = 'scatter',
      x = county_data()$year,
      y = county_data()$pct_mental_health_poor_above_14_days,
      text = paste0("Tract ", county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = county_data()$tract_name
        )
      ),
      showlegend = FALSE
    ) %>% layout(
      #title = "Measure 1 Over Time",
      #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
      xaxis = list(
        title = "Year",
        zeroline = FALSE
        #showticklabels = FALSE
      ),
      yaxis = list(
        title = "Value",
        type = "numeric", hoverformat = ".2f",
        zeroline = FALSE
        #showticklabels = FALSE
      )
      #autosize = F, height = 500
    )
    
    p
    
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
    
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("m8_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 1)
      
      click_data <- county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m8_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$pct_mental_health_poor_above_14_days,
            text = paste0("Tract ", click_data$tract_name),
            hoverinfo = 'text',
            mode = 'markers+lines',
            marker = list(color = 'steelblue'),
            line = list(color = 'steelblue')
            #inherit = FALSE,
            #showlegend = FALSE
          )
        )
    } 
    
  })
  
  
  output$m9_plot <- renderPlotly({
    
    # line plot of all tracts in county
    p <- plot_ly(
      type = 'scatter',
      x = county_data()$year,
      y = county_data()$pct_phys_health_poor_above_14_days,
      text = paste0("Tract ", county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = county_data()$tract_name
        )
      ),
      showlegend = FALSE
    ) %>% layout(
      #title = "Measure 1 Over Time",
      #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
      xaxis = list(
        title = "Year",
        zeroline = FALSE
        #showticklabels = FALSE
      ),
      yaxis = list(
        title = "Value",
        type = "numeric", hoverformat = ".2f",
        zeroline = FALSE
        #showticklabels = FALSE
      )
      #autosize = F, height = 500
    )
    
    p
    
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
    
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("m9_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 1)
      
      click_data <- county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m9_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$pct_phys_health_poor_above_14_days,
            text = paste0("Tract ", click_data$tract_name),
            hoverinfo = 'text',
            mode = 'markers+lines',
            marker = list(color = 'steelblue'),
            line = list(color = 'steelblue')
            #inherit = FALSE,
            #showlegend = FALSE
          )
        )
    } 
    
  })
  
  
  # row 4 -----------------------
  
  output$m10_plot <- renderPlotly({
    
    # line plot of all tracts in county
    p <- plot_ly(
      type = 'scatter',
      x = county_data()$year,
      y = county_data()$total_jobs,
      text = paste0("Tract ", county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = county_data()$tract_name
        )
      ),
      showlegend = FALSE
    ) %>% layout(
      #title = "Measure 1 Over Time",
      #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
      xaxis = list(
        title = "Year",
        zeroline = FALSE
        #showticklabels = FALSE
      ),
      yaxis = list(
        title = "Value",
        type = "numeric", hoverformat = ".2f",
        zeroline = FALSE
        #showticklabels = FALSE
      )
      #autosize = F, height = 500
    )
    
    p
    
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
    
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("m10_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 1)
      
      click_data <- county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m10_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$total_jobs,
            text = paste0("Tract ", click_data$tract_name),
            hoverinfo = 'text',
            mode = 'markers+lines',
            marker = list(color = 'steelblue'),
            line = list(color = 'steelblue')
            #inherit = FALSE,
            #showlegend = FALSE
          )
        )
    } 
    
  })
  
  
  output$m11_plot <- renderPlotly({
    
    # line plot of all tracts in county
    p <- plot_ly(
      type = 'scatter',
      x = county_data()$year,
      y = county_data()$pct_jobs_in_young_firms,
      text = paste0("Tract ", county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = county_data()$tract_name
        )
      ),
      showlegend = FALSE
    ) %>% layout(
      #title = "Measure 1 Over Time",
      #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
      xaxis = list(
        title = "Year",
        zeroline = FALSE
        #showticklabels = FALSE
      ),
      yaxis = list(
        title = "Value",
        type = "numeric", hoverformat = ".2f",
        zeroline = FALSE
        #showticklabels = FALSE
      )
      #autosize = F, height = 500
    )
    
    p
    
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
    
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("m11_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 1)
      
      click_data <- county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m11_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$pct_jobs_in_young_firms,
            text = paste0("Tract ", click_data$tract_name),
            hoverinfo = 'text',
            mode = 'markers+lines',
            marker = list(color = 'steelblue'),
            line = list(color = 'steelblue')
            #inherit = FALSE,
            #showlegend = FALSE
          )
        )
    } 
    
  })

  
  
  
  # data download -------------------------------
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("Health-Access-Data-", input$download_choice, ".xlsx", sep="")
    },
    content = function(file) {
      if(input$download_choice == "Health Access")
      {
        dat <- tract_data 
        dat$geometry <- NULL
        
        write.xlsx(dat, file)
      }
      else
      {
        # do nothing
      }
    }
  )
  
  
  # old template for measure plots
  
  # output$m1_plot <- renderPlotly({
  #   
  #   if(input$cty == "All Counties"){
  #     # do nothing
  #   }
  #   else
  #   {
  #     # line plot of all tracts in county
  #     p <- plot_ly(
  #       type = 'scatter',
  #       x = county_data()$year,
  #       y = county_data()$pct_pop_unemploy,
  #       text = paste0("Tract ", county_data()$tract_name),
  #       hoverinfo = 'text',
  #       mode = 'lines+markers',
  #       marker = list(color = 'lightgray'),
  #       line = list(color = 'lightgray'),
  #       transforms = list(
  #         list(
  #           type = 'groupby',
  #           groups = county_data()$tract_name
  #         )
  #       ),
  #       showlegend = FALSE
  #     )
  #     
  #     # add trace in a different color of tract that was clicked on
  #     if(!is.null(input$health_access_comp_map_shape_click$id))
  #     {
  #       click_data <- county_data() %>%
  #         filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
  #       
  #       p <- p %>%
  #         add_trace(
  #           type = 'scatter',
  #           x = click_data$year,
  #           y = click_data$pct_pop_unemploy,
  #           text = paste0("Tract ", click_data$tract_name),
  #           hoverinfo = 'text',
  #           mode = 'markers+lines',
  #           marker = list(color = 'steelblue'),
  #           line = list(color = 'steelblue'),
  #           inherit = FALSE,
  #           showlegend = FALSE
  #         )
  #     }
  #     
  #     # lables and layout of plot
  #     p <- p %>%
  #       layout(
  #         #title = "Measure 1 Over Time",
  #         #legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
  #         xaxis = list(
  #           title = "Year",
  #           zeroline = FALSE
  #           #showticklabels = FALSE
  #         ),
  #         yaxis = list(
  #           title = "Value",
  #           type = "numeric", hoverformat = ".2f",
  #           zeroline = FALSE
  #           #showticklabels = FALSE
  #         )
  #         #autosize = F, height = 500
  #       )
  #     
  #     p
  #   }
  #   
  # })
  
  
  
}


#
# APP ----------------------------------------------------------------------------------------------------
#

shinyApp(ui, server)