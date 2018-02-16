% Defining Tariff model
% Xiwang Li 07/11/2015


classdef Tariff
    %% Tariff Class For determining tariff charges

    
    properties (Access = public)
        %% Needed to initialize
        % Handle to an instance of the TariffModel class
        tariffModel 
        
        tariffName 
        
        
        billDates %OPTIONAL, datetime array of billing Dates, if not provided it will assume that bills reset every 30 days after the first time it's asked to simulate
        
        
        
        %% Inputs at Each Timestep
        buildingLoad % building Load in kW during the timestep
        dateTime % the date and time specified as a datetime array (Matlab's internal structure for storing dates)
        simulationStatus
        save
        weatherInputs
        
        %% Optional inputs
        predictedBaseLoad=0; %this doesn't do anything for now. Might use to normalize later.
        
        
        %% Outputs/States
        marginalPowerCost=0;
        marginalEnergyCost=0;
        
        dayPowerCost=0;
        dayEnergyCost=0;
        
        billPowerCost=0;
        billEnergyCost=0;
        billFixedCost=0;

        cumulativePowerCost =0;
        cumulativeEnergyCost=0;
        cumulativeFixedCost=0;
        cumulativeTotalCost=0;
        
        currentPowerCost %in $/kW 
        currentEnergyCost % in $/kWh
        
        tariffStatus
        totalTime=0; 
        saveTime=0;
       
        simulationFinished
        
       
        

        %% Internal states
        powerRows
        monthPowerRows
 
        billRows
        dayRows

        energyRows
        
        powerCosts
        energyCosts
        monthlyCosts
        
        previousLoad = 0;
        
        billingPeriod
        billingDay
        
        
        energyHistory
        
        kWhCost
        
        %% Potentially Useful things for Debugging/Graphing
         tariffHistory %handle to the tariffHistory class which will track historical states of the tariff
         writeHistory = false; %only writes history if this is changed from its default value
        
    end

    properties (Dependent)

    end
        
    
    methods
        
        %% Constructor for the Tariff Class
        
        function T = Tariff(tariffModel,tariffName,billDates)
            if nargin>0
                T.tariffModel = tariffModel;
                T.tariffName=tariffName;
                if nargin > 2
                    T.billDates = billDates;
                end
                T = T.tariffModel.initializeTariff(T);
            end
        end
        
        
        %% Update Inputs and Calculate Cost
        function T = updateCalculateCost(T,buildingLoad,dateTime,simulationStatus,Tsave)
            T.buildingLoad = buildingLoad;
            T.dateTime = dateTime;
            T.simulationStatus = simulationStatus;
            T.save = Tsave;
            T = T.calculateCost;
        end
        
        %% Run Simulation without Updating Inputs
        function T = calculateCost(T)
            T.simulationFinished = false;
            T = T.tariffModel.simulateNext(T);
        end
    end

    
    
end