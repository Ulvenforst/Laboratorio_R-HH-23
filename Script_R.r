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

library(gridExtra)
library(grid)
library(dplyr)
library(editrules)
library(tidyr)
library(ggplot2)

# Carga de datos
datos <- read.csv("Data/BD_Huella.txt", header = TRUE, sep = "\t")

# Limpieza de datos y calificación de variables cualitativas
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
mean_HHD <- mean(datos$HHD, na.rm = TRUE)
mean_per_hog <- mean(datos$per.hog, na.rm = TRUE)

datos$HHD[is.na(datos$HHD)] <- mean_HHD
datos$per.hog[is.na(datos$per.hog)] <- mean_per_hog

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

# Limpieza de per.hog
datos$per.hog <- ifelse(is.na(datos$per.hog) | datos$per.hog <= 0, mean_per_hog, datos$per.hog)
datos$per.hog <- round(datos$per.hog)

# Reglas de validación
rules <- editrules::editfile("Informe/consistencia.txt")
Valid_Data <- editrules::violatedEdits(rules, datos)
summary(Valid_Data)

# Guardar datos limpios
# ruta <- "Data/clean_huella.txt"
# write.table(datos, file = ruta, sep = "\t", row.names = FALSE, na = "")