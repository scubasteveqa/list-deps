library(shiny)
library(ggplot2)
library(naniar)
library(bslib)
library(DT)

# Define UI for application
ui <- page_sidebar(
  title = "Naniar Missing Data Explorer",
  sidebar = sidebar(
    sliderInput("obs",
                "Number of observations:",
                min = 1,
                max = 1000,
                value = 500),
    checkboxInput("showAllPackages", "Show all installed packages", FALSE)
  ),
  
  card(
    card_header("Missing Data Visualization"),
    plotOutput("missPlot")
  ),
  
  card(
    card_header("Installed Packages"),
    DTOutput("packageTable")
  )
)

# Define server logic
server <- function(input, output) {
  output$missPlot <- renderPlot({
    # Generate a random dataset with missing values
    set.seed(123)
    data <- data.frame(
      x = rnorm(input$obs),
      y = rnorm(input$obs)
    )
    data[sample(1:input$obs, 50), "x"] <- NA
    data[sample(1:input$obs, 30), "y"] <- NA
    
    # Create a missingness plot using naniar
    gg_miss_var(data)
  })
  
  # Get installed packages and display in a table
  output$packageTable <- renderDT({
    if (input$showAllPackages) {
      # Show all installed packages
      installed_pkgs <- as.data.frame(installed.packages()[, c("Package", "Version", "LibPath")])
    } else {
      # Show only the specified packages
      default_packages <- c("shiny", "ggplot2", "naniar", "DT", "bslib")
      all_pkgs <- installed.packages()
      installed_pkgs <- as.data.frame(all_pkgs[all_pkgs[, "Package"] %in% default_packages, c("Package", "Version", "LibPath")])
    }
    
    datatable(installed_pkgs, 
              options = list(pageLength = 10, 
                             autoWidth = TRUE,
                             scrollX = TRUE),
              filter = 'top',
              rownames = FALSE)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
