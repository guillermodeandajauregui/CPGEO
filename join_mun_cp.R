# este script hace los joins de interseccion entre un shp de CP y uno de municipios
# el ejemplo es para municipios y CPs de CDMX y EDOMEX
# se puede modificar para otras escalas geograficas

library(tidyverse)
library(sf)

#leemos shp de municipios
shp_mun <- read_sf("conjunto_de_datos/00mun.shp") #del marco geoestadistico INEGI 
shp_mun <- shp_mun %>% filter(CVE_ENT%in%c("09", "15")) %>% st_transform(crs = "WGS84") #aca filtramos y ponemos en crs WGS84 para homologar

#leemos shp de codigos postales
shp_cp.09 <- read_sf("CP_09CDMX_v7.shp") %>% st_transform(crs = "WGS84") #de SEPOMEX 
shp_cp.15 <- read_sf("CP_15Mex_v7.shp") %>% st_transform(crs = "WGS84") #de SEPOMEX 

shp_cp <- bind_rows(shp_cp.09, shp_cp.15) 
#algunos poligonos pueden no ser validos, los quitamos
shp_cp <- shp_cp %>% mutate(valid = st_is_valid(shp_cp)) %>% filter(valid)


#vamos a simplificar los poligonos 
x1 <- shp_cp %>%  st_simplify(dTolerance = 10)
x2 <- shp_mun %>%  st_simplify(dTolerance = 10)

#y aqui hacemos el join 
x <- st_join(x = x1, y = x2, join = st_intersects, largest = T)

# y luego escribimos un diccionario, si asi preferimos

x %>% 
  as_tibble() %>% 
  select(-geometry) %>% 
  vroom::vroom_write("dict_cp_mun_cdmx_y_edomex.txt.txt")
