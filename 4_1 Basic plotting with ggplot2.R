#4.1 Basic plotting with ggplot2
install.packages("titanic"); library("titanic")
data("titanic_train", package = "titanic")
titanic <- titanic_train
install.packages("faraway"); library(faraway); data("worldcup")
library(dplyr)
library(ggplot2)
#The basic steps behind creating a plot with ggplot2 are:
#Create an object of the ggplot class, typically specifying the data and some or all of the aesthetics;
#Add on geoms and other elements to create and customize the plot, using +.

4.1.1 Initializing a ggplot object
## Generic code - the first argument to ggplot must be a **dataframe** 
object <- ggplot(dataframe, aes(x = column_1, y = column_2))
## or, if you don't need to save the object
ggplot(dataframe, aes(x = column_1, y = column_2))

4.1.2 Plot aesthetics
#aesthetic options
#shape / color(border) / fill(inside) / size / alpha / linetype(solid, dashed)

4.1.3 Creating a basic ggplot plot
#To avoid errors, be sure to end lines with +, don’t start lines with it.
titanic %>% ggplot(aes(x=Fare))+ geom_histogram()
titanic %>% ggplot()+ geom_histogram(aes(x=Fare))
ggplot(titanic, aes(x=Fare))+ geom_histogram()
ggplot(titanic)+ geom_histogram(aes(x=Fare)) #specify aesthetics within an aes() call 
ggplot()+ geom_histogram(titanic, aes(x=Fare))
#color, size, shape, or position: you remember to make that specification within aes().
#if you specify a dataframe within a geom, be sure to use data = syntax, as data is not the first parameter expected for geom functions.
#To save a plot using code in a script, take the following steps: (1) open a graphics device (e.g., using the function pdf or png); (2) run the code to draw the map; and (3) close the graphics device using the dev.off function. Note that the function you use to open a graphics device will depend on the type of device you want to open, but you close all devices with the same function (dev.off).

4.1.4 Geoms
#if you do not include at least one geom, you’ll get a blank plot space.
#geom_histogram(): one continuous variable 
#bins argument to change the number of bins used to create the histogram
titanic %>% ggplot(aes(x=Fare))+ geom_histogram(bins=15)

#geom_plot(): sactterplot, TWO continuous variables
worldcup %>% 
  ggplot(aes(x=Time, y=Passes))+ geom_point()
worldcup %>% 
  ggplot(aes(x=Time, y=Passes, color=Position, size=Shots))+ 
  geom_point(alpha=0.5)

<Table 4.1: MVPs of geom functions>
  #geom_point(): x,y
  #geom_line(): x,y (x변수 순서대로 sorting 후 연결) / arrow, na.rm
  #geom_segment(): x,y,xend,yend / arrow, na.rm
  #geom_path(): x,y (원자료 순서대로) / na.rm
  #geom_polygon(): x,y
  #geom_histogram(): x / bins, binwidth
  #geom_abline(): intercept, slope
  #geom_hline(): yintercept
  #geom_vline(): xintercept
  #geom_smooth(): x,y / method, se=TRUE가 디폴트, span
  #geom_text(): x,y,label / parse, nudge_x, nudge_y

4.1.5 Using multiple geoms

noteworthy_player <- worldcup %>% 
  filter(Shots==max(Shots) | Passes==max(Passes)) %>%
  mutate(point_label = paste(Team, Position, sep=","))
worldcup %>% ggplot(aes(x=Passes, y= Shots))+
  geom_point()+
  geom_text(data=noteworthy_player, aes(label=point_label), #using data from different dataframes for different geoms, aes(label=)
            vjust= "inward", hjust="inward") #plot밖으로 나가지 않게 vjust/hjust "inward"옵션 
#table(worldcup$Time)
names(worldcup)
head(worldcup)
#?worldcup- Time: Time played in minutes
#Soccer games last 90 minutes each, and different teams play a different number of games at the World Cup, based on how well they do. To check if horizontal clustering is at 90-minute intervals, you can plot a histogram of player time (Time), with reference lines every 90 minutes. 
worldcup %>% ggplot(aes(x=Time))+ 
  geom_histogram(binwidth=10)+
  geom_vline(xintercept = 90*0:6, colour="blue", alpha=0.5)
#Based on this graph, player’s times do cluster at 90-minute marks, especially at 270 minutes, which would be approximately after three games, the number played by all teams that fail to make it out of the group stage.

4.1.6 Constant aesthetics
#Instead of mapping an aesthetic to an element of your data, you can use a constant value for it.
worldcup %>% ggplot(aes(x=Time, y=Passes))+
  geom_point(colour="darkgreen") #color,fill,shape

4.1.7 Other useful plot additions
#ggtitle: plot title
#xlab, ylab: x-,y-axis label
#xlim, ylim: limits of x-,y-axis

4.1.8 Example plots
data("nepali") #dataframe ""
#?nepali- a subset from public health study on Nepalese children.
names(nepali) #among these variables, select id, sex, weight, height, and age
nepali1 <- nepali %>%
  select(id, sex, wt, ht, age) %>%
  mutate(id=factor(id), 
         sex=factor(sex, levels=c(1,2), 
                    labels=c("Male", "Female")))
head(nepali1)
#데이터 정제시 원자료 이름과 다르게 할 것 
#차이는 distinct()
nepali <- nepali %>%
  select(id, sex, wt, ht, age) %>%
  mutate(id=factor(id), 
         sex=factor(sex, levels=c(1,2), 
                    labels=c("Male", "Female")))%>% 
  distinct(id, .keep_all=TRUE)
head(nepali)
#?distinct: Retain only unique/distinct rows from an input tbl
#factor(var, levels=c()기존의 데이터형태, labels = c()변경)

4.1.8.1 Histograms
nepali %>% ggplot(aes(x=ht))+ geom_histogram()
nepali %>% ggplot(aes(x=ht))+ 
  geom_histogram(fill="lightblue", colour="black")+
  ggtitle("Height of children")+
  xlab("Height(cm)") + xlim(c(0,120))

4.1.8.2 Scatterplots
nepali %>% ggplot(aes(x=ht, y=wt))+ geom_point()
nepali %>% ggplot(aes(x=ht, y=wt))+ 
  geom_point(colour="blue", size=0.5)+
  ggtitle("Weight versus Height")+ #ggtitle
  xlab("Height (cm)")+ ylab("Weight (kg)")
#to use color to show the sex of each child 

nepali %>% ggplot(aes(x=ht, y=wt))+ 
  geom_point(aes(colour=sex), size=0.5)+
  ggtitle("Weight versus Height")+ #ggtitle
  xlab("Height (cm)")+ ylab("Weight (kg)")
nepali %>% ggplot(aes(x=ht, y=wt, colour=sex))+ 
  geom_point(size=0.5)+
  ggtitle("Weight versus Height")+ 
  xlab("Height (cm)")+ ylab("Weight (kg)")

4.1.8.3 Boxplots
#Boxplots are one way to show the distribution of a continuous variable. 
#for a single, continuous variable - y in the aes call and map x to the constant 1
nepali %>% ggplot(aes(x=1, y=ht))+
  geom_boxplot()+
  xlab("")+ ylab("Height (cm)")
#separate boxplots based on the sex
nepali %>% ggplot(aes(x=sex, y=ht))+
  geom_boxplot()+
  xlab("Sex")+ ylab("Height (cm)")

4.1.9 Extensions of ggplot2
#ggpairs function from the GGally package to plot all pairs of scatterplots for several variables
#install.packages("GGally")
library(GGally)
#?ggpairs-Make a matrix of plots with a given data set
ggpairs(nepali %>% select(sex,wt,ht,age))
nepali %>% select(sex,wt,ht,age) %>%
  ggpairs()
#Notice how this output shows continuous and binary variables differently. For example, the center diagonal shows density plots for continuous variables, but a bar chart for the categorical variable.
