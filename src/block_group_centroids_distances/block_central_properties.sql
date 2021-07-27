
-- Create Block Group Centroids
select "GEOID" AS geoid_bg, 
       st_centroid(geometry)::geometry AS centroid_geom, 
       st_x(st_centroid(geometry))::numeric AS centroid_lon, 
       st_y(st_centroid(geometry))::numeric AS centroid_lat
  into data_commons.virginia_block_group_centroids
  from gis_census_cb.cb_2018_51_bg_500k
  
-- Get properties closest to Block Group Centroids
EXPLAIN SELECT 
       bg.geoid_bg,
       bg.centroid_lon AS bg_lon,
       bg.centroid_lat AS bg_lat,
       ST_SetSRID(ST_MakePoint(bg.centroid_lon::NUMERIC, bg.centroid_lat::NUMERIC), 4326)::geometry as bg_pt_geom,
       ST_X(props.geometry::geometry) AS closest_property_lon,
       ST_Y(props.geometry::geometry) AS closest_property_lat,
       props.geometry::geometry AS closest_property_geom,
       props.p_id_iris_frmtd AS closest_property_iris_id,
       ST_Distance(props.geometry::geometry, ST_SetSRID(ST_MakePoint(bg.centroid_lon::NUMERIC, bg.centroid_lat::NUMERIC), 4326)::geometry) AS dist
INTO data_commons.virginia_block_group_centroids_closest_property
FROM data_commons.virginia_block_group_centroids bg
CROSS JOIN LATERAL (
  SELECT p_id_iris_frmtd, geometry
  FROM corelogic_usda.current_tax_200627_latest_all_add_vars_add_progs_geom_blk prop
  ORDER BY ST_SetSRID(ST_MakePoint(bg.centroid_lon::NUMERIC, bg.centroid_lat::NUMERIC), 4326)::geometry <-> prop.geometry
  LIMIT 1
) props;
  
-- Add Block Group Population
SELECT a.geoid_bg, b."GEOID" AS block_geom, a.centroid_lon AS bg_ctr_lon, a.centroid_lat AS bg_ctr_lat, a.bg_pt_geom AS bg_ctr_geom, 
  closest_property_lon, closest_property_lat, closest_property_geom, closest_property_iris_id, b."POP10" AS block_population_10
INTO data_commons.virginia_block_group_centroids_closest_property_pop
FROM data_commons.virginia_block_group_centroids_closest_property a
LEFT JOIN gis_census_cb.cb_2018_51_bg_500k b
  ON a.block_geoid = b."BLOCKID10";
