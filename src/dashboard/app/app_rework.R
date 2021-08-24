library(shiny)
library(shinyWidgets)
library(sf)
library(leaflet)
library(echarts4r)

vhd_data <- readRDS("health_district_data.rds")
tract_data <- readRDS("tract_prototype_data.rds")
county_data <- readRDS("county_data.rds")

# standardizing data
vhd_data$region_type <- vhd_data$hd_rural
tract_data$region_type <- tract_data$srhp_rural
county_data$region_type <- county_data$srhp_rural

county_data$health_district <- county_data$HealthDistrict
tract_data$health_district <- vapply(tract_data$county_id, function(county) {
  county_data[which(county_data$county_id == county)[1], "HealthDistrict", drop = TRUE]
}, "")

tract_data$name <- tract_data$tract_name
county_data$name <- county_data$county_name
vhd_data$name <- vhd_data$health_district

tract_data$id <- tract_data$census_tract_fips
county_data$id <- county_data$county_id
vhd_data$id <- as.character(vhd_data$fid)

# global constants
layout <- list(
  bottom = 250,
  plot_width = 250
)
year_range <- range(as.numeric(as.character(county_data$year)))
region_types <- c(
  urban = "lightgray",
  rural = "lightgreen",
  mixed = "lightblue"
)

format_name <- function(name){
  gsub("\\b(\\w)", "\\U\\1", gsub("_", " ", name, fixed = TRUE), perl = TRUE)
}

measures <- list(
  "Health Access" = list(
    name = "health_access",
    components = list(
      "Health District" = c(
        "No Health Insurance" = "no_health_ins",
        "High Blood Pressure" = "bphigh_crudeprev",
        "Cancer" = "cancer_crudeprev",
        "Obesity" = "obesity_crudeprev",
        "Diabetes" = "diabetes_crudeprev",
        "Mental Health" = "mhlth_crudeprev",
        "Physical Health" = "phlth_crudeprev"
      ),
      "County" = c(
        "No Health Insurance" = "no_health_ins",
        "High Blood Pressure" = "bphigh_crudeprev",
        "Cancer" = "cancer_crudeprev",
        "High Cholesterol" = "highchol_crudeprev",
        "Obesity" = "obesity_crudeprev",
        "Diabetes" = "diabetes_crudeprev",
        "Mental Health" = "mhlth_crudeprev",
        "Physical Health" = "phlth_crudeprev"
      ),
      "Census Tract" = c(
        "No Health Insurance" = "no_health_ins",
        "High Blood Pressure" = "bphigh_crudeprev",
        "Cancer" = "cancer_crudeprev",
        "High Cholesterol" = "highchol_crudeprev",
        "Obesity" = "obesity_crudeprev",
        "Diabetes" = "diabetes_crudeprev",
        "Mental Health" = "mhlth_crudeprev",
        "Physical Health" = "phlth_crudeprev"
      )
    )
  )
)
for (variable in colnames(vhd_data)) {
  if (
    is.numeric(vhd_data[, variable, drop = TRUE]) &&
    variable %in% colnames(county_data) &&
    variable %in% colnames(tract_data)
  ) {
    formatted <- format_name(variable)
    v <- c(
      vhd_data[, variable, drop = TRUE],
      county_data[, variable, drop = TRUE],
      tract_data[, variable, drop = TRUE]
    )
    if (!all(v == 0)) {
      measures[[formatted]] <- list(
        name = variable,
        palettes = list(
          `Health District` = colorNumeric('Oranges', range(vhd_data[, variable, drop = TRUE], na.rm = TRUE)),
          `County` = colorNumeric('Oranges', range(county_data[, variable, drop = TRUE], na.rm = TRUE)),
          `Census Tract` = colorNumeric('Oranges', range(tract_data[, variable, drop = TRUE], na.rm = TRUE))
        ),
        components = measures[[formatted]]$components
      )
    }
  }
}

variables <- vapply(measures, '[[', '', 'name')
correlates <- Reduce('+', lapply(seq(year_range[1], year_range[2]), function(year){
  suppressWarnings(cor(st_drop_geometry(tract_data[tract_data$year == year, variables]), use = 'pairwise.complete.obs'))
})) / (1 + year_range[2] - year_range[1])
correlates[is.na(correlates)] = 0
  
ui <- basicPage(
  tags$head(
    tags$style(type = "text/css", paste0(
      "html, body{width: 100%; height: 100%; overflow: hidden}\n",
      ".h1, .h2, .h3, .h4, .h5, .h6, h1, h2, h3, h4, h5, h6, .form-group{margin-top: 0; margin-bottom: 6px}\n",
      ".plot_block{display: block}"
    ))
  ),
  absolutePanel(
    top = 0, left = 0, right = 0, bottom = layout$bottom,
    leafletOutput("map", height = "100%", width = "100%"),
    absolutePanel(
      top = 10, left = 55,
      style = "background: rgba(255, 255, 255, 0.5); max-width: 1152px; border-radius: 2px",
      column(width = 2, style = "width: 215px", radioGroupButtons(
        inputId = "scale",
        label = "Select Region Type",
        choices = c("Health District", "County"),
        selected = "Health District"
      )),
      column(width = 3, style = "width: 320px", fluidRow(
        column(
          width = 7,
          conditionalPanel(
            "input.scale === 'Health District'",
            selectInput(
              inputId = "district",
              label = "Which Health District?",
              choices = c("All", sort(unique(vhd_data$health_district))),
              selected = "All",
              selectize = FALSE
            )
          ),
          conditionalPanel(
            "input.scale === 'County'",
            selectInput(
              inputId = "county",
              label = "Which County?",
              choices = c("All", sort(unique(county_data$county_name))),
              selected = "All",
              selectize = FALSE
            )
          )
        ),
        column(width = 1, actionButton("reset", "Reset", style = "margin: 25px 2px 0 0"))
      )),
      column(width = 3, style = "width: 325px", radioGroupButtons(
        inputId = "shapes",
        label = "Show Shapes of",
        choices = c("Health District", "County", "Census Tract"),
        selected = "Health District"
      )),
      column(width = 3, style = "width: 200px", selectInput(
        inputId = "measure",
        label = "Color by and Plot",
        choices = names(measures),
        selected = "Health Access",
        selectize = FALSE
      ))
    ),
    absolutePanel(
      bottom = 0, right = 20, width = 155,
      sliderInput(
        inputId = "year",
        label = "Year on Map",
        min = year_range[1],
        max = year_range[2],
        value = 2019,
        sep = ""
      )
    )
  ),
  absolutePanel(
    left = 0, right = 0, bottom = 0, height = layout$bottom,
    fluidRow(
      style = "margin-right: 0; margin-left: 0",
      column(
        width = 3,
        echarts4rOutput("measure_plot", width = layout$plot_width, height = layout$bottom)
      ),
      column(
        width = 6,
        echarts4rOutput("components_plot", width = "100%", height = layout$bottom)
      ),
      column(
        width = 2,
        echarts4rOutput("correlates_plot", width = layout$plot_width, height = layout$bottom)
      )
    )
  )
)

server <- function(input, output, session) {

  # session variables
  pal <- function(v){
    measures[[input$measure]]$palettes[[input$shapes]](v)
  }
  attr(pal, 'colorType') = 'numeric'
  attr(pal, 'colorArgs') = list(na.color = '#808080')

  # utils
  make_label <- function(data) {
    adj <- abs(min(data[, measures[[input$measure]]$name, drop = TRUE], na.rm = TRUE))
    lapply(with(data, paste0(
      paste("<strong>Health District:</strong>", health_district),
      if (input$shapes != "Health District") paste("<br /><strong>County:</strong>", county_name),
      if (input$shapes == "Census Tract") paste0("<br /><strong>Census Tract: </strong>", tract_name),
      paste0(
        "<br /><strong>", input$measure, " Score: </strong>",
        round(data[, measures[[input$measure]]$name, drop = TRUE], 2)
      )
    )), HTML)
  }

  #
  # interface interactions
  #

  observeEvent(input$reset, {
    updateSelectInput(inputId = if (input$scale == "County") "county" else "district", selected = "All")
  })

  observeEvent(input$scale, {
    updateRadioGroupButtons(
      getDefaultReactiveDomain(), "shapes",
      choices = c(if (input$scale == "Health District") "Health District", "County", "Census Tract"),
      selected = if (input$scale == "County" && input$shapes == "Health District") "County" else input$shapes
    )
  })

  observe({
    data <- initial_data()
    year_data <- data[data$year == input$year, ]

    leafletProxy("map") %>%
      removeControl("legend") %>%
      addLegend(
        "bottomleft", pal, year_data[, measures[[input$measure]]$name, drop = TRUE],
        title = paste(input$measure, "Score"),
        opacity = 0.7,
        na.label = "Not Available",
        layerId = "legend"
      )
  })

  #
  # data selection and filtering
  #

  initial_data <- reactive({
    data <- if (input$shapes == "Census Tract") {
      tract_data
    } else if (input$shapes == "County") {
      county_data
    } else {
      vhd_data
    }
    
    group_by(data, name)
  })

  select_data <- reactive({
    data <- initial_data()

    if ((input$shapes == "Health District" || input$scale == "Health District") && input$district != "All") {
      data <- data[data$health_district == input$district, ]
    } else if (input$scale != "Health District" && input$shapes != "Health District" && input$county != "All") {
      data <- data[data$county_name == input$county, ]
    }

    data
  })

  select_year <- reactive({
    data <- select_data()
    data[data$year == input$year, ]
  })

  trim_plot_data <- function(data, n = 10) {
    yd <- data[data$year == input$year, ]
    if (nrow(yd) > n * 2) {
      data <- data[data$name %in% yd[
        order(yd[, measures[[input$measure]]$name, drop = TRUE])[c(seq_len(n), seq_len(n) + nrow(yd) - n)],
        "name",
        drop = TRUE
      ], ]
    }
    data
  }

  #
  # plots
  #
  
  output$measure_plot <- renderEcharts4r({
    n <- if(input$shapes == 'Census Tract') 5 else 10
    data <- select_data() %>%
      trim_plot_data(n)
    
    data[, measures[[input$measure]]$name] <- round(data[, measures[[input$measure]]$name, drop = TRUE], 4)
    data$color <- unname(region_types[data$region_type])
    
    do.call(e_line, list(
      e_charts(data, year, width = layout$plot_width, height = layout$bottom) %>%
        e_title(
          input$measure,
          if (length(unique(data$name)) == n * 2) paste("Top and Bottom", n), right = "center"
        ) %>% e_tooltip(
          "item",
          order = "valueDesc",
          appendToBody = TRUE,
          transitionDuration = 0,
          confine = TRUE
        ) %>% e_color(data$color) %>%
        e_text_g(
          type = 'text',
          bottom = 10,
          right = 'center',
          style = list(
            text = "Year",
            fontSize = 14
          )
        ),
      str2expression(measures[[input$measure]]$name)[[1]],
      legend = FALSE
    ))
  })
  
  output$components_plot <- renderEcharts4r({
    p <- do.call(e_charts, list(
      as.data.frame(select_year()),
      str2expression(measures[[input$measure]]$name)[[1]]
    )) %>% e_tooltip(
      "axis",
      order = "valueDesc",
      appendToBody = TRUE,
      transitionDuration = 0,
      contain = TRUE
    ) %>% e_text_g(
      type = 'text',
      bottom = 10,
      right = 'center',
      style = list(
        text = input$measure,
        fontSize = 14
      )
    )

    for(variable in measures[[input$measure]]$components[[input$shapes]]){
      p <- do.call(e_line, list(p, str2expression(variable)[[1]]))
    }
    p
  })
  
  output$correlates_plot <- renderEcharts4r({
    data <- as.data.frame(select_data())
    if(length(unique(data$name)) > 1) data <- data[data$year == input$year, ]
    data[, colnames(correlates)] = scale(data[, colnames(correlates)])
    
    top <- correlates[-which(rownames(correlates) == measures[[input$measure]]$name), measures[[input$measure]]$name]
    top <- names(top[order(-abs(top))])[1:4]

    p <- do.call(e_charts, list(
      data,
      str2expression(measures[[input$measure]]$name)[[1]],
      width = layout$plot_width,
      height = layout$bottom
    )) %>% e_tooltip(
      "axis",
      order = "valueDesc",
      appendToBody = TRUE,
      transitionDuration = 0,
      contain = TRUE
    ) %>% e_text_g(
      type = 'text',
      bottom = 10,
      right = 'center',
      style = list(
        text = 'Top Correlates',
        fontSize = 14
      )
    )
    for(variable in top){
      p <- do.call(e_line, list(p, str2expression(variable)[[1]]))
    }
    p
  })
  
  observe({
    do.call(e_line, list(
      echarts4rProxy("measure_plot", select_data() %>%
          trim_plot_data(if(input$shapes == 'Census Tract') 5 else 10), year),
      str2expression(measures[[input$measure]]$name)[[1]],
      legend = FALSE
    ))
  })
  
  #
  # map and map interactions
  #

  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(attributionControl = FALSE)) %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(-79, 38, zoom = 7)
  })

  observe({
    data <- select_data()
    year_data <- select_year()
    data <- as.data.frame(data)

    polygon_bounds <- as.numeric(st_bbox(year_data))
    polygon_bounds <- polygon_bounds + (polygon_bounds[3] - polygon_bounds[1]) / 15 * c(-1, -1, 1, 1)
    
    leafletProxy("map") %>%
      clearShapes() %>%
      addPolygons(
        data = year_data,
        fillColor = pal(year_data[, measures[[input$measure]]$name, drop = TRUE]),
        fillOpacity = 0.7,
        stroke = TRUE, smoothFactor = 0.7, weight = 0.5, color = "#202020",
        label = make_label(year_data),
        labelOptions = list(textsize = 14),
        layerId = year_data[, "id", drop = TRUE]
      ) %>%
      flyToBounds(polygon_bounds[1], polygon_bounds[2], polygon_bounds[3], polygon_bounds[4])
  })

  observeEvent(input$map_shape_click, {
    if (input$shapes != "Census Tract" && !is.null(input$map_shape_click$id)) {
      data <- select_year()
      if (input$map_shape_click$id != input[[if (input$shapes == "County") "county" else "district"]] &&
        input$map_shape_click$id %in% data$id) {
        if (input$shapes != input$scale) {
          updateRadioGroupButtons(getDefaultReactiveDomain(), "scale", selected = input$shapes)
        }
        updateSelectInput(
          inputId = if (input$shapes == "County") "county" else "district",
          selected = data[data$id == input$map_shape_click$id, "name", drop = TRUE]
        )
      }
    }
  })

  observeEvent(input$map_shape_mouseover, {
    data <- select_data()
    if (input$map_shape_mouseover$id %in% data$id) {
      data <- as.data.frame(data[data$id == input$map_shape_mouseover$id, ])
      
      # add line to measure plot
      do.call(e_line, list(
        echarts4rProxy("measure_plot", data, year) %>% e_remove_serie("hovered_line"),
        str2expression(measures[[input$measure]]$name)[[1]],
        name = "hovered_line",
        lineStyle = list(color = "#000"),
        legend = FALSE
      )) %>% e_execute()
      
      # fill out correlates plot
      data[, colnames(correlates)] = scale(data[, colnames(correlates)])
      subcors <- suppressWarnings(cor(
        data[, measures[[input$measure]]$name],
        data[, colnames(correlates)[!colnames(correlates) == measures[[input$measure]]$name]],
        use = 'pairwise.complete.obs'
      ))[1,]
      top <- names(subcors[order(-abs(subcors))])[1:4]

      proxy <- do.call(echarts4rProxy, list(
        "correlates_plot",
        data,
        str2expression(measures[[input$measure]]$name)[[1]]
      ))
      
      for(i in 1:4){
        proxy <- e_remove_serie(proxy, serie_index = i - 1)
      }
      
      for(variable in top){
        proxy <- do.call(e_line, list(
          proxy,
          str2expression(variable)[[1]]
        ))
      }
      e_execute(proxy)
    }
  })
  
  observeEvent(input$map_shape_mouseout, {
    # remove highlight from measure plot
    echarts4rProxy("measure_plot") %>%
      e_remove_serie("hovered_line")
    
    # remake aggregate correlation plot
    data <- as.data.frame(select_data())
    if(length(unique(data$name)) > 1) data <- data[data$year == input$year, ]
    data[, colnames(correlates)] = scale(data[, colnames(correlates)])
    subcors <- correlates[
      -which(rownames(correlates) == measures[[input$measure]]$name),
      measures[[input$measure]]$name
    ]
    top <- names(subcors[order(-abs(subcors))])[1:4]
    
    proxy <- do.call(echarts4rProxy, list(
      "correlates_plot",
      data,
      str2expression(measures[[input$measure]]$name)[[1]]
    ))
    
    for(i in 1:4){
      proxy <- e_remove_serie(proxy, serie_index = i - 1)
    }
    
    for(variable in top){
      proxy <- do.call(e_line, list(
        proxy,
        str2expression(variable)[[1]]
      ))
    }
    e_execute(proxy)
  })
}

shinyApp(ui, server)
