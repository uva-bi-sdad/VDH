library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyWidgets)
library(shinyjs)
library(leaflet)
library(plotly)
library(DT)
library(sf)
library(dplyr)

# DATA INGESTION --------------------------------------------------

# Using the prototype fake datasets for state and district and county, selecting for the shapes, years, rural, and health access
physician_access_state <- readRDS("~/git/vdh/src/dashboard/app/health_district_data.rds") %>% select(health_district, hd_rural, year, health_access)
physician_access <- readRDS("~/git/vdh/src/dashboard/app/tract_prototype_data.rds") %>% rename(data_value = health_access)
physician_access_district <- readRDS("~/git/vdh/src/dashboard/app/county_data.rds") %>% select(county_name, HealthDistrict, srhp_rural, year, health_access)

# Connection to database, not using at the moment
get_db_conn <-
  function(db_name = "sdad",
           db_host = "postgis1",
           db_port = "5432",
           db_user = Sys.getenv("db_usr"),
           db_pass = Sys.getenv("db_pwd")) {
    RPostgreSQL::dbConnect(
      drv = RPostgreSQL::PostgreSQL(),
      dbname = db_name,
      host = db_host,
      port = db_port,
      user = db_user,
      password = db_pass
    )
  }

#con <- get_db_conn()
#physician_access <- DBI::dbGetQuery(con, "
#                        SELECT * FROM dc_health_behavior_diet.va_tr_sdad_2018_2019_physician_access")
#tract_geo <-  st_read(dsn = con, query = "SELECT * FROM gis_census_cb.cb_2018_51_tract_500k")
#tract_geo <- st_read(con, c("gis_census_cb", "cb_2018_51_tract_500k"))
#DBI::dbDisconnect(con)

#geo_info <- readRDS("~/git/vdh/src/dashboard/app/county_data.rds") %>% select(county_id, county_name, srhp_rural, HealthDistrict)

#physician_access <- physician_access %>% mutate(county_id = substr(geoid_tr, 1, 5))
#physician_access <- left_join(physician_access, geo_info, by = "county_id")
#physician_access <- left_join(tract_geo, physician_access, by = c("GEOID" = "geoid_tr"))

#physician_access <- physician_access %>% group_by(county_id) %>% mutate(county_average = mean(data_value)) %>% ungroup() %>% group_by(HealthDistrict) %>% mutate(value = mean(data_value))

#physician_access_state <- physician_access %>% st_drop_geometry() %>% distinct(year, district_average, HealthDistrict, srhp_rural)
#physician_access_district <- physician_access %>% st_drop_geometry() %>% distinct(year, county_average, county_name, HealthDistrict, srhp_rural)

# Select columns
physician_access_county <- physician_access %>% select(year, data_value, tract_name, county_name, srhp_rural)

# color palette

pal <- colorNumeric("viridis", NULL)

## UI --------------------------------------------------------------------------

ui <- dashboardPage(

  # Creating title for page
  #title = "Virginia Department of Health",

  # header menu -----------------------------------------------------------------

  header = dashboardHeader(
    title = span("Virginia Department of Health - Protoype", style = "font-size: 24px"),
    titleWidth = 450
    #leftUi = tagList(

  ), # end dashboardHeader

  # dashboard body ----------------------------------------------------

  body = dashboardBody(
    width = 10,

    useShinyjs(),

    # row for controls --------------------------------------------------------
    fluidRow(
      # column for data story
      column(4, #h4("Dashboard controls"),
      selectInput(
        inputId = "menu",
        label = "Choose a Data Story",
        choices = c("Access to Health Care Services", "Healthy Moms and Babies", "Education as the Backbone of Rural Virginia", "Broadband Internet Supporting Rural Virginia", "Healthy Built and Natural Environments", "Behavioral Health, Substance Use Disorder and Recovery", "National Food Security", "Elevate Rural Workforce Development and Employment", "Financial Literacy: Leveraging Individualized Resources", "Rural Transportation", "Healthy Housing", "Healthy Minds, Body and Spirit", "Aging in Place and Addressing Social Isolation", "COVID-19 Pandemic"),
        selected = "Access to Health Care Services"
      ) #end selectInput

      ), #end column

      # column for start year end year
      column(3,
             sliderInput('years', 'Year Range',
                         min = 2014, max = 2019, value = 2019, sep = "")
             ),

      # column for rural and urban

      column(4,
             conditionalPanel(
               "input.datasetID === 'state'",
                 checkboxGroupButtons(
                   inputId = "staterural",
                   label = "Rural, Urban, or Mixed",
                   choices = c("Rural" = "rural", "Urban" = "urban", "Mixed" = "mixed"),
                   selected = c("rural", "urban", "mixed")
                 )
               ),
             conditionalPanel(
               "input.datasetID === 'district'",
               checkboxGroupButtons(
                 inputId = "districtrural",
                 label = "Rural or Urban",
                 choices = c("Rural" = "rural", "Urban" = "urban"),
                 selected = c("rural", "urban")
               )
             ),
             conditionalPanel(
               "input.datasetID === 'county'",
                 checkboxGroupButtons(
                   inputId = "countyrural",
                   label = "Rural or Urban",
                   choices = c("Rural" = "rural", "Urban" = "urban"),
                   selected = c("rural", "urban")
                 )
               )
      ) # end column
    ), # end controls fluidRow
    # row for datatable, map, plots, rank table
    fluidRow(
      width = 10,
        column(4,
               fluidRow(
               conditionalPanel("input.datasetID === 'state'",
                                DTOutput('statetbl', width = 450, height = 850))),
               conditionalPanel("input.datasetID === 'district'",
                                DTOutput('districttbl', width = 450, height = 850)),
               conditionalPanel("input.datasetID === 'county'",
                               h4("Work in progress")),
               h3("Area to select to explore related measures")),
        column(4,
               fluidRow(
          selectInput("datasetID", "Explore",
                      choices = c("State" = "state",
                      "Health District" = "district",
                      "County" = "county")),
            conditionalPanel(
              "input.datasetID === 'district'",
              selectInput(
                inputId = "filterdistrict",
                label = "Which Health District?",
                choices = c("All", sort(unique(physician_access_state$health_district))),
                selected = "All",
                selectize = FALSE
              )
            ),
            conditionalPanel(
              "input.datasetID === 'county'",
              selectInput(
                inputId = "filtercounty",
                label = "Which County?",
                choices = c(sort(unique(physician_access_district$county_name))),
                selected = "Arlington",
                selectize = FALSE
              )
            ),
            actionButton("reset", "Reset"),
           leafletOutput('map'),
           plotlyOutput('plot'))),
      column(3,
             h4("Rankings Table"),
             fluidRow(
             conditionalPanel("input.datasetID === 'state'",
                                DTOutput('stateranktbl', width = 400, height = 300))),
             conditionalPanel("input.datasetID === 'district'",
                              DTOutput('districtranktbl', width = 400, height = 300)),
             conditionalPanel("input.datasetID === 'county'",
                              h4("Work in progress"))
     # end fluidRow
      ) #end column
    ) #end fluidRow
  ), # end dashboardBody

sidebar <- dashboardSidebar(
  width = "0px"
)
 # end fluidRow

    #) # end dashboardBody

) # end UI

# Callback to collapse DT rows
callback_js <- JS(
  "table.on('click', 'tr.dtrg-group', function () {",
  "  var rowsCollapse = $(this).nextUntil('.dtrg-group');",
  "  $(rowsCollapse).toggleClass('hidden');",
  "});"
)

## SERVER --------------------------------------------------------------

server <- function(input, output, session) {

#  observeEvent(input$reset, {
#    updateSelectInput(inputId = if (input$datasetID == "County") "county" else "district", selected = "All")
#  })

#  observeEvent(input$datasetID, {
#    updateRadioGroupButtons(
#      getDefaultReactiveDomain(), "shapes",
#      choices = c(if (input$datasetID == "Health District") "Health District", "County", "Census Tract"),
#      selected = if (input$datasetID == "County" && input$shapes == "Health District") "County" else input$shapes
#    )
#  })

  # Leaflet proxy to update with datasetInput
  observe({
    data <- datasetInput()
    #year_data <- data[data$years == input$years, ]

    polygon_bounds <- as.numeric(st_bbox(data))
    polygon_bounds <- polygon_bounds + (polygon_bounds[3] - polygon_bounds[1]) / 15 * c(-1, -1, 1, 1)

    leafletProxy("map") %>%
      clearShapes() %>%
      removeControl("legend") %>%
      addPolygons(data = data,
                  stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                  fillColor = ~pal(data$value)) %>%
      addLegend(
        "bottomleft", pal, data$value,
        title = paste("Health Access Score"),
        opacity = 0.7,
        na.label = "Not Available",
        layerId = "legend") %>%
      flyToBounds(polygon_bounds[1], polygon_bounds[2], polygon_bounds[3], polygon_bounds[4])
  })

  # datasetInput, updates for state, district, or county view and rural input
  datasetInput <- reactive({
    if (input$datasetID == "state"){
      dataset <- physician_access_state %>% rename(value = health_access) %>% filter(hd_rural %in% input$staterural)
    }
    else if (input$datasetID == "district" && input$filterdistrict == "All"){
      dataset <- physician_access_district %>% rename(value = health_access) %>% filter(srhp_rural %in% input$districtrural)
    }
    else if (input$datasetID == "district" && input$filterdistrict != "All"){
      dataset <- physician_access_district %>% rename(value = health_access) %>% filter(HealthDistrict %in% input$filterdistrict) %>% filter(srhp_rural %in% input$districtrural)
    }
#    else if (input$datasetID == "county" && input$filtercounty == "All"){
#      dataset <- physician_access_county %>% rename(value = data_value)
#    }
    else if (input$datasetID == "county" && input$filtercounty != "All"){
      dataset <- physician_access_county %>% rename(value = data_value) %>% filter(county_name %in% input$filtercounty) %>% filter(srhp_rural %in% input$countyrural)
    }
  })


# Display table, still working out how we would show this exactly
display_table <- physician_access_county %>% st_drop_geometry()

  output$statetbl = renderDT(
    datatable(
    datasetInput(),
    filter="top",
    extensions = c('Buttons', 'RowGroup'),
    options = list(#lengthChange = FALSE,
                   #paging = TRUE,
                   #dom = 'tB',
                   #buttons = c('copy', 'csv', 'excel'),
                   rowGroup = list(dataSrc=c(1)),
                   scrollX = TRUE,
                   scrollY = TRUE,
                   pageLength = 20),#,
                   #lengthMenu = c(5, 10, 15, 20)),
    callback = callback_js))

  output$districttbl = renderDT(
    datatable(
      datasetInput(),
      filter="top",
      extensions = c('Buttons', 'RowGroup'),
      options = list(lengthChange = FALSE,
                     paging = TRUE,
                     dom = 'tB',
                     buttons = c('copy', 'csv', 'excel'),
                     rowGroup = list(dataSrc=c(2,1)),
                     scrollX = TRUE,
                     scrollY = TRUE),
      callback = callback_js))

# The rankings table isn't showing rankings right now, its just the display table
rankings_table <- display_table %>% group_by(year) %>% mutate(rank = rank(data_value, ties.method = "first"))

  output$stateranktbl = renderDT(
    datatable(
      datasetInput(),
      filter="top",
      extensions = c('Buttons', 'RowGroup'),
      options = list(#lengthChange = FALSE,
                     #paging = TRUE,
                     #dom = 'tB',
                     #buttons = c('copy', 'csv', 'excel'),
        pageLength = 5,
                     rowGroup = list(dataSrc=c(1)),
                     scrollX = TRUE,
                     scrollY = TRUE),
      callback = callback_js))

  output$districtranktbl = renderDT(
    datatable(
      datasetInput(),
      filter="top",
      extensions = c('Buttons', 'RowGroup'),
      options = list(lengthChange = FALSE,
                     paging = TRUE,
                     dom = 'tB',
                     buttons = c('copy', 'csv', 'excel'),
                     rowGroup = list(dataSrc=c(2, 1)),
                     scrollX = TRUE,
                     scrollY = TRUE),
      callback = callback_js))

  # Drawing base leaflet map
  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(attributionControl = FALSE)) %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(-79, 38, zoom = 7)
#    leaflet() %>%
#    addPolygons(data = datasetInput(),
#                stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
#                fillColor = ~pal(district_average), group = "State") %>%
#    addPolygons(data = physician_access_district,
#                  stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
#                  fillColor = ~pal(county_average), group = "Districts") %>%
#    addPolygons(data = physician_access_county,
#                  stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
#                  fillColor = ~pal(data_value), group = "Counties") %>%
#    addLegend(pal = pal, values = ~district_average, opacity = 1.0,
#                labFormat = labelFormat(transform = function(x) round(10^x))) #%>%
#    addLayersControl(
#      baseGroups = c("State", "Districts", "Counties"),
#      options = layersControlOptions(collapsed = FALSE))

  })

  # Drawing base plot
  output$plot <- renderPlotly(
    plot <- plot_ly(
      data = datasetInput(),
      x = ~year,
      y = ~value,
      type = "box",
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'))
    )

  # Plotly proxy to update with datasetInput
  observeEvent(input$datasetInput,{
    plotlyProxy("plot",session) %>%
      plotlyProxyInvoke("relayout")
  })

  # DT proxy to update with datasetInput
  proxy <- DT::dataTableProxy('tbl')
  shiny::observe({

    DT::replaceData(proxy, datasetInput())

  })

} # end server

## RUN APP

shinyApp(ui, server)
