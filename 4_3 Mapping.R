library(ggplot2);
install.packages("maps");library(maps)
library(dplyr); library(viridis)
4.3 Mapping
"""
The simplest techniques involve using data that includes latitude and longitude values and using these location values as the x and y aesthetics in a regular plot. 
R also has the ability to work with more complex spatial data objects and import shapefiles through extensions like the sp package.
R also has the capability to make interactive maps using the plotly and leaflet packages.
plus, htmlWidgets 
"""

4.3.1 Basics of mapping
4.3.1.1 Creating maps with ggplot2
"""
ggplot package내 map_data function
pull data for maps at different levels (“usa”, “state”, “world”, “county”). 
The data you pull give locations of the borders of geographic polygons like states and counties.
"""
us_map<- map_data("state")#get the polygon location data for US states
head(us_map) #longitude, latitude, "group", order, region
#the order in which these points should be connected to form a polygon (order), the name of the state (region)
#a group column that separates the points into unique polygons that should be plotted
us_map %>% filter(region %in% c("north carolina", "south carolina")) %>%
  ggplot(aes(x=long,y=lat))+
  geom_point()
us_map %>% filter(region %in% c("north carolina", "south carolina")) %>%
  ggplot(aes(x=long,y=lat))+
  geom_path()
"""
If you create a path for all the points in the map, 
without separating polygons for different geographic groupings (like states or islands), 
the path will be drawn without picking up the pen between one state’s polygon and the next state’s polygon, 
resulting in unwanted connecting lines.
-> Mapping a group aesthetic
-> No two states share a group, and some states have more than one group
"""
us_map %>% filter(region %in% c("north carolina", "south carolina")) %>%
  ggplot(aes(x=long, y=lat, group=group))+
  geom_path()
#path instead of line:This is because the line geom connects points by their order on the x-axis. 
#If you would like to set the colour inside geographical area -> polygon
us_map %>% 
  filter(region %in% c("north carolina", "south carolina")) %>%
  ggplot(aes(x=long, y=lat, group=group))+
  geom_polygon(fill="lightblue", colour="black")

#To get rid of the x- and y-axes and the background grid
#theme_void()
us_map %>%
  filter(region %in% c("north carolina", "south carolina"))%>%
  ggplot(aes(x=long, y=lat, group=group))+
  geom_polygon(fill="lightblue", colour="black")+
  theme_void()

#to map the full continental U.S
#just remove the line of the pipe chain for filtering
us_map %>% ggplot(aes(x=long, y=lat, group=group))+
  geom_polygon(fill="lightblue", colour="black")+
  theme_void()

#choropleth map 등치 지역도
#votes.repub dataset from maps pckgs
data(votes.repub); head(votes.repub) #matrix
head(us_map)
"""
To tidy the data,
- tbl_df() from dplyr: create a data frame tbl
-> use as_tibble() instead
- tolower(): Translate characters in character vectors, in particular from upper to lower case or vice versa.
- The viridis scales provide color maps that are perceptually uniform in both color and black-and-white.
- rownames(): Retrieve or set the row or column names of a matrix-like object.
"""
votes.repub %>%
  tbl_df() %>%
  mutate(state = rownames(votes.repub),
         state = tolower(state)) %>%
  right_join(us_map, by=c("state"="region")) 
"""
- mutate : to move these into a column of the dataframe 
-> The names are then converted to lowercase 

-right_join() from dplyr : join two tbls together
so only non-missing values from the us_map geographic data will be kept.
state from votes.repub - region from us_map
by: default- using all variables with common names across the two tables
To join by different variables on x and y use a named vector
by = c("a" = "b") will match x.a to y.b.
"""

votes.repub %>%
  tbl_df() %>%
  mutate(state = rownames(votes.repub),
         state = tolower(state)) %>%
  right_join(us_map, by=c("state"="region")) %>%
  ggplot(aes(x=long, y=lat, group=group, fill=`1976`))+
  geom_polygon(colour="black")+
  theme_void()+
  scale_fill_viridis(name="Republican\nvotes (%)")

#If you have data with point locations
#you can add those points to the map - geom_point()

library(readr)
serial <- read_csv(paste0("http://raw.githubusercontent.com/",
                          "dgrtwo/serial-ggvis/master/input_data/",
                          "serial_podcast_data/serial_map_data.csv"))
head(serial,3)

"""
to convert the x and y coordinates 
to latitude and longitude coordinates, and the following code cleans up the data using that algorithm. 
The murder occurred when cell phones were just becoming popular, 
and cell phone data was used in the case. 
The code also adds a column for whether of not the location is a cell tower.
"""

serial <- serial %>% 
  mutate(long = -76.8854 + 0.00017022*x, 
         lat = 39.23822 + 1.371014e-04 *y,
         tower = Type =="cell-site")
