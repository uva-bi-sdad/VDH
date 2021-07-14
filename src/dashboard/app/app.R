# VDH Dashboard prototype - using random data
# color parallel coordinates plot by rurality

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

vhd_data <- readRDS("health_district_data.rds")
tract_data <- readRDS("tract_prototype_data.rds")
county_data <- readRDS("county_data.rds")

rural_cty_data <- county_data %>%
  filter(srhp_rural == 'rural')

urban_cty_data <- county_data %>%
  filter(srhp_rural == 'urban') 


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
            #p("composite and measures. state map in local health districts. compare across health districst.")),
          
            fluidRow(
              
              column(
                width = 12,
                
                box(
                  title = "Health Care Access Composite Measure",
                  width = 12,
                  collapsible = TRUE,
                  leafletOutput("vhd_health_access_comp_map")
                )
              )
            )
            
          ),
            
          # County ------------------------------
          tabPanel(
            "County Data", 
            br(),
            #p("composite and measures. state map in counties. compare across counties. Measures colored by rurality."),
            
            fluidRow(
              column(
                width = 4,
                selectInput(
                  inputId = "hlth_district",
                  label = "Choose a Health District",
                  choices = c("All", c(unique(county_data$HealthDistrict)[sort.list(unique(county_data$HealthDistrict))])),
                  #selected = "All"
                  #selectize = TRUE)
                )
              )
              
            ),
            
            
            # Composite Map ---------------------
            
            fluidRow(
              
              column(
                width = 12,
                
                box(
                  title = "Health Care Access Composite Measure",
                  width = 12,
                  collapsible = TRUE,
                  leafletOutput("cty_health_access_comp_map")
                )
              )
            ),
            
            # plot options 
            
            fluidRow(
              
              column(1),
              
              column(
                width = 2,
                
                radioButtons("boxplots", 
                             label = h4("Boxplots"),
                             choices = list("On" = 1, "Off" = 0), 
                             selected = 1)
              ),
              
              # column(
              #   width = 3,
              #   
              #   radioButtons("par_coords", 
              #                label = h4("Parallel Coordinates"),
              #                choices = list("On" = 1, "Off" = 0), 
              #                selected = 1)
              # ),
              # 
              column(
                width = 4,
                
                radioButtons("rurality", 
                             label = h4("Rural and Urban Parallel Coordinates"),
                             choices = list("Both" = 1, "Rural Only" = 2, "Urban Only" = 3, "None" = 0), 
                             selected = 1)
              )
              
            ),
            

            # Measure Plots ------------------

            # row 1 --------------------------

            fluidRow(

              column(
                width = 6,

                box(
                  title = "No Health Insurance",
                  width = 12,
                  collapsible = TRUE,
                  plotlyOutput("cty_m1_plot", height = "350px")
                )
              )
            )  
 
          ),
            
        
          # Census Tract ------------------------------
          tabPanel(
            "Census Tract Data",
            br(),
            #p("composite and measures. county map by tracts. compare within county"),
              
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
                    title = "No Health Insurance",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m1_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
    
                  box(
                    title = "High Blood Pressure",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m2_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
                  
                  box(
                    title = "Cancer",
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
                    title = "High Cholesterol",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m4_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
                  
                  box(
                    title = "Obesity",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m5_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
                  
                  box(
                    title = "Diabetes",
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
                    title = "Mental Health",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m7_plot", height = "250px")
                  )
                ),
                
                column(
                  width = 4,
                  
                  box(
                    title = "Physical Health",
                    width = 12,
                    collapsible = TRUE,
                    plotlyOutput("m8_plot", height = "250px")
                  )
                )
                
                # column(
                #   width = 4,
                #   
                #   box(
                #     title = "Health Access",
                #     width = 12,
                #     collapsible = TRUE,
                #     plotlyOutput("m9_plot", height = "250px")
                #   )
                # )
                
              )
              
              # # row 4 ----------------------------------
              # 
              # fluidRow(
              #   
              #   column(
              #     width = 4,
              #     
              #     box(
              #       title = "Total Jobs",
              #       width = 12,
              #       collapsible = TRUE,
              #       plotlyOutput("m10_plot", height = "250px")
              #     )
              #   ),
              #   
              #   column(
              #     width = 4,
              #     
              #     box(
              #       title = "Percentage of Jobs in Young Firms",
              #       width = 12,
              #       collapsible = TRUE,
              #       plotlyOutput("m11_plot", height = "250px")
              #     )
              #   )
              #   
              # )
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
  
  # observeEvent(input$health_access_comp_map_shape_click, {
  #   click <- input$health_access_comp_map_shape_click
  #   print(click$id)
  # })
  # 
  
  #
  # Reactive Switches ----------------------------------------------------
  #
  
  # Census Tract data tab reactive filter - choosing a county 
  
  chosen_county_data <- reactive({
    
    tract_data %>%
      filter(county_name == input$cty)
    
  })  
  
  # County data tab reactive filter - choosing a health district 
  
  chosen_hd_data <- reactive({
    
    if(input$hlth_district == 'All')
    {
      county_data
    }
    else
    {
      county_data %>%
        filter(HealthDistrict == input$hlth_district)
    }
    
  })
  
  
  # leaflet map for tract health access composite ------------------------------------------
  
  output$health_access_comp_map <- renderLeaflet({
    
      map_data <- chosen_county_data() %>%
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
  
  
  # leaflet map for county health access composite ------------------------------------------
  
  output$cty_health_access_comp_map <- renderLeaflet({
    
    map_data <- chosen_hd_data() %>%
      filter(year == 2019)
    
    labels <- lapply(
      paste("<strong>County: </strong>",
            map_data$county_name,
            "<br />",
            "<strong>Health Access Score: </strong>",
            paste0(100*round(map_data$health_access, 2), "%") 
      ),
      htmltools::HTML
    )
    
    # I think the problem is in the palette
    pal <- colorQuantile(palette ="Oranges", domain = county_data[county_data$year == 2019, ]$health_access, 
                         probs = seq(0, 1, length = 6), na.color = oranges[6], right = FALSE)
    
    
    leaflet(data = map_data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = ~pal(health_access), 
        fillOpacity = 0.7, 
        stroke = TRUE, smoothFactor = 0.7, weight = 0.5, color = "#202020",
        popup = ~labels,
        layerId = ~county_id
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
  
  
  # leaflet map for VA health district health access composite ------------------------------------------
  
  output$vhd_health_access_comp_map <- renderLeaflet({
    
    map_data <- vhd_data %>%
      filter(year == 2019)
    
    labels <- lapply(
      paste("<strong>Health District: </strong>",
            map_data$health_district,
            "<br />",
            "<strong>Health Access Score: </strong>",
            paste0(100*round(map_data$health_access, 2), "%") 
      ),
      htmltools::HTML
    )
    
    # I think the problem is in the palette
    pal <- colorQuantile(palette ="Oranges", domain = vhd_data[vhd_data$year == 2019, ]$health_access, 
                         probs = seq(0, 1, length = 6), na.color = oranges[6], right = FALSE)
    
    
    leaflet(data = map_data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = ~pal(health_access), 
        fillOpacity = 0.7, 
        stroke = TRUE, smoothFactor = 0.7, weight = 0.5, color = "#202020",
        popup = ~labels,
        layerId = ~fid
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
      type = 'box',
      x = chosen_county_data()$year,
      y = ~chosen_county_data()$no_health_ins,
      fillcolor = "white",
      line = list(color = "#787878"),
      showlegend = FALSE
    ) %>% add_trace(
        type = 'scatter',
        x = chosen_county_data()$year,
        y = chosen_county_data()$no_health_ins,
        text = paste0("Tract ", chosen_county_data()$tract_name),
        hoverinfo = 'text',
        mode = 'lines+markers',
        marker = list(color = 'lightgray'),
        line = list(color = 'lightgray'),
        transforms = list(
          list(
            type = 'groupby',
            groups = chosen_county_data()$tract_name
          )
        ),
        inherit = FALSE,
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
        plotlyProxyInvoke("deleteTraces", 2) # delete the third trace (if it exists)
        
      click_data <- chosen_county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m1_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$no_health_ins,
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
      x = chosen_county_data()$year,
      y = chosen_county_data()$bphigh_crudeprev,
      text = paste0("Tract ", chosen_county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = chosen_county_data()$tract_name
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
      
      click_data <- chosen_county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m2_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$bphigh_crudeprev,
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
      x = chosen_county_data()$year,
      y = chosen_county_data()$cancer_crudeprev,
      text = paste0("Tract ", chosen_county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = chosen_county_data()$tract_name
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
      
      click_data <- chosen_county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m3_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$cancer_crudeprev,
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
      x = chosen_county_data()$year,
      y = chosen_county_data()$highchol_crudeprev,
      text = paste0("Tract ", chosen_county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = chosen_county_data()$tract_name
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
      
      click_data <- chosen_county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m4_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$highchol_crudeprev,
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
      x = chosen_county_data()$year,
      y = chosen_county_data()$obesity_crudeprev,
      text = paste0("Tract ", chosen_county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = chosen_county_data()$tract_name
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
      
      click_data <- chosen_county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m5_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$obesity_crudeprev,
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
      x = chosen_county_data()$year,
      y = chosen_county_data()$diabetes_crudeprev,
      text = paste0("Tract ", chosen_county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = chosen_county_data()$tract_name
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
      
      click_data <- chosen_county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m6_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$diabetes_crudeprev,
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
      x = chosen_county_data()$year,
      y = chosen_county_data()$mhlth_crudeprev,
      text = paste0("Tract ", chosen_county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = chosen_county_data()$tract_name
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
      
      click_data <- chosen_county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m7_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$mhlth_crudeprev,
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
      x = chosen_county_data()$year,
      y = chosen_county_data()$phlth_crudeprev,
      text = paste0("Tract ", chosen_county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = chosen_county_data()$tract_name
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
      
      click_data <- chosen_county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m8_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$phlth_crudeprev,
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
      x = chosen_county_data()$year,
      y = chosen_county_data()$health_access,
      text = paste0("Tract ", chosen_county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = chosen_county_data()$tract_name
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
      
      click_data <- chosen_county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      plotlyProxy("m9_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$health_access,
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
      x = chosen_county_data()$year,
      y = chosen_county_data()$total_jobs,
      text = paste0("Tract ", chosen_county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = chosen_county_data()$tract_name
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
      
      click_data <- chosen_county_data() %>%
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
      x = chosen_county_data()$year,
      y = chosen_county_data()$pct_jobs_in_young_firms,
      text = paste0("Tract ", chosen_county_data()$tract_name),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = chosen_county_data()$tract_name
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
      
      click_data <- chosen_county_data() %>%
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
  #       x = chosen_county_data()$year,
  #       y = chosen_county_data()$pct_pop_unemploy,
  #       text = paste0("Tract ", chosen_county_data()$tract_name),
  #       hoverinfo = 'text',
  #       mode = 'lines+markers',
  #       marker = list(color = 'lightgray'),
  #       line = list(color = 'lightgray'),
  #       transforms = list(
  #         list(
  #           type = 'groupby',
  #           groups = chosen_county_data()$tract_name
  #         )
  #       ),
  #       showlegend = FALSE
  #     )
  #     
  #     # add trace in a different color of tract that was clicked on
  #     if(!is.null(input$health_access_comp_map_shape_click$id))
  #     {
  #       click_data <- chosen_county_data() %>%
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
  
  # county measure plots -------------------------------------------------
  
  
  
  output$cty_m1_plot <- renderPlotly({
    
    rural_cty_data <- chosen_hd_data() %>%
      filter(srhp_rural == 'rural')
    
    urban_cty_data <- chosen_hd_data() %>%
      filter(srhp_rural == 'urban') 
    

    # line plots - urban    
    p <- plot_ly(
      type = 'scatter',
      x = urban_cty_data$year,
      y = urban_cty_data$no_health_ins,
      text = paste0(urban_cty_data$county_name, " County"),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = urban_cty_data$county_name
        )
      ),
      #inherit = FALSE,
      showlegend = FALSE
      
      # line plots - rural
    ) %>% add_trace(
      type = 'scatter',
      x = rural_cty_data$year,
      y = rural_cty_data$no_health_ins,
      text = paste0(rural_cty_data$county_name, " County"),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgreen'),
      line = list(color = 'lightgreen'),
      transforms = list(
        list(
          type = 'groupby',
          groups = rural_cty_data$county_name
        )
      ),
      inherit = FALSE,
      showlegend = FALSE  

      # box plots
    ) %>% add_trace(
        type = 'box',
        x = county_data$year,
        y = county_data$no_health_ins,
        fillcolor = "white",
        line = list(color = "#787878"),
        marker = list(color = "#787878"),
        inherit = FALSE,
        showlegend = FALSE  
            
    # layout  
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
    
    if(!is.null(input$cty_health_access_comp_map_shape_click$id))
    {
      # remove previously chosen tract (if there was one)
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 3) # delete the fourth trace (if it exists)
      
      click_data <- chosen_hd_data() %>%
        filter(county_id == input$cty_health_access_comp_map_shape_click$id)
      
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$no_health_ins,
            text = paste0(click_data$county_name, "County"),
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
  
  # toggle boxplots
  observeEvent(input$boxplots, {
    
    if(input$boxplots == 0)
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), 2)
    }
    else
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), 2)
    }
    
  }) 
  
  # # toggle parallel coordinates
  # observeEvent(input$par_coords, {
  #   
  #   if(input$par_coords == 0)
  #   {
  #     plotlyProxy("cty_m1_plot", session) %>%
  #       plotlyProxyInvoke("restyle", list(visible = FALSE), c(0,1))
  #   }
  #   else
  #   {
  #     plotlyProxy("cty_m1_plot", session) %>%
  #       plotlyProxyInvoke("restyle", list(visible = TRUE), c(0,1))
  #   }
  #   
  # }) 

  # rural/urban toggle
  observeEvent(input$rurality, {
    
    if(input$rurality == 0) # none
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), c(0,1))      
    }
    else if(input$rurality == 1) # both
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), c(0,1))
    }
    else if(input$rurality == 2) # rural only
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), 0)
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), 1)
    }
    else # urban only
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), 1)
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), 0)
      
    }
    
  }) 
  
}


#
# APP ----------------------------------------------------------------------------------------------------
#

shinyApp(ui, server)