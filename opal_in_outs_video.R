#load in packages
pkgs <- c("readr","tidyr","dplyr","ggplot2","rgdal", "rgeos", "maptools","tmap","ggmap","animation")
lapply(pkgs,library, character.only = TRUE)

#read in data
df <- read.csv("data/time-loc_20160808-14.csv")

#get stations only
rail <- as_data_frame(df) %>% filter(grepl("Station$",loc))

#prep for geocoding station locations
stationLatLon <- data_frame(loc = as.character(factor(unique(rail$loc)))) %>% 
  mutate(loc_long = paste0(loc,",NSW,Australia")) # just adding in more details to make the geocoding faster

#do the geocoding if it hasn't been done already. Otherwise read in the data form file
if(file.exists("data/station_latLons.csv")){
  latLon <- read_csv("data/station_latLons.csv")
} else{
  latLon <- geocode(stationLatLon$loc_long, output = "latlon" , source = "google")
  #write the lat long data to file
  write_csv(latLon,"data/station_latLons.csv")
}

#geocoded data set
stationLatLon <- stationLatLon %>% bind_cols(latLon) %>% select(-loc_long)

#add the lat lons to the data
rail_latLon <- rail %>% left_join(stationLatLon)
rail_latLon

# #[TO DO] make a nicer basemap using layers from open streetmaps
# #get the mapping data for Sydney
# polygons <- readOGR("data/sydney_australia.osm2pgsql-shapefiles",layer = "sydney_australia_osm_polygon")
# str(polygons@data)
# 
# #water polygons
# water <- polygons[!is.na(polygons$water)|!is.na(polygons$wetland)|!is.na(polygons$waterway)|!is.na(polygons$place),]
# #plot(water)
# 
# water.f <- fortify(water)
# ggplot(water.f)+geom_polygon(aes(x=long, y=lat, group=group,fill = water))
# str(water@data)
# 
# tm_shape(water)+
#   tm_fill("boundary")

#get data for one day to plot
plot_df <- rail_latLon %>% 
  group_by(date,time,loc,lat,lon) %>% 
  spread(tap,count) %>% 
  summarise(
    total_movements = on + off,
    perc_entering = on / total_movements
  ) %>% 
  ungroup() %>% 
  complete(date,time,nesting(loc,lat,lon),fill = list(total_movements = 0, perc_entering = 0.5)) %>% 
  filter(date == 20160809,time != "",time != -1) %>% 
  arrange(time,total_movements)


#make the temp base map
#download sydney map tiles
sydMap <- get_map(location = "Sydney,NSW,Australia", maptype = "toner")

#start building the plot
#get the base map
baseMap <- ggmap(sydMap, extent = "device",darken = 0.55)

#go through each time step and print the graphic
for(i in 1:length(unique(plot_df$time))){
  #get the time
  t <- unique(plot_df$time)[i]
  
  #get the sub set for plotting - time for only one 15 min window
  time_data <- plot_df %>% filter(time == t )
  
  #get the in and out data
  ins <- sum(time_data$total_movements*time_data$perc_entering)
  outs <- sum(time_data$total_movements*(1-time_data$perc_entering))
  
  map = baseMap + 
    geom_point(data = time_data, aes(x=lon,y=lat, size = total_movements, color = perc_entering),alpha = 0.8)+
    scale_size_continuous(range = c(2,10),limits = c(0,8000))+
    scale_color_gradient2(low = "#FE4A49", mid = "white", high = "#4CB944",midpoint = 0.5)+
    theme(legend.position = "none",
          plot.title = element_text(color ="white", vjust = 0.5,hjust = 0.5, size = 20),
          plot.subtitle = element_text(color ="white", vjust = 0.5,hjust = 0.5, size = 10),
          plot.background = element_rect(fill = "black",colour = "black")
    )+
    annotate(geom = "text", x = baseMap$data[2,1]-0.04,y = baseMap$data[2,2], 
             label = paste("Ins:",ins) ,col = "#4CB944", size = 6, hjust = "inward",vjust = -2.5)+
    annotate(geom = "text", x = baseMap$data[2,1]-0.04,y = baseMap$data[2,2],
             label = paste("Outs:",outs),col = "#FE4A49", size = 6, hjust = "inward",vjust = -1)+
    annotate(geom = "text", x = baseMap$data[2,1]-0.04,y = mean(baseMap$data[,2]),
             label = paste(t),col = "white", size = 10, hjust = "inward",vjust = 0)+
    labs(title = "Opal Tap On/Off | Train Stations",
         subtitle = "Data: Opal Tap On and Tap Off cc-by-TfNSW | Graphic: Rafid Morshedi")
  
  #save the PNG files to disk
  png(sprintf("./frames/frame_%03d.png", i), width=639.5*2, height=544*2, res=144, bg="black")
    #print the map
    print(map)
    #poor mans progress bar
    print(paste("Printing",i,"of",length(unique(plot_df$time))))
  dev.off()
  
}