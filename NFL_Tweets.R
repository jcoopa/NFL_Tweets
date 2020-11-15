#resources
#https://stackoverflow.com/questions/49996547/r-using-a-loop-on-a-list-of-twitter-handles-to-extract-tweets-and-create-multi
#https://developer.twitter.com/en/dashboard


##PREPARATION
#install.packages("rtweet")
#install.packages("dplyr")
#install.packages("ROAuth")
#rTweet package credentials and set up. 
library(rtweet)
library(dplyr)
library(ROAuth)


#store api keys (these are fake example values; replace with your own keys)
#Get your own API Keys and Tokens for free at https://developer.twitter.com
api_key <- "AeFYioyI9p" #example only
api_secret_key <- "OiNP1FTUSsqmFiiy"#example only
access_token <- "1267130388493"#example only
access_token_secret <- "RnbiAajDCd4"#example only

#authenticate via web browser
setup_twitter_oauth <- create_token(
  app = "rtweet_api",
  consumer_key = api_key,
  consumer_secret = api_secret_key,
  access_token = access_token,
  access_secret = access_token_secret)

#list of all NFL teams. for a more robust return, one could also collect all team locations for example Teams2 <- c(#Washing, #Detroit, #Philadelphia etc.)
Teams <-  c("#Rams",
            "#Chargers",
            "#Packers",
            "#Buccaneers",
            "#Bears",
            "#Bengals",
            "#Bills",
            "#Broncos", 
            "#Browns",
            "#Cardinals", 
            "#Colts",
            "#Cowboys", 
            "#Dolphins", 
            "#Eagles",
            "#Patriots", 
            "#Falcons",
            "#49ers",
            "#Jaguars",
            "#Lions", 
            "#Saints",
            "#Panthers",
            "#Ravens",
            "#Seahawks",
            "#Steelers",
            "#Texans",
            "#Titans",
            "#Raiders",
            "#Vikings",
            "#Giants",
            "#Jets", 
            "#Washington", 
            "#Chiefs")

#We will gather tweets created yesterday and before today started (GMT time zone)
yesterday <- format(Sys.Date()-1,"%Y-%m-%d")
today <- format(Sys.Date(),"%Y-%m-%d")

#loading the .RData file serves two purposes
#I Ran this query everyday during the 2020-21 NFL season. So "load" pulls in my tweets from previous days.
#The first time this is ran, you will need to create an empty .RData file named "NFL2020_tweets" otherwise you will get an error because 
#we will have no where to store all the tweets as rtweet retreives tweets for each team. 
#the easiest way to create a empty RData file with the right headings is to pull a couple tweets and delete them. here is some example code: 
DummyTABLE<-search_tweets(
  "Peace", #could have used a team word, but in the off season it might return null
  n = 100,
  type = "mixed", #most popular tweets
  include_rts = FALSE,
  geocode = NULL,
  max_id = NULL,
  parse = TRUE,
  token = setup_twitter_oauth,
  retryonratelimit = TRUE,
  verbose = TRUE,
  since = yesterday,
  until = today)

NFL2020_tweets <- head(DummyTABLE, 0)
save(NFL2020_tweets, file="NFL2020_tweets.RData")

#Load the data frame we just created, this is where the tweets will be agrregated
load(file="NFL2020_tweets.RData")

#collect tweets in a loop using the "Teams" we created earlier. 
for(i in 1:length(Teams)){
  result<-search_tweets(
    Teams[i],
    #n is the number of tweets to collect per team
    n = 1100,
    #Alternativly to "mixed" one could use "pop" (for popular) but in my experience only a handful (0-40) tweets can be returned using this method. 
    #I stick with "mixed"
    type = "mixed",
    include_rts = FALSE,
    geocode = NULL,
    max_id = NULL,
    parse = TRUE,
    token = setup_twitter_oauth,
    #This is important, Twitter limits queries to 1800 per 15 minute window. "retryonratelimit = TRUE" means that if i reach the limit of tweets, 
    #rtweets will pause for 15 minutes repeatededly untill i have gotten my desired tweets or all matching tweets are returned from twitter
    retryonratelimit = TRUE,
    verbose = TRUE,
    #set time frame (7 day window. check out Twitter's Premium API if you need to go back further than 7 days)
    since = yesterday,
    until = today)
  result$key <- Teams[i]
  Tweets_rtweet_DF <- result
  #sort tweets by count of favorites
  Tweets_rtweet_DF <- Tweets_rtweet_DF[order(Tweets_rtweet_DF$favorite_count, na.last = TRUE, decreasing = TRUE),]
  #1100 hundred tweets where collected, but i only want tweets with a lot of likes, so i'll take the top 300. 
  Tweets_rtweet_DF <- head(Tweets_rtweet_DF, n = 300) 
  #One by One, add each teams tweets to the existing NFL2020_tweets that we loaded earlier
  NFL2020_tweets <- rbind.data.frame(NFL2020_tweets,Tweets_rtweet_DF)
}

#save tweets as an .RData file so it this code can be ran again and new tweets can be added to the Data Frame
save(NFL2020_tweets, file="NFL2020_tweets.RData")

#summary view of tweets
summary(NFL2020_tweets)















