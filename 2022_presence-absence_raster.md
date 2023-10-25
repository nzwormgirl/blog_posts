---
title: "Creating a presence-absence raster from a shapefile"
author: "Amy Whitehead"
date: "19/04/2022"
output: html_document
---



Bakc in 2013 I published a post with a little function for [creating presence-absence rasters from point data](https://amywhiteheadresearch.wordpress.com/2013/05/27/creating-a-presence-absence-raster-from-point-data/). I was in the midst of creating ~1000 species distribution models for Australian species and I needed something that I could easily automate in R.

Both R and my approach to working with spatial data have changed a lot in the last nine years, particularly with excellent new packages such as [`sf`](https://r-spatial.github.io/sf/) and [`fasterize`](https://cran.r-project.org/web/packages/fasterize/vignettes/using-fasterize.html).  This post is a brief update to a new option for creating presence-absence rasters, prompted by a reader's question.

The steps are essentially the same but I've adopted some new packages (`sf` and `fasterize`) that make life easier.   
1. Create an sf point data set from a dataframe of point locations using `st_as_sf`.  
2. Convert the points to polygons using `st_buffer`. This step is necessary as `fasterize` currently doesn't work with points. For this simple example, I've elected to leave my points in WGS84, which means I get a warning that st_buffer doesn't work properly with lat/long data. I could have used `st_transform` to convert it to a different projection before using `st_buffer`.  
3. Convert the polygons to raster using `fasterize` and then `mask` out the ocean.  


```r
require(biomod2)
require(dplyr)
require(raster)
require(fasterize)
require(sf)

select <- dplyr::select
 
# read in a raster of the world
world <- raster(system.file( "external/bioclim/current/bio3.grd",package="biomod2"))

# read in species point data and extract data for foxes
mammals <- read.csv(system.file("external/species/mammals_table.csv", package="biomod2"), 
                    row.names = 1) 

head(mammals)
```

```
  X_WGS84  Y_WGS84 ConnochaetesGnou GuloGulo PantheraOnca PteropusGiganteus TenrecEcaudatus VulpesVulpes
1   -94.5 82.00001                0        0            0                 0               0            0
2   -91.5 82.00001                0        1            0                 0               0            0
3   -88.5 82.00001                0        1            0                 0               0            0
4   -85.5 82.00001                0        1            0                 0               0            0
5   -82.5 82.00001                0        1            0                 0               0            0
6   -79.5 82.00001                0        1            0                 0               0            0
```

```r
# extract fox data from larger dataset and keep only the x and y coordinates
fox_data <- mammals %>% 
  # keep only the spatial data and foxes
  select(X_WGS84,Y_WGS84,VulpesVulpes) %>% 
  # keep only the presence points for foxes
  filter(VulpesVulpes %in% 1) %>% 
  # convert to an sf points object projected in WGS84
  st_as_sf(coords=c("X_WGS84","Y_WGS84"),
           crs = 4326) %>% 
  # convert to an sf polygon object by buffering the points
  st_buffer(1) 
```

```
Warning in st_buffer.sfc(st_geometry(x), dist, nQuadSegs, endCapStyle = endCapStyle, : st_buffer does not
correctly buffer longitude/latitude data
```

```r
head(fox_data)
```

```
Simple feature collection with 6 features and 1 field
Geometry type: POLYGON
Dimension:     XY
Bounding box:  xmin: -95.5 ymin: 72.00001 xmax: -75.5 ymax: 74.00001
Geodetic CRS:  WGS 84
  VulpesVulpes                       geometry
1            1 POLYGON ((-93.5 73.00001, -...
2            1 POLYGON ((-87.5 73.00001, -...
3            1 POLYGON ((-84.5 73.00001, -...
4            1 POLYGON ((-81.5 73.00001, -...
5            1 POLYGON ((-78.5 73.00001, -...
6            1 POLYGON ((-75.5 73.00001, -...
```



