# Exercise 3: Mapping with ggplot2

# Install and load `ggplot2` and `dplyr`
#install.packages('ggplot2')
#install.packages('dplyr')
library("ggplot2")
library("dplyr")

# Read in the election data file (.csv)
# BE SURE TO SET YOUR WORKING DIRECTORY!
election <- read.csv('data/2016_US_County_Level_Presidential_Results.csv', stringsAsFactors = FALSE)

# Inspect the `election` data frame to understand the data you're working with


# Consider: what column contains state names? What column contains county names?
# What format are those county names in?
election$state_abbr
election$county_name

# Use `map_data()` to load the `county` map of the US, storing it in a variable
# install.packages('maps')
library('maps')
county <- map_data('county')

# Inspect this data frame to understand what data yu're working with


# Consider: what column contains state names? What column contains county names?
# What format are those county names in?
county$region
# full name 


### Data Wrangling

# The format for the states and and counties are different, so we need some way to match them
# The `election` data does have FIPS codes (https://en.wikipedia.org/wiki/FIPS_county_code)
# which we can use to match. A data frame that links FIPS to the state and county names is
# available from the `maps` library (which you should install and load)

# Use `data()` to load the `"county.fips"` data frame into the environment (does not return anything)
data(county.fips)
county.fip <- as.data.frame(county.fips)

# Inspect the `county.fips` data frame to see what you got


# Use a `join` operation to add the `fips` column to your `counties` data frame.
# Note that you may need to use `paste0()` and `mutate() to make a column of "state,county"
# to join by!
# Note: don't worry about Alaska for this exercise.
county$combine <- paste0(county$region, ',', county$subregion)
a <- county %>% left_join(county.fip, by = c('combine' = 'polyname'))

# Now you can join the `counties` map data (with fips!) to the `election` data
# Hint: use `by = c("fips" = "combined_fips")` to specify the column to join by
election <- a %>% left_join(election, by = c("fips" = "combined_fips"))

# One more change: add a column to store whether the Democrat or the Republication party
# had the higher number of votes ("won" the county)
# Hint: start by adding a column of logical values (TRUE/FALSE) of whether a party one,
#       and then join that with a simple data frame that matches to Strings
election <- mutate(election, winner = votes_dem > votes_gop)
dem.won <- data.frame(winner = c(T,F), party = c("Democrat", "Republican"))
election <- left_join(election, dem.won, by = "winner")

### Data Visualization

# Finally, plot the polygons of the map!
# Be sure and specify the `x` (longitude), `y` (latitude), and `group` (group) asthetics
# Use the `coord_quick_map()` coordinate system to make it look nice
ggplot(data = election) + geom_polygon(aes(x = long, y =lat, group = group)) + coord_quickmap()

# Modify the above plot so that each geometry is filled based on which party won the county
# Specify a `manual` fill scale to make Democratic counties "blue" and Republican counties "red"
ggplot(election) + geom_polygon(aes(x = long, y = lat, group = group, fill = party)) + scale_fill_manual(values = c('blue', 'red')) + coord_quickmap()


# For fun: how else can you fill in this map? What other insights can you produce?
