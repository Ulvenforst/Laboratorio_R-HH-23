# Laboratorio, Preprocesamiento de datos con R, Probabilidad y Estadística.
# Archivo: Informe_Huella.r
# Autores: Juan Camilo Narváez Tascón, 2140112-3743
#          Óscar David Cuaical, 2270657-3743
# Fecha creación: 21-11-23
# Fecha última modificación: 21-11-23
# Licencia: GPL-3.0

# Historia: Se desea caracterizar la huella hídrica de una institución de
# educación secundaria,se dispone de la base de datos data/BD_huella.txt,
# la cual contiene información de los estudiantes como: edad, genero, zona,
# grado escolar, cantidad de HH directa e indirecta en m3/año (HHD y HHI),
# el mayor componente de la HH directa e indirecta (comp_HHD y comp_HHI),
# y el número de personas que habitan en el hogar (per.hog).

# -------------------------------------------------------------------------
# Carga de datos
datos <- read.csv("data/BD_Huella.txt", header = TRUE, sep = "\t")

# 1. Limpieza de datos
# 1.1 Calificación de variables cualitativas:
# | Atributo |                            Valor                           |
# | -------- | ---------------------------------------------------------- |
# | genero   | 1=femenino; 2=masculino                                    |
# | zona     | 1=urbano; 2=rural                                          |
# | grado    | 6=sexto; 7=séptimo; 8=octavo, 9=noveno, 10=decimo, 11=once |

# install.packages("dplyr") # Se recomienda última versión.
# install.packages("vctrs") # Se requiere una versión mayor o igual a 0.6.4

library(dplyr)

datos <- datos %>%
  mutate(
    # Asegurarse de que todas las entradas son texto sin tilde
    genero = iconv(as.character(genero), to = "ASCII//TRANSLIT"),
    zona = iconv(as.character(zona), to = "ASCII//TRANSLIT"),
    grado = iconv(as.character(grado), to = "ASCII//TRANSLIT"),

    # Transformación a minúsculas para estandarizar
    genero = tolower(genero),
    zona = tolower(zona),
    grado = tolower(grado),

    # Recodificación de las variables
    genero = case_when(
      genero %in% c("femenino", "1") ~ "1",
      genero %in% c("masculino", "2") ~ "2",
      TRUE ~ NA_character_
    ),
    zona = case_when(
      zona %in% c("urbano", "1") ~ "1",
      zona %in% c("rural", "2") ~ "2",
      TRUE ~ NA_character_
    ),
    grado = case_when(
      grado %in% c("6", "sexto") ~ "6",
      grado %in% c("7", "septimo") ~ "7",
      grado %in% c("8", "octavo") ~ "8",
      grado %in% c("9", "noveno") ~ "9",
      grado %in% c("10", "decimo") ~ "10",
      grado %in% c("11", "once") ~ "11",
      TRUE ~ NA_character_
    ),
    # Convertir a factores
    genero = factor(genero, levels = c("1", "2"), labels = c("femenino", "masculino")),
    zona = factor(zona, levels = c("1", "2"), labels = c("urbano", "rural")),
    grado = factor(grado, levels = c("6", "7", "8", "9", "10", "11"), labels = c("sexto", "séptimo", "octavo", "noveno", "décimo", "once"))
  )

# Verificar los cambios
View(datos)

