
# coding: utf-8

# In[2]:

import numpy as np
import pandas as pd # pandas
import matplotlib.pyplot as plt # module for plotting 
import datetime as dt # module for manipulating dates and times
import numpy.linalg as lin # module for performing linear algebra operations


import scipy as sp
import scipy.stats
import matplotlib

import pylab as pl
from datetime import date


# In[3]:

def movingaverage(interval, window_size):
    window = np.ones(int(window_size))/float(window_size)
    return np.convolve(interval, window, 'same')


# In[28]:

datadir='Results\SystemOnOff\School_007_RLT/'

#WIL_room=['201','202','204','205','301','302','304','402','403','604']

#cases=['WIL_weekday','WIL_weekend']


WIL_room=['12','16','18','20','23','26','35','B6']
cases=['RLT_weekday','RLT_weekend']

for case in cases:
    datafile=datadir+case+'.xlsx'
    Willows=pd.read_excel(datafile)
    for RM in WIL_room:
        if RM !='B6':
            Will_RM=Willows[Willows['Room']==int(RM)]
        else:
            Will_RM=Willows[Willows['Room']==RM]
               
        
        Will_RM_Occupied=Will_RM.between_time('8:45','13:59')  # for RLT
        Will_RM_Occupied=Will_RM_Occupied['2017-04-28':'2017-05-25']  # for RLT       
        
        
        Will_RM_Occupied.dropna(axis=0, how='all')
        
        print RM
        print Will_RM_Occupied
              
        totalhours=len(Will_RM_Occupied)/60.
        #print 'toal occupied hours',totalhours

        Will_Cooling_On=Will_RM_Occupied[Will_RM_Occupied['HVACON_Cooling']==1]
        TotalCooling_hours=len(Will_Cooling_On)/60.
        
        Will_Heating_On=Will_RM_Occupied[Will_RM_Occupied['HVACON_heating']==1]
        TotalHeating_hours=len(Will_Heating_On)/60.        
        
        #print 'toal HVAC on hours',TotalHVACOn_hours
        
        Will_RM_Occupied['RMT']=Will_RM_Occupied['RMT'] #*9/5 + 32  # HP temperature C to F

        Will_RM_Temp=Will_RM_Occupied.RMT
        Mean_Temp=np.mean(Will_RM_Temp)
        Median_Temp=np.median(Will_RM_Temp)
        Max_Temp=max(Will_RM_Temp)
        Min_Temp=min(Will_RM_Temp)
        

        Will_RM_RH=Will_RM_Occupied.RMRH
        Mean_RH=np.mean(Will_RM_RH)
        Median_RH=np.median(Will_RM_RH)
        Max_RH=max(Will_RM_RH)
        Min_RH=min(Will_RM_RH)
       
        Will_RM_Occupied_Hi_temp=Will_RM_Occupied[Will_RM_Occupied['RMT']>78]
        Will_RM_Occupied_Low_temp=Will_RM_Occupied[Will_RM_Occupied['RMT']<68]
        hours_Hi_temp=len(Will_RM_Occupied_Hi_temp)/60./totalhours
        hours_Low_temp=len(Will_RM_Occupied_Low_temp)/60./totalhours

        hours_D_closed=(np.mean(Will_RM_Occupied['DS,%'])/100)
        hours_D_open=1-hours_D_closed
        Mean_CO2=np.mean(Will_RM_Occupied['CO2_ppm'])
        Medium_CO2=np.median(Will_RM_Occupied['CO2_ppm'])       


        Will_CO2_Low=Will_RM_Occupied[Will_RM_Occupied['CO2_ppm']<=1100]
        Will_CO2_Med=Will_RM_Occupied[(Will_RM_Occupied['CO2_ppm']>1100) & (Will_RM_Occupied['CO2_ppm']<=1700)]
        Will_CO2_Hi=Will_RM_Occupied[Will_RM_Occupied['CO2_ppm']>1700]

        hours_CO2_Low=len(Will_CO2_Low)/60./totalhours
        hours_CO2_Med=len(Will_CO2_Med)/60./totalhours
        hours_CO2_Hi=len(Will_CO2_Hi)/60. /totalhours
        
        
        Will_Comfot=Will_RM_Occupied[(Will_RM_Occupied['RMT']<(86.8-0.109*Will_RM_Occupied['RMRH'])) & (Will_RM_Occupied['RMT']>(73.6-0.06*Will_RM_Occupied['RMRH']))]
            
        hours_Comfot=len(Will_Comfot)/60./totalhours 

        Will_RM_Occupied_15=Will_RM_Occupied.resample('60Min').mean()
        Mean_CO2_15=np.mean(Will_RM_Occupied['CO2_ppm'])
        Medium_CO2_15=np.median(Will_RM_Occupied['CO2_ppm'])
        Peak_CO2_15=max(Will_RM_Occupied['CO2_ppm'])
                
        
        Will_RM_Occupied['Date']=pd.to_datetime(Will_RM_Occupied['Date and time'], format = '%Y-%m-%d %H:%M').dt.strftime("%m%d")
        all_dates=np.unique(Will_RM_Occupied['Date'])
        
        running_30_temp_max_all=[]
        running_30_RH_max_all=[]
        running_30_temp_min_all=[]
        running_30_RH_min_all=[]
        running_15_CO2_max_all=[]
        Vo_rate_all=[]
        
        numDates=len(all_dates)
        
        for i in range(numDates):
            Will_RM_Occupied_date=Will_RM_Occupied[Will_RM_Occupied['Date']==all_dates[i]]
            
            running_30_temp_max=max(Will_RM_Occupied_date['RMT'].rolling(window=30,center=False).mean().dropna())              
            running_30_RH_max=max(Will_RM_Occupied_date['RMRH'].rolling(window=30,center=False).mean().dropna())
            running_30_temp_min=min(Will_RM_Occupied_date['RMT'].rolling(window=30,center=False).mean().dropna())                 
            running_30_RH_min=min(Will_RM_Occupied_date['RMRH'].rolling(window=30,center=False).mean().dropna())
            running_15_CO2_max=max(Will_RM_Occupied_date['CO2_ppm'].rolling(window=15,center=False).mean().dropna())
            
            running_30_temp_max_all.append(running_30_temp_max)   
            running_30_RH_max_all.append(running_30_RH_max)
            running_30_temp_min_all.append(running_30_temp_min)
            running_30_RH_min_all.append(running_30_RH_min) 
            
            running_15_CO2_max_all.append(running_15_CO2_max)    
            Vo_rate=(0.0043*1e6/(running_15_CO2_max-360)) 
            Vo_rate_all.append(Vo_rate)
            
        Mean_highest_15_CO2=np.mean(running_15_CO2_max_all)    
        Median_highest_15_CO2=np.median(running_15_CO2_max_all)    
        #print Vo_rate_all
        mean_Vo=np.mean(Vo_rate_all)
        median_Vo=np.median(Vo_rate_all)
        Vo_5th = np.percentile(Vo_rate_all, 5)    
        Vo_25th = np.percentile(Vo_rate_all, 25)
        Vo_75th = np.percentile(Vo_rate_all, 75) 
        Vo_95th = np.percentile(Vo_rate_all, 95)   
        
        Max_30_running_temp=max(running_30_temp_max_all)
        Min_30_running_temp=min(running_30_temp_min_all)
        
        Max_30_running_RH=max(running_30_RH_max_all)
        Min_30_running_RH=min(running_30_RH_min_all)

        report=[RM,totalhours, TotalCooling_hours, TotalHeating_hours,hours_D_closed, hours_D_open,Mean_Temp, Median_Temp,
                Max_Temp,Min_Temp,Max_30_running_temp, Min_30_running_temp, \
                Mean_RH, Median_RH,Max_RH,Min_RH, Max_30_running_RH,Min_30_running_RH,\
                hours_Comfot,\
                Mean_CO2, Medium_CO2,hours_Hi_temp,hours_Low_temp,\
                hours_CO2_Low,hours_CO2_Med,hours_CO2_Hi, \
                Mean_highest_15_CO2, Median_highest_15_CO2,Peak_CO2_15,\
                mean_Vo, median_Vo, Vo_5th,Vo_25th, Vo_75th, Vo_95th]

        report=pd.DataFrame(report)
        report=report.T
        
        if RM==WIL_room[0]:
            Report_all=report
        else:
            Report_all=Report_all.append(report)
        

    Report_all.columns=['RM','totalhours', 'TotalCooling_hours','TotalHeating_hours','hours_Dr_Closed','hours_D_open','Mean_Temp', 'Median_Temp',                        'Max_Temp','Min_Temp','High30 min running room T','Lowest 30 min running room T',                        'Mean_RH', 'Median_RH','Max_RH','Min_RH','High30 min running room RH,%','Lowest 30 min running room RH,%',                        'hours in ASHRAE comfort zone',                        'Mean_CO2','Median CO2','hours_temp>78','hours<68','hours CO2<1100','hours_CO2-1100-1700',                         'hours_CO2>1700',
                        'Mean 15-min CO2, ppm', 'Medium 15-min CO2, ppm', 'Peak 15-min CO2, ppm',\
                        'mean ventilation, L/(s-persone)', 'median ventilation, L/(s-persone)', '5th ventilation, L/(s-persone)',\
                         '25th ventilation, L/(s-persone)','75th ventilation, L/(s-persone)','95th ventilation, L/(s-persone)']   

    reportdir=datadir+'report'+case+'.csv'
    Report_all.to_csv(reportdir)
    

