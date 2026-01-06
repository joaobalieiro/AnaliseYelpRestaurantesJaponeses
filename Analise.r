###########################################
# R commands to process the Yelp database #
###########################################

#############################################
# Part 1:  Setup and initial data wrangling #
#############################################

library(dplyr)

reviews    <- read.csv("yelp_academic_dataset_review.csv",   header = FALSE)
users      <- read.csv("yelp_academic_dataset_user.csv",     header = FALSE)
businesses <- read.csv("yelp_academic_dataset_business.csv", header = FALSE)

colnames(reviews)    <- c("user_id", "business_id", "stars")
colnames(users)      <- c("user_id", "user_name")
colnames(businesses) <- c("business_id", "city", "business_name",
                          "categories", "review_count", "avg_stars")

ru  <- inner_join(reviews, users)
rub <- inner_join(ru, businesses)

######################################################
# Part 2a:  Analysis of Method 1 -- Initial Analysis #
######################################################

# japanese restaurants: look for "Japanese" or "Sushi"
rub$is_japanese <- grepl("Japanese", rub$categories) | grepl("Sushi", rub$categories)
japanese <- subset(rub, is_japanese == TRUE)

# number of japanese restaurant reviews per user
num_reviews_Japanese <- japanese %>%
  select(user_id, user_name, is_japanese) %>%
  group_by(user_id) %>%
  summarise(tot_rev = sum(is_japanese))

print(table(num_reviews_Japanese$tot_rev))
print(count(num_reviews_Japanese))
print(mean(num_reviews_Japanese$tot_rev))

#################################################################
# Part 2b:  Analysis of Method 1 -- Extension to Other Cuisines #
#################################################################

rub$is_chinese <- grepl("Chinese", rub$categories)
chinese <- subset(rub, is_chinese == TRUE)
num_reviews_Chinese <- chinese %>%
  select(user_id, user_name, is_chinese) %>%
  group_by(user_id) %>%
  summarise(tot_rev = sum(is_chinese))

print(table(num_reviews_Chinese$tot_rev))
print(count(num_reviews_Chinese))
print(mean(num_reviews_Chinese$tot_rev))

rub$is_mexican <- grepl("Mexican", rub$categories)
mexican <- subset(rub, is_mexican == TRUE)
num_reviews_Mexican <- mexican %>%
  select(user_id, user_name, is_mexican) %>%
  group_by(user_id) %>%
  summarise(tot_rev = sum(is_mexican))

print(table(num_reviews_Mexican$tot_rev))
print(count(num_reviews_Mexican))
print(mean(num_reviews_Mexican$tot_rev))

rub$is_italian <- grepl("Italian", rub$categories)
italian <- subset(rub, is_italian == TRUE)
num_reviews_Italian <- italian %>%
  select(user_id, user_name, is_italian) %>%
  group_by(user_id) %>%
  summarise(tot_rev = sum(is_italian))

print(table(num_reviews_Italian$tot_rev))
print(count(num_reviews_Italian))
print(mean(num_reviews_Italian$tot_rev))

#####################################################################
# Part 2c:  Analysis of Method 1 -- Apply new weight and see effect #
#####################################################################

cj <- inner_join(japanese, num_reviews_Japanese)
cj$weighted_stars <- cj$stars * cj$tot_rev

new_rating_Japanese <- cj %>%
  select(city, business_name, avg_stars, stars, tot_rev, weighted_stars) %>%
  group_by(city, business_name, avg_stars) %>%
  summarise(cnt = n(),
            avg = sum(stars) / cnt,
            new = sum(weighted_stars) / sum(tot_rev),
            dif = new - avg,
            .groups = "drop")

print(summary(new_rating_Japanese$dif))

nrj5 <- subset(new_rating_Japanese, cnt > 5)
print(summary(nrj5$dif))

################################################################
# Part 3:  Analysis of Method 2 -- Generate "immigrant" rating #
################################################################

# read japanese names into a list
jnames <- scan("japanese_names.txt", what = character())

# flag reviews by users with japanese names
japanese$reviewer_japanese_name <- japanese$user_name %in% jnames
japanese$jstars <- japanese$stars * japanese$reviewer_japanese_name

print(table(japanese$reviewer_japanese_name))
print(sum(japanese$reviewer_japanese_name) / nrow(japanese))

avg_rating_Japanese <- japanese %>%
  select(business_id, business_name, city, stars,
         avg_stars, reviewer_japanese_name, is_japanese, jstars) %>%
  group_by(city, business_name, avg_stars) %>%
  summarise(count = n(),
            nj = sum(reviewer_japanese_name),
            pj = sum(reviewer_japanese_name) / n(),
            avg = sum(stars) / count,
            jas = sum(jstars) / nj,
            dif = jas - avg,
            .groups = "drop")

print(summary(avg_rating_Japanese$dif))

arj5 <- subset(avg_rating_Japanese, nj > 5)
print(summary(arj5$dif))
