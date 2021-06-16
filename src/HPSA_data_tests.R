library(sf)

cmpt_areas <- st_read("data/HPSA_CMPPC_SHP/HPSA_CMPPC_SHP_DET_CUR_VX.shp")

cmpt_areas_va_ct <- cmpt_areas[cmpt_areas$StAbbr == "VA" & cmpt_areas$CmpTypCD == "CT",]
