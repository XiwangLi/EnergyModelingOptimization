
library('zoo')

data <- read.table('CO2_Weekday.csv', header=T, sep=',')
t <- strptime(data$Time, '%Y-%m-%d %H:%M')
data <- data.frame(data, t)

# Assume co2 outdoor = 350 ppm (based on weekend co2 concentration)
cout <- 350

# Ceiling height (m)
Hceiling <- 8.5/3.2804

RoomID <- unique(data$Room)

nS <- 2

par(mfrow=c(5,5))
par(mar=c(3,3,2,1))
par(mgp=c(2,0.5,0))

# for (nS in 1:length(Sensor)) {
	
	mo <- unique(as.numeric(format(data$t[data$Room==RoomID[nS]], '%m')))
	
	for (m in 1:length(mo)) {
	
		dy <- unique(as.numeric(format(data$t[data$Room==RoomID[nS] & as.numeric(format(data$t, '%m'))==mo[m]], '%d')))
	
			for (d in 2:length(dy)) {
				
			# --- F4	---
			# if (!(mo[m]==10 & dy[d]==20)) {
				
			# --- F5 ---
			if (!(mo[m]==10 & (dy[d]==18 | dy[d]==19 | dy[d]==20))) {
	
				pickDay <- subset(data, Room==RoomID[nS] & as.numeric(format(t, '%m'))==mo[m] & as.numeric(format(t, '%d'))==dy[d])
				
				t0 <- match(1, pickDay$Schedule)
				t1 <- t0 + 8
				pick <- pickDay[t0:t1,]
				
				# plot(pick$t, pick$CO2, type='l', main=format(pick$t[1], '%m/%d'), ylab='CO2 (ppm)', xlab='')
			
				cpick <- pick$CO2
				tpick <- as.numeric(difftime(pick$t, pick$t[1]), units='hours')
				c0 <- cpick[1]
				cts <- data.frame(tpick, cpick)
				sguess <- max(cpick) - cout
				kguess <- 1.0
				
				r <- nls(cpick ~ cout + s + (c0 - cout - s)*exp(-k * tpick), data=cts, start=list(s=sguess, k=kguess), control=nls.control(warnOnly=T))
							
				sfit <- summary(r)$parameters[1]
				kfit <- summary(r)$parameters[2]
				
				# CO2 generation rate
				# 0.0043 L/s-person students (elementary schools), 15.5 L/h-person
				# 0.0052 L/s-person teacher, 18.7 L/h-person
																			
				vr <- 15.5/3600*1e6/sfit
				ach <- kfit
				occ <- sfit/1e6*ach/0.0155*100*Hceiling
				
				t0 <- match(2, pickDay$Schedule)
				t1 <- t0 + 13
				pick <- pickDay[t0:t1,]
				
				plot(pick$t, pick$CO2, type='l', main=format(pick$t[1], '%m/%d'), ylab='CO2 (ppm)', xlab='')
		
				cpick <- pick$CO2
				cpick <- log((cpick - cout)/(cpick[1] - cout))
				tpick <- as.numeric(difftime(pick$t, pick$t[1]), units='hours')
		
				r <- lm(cpick~tpick+0)
				ach2 <- as.numeric(r$coefficient[1])
				
				print(c(mo[m], dy[d], vr, ach, occ, ach2))
			}
		
		}
	}
# }
