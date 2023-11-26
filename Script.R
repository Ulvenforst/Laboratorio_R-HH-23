# -------------------------------------------------------------------------
# Laboratorio, Preprocesamiento de datos con R, Probabilidad y Estadística.
# Archivo: Informe_Huella.r
# Autores: Juan Camilo Narváez Tascón, 2140112-3743
#          Oscar David Cuaical, 2270657-3743
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
# 1. Librerias necesarias
library(dplyr)
library(editrules)

# Carga de datos
datos <- read.csv("Data/BD_Huella.txt", header = TRUE, sep = "\t")

# -------------------------------------------------------------------------
# 2. Reglas de validacion 
Rules <- editrules::editfile("Entregables/consistencia.txt")

# # Conexión entre las  reglas => Opcional (Grafica de relacion)

# windows()
# plot(Rules)

# Verificación de las reglas sobres los datos
editrules::violatedEdits(Rules, datos)
Valid_Data = editrules::violatedEdits(Rules, datos)
summary(Valid_Data)
# -------------------------------------------------------------------------
# 2.1 Aplicar reglas de validacion 

# Cambiar genero
datos$genero <- tolower(datos$genero)
datos$genero[datos$genero == "femenino"] <- 1
datos$genero[datos$genero == "masculino"] <- 2

# Cambiar zona
datos$zona <- tolower(datos$zona)
datos$zona[datos$zona == "urbano"] <- 1
datos$zona[datos$zona == "rural"] <- 2

# Cambiar grado
datos$grado <- tolower(datos$grado)
datos$grado[datos$grado == "sexto"] <- 6
datos$grado[datos$grado == "septimo"] <- 7
datos$grado[datos$grado == "octavo"] <- 8
datos$grado[datos$grado == "noveno"] <- 9
datos$grado[datos$grado == "decimo"] <- 10
datos$grado[datos$grado == "once"] <- 11

#Columna comp_HHD
datos$comp_HHD <- tolower(datos$comp_HHD)
datos$comp_HHD <- gsub("[._]", "_", datos$comp_HHD)
datos$comp_HHD <- gsub("uso_bano", "uso_baño", datos$comp_HHD)
datos$comp_HHD <- gsub("riego_jardin", "riego_jardin", datos$comp_HHD)
datos$comp_HHD <- gsub("uso_cocina", "uso_cocina", datos$comp_HHD)
datos$comp_HHD <- gsub("lavado_ropa", "lavado_ropa", datos$comp_HHD)

#Columna comp_HHI
vals_comp_HHI <- c("carne" = "carne",
                   "fruta" = "fruta",
                   "café" = "café")

datos <- datos %>%
  mutate(comp_HHI = tolower(comp_HHI)) %>%
  mutate(comp_HHI = case_when(
    comp_HHI %in% names(vals_comp_HHI) ~ vals_comp_HHI[comp_HHI],
    TRUE ~ as.character(comp_HHI)
  ))
# -------------------------------------------------------------------------
# 3. Completar registros faltantes NA

# 3.1 Columna HHD -> Completar mean 
datos$HHD <- as.numeric(datos$HHD)
media_HHD <- mean(datos$HHD, na.rm = TRUE)
datos$HHD <- ifelse(is.na(datos$HHD), media_HHD, datos$HHD)
datos$HHD <- ifelse(datos$HHD %% 1 == 0, formatC(datos$HHD, 
             format = "d", digits = 0), formatC(datos$HHD, 
             format = "f", digits = 2))

# 3.2 Columna HHI -> Completar con mean
datos$HHI <- as.numeric(datos$HHI)
media_HHI <- mean(datos$HHI, na.rm = TRUE)
datos$HHI <- ifelse(is.na(datos$HHI), media_HHI, datos$HHI)
datos$HHI <- ifelse(datos$HHI %% 1 == 0, formatC(datos$HHI, 
             format = "d", digits = 0), formatC(datos$HHI, 
             format = "f", digits = 2))

# 3.3 Columna per.hog -> Completar mean
datos$per.hog <- as.numeric(datos$per.hog)
media_per.hog <- mean(datos$per.hog, na.rm = TRUE)
datos$per.hog <- ifelse(is.na(datos$per.hog), media_per.hog, datos$per.hog)
datos$per.hog <- ifelse(datos$per.hog %% 1 == 0, formatC(datos$per.hog, 
             format = "d", digits = 0), formatC(datos$per.hog, 
             format = "f", digits = 2))

# -------------------------------------------------------------------------
# 4. Diagnostico de datos atipicos 











