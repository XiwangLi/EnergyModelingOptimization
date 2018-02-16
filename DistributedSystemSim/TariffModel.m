% Tariff model class
% Xiwang Li  7/11/2015

classdef TariffModel < handle
    %% Class to perform operations on a tariff instance
    % Tariff objects should remain consistent through development while
    % this can be updated as the tariff model gets more detailed, this
    % shoudl allow code written to access the Tariff class to be
    % independent of the Tariff Model so that it doesn't break even when
    % the model is updated

    properties
        % We'll initialize all the set values for the tariff model,
        % this allows us to change them, then create a new handle to a
        % new tariff model. The Tariff object that the model is
        % modified by will not be modified by changes to the Tariff
        % Model, only during operation will there be a difference.
        
        standardDuration = 15; %time in minutes that this is written for...probably not going to change this. 
        
        powerCostsFile = ['Tariff Module',filesep,'powerCosts.mat'];
        energyCostsFile
        fixedCostsFile
        
        powerCosts
        energyCosts
        fixedCosts
    end
    methods 
        %% Initialize a TariffModel 
        function TM = TariffModel()
            load(TM.powerCostsFile);
            pvars = {'costName','costUnits','peakPeriod','costType','utility','zone','riders','tension','costCategory'};
            TM.powerCosts = vars2cats(costs,pvars); % Converts variables in pvars to categorical variables
            
            
        end
        
        %% Initialize a new Tariff Object that uses this Tariff Model
        function T = initializeTariff(TM,T)
            %takes a  Tariff Object with ratedEnergy, maxChargePower &
            %maxDischargePower set  and initializes the unset properties
            %that need initialization
            T.buildingLoad=0;
            T.dateTime = datetime(); %
            T.simulationStatus;
            T.save=false;
            
                % assign values according to tariff from the master cost
                % tables stored in TM to the cost tables in T
            switch T.tariffName
                case 'ConEd_SC9_R3_ZJ_LT'
                    utility = 'ConEd';
                    schedule = 9;
                    rate = 3;
                    zone = 'J';
                    tension = 'LT';
                    T.powerCosts = TM.powerCosts((TM.powerCosts.utility ==utility & TM.powerCosts.schedule ==schedule & ...
                        TM.powerCosts.rate ==rate & TM.powerCosts.zone ==zone & TM.powerCosts.tension ==tension),:);
                    
                    T.dayRows = T.powerCosts.peakPeriod == 'day';
                    T.billRows = T.powerCosts.peakPeriod == 'bill';
                otherwise
                    error('Tariff Name not Recognized, please use a different tariff')
            end
            used = {'months','days','hours','cost','peakPeriod','maxPower','minPower','costType','peakThisDay','peakThisBill','peakOverall'};
            T.powerCosts = T.powerCosts(:,used);
            T.predictedBaseLoad=0;
            
            T.billingPeriod=0;
            
            T.totalTime=0;
            T.saveTime=0;
       
            T.simulationFinished=false;
           % T.tariffHistory = TariffHistory(T);
            T.tariffStatus ='initialized';
            
        end
        
        function T = simulateNext(TM,T)
            oldT = T; % set oldT equal to the previous T
            averageLoad = (T.previousLoad + T.buildingLoad)/2;%this isn't quite right, as it will make it so last month's load is measured (from 23:45  to 00:00), but should be close enough, only a problem in edge cases.
            
            %% Decide if new day etc
            if isempty(T.billDates) || T.dateTime > T.billDates(end)
                T.billDates = TM.makeBillDates(T.dateTime,12,T.billDates);
            end
            newDay = false;
            newBill =false;
            if T.dateTime.Hour == 0 && T.dateTime.Minute < TM.standardDuration
                %it's a new day!
                newDay = true;
                T.dayPowerCost=0;
                T.powerCosts.peakThisDay = zeros(size(T.powerCosts.peakThisDay));
                T.dayEnergyCost = 0;
                [T.kWhCost,T.energyHistory] = TM.getkWhCost(T.dateTime,T.weatherInputs);
                
                if T.billingPeriod == 0 || ~isbetween(T.dateTime,T.billDates(T.billingPeriod),T.billDates(T.billingPeriod+1)-caldays(1)) %checks whether current time is between billdates
                    newBill = true;
                    T.billPowerCost=0;
                    T.monthPowerRows = cellfun(@ismember,repmat(num2cell(T.dateTime.Month),size(T.powerCosts.months)),T.powerCosts.months);
                    T.billingPeriod = T.billingPeriod + 1;
                    T.powerCosts.peakThisBill = zeros(size(T.powerCosts.peakThisBill));
                    T.billEnergyCost=0;
                end
                T.powerRows = T.monthPowerRows & cellfun(@ismember,repmat(num2cell(day(T.dateTime,'dayofweek')),size(T.powerCosts.days)),T.powerCosts.days);
            end
            
                %% now we'll update the peaks for Power Costs
            if averageLoad > min(T.powerCosts.peakThisDay(T.powerRows))
                
                rows = T.powerRows & cellfun(@ismember,repmat(num2cell(T.dateTime.Hour),size(T.powerCosts.hours)),T.powerCosts.hours);
                rows = (rows & T.powerCosts.maxPower > averageLoad ...
                    &  T.powerCosts.minPower < averageLoad ...
                    &  T.powerCosts.peakThisDay < averageLoad);
            else
                rows = zeros(size(T.powerRows));
            end
            dayPeak = false;
            billPeak = false;
            if any(rows)
                dayPeak = true;
                T.powerCosts.peakThisDay(rows) = ones(size(T.powerCosts.peakThisDay(rows))).*averageLoad;
                rows = T.powerCosts.peakThisDay>T.powerCosts.peakThisBill;
                if any(rows)
                    billPeak = true;
                    T.powerCosts.peakThisBill(rows) = ones(size(T.powerCosts.peakThisBill(rows))).*averageLoad;
                    rows = T.powerCosts.peakThisBill > T.powerCosts.peakOverall;
                    if any(rows)
                        T.powerCosts.peakOverall(rows) = ones(size(T.powerCosts.peakOverall(rows))).*averageLoad;
                    end
                end
                
            end
                %% Now we need to do calculations on the peaks to get daily/billing cycle/cumulative power cost
            
            
            if ~dayPeak
                 T.dayPowerCost=oldT.dayPowerCost;
                 margDayPowerCost=0;
            else
                 T.dayPowerCost= sum(T.powerCosts.peakThisDay(T.dayRows).*T.powerCosts.cost(T.dayRows));
                if newDay
                    margDayPowerCost = T.dayPowerCost;
                else
                    margDayPowerCost = T.dayPowerCost - oldT.dayPowerCost;
                end
                
                
            end
            if billPeak
                if newBill
                    T.billPowerCost = sum(T.powerCosts.peakThisBill(T.billRows).*T.powerCosts.cost(T.billRows)) + T.dayPowerCost;
                    T.marginalPowerCost = T.billPowerCost;
                else
                    dayCost = oldT.billPowerCost-sum(oldT.powerCosts.peakThisBill(T.billRows).*oldT.powerCosts.cost(T.billRows)) + margDayPowerCost;
                    T.billPowerCost = sum(T.powerCosts.peakThisBill(T.billRows).*T.powerCosts.cost(T.billRows)) + dayCost;
                    T.marginalPowerCost = T.billPowerCost - oldT.billPowerCost;
                end
            else
                T.billPowerCost = T.billPowerCost + margDayPowerCost;
                T.marginalPowerCost = margDayPowerCost;
            end

            T.cumulativePowerCost = T.cumulativePowerCost + T.marginalPowerCost;
%debugging stuff 
            
            %            if billPeak && (T.dateTime.Month == 6  || T.dateTime.Month == 7)
%                
%                thing = T.billEnergyCost;
%                T.dateTime
%            end
            
            %% Now deal with Energy
            energyUsed = T.buildingLoad*TM.standardDuration./60;
            
            
            
            T.marginalEnergyCost  = T.kWhCost(T.dateTime.Hour+1) *energyUsed;
            T.dayEnergyCost = T.dayEnergyCost + T.marginalEnergyCost;
            T.billEnergyCost = T.billEnergyCost + T.marginalEnergyCost;
            T.cumulativeEnergyCost = T.cumulativeEnergyCost + T.marginalEnergyCost;
             T.cumulativeTotalCost = T.cumulativePowerCost + T.cumulativeFixedCost + T.cumulativeEnergyCost;
            
            T.previousLoad = T.buildingLoad;
            T.simulationFinished = true;
        end
        function [kWhCost,history] = getkWhCost(TM,dateTime,weather)
            %later we'll have a more difficult function, but for now, we'll
            %just use some values from the data we have and go from there,
            %this will be called and returned only once per day, at
            %beginning of day and will return a 24 x 1 array of hourly
            %prices, much like will happen when day ahead rates are
            %published. 
            kWhCost = [56.07,49.31,46.88,46.73,45.69,46.43,50.60,52.93,58.80,84,85.54,87.95,87,86.11,84.70,85,92.16,1,97.97,94.55,93,91.38,88.06,65.40]./1000;
            history = 8;%Just a placeholder
        end
        
        
    end  
    methods (Static)
        
        function billDates = makeBillDates(startDate,numbills,prevDates)
            startDate = dateshift(startDate,'start','day');
            if isempty(prevDates)
                prevDates = startDate;
            end
            billDates = [prevDates,prevDates(end)+calmonths(1:numbills)];
        end
    end
    
    
    
end