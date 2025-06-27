library(shiny)
library(shinydashboard)
library(tidyverse)
library(lubridate)
library(plotly)
library(readr)
library(base64enc)

# Leer dataset y manejar columnas
ufc_data <- read_csv("data/ufc-master.csv") %>%
  mutate(
    Winner = case_when(
      Winner == "Red" ~ RedFighter,
      Winner == "Blue" ~ BlueFighter,
      TRUE ~ "Draw"
    ),
    total_fight_time_seconds = TotalFightTimeSecs,
    win_method = case_when(
      str_detect(tolower(Finish), "sub") ~ "Sumisión",
      str_detect(tolower(Finish), "ko|tko") ~ "KO/TKO",
      str_detect(tolower(Finish), "dec") ~ "Decisión",
      str_detect(tolower(Finish), "doc") ~ "Paro Médico",
      str_detect(tolower(Finish), "dq") ~ "Descalificación",
      TRUE ~ "Otro"
    )
  )

# Filtrar peleas de Islam
islam_fights <- ufc_data %>%
  filter(RedFighter == "Islam Makhachev" | BlueFighter == "Islam Makhachev") %>%
  mutate(
    FightDate = as.Date(Date),
    Opponent = ifelse(RedFighter == "Islam Makhachev", BlueFighter, RedFighter),
    Result = case_when(
      Winner == "Islam Makhachev" ~ "Ganada",
      Winner == "Draw" ~ "Empate",
      TRUE ~ "Perdida"
    )
  ) %>%
  arrange(FightDate)

# Intentar cargar imágenes localmente
tryCatch({
  islam_img <- base64enc::dataURI(file = "www/islam.jpg", mime = "image/jpeg")
  rusia_img <- base64enc::dataURI(file = "www/rusia.jpg", mime = "image/jpeg")
}, error = function(e) {
  # Si falla, usar imágenes de respaldo de internet
  islam_img <<- "https://raw.githubusercontent.com/mikecco/shiny-apps-sports/main/ufc_dashboard/islam.jpg"
  rusia_img <<- "https://raw.githubusercontent.com/mikecco/shiny-apps-sports/main/ufc_dashboard/rusia.jpg"
})

# UI
ui <- dashboardPage(
  dashboardHeader(title = "Islam Makhachev - Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Resumen", tabName = "resumen", icon = icon("user")),
      menuItem("Evolución", tabName = "evolucion", icon = icon("chart-line")),
      menuItem("Estilo de pelea", tabName = "estilo", icon = icon("dumbbell")),
      menuItem("Resultados", tabName = "resultados", icon = icon("check-circle")),
      menuItem("Estadísticas", tabName = "estadisticas", icon = icon("chart-bar"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .resumen-content {
          margin-left: 20px;
          padding: 15px;
          background-color: #f8f9fa;
          border-radius: 8px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .info-box {
          margin-top: 20px;
          padding: 15px;
          background-color: #e9f7ef;
          border-left: 4px solid #28a745;
          border-radius: 4px;
        }
        .fighter-title {
          margin-top: 0;
          color: #2c3e50;
          border-bottom: 2px solid #3498db;
          padding-bottom: 10px;
        }
        .section-title {
          color: #2980b9;
          margin-top: 25px;
          margin-bottom: 15px;
        }
        .stats-list {
          list-style-type: none;
          padding-left: 0;
        }
        .stats-list li {
          margin-bottom: 10px;
          padding-left: 20px;
          position: relative;
        }
        .stats-list li:before {
          content: '•';
          position: absolute;
          left: 0;
          color: #3498db;
          font-weight: bold;
        }
        .image-container {
          margin-bottom: 20px;
        }
      "))
    ),
    
    tabItems(
      # TAB RESUMEN (diseño mejorado)
      tabItem(tabName = "resumen",
              fluidRow(
                box(
                  width = 12, solidHeader = TRUE, status = "primary",
                  fluidRow(
                    column(4, align = "center",
                           div(class = "image-container",
                               tags$img(src = islam_img, height = "300px", 
                                        style = "border-radius: 15px; display: block; margin-left: auto; margin-right: auto;"),
                               div(style = "margin-top: 20px;",
                                   tags$h4("Peso Ligero - UFC", style = "font-weight: bold;"),
                                   div(style = "display: flex; align-items: center; justify-content: center; margin-bottom: 10px;",
                                       tags$img(src = rusia_img, height = "25px", style = "margin-right: 8px;"),
                                       tags$span("Rusia", style = "font-size: 16px; font-weight: bold;")
                                   ),
                                   tags$p(style = "margin-bottom: 5px;"),
                                   tags$p("Edad 33 años")
                               )
                           )
                    ),
                    column(8,
                           div(class = "resumen-content",
                               tags$h2("Islam Makhachev", class = "fighter-title"),
                               
                               tags$h3("Resumen del peleador", class = "section-title"),
                               tags$p("Islam Makhachev es un peleador ruso de artes marciales mixtas que compite en la categoría de peso ligero de UFC. Es conocido por su dominio del grappling y su resistencia física dentro del octágono."),
                               tags$p("Es entrenado por el legendario Khabib Nurmagomedov y ha sido considerado como su sucesor."),
                               tags$p("Desde su debut en 2015, ha mostrado una evolución constante y se ha mantenido entre los mejores del ranking. Llegando al máximo de su carrera al convertirse, en el 2022, como el actual campeón de su división."),
                               
                               div(class = "info-box",
                                   tags$h3("Información clave", class = "section-title"),
                                   tags$ul(class = "stats-list",
                                           tags$li(tags$strong("Récord: "), "25-1-0"),
                                           tags$li(tags$strong("Estilo: "), "Sambo / Wrestling"),
                                           tags$li(tags$strong("Altura: "), "1.79 m"),
                                           tags$li(tags$strong("Equipo: "), "Khabib´s team y American Kickboxing Academy"),
                                           tags$li(tags$strong("Ranking: "), "Campeón de Peso Ligero de UFC")
                                   )
                               )
                           )
                    )
                  )
                )
              )
      ),
      
      # TAB EVOLUCIÓN
      tabItem(tabName = "evolucion",
              fluidRow(
                box(width = 12, plotlyOutput("fight_timeline"))
              )
      ),
      
      # TAB ESTILO DE PELEA
      tabItem(tabName = "estilo",
              fluidRow(
                box(width = 12, plotlyOutput("method_distribution"))
              )
      ),
      
      # TAB RESULTADOS
      tabItem(tabName = "resultados",
              fluidRow(
                box(width = 6, plotlyOutput("result_distribution")),
                box(width = 6, plotlyOutput("avg_duration"))
              )
      ),
      
      # TAB ESTADÍSTICAS
      tabItem(tabName = "estadisticas",
              fluidRow(
                valueBoxOutput("total_peleas"),
                valueBoxOutput("victorias"),
                valueBoxOutput("derrotas")
              ),
              fluidRow(
                valueBoxOutput("porcentaje_finalizacion"),
                valueBoxOutput("duracion_promedio")
              )
      )
    )
  )
)

# SERVER
server <- function(input, output, session) {
  # Línea de tiempo de peleas
  output$fight_timeline <- renderPlotly({
    p <- islam_fights %>%
      ggplot(aes(x = FightDate, y = reorder(Opponent, FightDate), 
                 color = Result, text = paste("Oponente:", Opponent, "<br>Resultado:", Result))) +
      geom_point(size = 4) +
      labs(title = "Línea de tiempo de peleas", x = "Fecha", y = "Oponente") +
      theme_minimal() +
      scale_color_manual(values = c("Ganada" = "green", "Perdida" = "red", "Empate" = "blue", "Sin resultado" = "gray"))
    
    ggplotly(p, tooltip = "text")
  })
  
  # Estilo de pelea 
  output$method_distribution <- renderPlotly({
    datos <- islam_fights %>%
      filter(Result == "Ganada") %>%
      count(win_method) 
    
    if(nrow(datos) == 0) {
      return(plotly_empty() %>% 
               layout(title = "Datos no disponibles",
                      annotations = list(text = "No hay datos de métodos de victoria", 
                                         showarrow = FALSE)))
    }
    
    p <- datos %>%
      ggplot(aes(x = reorder(win_method, n), y = n, fill = win_method, 
                 text = paste("Método:", win_method, "<br>Victorias:", n))) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      labs(title = "Métodos de victoria", x = "Método", y = "Cantidad") +
      theme_minimal()
    
    ggplotly(p, tooltip = "text")
  })
  
  # Resultados
  output$result_distribution <- renderPlotly({
    datos <- islam_fights %>%
      count(Result)
    
    p <- datos %>%
      ggplot(aes(x = Result, y = n, fill = Result, 
                 text = paste("Resultado:", Result, "<br>Peleas:", n))) +
      geom_col(show.legend = FALSE) +
      labs(title = "Resultados de peleas", x = "", y = "Cantidad") +
      theme_minimal() +
      scale_fill_manual(values = c("Ganada" = "green", "Perdida" = "red", "Empate" = "blue", "Sin resultado" = "gray"))
    
    ggplotly(p, tooltip = "text")
  })
  
  # Duración promedio
  output$avg_duration <- renderPlotly({
    datos <- islam_fights %>%
      filter(!is.na(total_fight_time_seconds)) %>%
      mutate(DurationMin = total_fight_time_seconds / 60)
    
    if(nrow(datos) == 0) {
      return(plotly_empty() %>% 
               layout(title = "Datos no disponibles",
                      annotations = list(text = "No hay datos de duración de peleas", 
                                         showarrow = FALSE)))
    }
    
    p <- datos %>%
      ggplot(aes(x = Result, y = DurationMin, color = Result,
                 text = paste("Oponente:", Opponent, 
                              "<br>Duración:", round(DurationMin, 1), "min",
                              "<br>Resultado:", Result))) +
      geom_jitter(width = 0.2, size = 3) +
      labs(title = "Duración de peleas por resultado", x = "", y = "Minutos") +
      theme_minimal()
    
    ggplotly(p, tooltip = "text")
  })
  
  # Estadísticas generales
  output$total_peleas <- renderValueBox({
    valueBox(nrow(islam_fights), "Total de peleas", icon = icon("gloves"), color = "aqua")
  })
  
  output$victorias <- renderValueBox({
    victorias <- sum(islam_fights$Result == "Ganada", na.rm = TRUE)
    valueBox(victorias, "Victorias", icon = icon("trophy"), color = "green")
  })
  
  output$derrotas <- renderValueBox({
    derrotas <- sum(islam_fights$Result == "Perdida", na.rm = TRUE)
    valueBox(derrotas, "Derrotas", icon = icon("times-circle"), color = "red")
  })
  
  output$porcentaje_finalizacion <- renderValueBox({
    total_victorias <- sum(islam_fights$Result == "Ganada", na.rm = TRUE)
    
    if(total_victorias > 0) {
      finalizaciones <- islam_fights %>%
        filter(Result == "Ganada") %>%
        filter(win_method %in% c("Sumisión", "KO/TKO")) %>%
        nrow()
      
      porc <- round(100 * finalizaciones / total_victorias, 1)
      valueBox(paste0(porc, "%"), "Victorias por finalización", icon = icon("bolt"), color = "orange")
    } else {
      valueBox("0%", "Victorias por finalización", icon = icon("bolt"), color = "orange")
    }
  })
  
  output$duracion_promedio <- renderValueBox({
    avg_duration <- islam_fights %>%
      filter(!is.na(total_fight_time_seconds)) %>%
      summarise(prom = mean(total_fight_time_seconds, na.rm = TRUE)) %>%
      pull(prom) / 60
    
    if (is.na(avg_duration)) {
      valueBox("N/D", "Duración promedio", icon = icon("clock"), color = "purple")
    } else {
      valueBox(
        paste0(round(avg_duration, 1), " min"),
        "Duración promedio", icon = icon("clock"), color = "purple"
      )
    }
  })
}

# Ejecutar app
shinyApp(ui = ui, server = server)
