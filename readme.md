# Laboratorio R - Preprocesamiento de datos con R
> (Estructura de Datos, Consistencia, Limpieza, Datos atípicos, Datos faltantes, Visualización)

La huella hídrica (HH) es un indicador multidimensional que mide el consumo directo e indirecto de agua que una persona,
organización, comunidad o país realiza en un área determinada en un tiempo específico, lo que puede ser útil para la toma
de decisiones a futuro. Con el objetivo de caracterizar la huella hídrica de una institución de educación secundaria, se
pone a su disposición la base de datos BD_huella.txt, la cual contiene información de los estudiantes como: edad, genero,
zona, grado escolar, cantidad de HH directa e indirecta en m3/año (HHD y HHI), el mayor componente de la HH directa e indirecta
(comp_HHD y comp_HHI), y el número de personas que habitan en el hogar (per.hog).

Las variables cualitativas deben seguir la siguiente codificación:
| Atributo | Valor |
| ----------- | ----------- |
| genero | 1=femenino; 2=masculino |
| zona | 1=urbano; 2=rural |
| grado |6=sexto; 7=séptimo; 8=octavo, 9=noveno, 10=decimo, 11=once |

A usted se le solicita realizar un análisis exploratorio de datos. En ese sentido, se requiere que usted diseñe 
una visualización contundente datos, a través de tableros gráficos resumen, en la cual se evidencie la 
diferencia entre género, para la huella hídrica (directa, indirecta), además de posibles diferencias debidas a la 
zona y grado escolar. Adicionalmente se requiere visualizar, de forma sintética, la estructura de correlación 
entre las variables huella hídrica total y la edad.

## El preprocesamiento y limpieza de los datos. (`limpieza`)
En una inspección rápida de la hoja de datos, usted podrá notar la presencia de algunos registros 
inconsistentes, datos faltantes y datos atípicos. Para evitar sesgos sobre los resultados y pérdida de registros, 
es necesario que usted, previo a realizar cualquier análisis, realice una actividad de limpieza de datos utilizando 
herramientas de software (R).
Para realizar el ejercicio en R, usted debe seguir el siguiente libreto de limpieza y
preprocesamiento:
1. Lea la hoja de datos y adecúe el formato de cada variable, verificando que dispone de una hoja de 
datos técnicamente correcta.
2. Construya el archivo: *consistencia.txt*, en el cual incluya las ecuaciones que usted considera 
necesarias para verificar la consistencia de los datos en el conjunto de variables.
3. Aplique estas reglas sobre la hoja de datos y genere un pequeño reporte de sus resultados.
4. Visualice e identifique los registros que presentan datos faltantes.
5. Sobre el conjunto de variables cuantitativas, realice un diagnóstico de datos atípicos.
6. Con los resultados de los puntos anteriores, usted dispone del listado con registros inconsistentes y 
con datos faltantes. Es necesario corregirlo.
7. Genere un resumen de los cambios realizados en la hoja de datos. *ReporteCambios.txt*
Perfecto, ahora usted tiene una hoja de datos limpia, guárdela en un archivo nuevo *clean_huella.txt*.
### Cree las siguientes variables:
Genere una nueva variable denominada huella hídrica total (HHT), que equivale a la suma entre 
HHD y HHI.
Sobre la nueva variable calculada (HHT), clasifíquela (HHT_clas) en 3 grupos que cumplan 
con las siguientes condiciones:
| Grupo | Rango de clasificación |
|-------|------------------------|
| Bajo  | si HHT ≤ 1789          |
| Medio | si 1789 < HHT ≤ 1887   |
| Alto  | si HHT > 1887          |

## Visualización de datos (`visualización`)
Utilice su pericia en el procesamiento de datos para resumir los datos en uno o pocos tableros gráficos.
1. Presente en una sola ventana gráfica las distribuciones de:
    - Clasificación de la huella hídrica total, 
    - Componente de la huella hídrica directa,
    - Componente de la huella hídrica indirecta.
3. Presente en una sola ventana grafica el comportamiento de los puntajes de la huella hídrica directa e 
indirecta por cada uno de los factores de estudio (sexo, grado escolar y zona).
4. Presente un resumen de los principales indicadores descriptivos de las variables cuantitativas 
por cada uno de los factores (sexo, grado escolar y zona).

> Nota 1: Por favor sea muy cuidadoso con la gestión de los gráficos. Ubique nombres adecuados para 
los ejes, leyendas y títulos. Sea consistente con el manejo de los colores e intente que su representación 
sea lo más contundente posible, que hable por si sola.

> Nota 2: El informe debe ser presentado en Rmarkdown.

**Recomendaciones: Sea cuidadoso en la construcción de cada uno de los gráficos, evalué sus 
conclusiones e interpretaciones.**

*"Tome cada ejercicio práctico como una oportunidad de aprendizaje y de entrenamiento para lo que muy seguramente 
será su diario vivir en su ejercicio profesional”*

## Entregables
Como entregable del presente laboratorio, usted debe ubicar en el campus virtual dos archivos comprimidos (o 
enlaces web que dirijan a los archivos comprimidos, cuando el archivo supere el tamaño máximo de carga el 
campus virtual) que contenga los siguientes elementos:

1. Solución_R.zip: contiene los soportes de la solución del laboratorio en R
    a. El archivo *consistencia.txt*
    b. El archivo *ReporteCambios.txt*
    c. La nueva hoja de datos *clean_huella.csv*
    d. El script R, *Script_R.txt*, editado adecuadamente con una división desplegable asociada a cada uno de los puntos desarrollados (Puntos 1 a 6) 
2. *Informe_Huella.pdf*: Contiene el informe escrito, donde evidencia el desarrollo de los puntos del laboratorio. En este deben estar los tableros gráficos y sus respectivas interpretaciones

## Condiciones de entrega.
1. Trabajo en equipo - El laboratorio debe ser desarrollado en grupos de 3 personas. (No se recibirán
trabajos de forma individual).
2. Forma y tiempo de Entrega – Entrega en el campus virtual. La asignación estará disponible para la carga 
de los entregables hasta el viernes 1 de diciembre – 11:59 pm
