# Title: Shiny App3
# Description: This app visualizes California crash data (2014-2023) with dynamic plots and an interactive map.
# Author: Alan Vo
# Date: 12/6/2024


# =======================================================
# Packages (you can use other packages if you want)
# =======================================================
library(shiny)
library(tidyverse)    # data wrangling and graphics
library(lubridate)    # for working with dates
library(leaflet)      # web interactive maps
library(plotly)       # web interactive graphics

# Load the dataset
crashes <- read_csv(
  file = "crashes_california_2014_2023.csv", 
  col_types = list(
    col_double(),    # CASE_ID
    col_double(),    # ACCIDENT_YEAR
    col_date(),      # COLLISION_DATE 
    col_double(),    # COLLISION_TIME 
    col_double(),    # HOUR 
    col_integer(),   # DAY_OF_WEEK 
    col_character(), # WEATHER_1 
    col_character(), # WEATHER_2 
    col_character(), # STATE_HWY_IND
    col_character(), # COLLISION_SEVERITY 
    col_integer(),   # NUMBER_KILLED 
    col_integer(),   # NUMBER_INJURED 
    col_integer(),   # PARTY_COUNT 
    col_character(), # PCF_VIOL_CATEGORY 
    col_character(), # TYPE_OF_COLLISION 
    col_character(), # ROAD_SURFACE 
    col_character(), # ROAD_COND_1 
    col_character(), # ROAD_COND_2 
    col_character(), # LIGHTING 
    col_character(), # PEDESTRIAN_ACCIDENT 
    col_character(), # BICYCLE_ACCIDENT 
    col_character(), # MOTORCYCLE_ACCIDENT 
    col_character(), # TRUCK_ACCIDENT 
    col_character(), # NOT_PRIVATE_PROPERTY 
    col_character(), # ALCOHOL_INVOLVED 
    col_character(), # COUNTY 
    col_character(), # CITY 
    col_character(), # PO_NAME
    col_double(),    # ZIP_CODE
    col_double(),    # POINT_X 
    col_double()     # POINT_Y
  )
)

# Convert days and hours
crashes <- crashes %>%
  mutate(
    DAY_OF_WEEK = wday(COLLISION_DATE, label = TRUE, abbr = FALSE), # Full day names
    HOUR_AMPM = case_when( # Convert 24-hour format to 12-hour with AM/PM
      HOUR == 0 ~ "12 AM",
      HOUR > 0 & HOUR < 12 ~ paste0(HOUR, " AM"),
      HOUR == 12 ~ "12 PM",
      HOUR > 12 ~ paste0(HOUR - 12, " PM"),
      TRUE ~ NA_character_
    )
  )

# Define UI
ui <- fluidPage(
  titlePanel("California Crash Data Analysis (2014–2023)"),
  
  sidebarLayout(
    sidebarPanel(
      conditionalPanel(
        condition = "input.tabselected == 1",
        h4("Graphics Filters"),
        selectInput("year_graphics", "Select Year:", choices = unique(crashes$ACCIDENT_YEAR), selected = 2023),
        selectInput("severity", "Collision Severity:", choices = unique(crashes$COLLISION_SEVERITY), selected = "Fatal"),
        selectInput("county_graphics", "County:", choices = unique(crashes$COUNTY), selected = "Los Angeles")
      ),
      conditionalPanel(
        condition = "input.tabselected == 2",
        h4("Map Filters"),
        sliderInput("year_map", "Select Year:", 
                    min = min(crashes$ACCIDENT_YEAR), 
                    max = max(crashes$ACCIDENT_YEAR), 
                    value = max(crashes$ACCIDENT_YEAR), 
                    step = 1),
        selectInput("city_map", "Select City:", choices = unique(crashes$PO_NAME), multiple = TRUE),
        selectInput("violation", "Violation Category:", choices = unique(crashes$PCF_VIOL_CATEGORY), multiple = TRUE),
        radioButtons("color_by", "Color Map By:", choices = c("Type of Collision" = "TYPE_OF_COLLISION", 
                                                              "Collision Severity" = "COLLISION_SEVERITY"))
      )
    ),
    
    mainPanel(
      tabsetPanel(
        type = "tabs",
        id = "tabselected",
        tabPanel(
          title = "Graphics",
          value = 1,
          plotlyOutput("plot1"),
          hr(),
          plotlyOutput("plot2"),
          hr(),
          plotlyOutput("plot3")
        ),
        tabPanel(
          title = "Map",
          value = 2,
          leafletOutput("map", height = 600)
        )
      )
    )
  )
)

# Define server
server <- function(input, output) {
  # Graphics Tab Outputs
  output$plot1 <- renderPlotly({
    filtered_data <- crashes %>%
      filter(ACCIDENT_YEAR == input$year_graphics & COLLISION_SEVERITY == input$severity)
    
    plot <- ggplot(filtered_data) +
      geom_bar(aes(x = DAY_OF_WEEK), fill = "skyblue") +
      labs(title = "Collisions by Day of the Week", x = "Day of Week", y = "Count") +
      theme_minimal()
    
    ggplotly(plot)
  })
  
  output$plot2 <- renderPlotly({
    filtered_data <- crashes %>%
      filter(ACCIDENT_YEAR == input$year_graphics, COUNTY == input$county_graphics)
    
    plot <- ggplot(filtered_data) +
      geom_bar(aes(x = HOUR_AMPM), fill = "steelblue") +
      labs(title = "Collisions by Hour of the Day", x = "Hour (AM/PM)", y = "Count") +
      theme_minimal()
    
    ggplotly(plot)
  })
  
  output$plot3 <- renderPlotly({
    filtered_data <- crashes %>%
      filter(ACCIDENT_YEAR == input$year_graphics)
    
    plot <- ggplot(filtered_data) +
      geom_bar(aes(x = TYPE_OF_COLLISION, fill = COLLISION_SEVERITY)) +
      labs(title = "Collision Type by Severity", x = "Type of Collision", y = "Count") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(plot)
  })
  
  # Map Tab Output
  output$map <- renderLeaflet({
    filtered_data <- crashes %>%
      filter(ACCIDENT_YEAR == input$year_map, 
             PO_NAME %in% input$city_map, 
             PCF_VIOL_CATEGORY %in% input$violation)
    
    color_palette <- colorFactor(palette = "viridis", domain = filtered_data[[input$color_by]])
    
    leaflet(filtered_data) %>%
      addTiles() %>%
      addCircles(lng = ~POINT_X, lat = ~POINT_Y, 
                 color = ~color_palette(get(input$color_by)),
                 label = ~paste0("Date: ", COLLISION_DATE, "<br>",
                                 "Type: ", TYPE_OF_COLLISION, "<br>",
                                 "Cause: ", PCF_VIOL_CATEGORY))
  })
}

# Run the app
shinyApp(ui = ui, server = server)
