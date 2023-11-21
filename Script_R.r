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