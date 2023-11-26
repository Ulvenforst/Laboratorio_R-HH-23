# OSCAR DAVID CUAICAL LOPEZ
# Juan Camilo Narvaez 
# 202270657-3743
library(dplyr)


datos <- read.table("BD_huella.txt", header = TRUE, sep = "\t")

## Limpieza de datos -> cambiar genero
datos$genero <- tolower(datos$genero)
# Reemplazar los valores según las condiciones
datos$genero[datos$genero == "femenino"] <- 1
datos$genero[datos$genero == "masculino"] <- 2


## Limpieza de datos -> cambiar zona
datos$zona <- tolower(datos$zona)
# Reemplazar los valores según las condiciones
datos$zona[datos$zona == "urbano"] <- 1
datos$zona[datos$zona == "rural"] <- 2


## Limpieza de datos -> cambiar grado
datos$grado <- tolower(datos$grado)
# Reemplazar los valores según las condiciones
datos$grado[datos$grado == "sexto"] <- 6
datos$grado[datos$grado == "septimo"] <- 7
datos$grado[datos$grado == "octavo"] <- 8
datos$grado[datos$grado == "noveno"] <- 9
datos$grado[datos$grado == "decimo"] <- 10
datos$grado[datos$grado == "once"] <- 11


## Limpieza de datos -> cambiar N/A por media
media_HHD <- mean(datos$HHD, na.rm = TRUE)
datos$HHD[is.na(datos$HHD)] <- media_HHD
print(media_HDD)


## Limpieza de datos -> cambiar N/A por media
media_HHI <- mean(datos$HHI, na.rm = TRUE)
datos$HHI[is.na(datos$HHI)] <- media_HHI
print(media_HHI)

media_perhog <- mean(datos$per.hog, na.rm = TRUE)
print(media_perhog)

## Limpieza de datos -> cambiar a factores
datos$genero <- factor(datos$genero)
datos$zona <- factor(datos$zona)
datos$grado <- factor(datos$grado)
datos$comp_HHI <- factor(datos$comp_HHI)
datos$comp_HHD <- factor(datos$comp_HHD)


## Voy a aplicar un modelo de regresion lineal para HHI 
# 1.1 Entrenamiento y pruebas 
set.seed(123)
indice_entrenamiento <- sample(1:nrow(datos), 0.8*nrow(datos))

datos_entrenamiento <- datos[indice_entrenamiento, ]
datos_prueba <- datos[-indice_entrenamiento, ]

# 1.2 Cinstruir el modelo de regresion lineal 
modelo <- lm(HHI ~ ., data = datos_entrenamiento)
# 1.3 Predicciones en el conjunto de prueba
predicciones <- predict(modelo, newdata=datos_prueba)

# Revision del modelo 
resultados <- data.frame(Real = datos_prueba$HHI, Predicciones = predicciones)
print(resultados)

# 1.4 remplazar nulos 
columnas_categoricas <- c("comp_HHD")

datos_prueba[columnas_categoricas] <- lapply(columnas_categoricas, function(x) factor(datos_prueba[[x]], levels = levels(datos_entrenamiento[[x]])))

datos$HHI[is.na(datos$HHI)] <- predict(modelo, newdata = datos[is.na(datos$HHI), ])


## Limpieza de datos -> Cambiar Strings

#Columna comp_HDD
vals_comp_HHD <- c("uso.baño" = "baño",
                     "riego.jardin" = "jardin",
                     "uso.cocina" = "cocina",
                     "lavado.ropa" = "ropa")

datos <- datos %>%
  mutate(comp_HHD = tolower(comp_HHD)) %>%
  mutate(comp_HHD = gsub("_", ".", comp_HHD)) %>%
  mutate(comp_HHD = case_when(
    comp_HHD %in% names(vals_comp_HHD) ~ vals_comp_HHD[comp_HHD],
    TRUE ~ as.character(comp_HHD)
  ))


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











