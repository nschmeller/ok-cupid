## ----echo=FALSE, message=FALSE, warning=FALSE----------------------------
# The following packages must be installed
library(xtable)
library(stringr)
library(dplyr)
library(ggplot2)

# Set rounding to 2 digits
options(digits=2)

## ----cache=TRUE----------------------------------------------------------
profiles <- read.csv(file="profiles.csv", header=TRUE, stringsAsFactors=FALSE)
n <- nrow(profiles)

## ----cache=TRUE, all_heights, fig.height=4, fig.width=6, fig.cap="Heights of all users.", fig.align='center'----
require(mosaic)
favstats(height, data=profiles)

## ----cache=TRUE----------------------------------------------------------
require(dplyr)
profiles.subset <- filter(profiles, height>=55 & height <=80)

## ----cache=TRUE, heights_by_sex, fig.height=7, fig.width=10, fig.cap="Histograms of user heights split by sex.", fig.align='center'----
histogram(~height | sex, width=1, layout=c(1,2), xlab="Height (in)", data=profiles.subset)

## ----cache=TRUE, sex_and_orientation, fig.height=4, fig.width=8, fig.cap="Distributions of sex and sexual orientation.", fig.align='center'----
par(mfrow=c(1, 2))
barplot(table(profiles$sex)/n, xlab="sex", ylab="proportion")
barplot(table(profiles$orientation)/n, xlab="orientation", ylab="proportion")

## ----cache=TRUE, sex_by_orientation, fig.height=4, fig.width=4, fig.cap="Cross-classification of sex and sexual orientation.", fig.align='center'----
tally(orientation ~ sex, data=profiles, format='proportion')
sex.by.orientation <- tally(~sex + orientation, data=profiles)
sex.by.orientation
mosaicplot(sex.by.orientation, main="Sex vs Orientation", las=1)

## ----cache=TRUE----------------------------------------------------------
require(stringr)
essays <- select(profiles, starts_with("essay"))
essays <- apply(essays, 1, paste, collapse=" ")
essays <- str_replace_all(essays, "\n", " ")
essays <- str_replace_all(essays, "<br />", " ")

## ----cache=TRUE----------------------------------------------------------
profiles$has.book <- str_detect(essays, "book")
tally(has.book ~ sex, profiles, format='proportion')

## ----echo=FALSE, cache=TRUE, results='asis'------------------------------
queries <- c("travel", "food", "wine", "beer")
output <- data.frame(word=queries, female=rep(0, length(queries)), male=rep(0, length(queries)))
for(i in 1:length(queries)) {
  query <- queries[i]
  has.query <- str_detect(essays, query)
  results <- table(has.query, profiles$sex)
  output[i, 2:3] <- results[2, ] / colSums(results)
}
print(xtable(output, digits=c(0, 0, 3, 3), caption ="Proportions of each sex using word in essays.", label = "tab:word_use"), include.rownames=FALSE)

## ----cache=TRUE, travel_vs_wine, fig.height=3.5, fig.width=3.5, fig.cap="Co-occurrence of `travel' and `wine.'", fig.align='center'----
profiles$has.wine <- str_detect(essays, "wine")
profiles$has.travel <- str_detect(essays, "travel")
travel.vs.wine <- tally(~has.travel + has.wine, data=profiles)
mosaicplot(travel.vs.wine, main="", xlab="travel", ylab="wine")

## ----cache=TRUE----------------------------------------------------------
profiles$has.football <- str_detect(essays, "football")
results <- table(profiles$has.football, profiles$sex)
results
# Set x to be the second row of the results, and n to be the column sums.
prop.test(x=results[2, ], n=colSums(results), alternative="two.sided")

## ----cache=TRUE, eval=FALSE----------------------------------------------
## c(1, 2, 3, 4, NA) %>% sum(na.rm=TRUE)
## sum(c(1, 2, 3, 4, NA), na.rm=TRUE)

## ----cache=TRUE----------------------------------------------------------
male.words <- subset(essays, profiles$sex == "m") %>%
  str_split(" ") %>%
  unlist() %>%
  table() %>%
  sort(decreasing=TRUE) %>%
  names()
female.words <- subset(essays, profiles$sex == "f") %>%
  str_split(" ") %>%
  unlist() %>%
  table() %>%
  sort(decreasing=TRUE) %>%
  names()

## ----cache=TRUE----------------------------------------------------------
# Top 25 male words:
male.words[1:25]
# Top 25 female words
female.words[1:25]
# Words in the males top 500 that weren't in the females' top 500:
setdiff(male.words[1:500], female.words[1:500])
# Words in the male top 500 that weren't in the females' top 500:
setdiff(female.words[1:500], male.words[1:500])

## ----cache=TRUE----------------------------------------------------------
set.seed(76)
sample(1:10)
set.seed(76)
sample(1:10)
set.seed(79)
sample(1:10)

## ----cache=TRUE----------------------------------------------------------
profiles <- filter(profiles, height>=55 & height <=80)
set.seed(76)
profiles <- sample_n(profiles, 5995)

## ----cache=TRUE, is_female_vs_height, fig.height=3, fig.width=6, fig.cap="Female indicator vs height.", fig.align='center'----
require(ggplot2)
profiles <- mutate(profiles, is.female = ifelse(sex=="f", 1, 0))
ggplot(data=profiles, aes(x=height, y=is.female)) +
  geom_point() +
  xlab("Height (in.)") +
  ylab("Is female?")

## ----cache=TRUE, is_female_vs_height_jittered, fig.height=3, fig.width=6, fig.cap="Female indicator vs height (jittered).", fig.align='center'----
ggplot(data=profiles, aes(x=height, y=is.female)) +
  geom_jitter(position = position_jitter(width = .2, height=.2)) +
  xlab("Height (in.)") +
  ylab("Is female?")

## ----cache=TRUE----------------------------------------------------------
linear.model <- lm(is.female ~ height, data=profiles)
msummary(linear.model)
b1 <- coef(linear.model)
b1

## ----cache=TRUE----------------------------------------------------------
logistic.model <- glm(is.female ~ height, family=binomial, data=profiles)
msummary(logistic.model)
b2 <- coefficients(logistic.model)
b2

## ----cache=TRUE, is_female_vs_height_logistic_vs_linear, fig.height=3, fig.width=6, fig.cap="Predicted linear (red) and logistic (blue) regression curves.", fig.align='center'----
inverse.logit <- function(x, b){
  linear.equation <- b[1] + b[2]*x
  1/(1+exp(-linear.equation))
}
ggplot(data=profiles, aes(x=height, y=is.female)) +
  geom_jitter(position = position_jitter(width = .2, height=.2)) +
  xlab("Height (in.)") +
  ylab("Is female?") +
  geom_abline(intercept=b1[1], slope=b1[2], col="red", size=2) +
  stat_function(fun = inverse.logit, args=list(b=b2), color="blue", size=2)

## ----cache=TRUE, fitted_values, fig.height=3.5, fig.width=5, fig.cap="Fitted probabilities of being female and decision threshold (in red).", fig.align='center'----
profiles$p.hat <- fitted(logistic.model)
ggplot(data=profiles, aes(x=p.hat)) +
  geom_histogram(binwidth=0.1) +
  xlab(expression(hat(p))) +
  ylab("Frequency") +
  xlim(c(0,1)) +
  geom_vline(xintercept=0.5, col="red", size=1.2)
profiles <- mutate(profiles, predicted.female = p.hat >= 0.5)
tally(~is.female + predicted.female, data=profiles)

## ----cache=TRUE, echo=FALSE----------------------------------------------
# Compute misclassification error rate
perf.table <- table(truth=profiles$is.female, prediction=profiles$predicted.female)
misclass.error <- 1 - sum(diag(perf.table))/sum(perf.table)

## ----echo=TRUE, message=FALSE, eval=FALSE--------------------------------
## purl(input="JSE.Rnw", output="JSE.R", quiet=TRUE)

