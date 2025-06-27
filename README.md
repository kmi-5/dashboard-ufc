**Dashboard UFC - Islam Makhachev** 

Este proyecto implementa un dashboard interactivo en RStudio utilizando las librerías **Shiny** y **shinydashboard** teniendo como objetivo analizar la evolución deportiva del peleador **Islam Makhachev**, actual campeón de peso ligero de la UFC. Utilizando visualizaciones interactivas desarrolladas en R. Presenta información detallada de cada una de sus peleas registradas, incluyendo resultados, fechas, duración y métodos de finalización.
Cabe aclarar que el análisis se basó en el dataset público disponible en [Kaggle](https://www.kaggle.com/datasets/mdabbert/ultimate-ufc-dataset?utm_source), el cual contiene información actualizada hasta el 1 de junio de 2024.

Primero, el código carga y limpia un dataset general de peleas de UFC (`ufc-master.csv`). Se transforman algunas columnas para facilitar el análisis: se identifica el ganador con el nombre del peleador (en lugar de “Red” o “Blue”), se clasifica el método de victoria en categorías (sumisión, KO/TKO, decisión, etc.) y se calcula la duración total de cada pelea en segundos.
Luego, se filtran solo las peleas en las que participó Islam Makhachev, creando nuevas variables como la fecha del combate, el oponente, y el resultado de la pelea (ganada, perdida o empate). También se prepara la carga de imágenes, tratando primero de cargarlas localmente y, en caso de error, usando URLs remotas.


# Interfaz contenido:

* **Resumen:** presenta información básica y descriptiva sobre Islam, su récord, estilo de pelea, y equipo.
* **Evolución:** muestra una línea de tiempo con cada pelea en orden cronológico.
* **Estilo de pelea:** gráfica la distribución de los métodos de victoria en las peleas ganadas.
* **Resultados:** presenta gráficos con la cantidad de peleas ganadas, perdidas o empatadas, y la duración promedio de las peleas según el resultado.
* **Estadísticas:** muestra indicadores numéricos clave como total de peleas, victorias, derrotas, porcentaje de finalizaciones, y duración promedio.


# Funcionamiento de gráficos:

* En la pestaña *Evolución*, se utiliza un gráfico de puntos (`geom_point`) donde cada punto representa una pelea contra un oponente en una fecha específica, coloreado según el resultado (verde para ganada, rojo para perdida, azul para empate). Este gráfico permite visualizar la trayectoria temporal del peleador.
* En *Estilo de pelea*, un gráfico de barras horizontales muestra la cantidad de victorias por cada método de finalización, lo que ayuda a entender cuál es el estilo dominante en sus triunfos.
* En *Resultados*, otro gráfico de barras muestra el conteo total de peleas por resultado, mientras que un gráfico de dispersión (`geom_jitter`) representa la duración de cada pelea agrupada por resultado, mostrando la variabilidad en minutos.
* Los gráficos son interactivos gracias a `plotly`, lo que permite ver detalles en ventanas al pasar el cursor sobre los puntos o barras, como el nombre del oponente, resultado o duración exacta de pelea.


# Cómo ejecutar

1. Clonar o descargar este repositorio.
2. Asegurarse de tener las librerías instaladas.
	library(shiny)
	library(shinydashboard)
	library(tidyverse)
	library(lubridate)
	library(plotly)
	library(readr)
	- ejecución de app.
	shinyApp(ui = ui, server = server)
3. Ejecutar el archivo `app.R` o el script principal desde RStudio.





