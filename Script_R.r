# Laboratorio, Preprocesamiento de datos con R, Probabilidad y Estadística.
# Archivo: Informe_Huella.r
# Autores: Juan Camilo Narváez Tascón, 2140112-3743
#          Óscar David Cuaical, 2270657-3743
# Fecha creación: 21-11-23
# Fecha última modificación: 23-11-23
# Licencia: GPL-3.0

# Historia: Se desea caracterizar la huella hídrica de una institución de
# educación secundaria,se dispone de la base de datos data/BD_huella.txt,
# la cual contiene información de los estudiantes como: edad, genero, zona,
# grado escolar, cantidad de HH directa e indirecta en m3/año (HHD y HHI),
# el mayor componente de la HH directa e indirecta (comp_HHD y comp_HHI),
# y el número de personas que habitan en el hogar (per.hog).

# -------------------------------------------------------------------------
# Librerías necesarias
# install.packages("dplyr") # Se recomienda última versión.
# install.packages("editrules") # Se recomienda última versión.
# install.packages("tidyr") # Se recomienda última versión.
# install.packages("vctrs") # Se requiere una versión mayor o igual a 0.6.4
# install.packages("ggplot2") # Se recomienda última versión.
library(dplyr)
library(editrules)
library(tidyr)
library(ggplot2)

# Carga de datos
datos <- read.csv("data/BD_Huella.txt", header = TRUE, sep = "\t")

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

# Modelos de regresión lineal para HHD y HHI
modelo_HHD <- lm(HHD ~ edad + genero + zona + grado + per.hog, data = datos)
modelo_HHI <- lm(HHI ~ edad + genero + zona + grado + per.hog, data = datos)

# Aplicación de los modelos para estimar HHD y HHI
datos <- datos %>%
  mutate(
    HHD = ifelse(is.na(HHD) | HHD <= 0, round(predict(modelo_HHD, newdata = datos)), HHD),
    HHI = ifelse(is.na(HHI) | HHI <= 0, round(predict(modelo_HHI, newdata = datos)), HHI)
  )

# Limpieza de per.hog
mean_per_hog <- round(mean(datos$per.hog, na.rm = TRUE))
datos <- datos %>%
  mutate(per.hog = ifelse(is.na(per.hog) | per.hog <= 0, mean_per_hog, per.hog))

# Reglas de validación
rules <- editrules::editfile("informe/consistencia.txt")
Valid_Data <- editrules::violatedEdits(rules, datos)
summary(Valid_Data)