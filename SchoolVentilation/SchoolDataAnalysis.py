
# coding: utf-8

# In[2]:

import numpy as np
import pandas as pd # pandas
import matplotlib.pyplot as plt # module for plotting 
import datetime as dt # module for manipulating dates and times
import numpy.linalg as lin # module for performing linear algebra operations
from __future__ import division

import scipy as sp
import scipy.stats
import matplotlib

import pylab as pl
from datetime import date


# In[83]:

#classroom=['TMC','RIO','SNA','WIL']
classroom=['BRL']

MeasuresTMCCO2=['F4_RM_CO2_004','F5_RM_CO2_006', 'F11_RM_CO2_001','F12_RM_CO2_002','F23_RM_CO2_005', 'F34_RM_CO2_007','F37_RM_CO2_009','F38_RM_CO2_008']
MeasuresTMCSA=['F4_SA_TRH_004','F5_SA_TRH_006','F11_SA_TRH_001','F12_SA_TRH_002','F23_SA_TRH_005', 'F34_SA_TRH_007','F37_SA_TRH_009','F38_SA_TRH_008']

MeasuresRIOSA=['F1_SA_TRH_011','F2_SA_TRH_021','F3_SA_TRH_022','F4_SA_TRH_023','F5_SA_TRH_027','F6_SA_TRH_005', 'F7_SA_TRH_007','F8_SA_TRH_018','F9_SA_TRH_019','F10_SA_TRH_001']

RIO_room=['F1','F2','F3','F4','F5','F6','F7','F8','F9','F10']
RIO_Dsensor=['011','012','013','014','015','016','017','018','003','010']


MeasuresSNACO2=['S104_RM_CO2_023','S106_RM_CO2_025','S107_RM_CO2_024','S109_RM_CO2_022','S111_RM_CO2_021','S202_RM_CO2_030', 'S204_RM_CO2_027','S205_RM_CO2_029','S207_RM_CO2_026','S209_RM_CO2_028','W301_RM_CO2_003','W302_RM_CO2_004',                 'W304_RM_CO2_006','W307_RM_CO2_005','W401_RM_CO2_001','W402_RM_CO2_002']
MeasuresSNASA=['S104_SA_TRH_015','S106_SA_TRH_013','S107_SA_TRH_014','S109_SA_TRH_020','S111_SA_TRH_017','S202_SA_TRH_019', 'S204_SA_TRH_018','S205_SA_TRH_016','S207_SA_TRH_012','S209_SA_TRH_011','W301_SA_TRH_003','W302_SA_TRH_004',              'W304_SA_TRH_006','W307_SA_TRH_005','W401_SA_TRH_001','W402_SA_TRH_002']

SNA_room=['S104','S106','S107','S109','S111','S202','S204','S205','S207','S209','W301','W302','W304','W307','W401','W402']
SNA_Dsensor=['018','017','011','015','012','014','013','003','016','010','019','004','006','005','001','002']



MeasuresWILCO2=['201_RM_CO2_020', '202_RM_CO2_019','204_RM_CO2_014','205_RM_CO2_018','301_RM_CO2_015','302_RM_CO2_017', '304_RM_CO2_013','402_RM_CO2_012','403_RM_CO2_011','604_RM_CO2_016']

MeasuresWILSA=['201_SA_TRH_008','202_SA_TRH_009','204_SA_TRH_024','205_SA_TRH_010','301_SA_TRH_025','302_SA_TRH_020','304_SA_TRH_023','402_SA_TRH_022','403_SA_TRH_021','604_SA_TRH_026']



WIL_room=['201','202','204','205','301','302','304','402','403','604']
WIL_Dsensor=['007','008','026','009','027','020','025','024','023','028']


MeasuresHPCO2=['101_RM_CO2_012','108_RM_CO2_019','205_RM_CO2_013','207_RM_CO2_020','302_RM_CO2_011','305_RM_CO2_025', '308_RM_CO2_018','309_RM_CO2_017','403_RM_CO2_015','404_RM_CO2_014']
MeasuresHPSA=['101_SA_TRH_001','108_SA_TRH_018','205_SA_TRH_012','207_SA_TRH_019','302_SA_TRH_017','305_SA_TRH_020',  '308_SA_TRH_016','309_SA_TRH_015','403_SA_TRH_014','404_SA_TRH_013']

HP_room=['101','108','205','207','302','305','308','309','403','404']
HP_Dsensor=['001','008','002','009','007','010','006','005','004','003']

    
Birch_CO2=[]
Birch_DS=[]
Birch_SATRH=[]

RLT_CO2=[]
RLT_DS=[]
RLT_SATRH=[]


index=['16','18','20','23','26','35','B6']
for i in index:
    RLT_CO2_room='Ralston_CO2_Room_'+i
    RLT_DoorState_room='Ralston_Door_sensor_Room_'+i
    RLT_SA_TRH_room='Ralston_Supply_Air_Room_'+i
    
    RLT_CO2.append(RLT_CO2_room)
    RLT_DS.append(RLT_DoorState_room)
    RLT_SATRH.append(RLT_SA_TRH_room)


#index=[13,14,15,16,17,19,20,21,22,23,30,31,32,33]
#for i in index:
#    BRL_CO2_room='Birch_Lane_Co2_Room_'+str(i)
#    BRL_DoorState_room='Birch_Lane_Door_Sensor_Room_'+str(i)
#    BRL_SA_TRH_room='Birch_Lane_TRH_Room_'+str(i)
    
#    Birch_CO2.append(BRL_CO2_room)
#    Birch_DS.append(BRL_DoorState_room)
#    Birch_SATRH.append(BRL_SA_TRH_room)
   


# In[78]:

classroom=['RLT']
for rm in classroom:
    if rm=='RIO':
        CO2fileName=MeasuresRIOCO2
        SAfileName=MeasuresRIOSA
        Dr_room=RIO_room
        Dr_sensor=RIO_Dsensor
    
    elif rm=='SNA':
        CO2fileName=MeasuresSNACO2
        SAfileName=MeasuresSNASA
        Dr_room=SNA_room
        Dr_sensor=SNA_Dsensor     
    
    elif rm=='TMC':
        CO2fileName=MeasuresTMCCO2
        SAfileName=MeasuresTMCSA
        Dr_room=TMC_room
        Dr_sensor=TMC_Dsensor
        
    elif rm=='HP':
        CO2fileName=MeasuresHPCO2
        SAfileName=MeasuresHPSA
        Dr_room=HP_room
        Dr_sensor=HP_Dsensor
    elif rm=='BRL':
        CO2fileName=Birch_CO2
        SAfileName=Birch_SATRH
        Dr_sensor=Birch_DS 
        
    elif rm=='RLT':
        CO2fileName=RLT_CO2
        SAfileName=RLT_SATRH
        Dr_sensor=RLT_DS    
    
        
    else:
        CO2fileName=MeasuresWILCO2
        SAfileName=MeasuresWILSA 
        Dr_room=WIL_room
        Dr_sensor=WIL_Dsensor
    #print CO2fileName
        
    for CO2 in CO2fileName:
        rnNumber=classroom.index(rm)+7
        rmName='School_00'+str(rnNumber)+'_'+rm   
        rawdatadir='C:\Users\Xiwang_LBL\Google Drive\K12SchoolUCD\Task2_FieldSurvey\Field_Data/'+rmName+'\Data_CSV/' 
        # Please replace this directory

        rawCO2CSV=rawdatadir+CO2+'.csv'
        cleanCO2CSV=CO2+'.xlsx'
        #print CO2
        index=CO2fileName.index(CO2)

        SACSV=rawdatadir+SAfileName[index]+'.csv'
        cleanSACSV=SAfileName[index]+'.xlsx'
        
        if (rm=='BRL') | (rm=='RLT'):
            Doorstate=rawdatadir+Dr_sensor[index]+'.csv'
            cleanDS=Dr_sensor[index]+'.xlsx'
        
        else: 
            Doorstate=rawdatadir+Dr_room[index]+'_DS_State_'+Dr_sensor[index]+'.csv'
            cleanDS=Dr_room[index]+'_DS_State_'+Dr_sensor[index]+'.xlsx'


        SARaw=pd.read_csv(SACSV)

        with open(rawCO2CSV) as f:
            content=f.readlines()[2:-2]

            CO2_tot=[]
            for line in range(len(content)):
                new_line=content[line].split(',')
                
                CO2=[new_line[index] for index in [1,2,3,6]]              
                CO2_tot.append(CO2)

            CO2_tot = pd.DataFrame(CO2_tot , columns=["Datetime", "T", "RH","CO2"])
            CO2_tot=CO2_tot.set_index(pd.DatetimeIndex(CO2_tot['Datetime']))
            CO2_tot_final=CO2_tot[['T','RH','CO2']]
            cleanCSVname='DataCleaned/'+rmName+'/'+cleanCO2CSV

            index_01T = pd.DatetimeIndex(freq='01T', start=CO2_tot_final.index[0], end=CO2_tot_final.index[-1])
            df2 = CO2_tot_final.reindex(index=index_01T)
            for col in df2:
                df2[col] = pd.to_numeric(df2[col], errors='coerce')  #convering all the elements to numeric for "interpolate with all NaNs" 

            CO2_min=df2.interpolate(method='time')
            CO2_min.to_excel(cleanCSVname)

        with open(SACSV) as f:
            content=f.readlines()[2:-2]

            SA_tot=[]
            for line in range(len(content)):
                new_line=content[line].split(',')
                SA=new_line[1:4]
                SA_tot.append(SA)

    #        print SA_tot

            SA_tot = pd.DataFrame(SA_tot , columns=["Datetime", "T", "RH"])
            SA_tot=SA_tot.set_index(pd.DatetimeIndex(SA_tot ['Datetime']))
            SA_tot_final=SA_tot[['T','RH']]
            cleanSAname='DataCleaned/'+rmName+'/'+cleanSACSV

            index_01T = pd.DatetimeIndex(freq='01T', start=SA_tot_final.index[0], end=SA_tot_final.index[-1])
            df2 = SA_tot_final.reindex(index=index_01T)
            for col in df2:
                df2[col] = pd.to_numeric(df2[col], errors='coerce')  #convering all the elements to numeric for "interpolate with all NaNs" 
            TRH_min=df2.interpolate(method='time')
            TRH_min.to_excel(cleanSAname)
    
    
        with open(Doorstate) as f:
            content=f.readlines()[2:-2]

            DS_tot=[]
            for line in range(len(content)):
                new_line=content[line].split(',')
                DS=new_line[1:3]
                DS_tot.append(DS)

    
            DS_tot = pd.DataFrame(DS_tot , columns=["Datetime", "DS,%"])
            DS_tot=DS_tot.set_index(pd.DatetimeIndex(DS_tot ['Datetime']))
            DS_tot_final=DS_tot[['DS,%']]
            cleanSAname='DataCleaned/'+rmName+'/'+cleanDS

            #index_01T = pd.DatetimeIndex(freq='01T', start=SA_tot_final.index[0], end=SA_tot_final.index[-1])
            #df2 = SA_tot_final.reindex(index=index_01T)
            #for col in df2:
                #df2[col] = pd.to_numeric(df2[col], errors='coerce')  #convering all the elements to numeric for "interpolate with all NaNs" 
            TRH_min=df2.interpolate(method='time')
            DS_tot_final.to_excel(cleanSAname)


from datetime import datetime, timedelta
date_format = "%m/%d/%Y"

for rm in classroom:
    if rm=='RIO':
        CO2fileName=MeasuresRIOCO2
        SAfileName=MeasuresRIOSA
        startDay=datetime.strptime('10/18/2016', date_format)
        endDay=datetime.strptime('10/23/2016', date_format)
        
        RIOdatadir='Results\SystemOnOff\School_002_RIO/'
        CaliCofile=RIOdatadir+'Vaisala_Cal.csv'
        Coeffs=pd.read_csv(CaliCofile)        

    elif rm=='SNA':
        CO2fileName=MeasuresSNACO2
        SAfileName=MeasuresSNASA
        startDay=datetime.strptime('11/19/2016', date_format)
        endDay=datetime.strptime('11/24/2016', date_format)
        SNAdatadir='Results\SystemOnOff\School_003_SNA/'
        CaliCofile=SNAdatadir+'Vaisala_Cal.csv'
        Coeffs=pd.read_csv(CaliCofile) 
        
    elif rm=='TMC':       
        CO2fileName=MeasuresTMCCO2
        SAfileName=MeasuresTMCSA
        startDay=datetime.strptime('10/03/2016', date_format)
        endDay=datetime.strptime('10/08/2016', date_format)
        
        TMCdatadir='Results\SystemOnOff\School_001_TMC/'
        CaliCofile=TMCdatadir+'Vaisala_Cal.csv'
        Coeffs=pd.read_csv(CaliCofile)        
        
    elif rm=='HP':       
        CO2fileName=MeasuresHPCO2
        SAfileName=MeasuresHPSA
        startDay=datetime.strptime('02/23/2017', date_format)
        endDay=datetime.strptime('02/28/2017', date_format)
        
        HPdatadir='Results\SystemOnOff\School_005_HP/'
        CaliCofile=HPdatadir+'Vaisala_Cal.csv'
        Coeffs=pd.read_csv(CaliCofile)    
        
    elif rm=='BRL':  
        CO2fileName=Birch_CO2
        SAfileName=Birch_SATRH
        Dr_sensor=Birch_DS  
        
        startDay=datetime.strptime('04/21/2017', date_format)
        endDay=datetime.strptime('04/26/2017', date_format)
         
        BRLdatadir='Results\SystemOnOff\School_006_BRL/'
 
        
    elif rm=='RLT':  
        CO2fileName=RLT_CO2
        SAfileName=RLT_SATRH
        Dr_sensor=RLT_DS  
        
        startDay=datetime.strptime('05/01/2017', date_format)
        endDay=datetime.strptime('05/06/2017', date_format)
         
        BRLdatadir='Results\SystemOnOff\School_007_RLT/'
        
    else:
        CO2fileName=MeasuresWILCO2
        SAfileName=MeasuresWILSA
        startDay=datetime.strptime('1/13/2017', date_format)
        endDay=datetime.strptime('1/18/2017', date_format)
         
        WILdatadir='Results\SystemOnOff\School_004_WIL/'
        CaliCofile=WILdatadir+'Vaisala_Cal.csv'
        Coeffs=pd.read_csv(CaliCofile)
        
        
    #print CO2fileName
    nDay=(endDay-startDay).days
    rows=len(CO2fileName)

    #ax=plt.subplots(rows, nDay, sharex=True, figsize=(30,15))
    #print 'Ndays', nDay
    
    numplt=0
    for CO2 in CO2fileName:
        rnNumber=classroom.index(rm)+7
        rmName='School_00'+str(rnNumber)+'_'+rm        
        cleandatadir='DataCleaned/'+rmName+'/'        
        CO2CSV=cleandatadir+CO2+'.xlsx'

        print 'RM: ', CO2
        
        index=CO2fileName.index(CO2)        
        SACSV=cleandatadir+SAfileName[index]+'.xlsx'
        
        print index
        #print Dr_room[index]
        
                
        if (rm=='BRL') | (rm=='RLT'):
            #Doorstate=rawdatadir+Dr_sensor[index]+'.csv'
            cleanDS=cleandatadir+Dr_sensor[index]+'.xlsx'
        
        else: 
            cleanDS=cleandatadir+Dr_room[index]+'_DS_State_'+Dr_sensor[index]+'.xlsx'
        
        
        

        CO2data=pd.read_excel(CO2CSV)
        SAdata=pd.read_excel(SACSV)
        DSdata=pd.read_excel(cleanDS)
        
               
        #print 'readingdem', CO2data.shape
        CO2data.columns = ["RMT", "RMRH","CO2"]
        SAdata.columns = ["SAT", "SARH"]    
        DSdata.columns = ["DS,%"]
        
########################System On/Off####################################### Here is the code for determinig system on/off
        CO2data['RMTNext']=CO2data.RMT.shift(1)
        SAdata['SATNext']=SAdata.SAT.shift(1)        
        CO2data['RMTChange']=CO2data.RMT-CO2data.RMTNext
        SAdata['SATChange']=SAdata.SAT-SAdata.SATNext        
        
        TotalTEMP = pd.concat([CO2data, SAdata], axis=1, join='inner')       
        
        TotalTEMP['HVACON_Cooling']=(TotalTEMP.RMT>TotalTEMP.SAT)&(TotalTEMP.SATChange<0)&(TotalTEMP.RMTChange<0)&(abs(TotalTEMP.SATChange)>abs(TotalTEMP.RMTChange))
        TotalTEMP['HVACON_heating']=(TotalTEMP.RMT<TotalTEMP.SAT)&(TotalTEMP.SATChange>0)&(TotalTEMP.RMTChange>0)&(abs(TotalTEMP.SATChange)>abs(TotalTEMP.RMTChange))
        
        systemonoffdir='results/SystemOnOff/'+rmName+'/'+CO2+'.xlsx'
               
        TotalTEMP['Room']=CO2[-2:]
        TotalTEMP['DS,%']=DSdata["DS,%"]
        
        
        CoID=CO2[-2:]
        coe_a=float(Coeffs[Coeffs['Vaisala']==int(CoID)].a)
        coe_b=float(Coeffs[Coeffs['Vaisala']==int(CoID)].b)
        TotalTEMP['CO2_ppm']=TotalTEMP['CO2']*coe_a+coe_b # converting CO2 measurments to PPM
        TotalTEMP['CO2_ppm']=TotalTEMP['CO2']      
        TotalTEMP.to_excel(systemonoffdir)        
         
##################################Ploting#######################################        
        fig=plt.figure(figsize=(30,5))

        for day in range (nDay):
            numplt=day+1
            plotDay=startDay+timedelta(hours=(day-1)*24)          
            DayofWeek=plotDay.weekday()+1
            
            if DayofWeek == 1:
                StartTime=plotDay+timedelta(hours=6, minutes = 45)
                EndTime=plotDay+timedelta(hours=20, minutes = 15)
            elif DayofWeek < 6:
                StartTime=plotDay+timedelta(hours=6, minutes = 30)
                EndTime=plotDay+timedelta(hours=20, minutes = 15)
            else:
                StartTime=plotDay
                EndTime=plotDay+timedelta(hours=23, minutes = 59)
                
            CO2ana=CO2data[StartTime:EndTime]
            SAana=SAdata[StartTime:EndTime]     
            result = pd.concat([CO2ana, SAana], axis=1, join='inner')          

            ax=plt.subplot(1, nDay, numplt)
            l1=ax.plot(result.RMT, 'r', label=u'Room Temperature')
            l2=ax.plot(result.SAT, 'b', label=u'SA Temperature')
            #legend = plt.legend(loc='upper right', shadow=True)
            
            ticks = ax.get_xticks()
            ax.set_xticks(ticks[::3])            
            #lgd = plt.legend((l1, l2), ('Room Temperature', 'SA Temperature'), loc='upper center')
            pltdate=plotDay.date()
            l = pl.legend(title=pltdate,loc='upper center', bbox_to_anchor=(0.5, 1.25))
            
            #plt.xticks(plt.get_xticks()[::4])         
           
        pdname='Results/Plots/'+rmName+'/'+CO2+'.pdf'
        fig.savefig(pdname,bbox_inches='tight')  
        #fig.savefig(pdname)
        plt.show()
        


#rmname='201_RM_CO2_020'

WIL_file=WILdatadir+'201_RM_CO2_020.xlsx'
WIL_data=pd.read_excel(WIL_file)
WIL_workingtime=WIL_data.between_time('9:00','17:00')    
WIL_Average_day=pd.DataFrame(WIL_workingtime.resample('D').mean().RMT)
WIL_Average_hour=pd.DataFrame(WIL_workingtime.resample('H').mean().RMT)
WIL_CO2=pd.DataFrame(WIL_data.CO2)


for rmname in MeasuresWILCO2:
    WIL_file=WILdatadir+rmname+'.xlsx'
    WIL_data=pd.read_excel(WIL_file)
    WIL_workingtime=WIL_data.between_time('9:00','17:00')
 
    WIL_Average_day[rmname]=pd.DataFrame(WIL_workingtime.resample('D').mean().RMT)
    WIL_Average_hour[rmname]=pd.DataFrame(WIL_data.resample('H').mean().RMT)
    WIL_CO2[rmname]=pd.DataFrame(WIL_data.CO2)

WIL_CO2.columns = ['CO2', '201', '202','204','205','301','304','402','403','604']
del WIL_CO2['CO2']
CO2Dir=WILdatadir+'WILCO2.csv'
WIL_CO2.to_csv(CO2Dir)


# In[22]:

# Ploting Room temperature

fig=plt.figure(figsize=(15,5))


for rmname in MeasuresWILCO2:
    
    RMtemp=WIL_Average_hour[rmname]
    lgendname=rmname[:3]
    if lgendname=='201':
        plt.plot(RMtemp, label=lgendname, color='k' )
    elif lgendname=='304':
        plt.plot(RMtemp, label=lgendname, color='blue')
    else:
        plt.plot(RMtemp, label=lgendname,linestyle='--')
    
legend = plt.legend(loc='upper center', ncol=5, fontsize=12)
plt.ylim((40,100))
pdname='Results/Plots/RMTEMP/RoomTemperatureCompare.pdf'

plt.xlabel('Date')
plt.ylabel('Temperature, $^\circ$F')

fig.savefig(pdname,bbox_inches='tight')  
plt.show()



# In[89]:

# Conbining all the rooms for each room 

datadir='Results\SystemOnOff\School_007_RLT/'

school_file=datadir+'Ralston_CO2_Room_12.xlsx'
school_all=pd.read_excel(school_file)
school_all['Date and time']=school_all.index


for rmname in RLT_CO2:

    #RMID=RIO_room.index(rmname)
    #sensorname=RIO_Dsensor[RMID]
    
    school_file=datadir+rmname+'.xlsx'
    
    print school_file
    RM_data=pd.read_excel(school_file)
    school_all=school_all.append(RM_data)
    
    school_all['DayWeek']=school_all.index.weekday



# selecting weekday data
weekday=school_all[(school_all['DayWeek']<5)]

Dir=datadir+'RLT_weekday.xlsx'
weekday.to_excel(Dir)

weekend=school_all[(school_all['DayWeek']==5)|(school_all['DayWeek']==6)]
Dir=datadir+'RLT_weekend.xlsx'
weekend.to_excel(Dir)

