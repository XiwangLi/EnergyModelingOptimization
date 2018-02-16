

CalFactor <- read.csv('Vaisala_Cal.csv', header=T, colClasses=c('character', 'numeric', 'numeric'))

Room <- c('F4', 'F5', 'F11', 'F12', 'F23', 'F34', 'F37', 'F38')
Vaisala <- c('004', '006', '001', '002', '005', '007', '009', '008')

# i <- 6

write('Room,Time,CO2,Temp,RH,Schedule', file='CO2_Weekday.csv', append=F)
write('Room,Time,CO2', file='CO2_Weekend.csv', append=F)

for (i in 1:length(Room)) {
	
	pdf(paste(c(Room[i], '_RM_CO2_', Vaisala[i], '.pdf'), collapse=''), height=8, width=10)
	par(mfrow=c(5,5))
	par(mar=c(1,3,1,1))
	par(mgp=c(2,0.5,0))	
	
	data <- read.csv(paste(c(Room[i], '_RM_CO2_', Vaisala[i], '.csv'), collapse=''), header=F, skip=2)
	t <- strptime(data[,2], '%m/%d/%Y %I:%M:%S %p')

	v <- match(Vaisala[i], CalFactor$Vaisala)	
	data <- data.frame(t, Temp=data[,3], RH=data[,4], CO2=data[,5]*CalFactor$a[v]+CalFactor$b[v])
	
	StartDay <- strptime('10/03/2016 00:00', '%m/%d/%Y %H:%M')
	EndDay <- strptime('11/05/2016 00:00', '%m/%d/%Y %H:%M')
	nDay <- as.numeric(difftime(EndDay, StartDay, units='days'))
	
	for (j in 1:(nDay-1)) {
		
		PlotDay <- StartDay + (j-1)*24*60*60
		t0 <- findInterval(PlotDay, data$t)
		t1 <- findInterval(PlotDay + 24*60*60 - 1, data$t)
		pick <- data[t0:t1, ]
		
		DayOfWeek <- as.numeric(format(PlotDay, '%u'))
		if (DayOfWeek < 6) {
			colist <- 'blue'
		} else {
			colist <- 'red'
		}

		# Monday starts at 8:45am, other school days starts 7:30am
		if (DayOfWeek == 1) {
			StartTime <- PlotDay + 8*60*60 + 45*60
		} else {
			StartTime <- PlotDay + 7*60*60 + 30*60
		}
		
		# Minimum day ends at 11:45am, other school days end 2:15pm
		if (format(PlotDay, '%d')=='13' | format(PlotDay, '%d')=='14') {
			EndTime <- PlotDay + 11*60*60 + 45*60
		} else {
			EndTime <- PlotDay + 14*60*60 + 15*60
		}
	
		if (DayOfWeek < 6) {
			plot(pick$t, pick$CO2, col=colist, type='l', xlab='', ylab='CO2 (ppm)', ylim=c(0,2100), xaxt='n')
			text(x=pick$t[nrow(pick)], y=1900, format(PlotDay, '%m/%d'), font=2, adj=1)
			
			tguide <- seq(PlotDay, PlotDay+24*60*60, 3*60*60)
			axis(side=1, at=tguide, labels=format(tguide, '%H:%M'))
			
			abline(v=c(StartTime, EndTime), col='red', lty=3)
			
			t0 <- findInterval(StartTime, pick$t)
			t1 <- findInterval(EndTime, pick$t)
			
			Schedule <- c(rep(0, t0-1), rep(1, t1-t0+1), rep(2, nrow(pick)-t1))
			
			write.table(data.frame(Sensor=rep(Room[i], nrow(pick)), Time=format(pick$t, '%Y-%m-%d %H:%M'), CO2=pick$CO2, Temp=pick$Temp, RH=pick$RH, Schedule), file='CO2_Weekday.csv', append=T, sep=',', row.names=F, col.names=F)
		} else {
			write.table(data.frame(Sensor=rep(Room[i], nrow(pick)), Time=format(pick$t, '%Y-%m-%d %H:%M'), CO2=pick$CO2), file='CO2_Weekend.csv', append=T, sep=',', row.names=F, col.names=F)
			
		}
	}

	dev.off()
}
