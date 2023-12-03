# Laboratorio, Preprocesamiento de datos con R, Probabilidad y Estadística.
# Archivo: Informe_Huella.r
# Autores: Juan Camilo Narváez Tascón, 2140112-3743
#          Óscar David Cuaical, 2270657-3743
# Fecha creación: 21-11-23
# Fecha última modificación: 2-12-23
# Licencia: GPL-3.0

# Historia: Se desea caracterizar la huella hídrica de una institución de
# educación secundaria,se dispone de la base de datos data/BD_huella.txt,
# la cual contiene información de los estudiantes como: edad, genero, zona,
# grado escolar, cantidad de HH directa e indirecta en m3/año (HHD y HHI),
# el mayor componente de la HH directa e indirecta (comp_HHD y comp_HHI),
# y el número de personas que habitan en el hogar (per.hog).

# -------------------------------------------------------------------------
# Librerías necesarias
# install.packages("visdat") # Se recomienda última versión.
# install.packages("rmarkdown")
# install.packages("dplyr") # Se recomienda última versión.
# install.packages("editrules") # Se recomienda última versión.
# install.packages("tidyr") # Se recomienda última versión.
# install.packages("vctrs") # Se requiere una versión mayor o igual a 0.6.4
# install.packages("ggplot2") # Se recomienda última versión.
# install.packages("gridExtra") # Se recomienda última versión.
# install.packages("grid") # Se recomienda última versión.
install.packages("knitr") # Se recomienda última versión.

library(data.table)
library(gridExtra)
library(grid)
library(visdat)
library(dplyr)
library(editrules)
library(tidyr)
library(ggplot2)
library(knitr)

# 1.1 Carga de datos
datos <- read.csv("Data/BD_Huella.txt", header = TRUE, sep = "\t")

# 1.3 Limpieza de datos y calificación de variables cualitativas
datos <- datos %>%
  mutate(
    genero = iconv(as.character(genero), to = "ASCII//TRANSLIT"),
    zona = iconv(as.character(zona), to = "ASCII//TRANSLIT"),
    grado = iconv(as.character(grado), to = "ASCII//TRANSLIT"),
    genero = tolower(genero),
    zona = tolower(zona),
    grado = tolower(grado),
    genero = case_when(genero %in% c("femenino", "1") ~ "1",
                       genero %in% c("masculino", "2") ~ "2",
                       TRUE ~ NA_character_),
    zona = case_when(zona %in% c("urbano", "1") ~ "1",
                     zona %in% c("rural", "2") ~ "2",
                     TRUE ~ NA_character_),
    grado = case_when(grado %in% c("6", "sexto") ~ "6",
                      grado %in% c("7", "septimo") ~ "7",
                      grado %in% c("8", "octavo") ~ "8",
                      grado %in% c("9", "noveno") ~ "9",
                      grado %in% c("10", "decimo") ~ "10",
                      grado %in% c("11", "once") ~ "11",
                      TRUE ~ NA_character_),
    genero = factor(genero, levels = c("1", "2"), labels = c("femenino", "masculino")),
    zona = factor(zona, levels = c("1", "2"), labels = c("urbano", "rural")),
    grado = factor(grado, levels = c("6", "7", "8", "9", "10", "11"), labels = c("sexto", "séptimo", "octavo", "noveno", "décimo", "once")),
    comp_HHD = tolower(gsub("[._]", "_", comp_HHD)),
    comp_HHI = tolower(comp_HHI)
  )

# 1.4 Visualización de datos faltantes
x11()
print(vis_miss(datos))

# 1.5 Estudio de datos atípicos
x11()
variables_interes <- c("edad", "HHD", "HHI", "per.hog")

# Ajustar los márgenes y el número de gráficos por ventana gráfica
par(mfrow=c(4, 2), mar=c(4, 4, 2, 1))

# Visualización de datos atípicos para cada variable cuantitativa
for (var in variables_interes) {
  # Histograma
  hist(datos[[var]], main=paste("Histograma de", var), xlab=var, col="lightblue")

  # Boxplot
  boxplot(datos[[var]], main=paste("Boxplot de", var), xlab=var, col="lightgreen", horizontal=TRUE)
}

calcular_cerco_superior_y_conteo <- function(data, variable) {
    Q3 <- quantile(data[[variable]], 0.75, na.rm = TRUE)
    IQR <- IQR(data[[variable]], na.rm = TRUE)
    upper_bound <- Q3 + 1.5 * IQR
    conteo_atipicos <- sum(data[[variable]] > upper_bound, na.rm = TRUE)

    max_value <- max(data[[variable]], na.rm = TRUE)
    
    mensaje <- paste("Cerco superior de", variable, ":", upper_bound, 
                     "; Número de datos atípicos:", conteo_atipicos, 
                     "; Valor máximo:", max_value)
    return(mensaje)
}

# Aplicar la función a las variables de interés
calcular_cerco_superior_y_conteo(datos, "HHD")
calcular_cerco_superior_y_conteo(datos, "HHI")
calcular_cerco_superior_y_conteo(datos, "per.hog")

# 1.6 Limpieza de datos atípicos y faltantes.
# Función para reemplazar datos atípicos con NA
reemplazar_atipicos_con_NA <- function(data, variable) {
    Q3 <- quantile(data[[variable]], 0.75, na.rm = TRUE)
    IQR <- IQR(data[[variable]], na.rm = TRUE)
    upper_bound <- Q3 + 1.5 * IQR

    # Reemplazar datos que exceden el cerco superior con NA
    data[[variable]][data[[variable]] >= upper_bound] <- NA
    return(data)
}

# Aplicar la función a HHD y per.hog
datos <- reemplazar_atipicos_con_NA(datos, "HHD")
datos <- reemplazar_atipicos_con_NA(datos, "per.hog")

# Imputar valores faltantes para HHD y per.hog con la media de cada variable
mean_HHD <- round(mean(datos$HHD, na.rm = TRUE))
mean_per_hog <- round(mean(datos$per.hog, na.rm = TRUE))

# Modelos de regresión lineal para HHD y HHI
modelo_HHD <- lm(HHD ~ edad + genero + zona + grado + per.hog, data = datos)
modelo_HHI <- lm(HHI ~ edad + genero + zona + grado + per.hog, data = datos)

# Aplicación de los modelos para estimar HHD y HHI
datos <- datos %>%
  mutate(
    HHD = ifelse(is.na(HHD) | HHD <= 0, predict(modelo_HHD, newdata = datos), HHD),
    HHI = ifelse(is.na(HHI) | HHI <= 0, predict(modelo_HHI, newdata = datos), HHI)
  ) %>%
  mutate(
    HHD = round(HHD),
    HHI = round(HHI)
  )

datos$HHD[is.na(datos$HHD)] <- mean_HHD
datos$per.hog[is.na(datos$per.hog)] <- mean_per_hog

# Limpieza de per.hog
datos$per.hog <- ifelse(is.na(datos$per.hog) | datos$per.hog <= 0, mean_per_hog, datos$per.hog)

# 1.2 Reglas de validación
rules <- editrules::editfile("Informe/consistencia.txt")
Valid_Data <- editrules::violatedEdits(rules, datos)
summary(Valid_Data)

# 1.7 Guardar datos limpios
ruta <- "Data/clean_huella.csv"
# write.csv(datos, file = ruta, row.names = FALSE, na = "", fileEncoding = "UTF-8")

# Carga de datos limpios
datos <- read.csv(ruta, header = TRUE)

# 1.8 Creacion de las nuevas variables HHT Y HHT_clas
datos$HHT <- datos$HHD + datos$HHI
datos$HHT_clas <- cut(datos$HHT,
                      breaks = c(-Inf, 1789, 1887, Inf),
                      labels = c("bajo", "medio", "alto"),
                      include.lowest = TRUE)

# 2.1 Distribuciones

# Asegurándonos de que los nombres de los ejes y las etiquetas estén presentes y claros
x11()
grid.arrange(p_HHD, bp_HHD, p_HHI, bp_HHI, p_HHT, bp_HHT, ncol = 2, nrow = 3)
bp_theme <- theme(
  axis.title.x = element_text(face = "bold", color = "black", size = 12),
  axis.text.x = element_text(angle = 45, hjust = 1, color = "black", size = 10),
  axis.title.y = element_text(face = "bold", color = "black", size = 12),
  axis.text.y = element_text(color = "black", size = 10),
  plot.title = element_text(hjust = 0.5, face = "bold", size = 14)
)

# Crear los gráficos de boxplot con etiquetas adecuadas
bp_HHD <- ggplot(datos, aes(x = comp_HHD, y = HHD)) + 
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Boxplot de HHD por Componente", x = "Componente de HHD", y = "HHD") +
  bp_theme

bp_HHI <- ggplot(datos, aes(x = comp_HHI, y = HHI)) + 
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Boxplot de HHI por Componente", x = "Componente de HHI", y = "HHI") +
  bp_theme

bp_HHT <- ggplot(datos, aes(x = HHT_clas, y = HHT)) + 
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Boxplot de HHT por clasificacion", x = "clasifiacion HHT", y = "HHT") +
  bp_theme

# Crear los gráficos de distribución
p_HHD <- ggplot(datos, aes(x = HHD)) +
  geom_histogram(aes(y = ..density..), binwidth = 10, fill = "blue", color = "black", alpha = 0.5) +
  geom_density(color = "red", size = 1) +
  theme_minimal() +
  labs(title = "Distribución de HHD", x = "HHD", y = "Densidad") +
  bp_theme

p_HHI <- ggplot(datos, aes(x = HHI)) +
  geom_histogram(aes(y = ..density..), binwidth = 100, fill = "green", color = "black", alpha = 0.5) +
  geom_density(color = "red", size = 1) +
  theme_minimal() +
  labs(title = "Distribución de HHI", x = "HHI", y = "Densidad") +
  bp_theme

p_HHT <- ggplot(datos, aes(x = HHT)) +
  geom_histogram(aes(y = ..density..), binwidth = 20, fill = "orange", color = "black", alpha = 0.5) +
  geom_density(color = "red", size = 1) +
  theme_minimal() +
  labs(title = "Distribución de HHT", x = "HHT", y = "Densidad") +
  bp_theme


# Organizar las gráficas en un solo panel con x11
x11()

# 2.2 Comportamiento de HHD y HHI con cada factor
common_theme <- theme_minimal() +
  theme(
    axis.title = element_text(size = 12),
    axis.text.x = element_text(size = 10, angle = 45, vjust = 0.5), # Etiquetas del eje X inclinadas
    axis.text.y = element_text(size = 10),
    plot.title = element_text(hjust = 0.5, size = 14),
    legend.position = "none" # Desactivar la leyenda globalmente
  )

# Función para crear gráficos de HHD y HHI por factor con colores suaves
crear_graficos_por_factor <- function(data, factor) {
  pa_HHD <- ggplot(data, aes_string(x = factor, y = "HHD", fill = factor)) +
    geom_boxplot() +
    labs(title = paste("HHD por", factor), y = "HHD") +
    scale_fill_brewer(palette = "Set2") +
    common_theme
  
  pa_HHI <- ggplot(data, aes_string(x = factor, y = "HHI", fill = factor)) +
    geom_boxplot() +
    labs(title = paste("HHI por", factor), y = "HHI") +
    scale_fill_brewer(palette = "Set3") +
    common_theme
  
  return(list(pa_HHD, pa_HHI))
}

# Crear los gráficos para cada factor
graficos_genero <- crear_graficos_por_factor(datos, "genero")
graficos_grado <- crear_graficos_por_factor(datos, "grado")
graficos_zona <- crear_graficos_por_factor(datos, "zona")

# Combinar los gráficos en una sola ventana
grid.arrange(
  graficos_genero[[1]], graficos_genero[[2]],
  graficos_grado[[1]], graficos_grado[[2]],
  graficos_zona[[1]], graficos_zona[[2]],
  ncol = 2, nrow = 3
)

# 2.3 Resumen general de indicadores descriptivos para HHD y HHI
# Función para calcular la moda
moda <- function(x) {
  uniqx <- unique(x)
  uniqx[which.max(tabulate(match(x, uniqx)))]
}

resumen_general <- datos %>%
  summarise(
    count_HHD = n(),
    mean_HHD = mean(HHD, na.rm = TRUE),
    median_HHD = median(HHD, na.rm = TRUE),
    sd_HHD = sd(HHD, na.rm = TRUE),
    min_HHD = min(HHD, na.rm = TRUE),
    max_HHD = max(HHD, na.rm = TRUE),
    mode_HHD = moda(HHD),
    count_HHI = n(),
    mean_HHI = mean(HHI, na.rm = TRUE),
    median_HHI = median(HHI, na.rm = TRUE),
    sd_HHI = sd(HHI, na.rm = TRUE),
    min_HHI = min(HHI, na.rm = TRUE),
    max_HHI = max(HHI, na.rm = TRUE),
    mode_HHI = moda(HHI)
  )

resumen_genero <- datos %>%
  group_by(genero) %>%
  summarise(
    count = n(),
    mean_HHD = mean(HHD, na.rm = TRUE),
    median_HHD = median(HHD, na.rm = TRUE),
    sd_HHD = sd(HHD, na.rm = TRUE),
    min_HHD = min(HHD, na.rm = TRUE),
    max_HHD = max(HHD, na.rm = TRUE),
    mode_HHD = moda(HHD),
    mean_HHI = mean(HHI, na.rm = TRUE),
    median_HHI = median(HHI, na.rm = TRUE),
    sd_HHI = sd(HHI, na.rm = TRUE),
    min_HHI = min(HHI, na.rm = TRUE),
    max_HHI = max(HHI, na.rm = TRUE),
    mode_HHI = moda(HHI)
  )

resumen_grado <- datos %>%
  group_by(grado) %>%
  summarise(
    count = n(),
    mean_HHD = mean(HHD, na.rm = TRUE),
    median_HHD = median(HHD, na.rm = TRUE),
    sd_HHD = sd(HHD, na.rm = TRUE),
    min_HHD = min(HHD, na.rm = TRUE),
    max_HHD = max(HHD, na.rm = TRUE),
    mode_HHD = moda(HHD),
    mean_HHI = mean(HHI, na.rm = TRUE),
    median_HHI = median(HHI, na.rm = TRUE),
    sd_HHI = sd(HHI, na.rm = TRUE),
    min_HHI = min(HHI, na.rm = TRUE),
    max_HHI = max(HHI, na.rm = TRUE),
    mode_HHI = moda(HHI)
  )

resumen_zona <- datos %>%
  group_by(zona) %>%
  summarise(
    count = n(),
    mean_HHD = mean(HHD, na.rm = TRUE),
    median_HHD = median(HHD, na.rm = TRUE),
    sd_HHD = sd(HHD, na.rm = TRUE),
    min_HHD = min(HHD, na.rm = TRUE),
    max_HHD = max(HHD, na.rm = TRUE),
    mode_HHD = moda(HHD),
    mean_HHI = mean(HHI, na.rm = TRUE),
    median_HHI = median(HHI, na.rm = TRUE),
    sd_HHI = sd(HHI, na.rm = TRUE),
    min_HHI = min(HHI, na.rm = TRUE),
    max_HHI = max(HHI, na.rm = TRUE),
    mode_HHI = moda(HHI)
  )

print(resumen_general)
print(resumen_genero)
print(resumen_grado)
print(resumen_zona)
