data <- read.csv('CO2_Weekday.csv', header=T, sep=',')
RoomID <- as.vector(unique(data$Room))

library(zoo)

par(mfrow=c(3,3))
par(mar=c(1,1,2,1))
par(cex=1.1)

for (i in 1:length(Room)) {

	pick <- subset(data, Room==RoomID[i] & Schedule==1)	
	
	C <- ifelse(pick$CO2>400, pick$CO2, NA)
	# Cavg <- rollapply(C, 12, mean, na.rm=T)
	
	n <- length(C[!is.na(C)])
	slice <- c(length(C[!is.na(C) & C > 1700]), length(C[!is.na(C) & C > 1100 & C <= 1700]), length(C[!is.na(C) & C <= 1100]))/n
	pct <- paste(round(slice*100), '%', sep='')
	pie(slice, labels=pct, col=c('orange', 'yellow', 'green'), main=Room[i])
	
	# hist(pick$Temp, main=Room[i])
	# print(c(Room[i], mean(pick$Temp), as.numeric(quantile(pick$Temp, c(0.05, 0.95)))))
	
	# hist(pick$RH, main=Room[i])
	# print(c(Room[i], mean(pick$RH), as.numeric(quantile(pick$RH, c(0.05, 0.95)))))
	
}

plot(0, type='n', axes=F)
legend('topleft', legend=c('CO2 above 1700 ppm', 'CO2 1100 to 1700 ppm', 'CO2 below 1100 ppm'), fill=c('orange', 'yellow', 'green'))