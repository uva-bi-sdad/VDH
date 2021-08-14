# VDH Dashboard prototype - Health Access

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
library(htmlwidgets)

#
# DATA INGESTION -------------------------------------------------------
#

vhd_data <- readRDS("health_district_data.rds")
tract_data <- readRDS("tract_prototype_data.rds")
county_data <- readRDS("county_data.rds")

rural_hd_data <- vhd_data %>%
  filter(hd_rural == 'rural')

# Need to do something with the mixed data on the health districts tab
mixed_hd_data <- vhd_data %>%
  filter(hd_rural == 'mixed')

urban_hd_data <- vhd_data %>%
  filter(hd_rural == "urban")


# color palettes -------------------

oranges <- brewer.pal(n=6, name = 'Oranges')


#
# UI FUNCTIONS -------------------------------------
#

composite_map_box_ui <- function(box_title, map_name)
{
  box(
    title = box_title,
    width = 12,
    collapsible = TRUE,
    leafletOutput(map_name)
  )
}

measure_box_ui <- function(box_title, plot_name)
{
  box(
    title = box_title,
    width = 12,
    collapsible = TRUE,
    plotlyOutput(plot_name, height = "250px")
  )
}

plot_options_ui <- function(input_id1, input_id2, tab_geo)
{
  dropdown(
    style = "simple", 
    icon = icon("gear"),
    status = "primary",  # color
    label = "Plot Options",
    size = 'sm',
    #up = TRUE,
    right = TRUE,
    width = "200px",
    #animate = animateOptions(
    #  enter = animations$fading_entrances$fadeInLeftBig,
    #  exit = animations$fading_exits$fadeOutRightBig
    #),
    tags$h4("Global Plot Options"),
    
    selectInput(
      inputId = input_id1,
      label = "Boxplots Toggle",
      choices = c("On", "Off"),
      selected = "On"
    ),
    
    if(tab_geo == "hd")
    {
      selectInput(
        inputId = input_id2,
        label = "Line Plots Toggle",
        choices = c("All", "Rural", "Urban", "Mixed", "Off"),
        selected = "All"
      )
    }
    else
    {
      selectInput(
        inputId = input_id2,
        label = "Line Plots Toggle",
        choices = c("All", "Rural", "Urban", "Off"),
        selected = "All"
      )
    }
      
  )
}

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
    
  ),
  
  # sidebar menu ------------------------------------------------------
  
  sidebar = dashboardSidebar(
    
    selectInput(
      inputId = "menu",
      label = "Choose a Menu",
      choices = c("Community Capitals", "VDH"),
      selected = "Community Capitals"
      #selectize = TRUE)
    ),
    
    conditionalPanel("input.menu == 'Community Capitals'",
    
      sidebarMenu(
        hr(),
        menuItem(text = "Community Capital Areas", tabName = "capitals", icon = icon("list-ol")),
        menuItem(text = "Financial", tabName = "financial", icon = icon("money-check-alt")),
        menuItem(text = "Human", tabName = "human", icon = icon("child"),
                 menuSubItem("Health Care Access", tabName = "health-care")),
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
    
    conditionalPanel("input.menu == 'VDH'",
                     
      sidebarMenu(
        hr(),
        menuItem(text = "VDH Landing Page", tabName = "vdh-landing", icon = icon("list-ol")),
        menuItem(text = "Healthy Moms and Babies", tabName = "moms-babies", icon = icon("money-check-alt")),
        menuItem(text = "Education as the Backbone of Rural Virginia", tabName = "education", icon = icon("child")),
        menuItem(text = "Broadband Internet Supporting Rural Virginia", tabName = "broadband", icon = icon("handshake")),
        menuItem(text = "Healthy Built and Natural Environments", tabName = "built-natural", icon = icon("tree")),
        menuItem(text = "Access to Health Care Services", tabName = "health-care", icon = icon("home")),
        menuItem(text = "Behavioral Health, Substance Use Disorder and Recovery", tabName = "behavior", icon = icon("landmark")),
        menuItem(text = "National Food Security", tabName = "food-security", icon = icon("theater-masks")),
        menuItem(text = "Elevate Rural Workforce Development and Employment", tabName = "workforce", icon = icon("theater-masks")),
        menuItem(text = "Financial Literacy: Leveraging Individualized Resources", tabName = "financial-literacy", icon = icon("theater-masks")),
        menuItem(text = "Rural Transportation", tabName = "transportation", icon = icon("theater-masks")),
        menuItem(text = "Healthy Housing", tabName = "housing", icon = icon("theater-masks")),
        menuItem(text = "Healthy Minds, Body and Spirit", tabName = "mind-body-spirit", icon = icon("theater-masks")),
        menuItem(text = "Aging in Place and Addressing Social Isolation", tabName = "aging", icon = icon("theater-masks")),
        menuItem(text = "COVID-19 Pandemic", tabName = "covid", icon = icon("theater-masks")),
        hr(),
        menuItem(text = "Data and Methods", tabName = "data", icon = icon("info-circle"),
                 menuSubItem(text = "Measures Table", tabName = "datamethods"),
                 menuSubItem(text = "Data Descriptions", tabName = "datadescription")),
        menuItem(text = "Resources", tabName = "resources", icon = icon("book-open"),
                 menuSubItem(text = "Bibliography", tabName = "biblio")),
        menuItem(text = "About Us", tabName = "contact", icon = icon("address-card"))
      )
    )
    
  ),
  
  
  # # right side menu 
  # controlbar = dashboardControlbar(
  #   id = "plot_controls",
  #   overlay = FALSE,
  #   p("test")
  # ),
  
  
  # dashboard body ----------------------------------------------------
  
  body = dashboardBody(
    
    tabItems(
      
      #
      # COMMUNITY CAPITALS LANDING - test tab for now -------------------
      #
      
      tabItem(
        tabName = 'capitals',
        p('Capitals Test')
      ),      
      
      #
      # VDH LANDING - test tab for now -----------------------------
      #
      
      tabItem(
        tabName = 'vdh-landing',
        p('VDH Test')
      ),
      
      #
      # HEALTH ACCESS ----------------------------------------------
      #
      
      tabItem(
        tabName = "health-care",
        
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
          
            fluidRow(
              column(width = 12, composite_map_box_ui("Health Care Access Composite Measure", "vhd_health_access_comp_map"))
            ),
            
            # plot options 
            fluidRow(
              column(10),
              column(width = 2, plot_options_ui("hd_boxplots", "hd_rurality", "hd"))
            ),
            br(),
            
            # Measure plots
            fluidRow(
              column(width = 6, measure_box_ui("No Health Insurance", "hd_m1_plot"))
            )  
            
          ),
            
          # County ------------------------------
          tabPanel(
            "County Data", 
            br(),
            
            fluidRow(
              column(
                width = 4,
                selectInput(
                  inputId = "hlth_district",
                  label = "Choose a Health District",
                  choices = c("All", c(unique(county_data$HealthDistrict)[sort.list(unique(county_data$HealthDistrict))])),
                  selected = "All"
                )
              )
            ),
            
            
            # Composite Map 
            fluidRow(
              column(width = 12, composite_map_box_ui("Health Care Access Composite Measure", "cty_health_access_comp_map"))
            ),
            
            # plot options 
            fluidRow(
              column(10),
              column(width = 2, plot_options_ui("boxplots", "rurality", "county"))
            ),
            br(),
            
            # Measure Plots 
            fluidRow(
              column(width = 6, measure_box_ui("No Health Insurance", "cty_m1_plot"))
            )  
 
          ),
            
        
          # Census Tract ------------------------------
          tabPanel(
            "Census Tract Data",
            br(),
              
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
            
            # Composite Map 
            fluidRow(
              column(width = 12, composite_map_box_ui("Health Care Access Composite Measure", "health_access_comp_map"))
            ),
              
            # plot options 
            fluidRow(
              column(10),
              column(width = 2, plot_options_ui("ct_boxplots", "ct_rurality", "tract"))
            ),
            br(),
            
            # Measure Plots
            fluidRow(
              column(width = 4, measure_box_ui("No Health Insurance", "m1_plot")),
              column(width = 4, measure_box_ui("High Blood Pressure", "m2_plot")),
              column(width = 4, measure_box_ui("Cancer", "m3_plot"))
            ),
            
            fluidRow(
              column(width = 4, measure_box_ui("High Cholesterol", "m4_plot")),
              column(width = 4, measure_box_ui("Obesity", "m5_plot")),
              column(width = 4, measure_box_ui("Diabetes", "m6_plot"))
            ),
            
            fluidRow(
              column(width = 4, measure_box_ui("Mental Health", "m7_plot")),
              column(width = 4, measure_box_ui("Physical Health", "m8_plot"))
            )
        
          )
        )
      )
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
  
  # filter to rural chosen data
  rural_tract_data <- reactive({
    chosen_county_data() %>%
      filter(srhp_rural == 'rural')
  })
  
  # filter to urban chosen data 
  urban_tract_data <- reactive({
    chosen_county_data() %>%
      filter(srhp_rural == 'urban')
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
  
  # filter to rural chosen data
  rural_cty_data <- reactive({
    chosen_hd_data() %>%
    filter(srhp_rural == 'rural')
  })
  
  # filter to urban chosen data 
  urban_cty_data <- reactive({
    chosen_hd_data() %>%
    filter(srhp_rural == 'urban')
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
    
    overall_health_access <- tract_data[tract_data$year == 2019, "health_access", drop = TRUE]
    pal <- colorQuantile(palette ="Oranges", domain = overall_health_access, 
                         probs = seq(0, 1, length = 6), na.color = oranges[6], right = FALSE)

    
    leaflet(data = map_data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = ~pal(health_access), 
        fillOpacity = 0.7, 
        stroke = TRUE, smoothFactor = 0.7, weight = 0.5, color = "#202020",
        popup = ~labels,
        layerId = ~census_tract_fips
      ) %>%
      addLegend(
        position = "bottomleft",
        pal = pal,
        values =  ~overall_health_access,
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

    overall_health_access <- county_data[county_data$year == 2019, "health_access", drop = TRUE]
    pal <- colorQuantile(palette ="Oranges", domain = overall_health_access, 
                         probs = seq(0, 1, length = 6), na.color = oranges[6], right = FALSE)
    
    
    leaflet(data = map_data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = ~pal(health_access), 
        fillOpacity = 0.7, 
        stroke = TRUE, smoothFactor = 0.7, weight = 0.5, color = "#202020",
        popup = ~labels,
        layerId = ~county_id
      ) %>%
      addLegend(
        position = "bottomleft",
        pal = pal,
        values =  ~overall_health_access,
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
    
    overall_health_access <- vhd_data[vhd_data$year == 2019, "health_access", drop = TRUE]  
    pal <- colorQuantile(palette ="Oranges", domain = overall_health_access, 
                         probs = seq(0, 1, length = 6), na.color = oranges[6], right = FALSE)
    
    
    leaflet(data = map_data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = ~pal(health_access), 
        fillOpacity = 0.7, 
        stroke = TRUE, smoothFactor = 0.7, weight = 0.5, color = "#202020",
        popup = ~labels,
        layerId = ~fid
      ) %>%
      addLegend(
        position = "bottomleft",
        pal = pal,
        values =  ~overall_health_access,
        title = "Health Access Score",
        opacity = 0.7,
        na.label = "Not Available")
    
  })
  
  
  #
  # Plotly Measure Plot function -----------------------------
  #
  
  measure_plot <- function(urban_data, rural_data, all_data, var_name, label_name, tab_geo, mixed_data = NULL)
  {
    #print("drawing")
    
    # SET TRACE VISIBILITY according to plot controls.  order = urban, rural, boxplots
    vis_traces = c(TRUE, TRUE, TRUE, TRUE)

    if(tab_geo == "county")
    {
      # parallel coords
      if(isolate(input$rurality) == "All")
      {
        vis_traces[1] = TRUE
        vis_traces[2] = TRUE
      }
      else if(isolate(input$rurality) == "Rural")
      {
        vis_traces[1] = FALSE
        vis_traces[2] = TRUE
      }
      else if(isolate(input$rurality) == "Urban")
      {
        vis_traces[1] = TRUE
        vis_traces[2] = FALSE
      }
      else # neither
      {
        vis_traces[1] = FALSE
        vis_traces[2] = FALSE
      }
      
      # boxplots
      if(isolate(input$boxplots) == "Off")
      {
        vis_traces[3] = FALSE
      }
      else # on
      {
        vis_traces[3] = TRUE
      }
    }
    else if(tab_geo == "tract")
    {
      # parallel coords
      if(isolate(input$ct_rurality) == "All")
      {
        vis_traces[1] = TRUE
        vis_traces[2] = TRUE
      }
      else if(isolate(input$ct_rurality) == "Rural")
      {
        vis_traces[1] = FALSE
        vis_traces[2] = TRUE
      }
      else if(isolate(input$ct_rurality) == "Urban")
      {
        vis_traces[1] = TRUE
        vis_traces[2] = FALSE
      }
      else # neither
      {
        vis_traces[1] = FALSE
        vis_traces[2] = FALSE
      }
      
      # boxplots
      if(isolate(input$ct_boxplots) == "Off")
      {
        vis_traces[3] = FALSE
      }
      else # on
      {
        vis_traces[3] = TRUE
      }
    }
    else  # tract_geo = hd
    {
      # parallel coords
      if(isolate(input$hd_rurality) == "All")
      {
        vis_traces[1] = TRUE
        vis_traces[2] = TRUE
        vis_traces[4] = TRUE  
      }
      else if(isolate(input$hd_rurality) == "Rural")
      {
        vis_traces[1] = FALSE
        vis_traces[2] = TRUE
        vis_traces[4] = FALSE
      }
      else if(isolate(input$hd_rurality) == "Urban")
      {
        vis_traces[1] = TRUE
        vis_traces[2] = FALSE
        vis_traces[4] = FALSE
      }
      else if(isolate(input$hd_rurality) == "Mixed")
      {
        vis_traces[1] = FALSE
        vis_traces[2] = FALSE
        vis_traces[4] = TRUE
      }
      else # neither
      {
        vis_traces[1] = FALSE
        vis_traces[2] = FALSE
        vis_traces[4] = FALSE
      }
      
      # boxplots
      if(isolate(input$hd_boxplots) == "Off")
      {
        vis_traces[3] = FALSE
      }
      else # on
      {
        vis_traces[3] = TRUE
      }
    }
     
    
    # PLOT -- throws a warning if one of urban or rural data are empty, but plot is still correct
    # also throws a warning if there is missing data
    
    # line plots - urban    
    p <- plot_ly(
      data = urban_data,
      type = 'scatter',
      x = ~year,
      y = as.formula(paste0("~", var_name)),     
      text = as.formula(paste0("~", label_name)),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgray'),
      line = list(color = 'lightgray'),
      transforms = list(
        list(
          type = 'groupby',
          groups = as.formula(paste0("~", label_name)) 
        )
      ),
      #inherit = FALSE,
      visible = vis_traces[1],
      showlegend = FALSE
      
      # line plots - rural
    ) %>% add_trace(
      data = rural_data,
      type = 'scatter',
      x = ~year,
      y = as.formula(paste0("~", var_name)),
      text = as.formula(paste0("~", label_name)),
      hoverinfo = 'text',
      mode = 'lines+markers',
      marker = list(color = 'lightgreen'),
      line = list(color = 'lightgreen'),
      transforms = list(
        list(
          type = 'groupby',
          groups = as.formula(paste0("~", label_name))
        )
      ),
      visible = vis_traces[2],
      inherit = FALSE,
      showlegend = FALSE  
      
      # box plots
    ) %>% add_trace(
      data = all_data,
      type = 'box',
      x = ~year,
      y = as.formula(paste0("~", var_name)),
      fillcolor = 'transparent',
      line = list(color = "#787878"),
      marker = list(color = "#787878"),
      visible = vis_traces[3],
      inherit = FALSE,
      showlegend = FALSE  
    ) 
    

    if(tab_geo == 'hd')
    {
      p <- p %>% add_trace(
        data = mixed_data,
        type = 'scatter',
        x = ~year,
        y = as.formula(paste0("~", var_name)),
        text = as.formula(paste0("~", label_name)),
        hoverinfo = 'text',
        mode = 'lines+markers',
        marker = list(color = 'lightblue'),
        line = list(color = 'lightblue'),
        transforms = list(
          list(
            type = 'groupby',
            groups = as.formula(paste0("~", label_name))
          )
        ),
        visible = vis_traces[4],
        inherit = FALSE,
        showlegend = FALSE
      )
    }
    
    #layout
    p %>% layout(
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
      
    ) #%>% onRender("function(p){
          #   var e = p.getElementsByClassName('boxlayer')
          #   if(e && e[0].parentElement){
          #     e[0].parentElement.appendChild(e[0].parentElement.children[0])
          #   }
          # }")
    
  }
  
  # tract measure plots ----------------------------------------
  
  output$m1_plot <- renderPlotly({
    measure_plot(urban_tract_data(), rural_tract_data(), chosen_county_data(), "no_health_ins", "tract_name", "tract")
  })
  
  output$m2_plot <- renderPlotly({
    measure_plot(urban_tract_data(), rural_tract_data(), chosen_county_data(), "bphigh_crudeprev", "tract_name", "tract")
  })
  
  output$m3_plot <- renderPlotly({
    measure_plot(urban_tract_data(), rural_tract_data(), chosen_county_data(), "cancer_crudeprev", "tract_name", "tract")
  })
  
  output$m4_plot <- renderPlotly({
    measure_plot(urban_tract_data(), rural_tract_data(), chosen_county_data(), "highchol_crudeprev", "tract_name", "tract")
  })
    
  output$m5_plot <- renderPlotly({
    measure_plot(urban_tract_data(), rural_tract_data(), chosen_county_data(), "obesity_crudeprev", "tract_name", "tract")
  })
  
  output$m6_plot <- renderPlotly({
    measure_plot(urban_tract_data(), rural_tract_data(), chosen_county_data(), "diabetes_crudeprev", "tract_name", "tract")
  })
  
  output$m7_plot <- renderPlotly({
    measure_plot(urban_tract_data(), rural_tract_data(), chosen_county_data(), "mhlth_crudeprev", "tract_name", "tract")
  })
  
  output$m8_plot <- renderPlotly({
    measure_plot(urban_tract_data(), rural_tract_data(), chosen_county_data(), "phlth_crudeprev", "tract_name", "tract")
  })
  
  
  #
  # Observe Events for tract measure plots -------------------------
  #
  
  observe({
    
    if(!is.null(input$health_access_comp_map_shape_click$id))
    {
      click_data <- chosen_county_data() %>%
        filter(census_tract_fips == input$health_access_comp_map_shape_click$id)
      
      m_name = c("no_health_ins", "bphigh_crudeprev", "cancer_crudeprev", "highchol_crudeprev",
                 "obesity_crudeprev", "diabetes_crudeprev", "mhlth_crudeprev", "phlth_crudeprev")
      
      
      for(i in 1:8) # 8=number of plots on tract page
      {
        p_name = paste0("m", i, "_plot")
        
        # remove previously chosen tract (if there was one)
        plotlyProxy(p_name, session) %>%
          plotlyProxyInvoke("deleteTraces", 3) # delete the fourth trace (if it exists)        
        
        plotlyProxy(p_name, session) %>%
          plotlyProxyInvoke("addTraces", 
            list(
              #data = click_data,
              type = 'scatter',
              x = click_data$year,
              y = click_data[[m_name[i]]], 
              text = click_data$tract_name,       
              hoverinfo = 'text',
              mode = 'markers+lines',
              marker = list(color = 'steelblue'),
              line = list(color = 'steelblue')
              #inherit = FALSE,
              #showlegend = FALSE
            )
          )
      }
    } 
  })
  
  
  # plot toggles are causing a problem with county data selection. if boxplots are off - only 1st plot is being updated with county switch
  
  # toggle boxplots
  observeEvent(input$ct_boxplots, {
    
    if(input$ct_boxplots == "Off")
    {
      for(i in 1:8) # 8=number of plots on tract page
      {
        p_name = paste0("m", i, "_plot")
        
        plotlyProxy(p_name, session) %>%
          plotlyProxyInvoke("restyle", list(visible = FALSE), 2)
      }
      
      # change boxplot switches on other tabs to Off
      updateSelectInput(session, "hd_boxplots", selected = "Off")
      updateSelectInput(session, "boxplots", selected = "Off")
    }
    else  # boxplots On
    {
      for(i in 1:8) # 8=number of plots on tract page
      {
        p_name = paste0("m", i, "_plot")
      
        plotlyProxy(p_name, session) %>%
          plotlyProxyInvoke("restyle", list(visible = TRUE), 2)
      }
      
      # change boxplot switches on other tabs to Off
      updateSelectInput(session, "hd_boxplots", selected = "On")
      updateSelectInput(session, "boxplots", selected = "On")
    }
    
  }) 
  
  
  # rural/urban toggle
  observeEvent(input$ct_rurality, {
    
    if(input$ct_rurality == "Off") # none
    {
      for(i in 1:8) # 8=number of plots on tract page
      {
        p_name = paste0("m", i, "_plot")
      
        plotlyProxy(p_name, session) %>%
          plotlyProxyInvoke("restyle", list(visible = FALSE), c(0,1))
      }
    }
    else if(input$ct_rurality == "All") # All
    {
      for(i in 1:8) # 8=number of plots on tract page
      {
        p_name = paste0("m", i, "_plot")
      
        plotlyProxy(p_name, session) %>%
          plotlyProxyInvoke("restyle", list(visible = TRUE), c(0,1))
      }
    }
    else if(input$ct_rurality == "Rural") # rural only
    {
      for(i in 1:8) # 8=number of plots on tract page
      {
        p_name = paste0("m", i, "_plot")
        
        plotlyProxy(p_name, session) %>%
          plotlyProxyInvoke("restyle", list(visible = FALSE), 0) %>%
          plotlyProxyInvoke("restyle", list(visible = TRUE), 1)
      }
    }
    else # urban only
    {
      for(i in 1:8) # 8=number of plots on tract page
      {
        p_name = paste0("m", i, "_plot")

        plotlyProxy(p_name, session) %>%
          plotlyProxyInvoke("restyle", list(visible = FALSE), 1) %>%
          plotlyProxyInvoke("restyle", list(visible = TRUE), 0)
      }
    }
    
  }) 
  
  
  
  #
  # Data Download -----------------------------------------------------
  #
  
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
  
  
  #
  # county measure plots -------------------------------------------------
  #
  
  output$cty_m1_plot <- renderPlotly({
    measure_plot(urban_cty_data(), rural_cty_data(), county_data, "no_health_ins", "county_name", "county")
  })
  
  
  # add trace in a different color of tract that was clicked on
  observe({
    
    if(!is.null(input$cty_health_access_comp_map_shape_click$id))
    {
      click_data <- chosen_hd_data() %>%
        filter(county_id == input$cty_health_access_comp_map_shape_click$id)
      
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 3) %>% # delete the fourth trace (prev chosen tract - if it exists)
      
        # add chosen tract in blue
        plotlyProxyInvoke(
          "addTraces", 
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$no_health_ins,
            text = paste0(click_data$county_name, " County"),
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
    
    if(input$boxplots == "Off")
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), 2)
      
      # change boxplot switches on other tabs to Off
      updateSelectInput(session, "hd_boxplots", selected = "Off")
      updateSelectInput(session, "ct_boxplots", selected = "Off")
    }
    else
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), 2)
      
      # change boxplot switches on other tabs to Off
      updateSelectInput(session, "hd_boxplots", selected = "On")
      updateSelectInput(session, "ct_boxplots", selected = "On")
    }
    
  }) 
  

  # rural/urban toggle
  observeEvent(input$rurality, {
    
    if(input$rurality == "Off") # none
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), c(0,1))      
    }
    else if(input$rurality == "All") # All
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), c(0,1))
    }
    else if(input$rurality == "Rural") # rural only
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), 0) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), 1)
    }
    else # urban only
    {
      plotlyProxy("cty_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), 1) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), 0)
      
    }
    
  }) 

  
  #
  # health district measure plots -------------------------------------------------
  #
  
  output$hd_m1_plot <- renderPlotly({
    measure_plot(urban_hd_data, rural_hd_data, vhd_data, "no_health_ins", "health_district", "hd", mixed_hd_data)
  })
  

  # add trace in a different color of tract that was clicked on
  observe({

    if(!is.null(input$vhd_health_access_comp_map_shape_click$id))
    {
      click_data <- vhd_data %>%
        filter(fid == input$vhd_health_access_comp_map_shape_click$id)

      plotlyProxy("hd_m1_plot", session) %>%
        plotlyProxyInvoke("deleteTraces", 4) %>% # delete the fifth trace (prev chosen tract-if it exists)
        
        # add chosen tract in blue
        plotlyProxyInvoke(
          "addTraces",
          list(
            type = 'scatter',
            x = click_data$year,
            y = click_data$no_health_ins,
            text = click_data$health_district,
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
  observeEvent(input$hd_boxplots, {

    if(input$hd_boxplots == "Off")
    {
      plotlyProxy("hd_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), 2)
      
      
      # change boxplot switches on other tabs to Off
      updateSelectInput(session, "ct_boxplots", selected = "Off")
      updateSelectInput(session, "boxplots", selected = "Off")
    }
    else
    {
      plotlyProxy("hd_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), 2)
      
      # change boxplot switches on other tabs to Off
      updateSelectInput(session, "ct_boxplots", selected = "On")
      updateSelectInput(session, "boxplots", selected = "On")
    }

  })


  # rural/urban toggle
  observeEvent(input$hd_rurality, {

    if(input$hd_rurality == "Off") # none
    {
      plotlyProxy("hd_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), c(0,1,3))
      
      # add other plotlyProxys here for other plots - we will have an observe event for each tab,
      # or could do plot controls as global vars so do not have to switch per tab. could use a for loop
    }
    else if(input$hd_rurality == "All") # all
    {
      plotlyProxy("hd_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), c(0,1,3))
    }
    else if(input$hd_rurality == "Rural") # rural only
    {
      plotlyProxy("hd_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), c(0,3)) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), 1)
    }
    else if(input$hd_rurality == "Urban") # urban only
    {
      plotlyProxy("hd_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), c(1,3)) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), 0)
    }
    else # mixed only
    {
      plotlyProxy("hd_m1_plot", session) %>%
        plotlyProxyInvoke("restyle", list(visible = FALSE), c(0,1)) %>%
        plotlyProxyInvoke("restyle", list(visible = TRUE), 3)
      
    }

  })

}

#
# APP ----------------------------------------------------------------------------------------------------
#

shinyApp(ui, server)