classdef Battery
    %% Battery class, will add more comments with info, 
    % but can find more detailed descriptions in the Battery Module
    % Specifications Document- will update

    properties (Access = public)
        %% Needed to initialize
        % Handle to an instance of the BatteryModel class
        batteryModel 
        
        ratedEnergy
        maxChargePower
        maxDischargePower
        
        %% Inputs
        requestedPower
        temperature
        deltaTime
        simulationStatus
        save
        
        %% Optional inputs
        simulateDischargePowers
        
        
        %% Outputs/States
        batteryPower
        remainingEnergy % remaining energy at current power before hitting bottom Vlimit
        SOD
        SOH
        totalTime
        saveTime
        simulationFinished
        
        batteryStatus

        %% Internal states
        batteryRate
        batteryVoltage
        restInfo
        initChargeSOD=[0,0];%first is CC charge initSOD, second is CV charge init SOD
%         effectiveSOD % SOD modified for SOH etc. The normal SOD tracks only current in/out, this is a modified version used for calculation purposes
%         effectiveSOH % the SOH we'll use for calculations, might be different from SOH we report which will be linear and help us calculate this one...
%         
        %% Potentially Useful things for Debugging/Graphing
         batteryHistory %handle to the batteryHistory class which will track historical states of battery
         writeHistory = false; %only writes history if this is changed from its default value
        
    end

    properties (Dependent)
        %%  Outputs only calculated on get command
        dischargeCurves
        chargeCurves
    end
        
    
    methods
        
        %% Constructor for the Battery Class
        
        function B = Battery(batteryModel,ratedEnergy,maxChargePower,maxDischargePower)
            if nargin>0
                B.batteryModel = batteryModel;
                B.ratedEnergy=ratedEnergy;
                B.maxChargePower = maxChargePower;
                B.maxDischargePower = maxDischargePower;
                B = B.batteryModel.initializeBattery(B);
            end
        end
        
        %% Dependent Property Functions
        function dcurves = get.dischargeCurves(B)
            dcurves = B.batteryModel.makeDischargeCurves(B);
        end
        function B = set.dischargeCurves(B,~)
            error('You cannot set the dischargeCurves property');
        end
        function ccurves = get.chargeCurves(B)
            ccurves = B.batteryModel.makeChargeCurves(B);
        end
        function B = set.chargeCurves(B,~) %#ok<*INUSD>
            error('You cannot set the chargeCurves property');
        end
        
        %% Update Inputs and Run Simulation
        function B = updateRunSimulation(B,requestedPower,temperature,deltaTime,simulationStatus,Bsave)
            B.requestedPower = requestedPower;
            B.temperature = temperature;
            B.deltaTime = deltaTime;
            B.simulationStatus = simulationStatus;
            B.save = Bsave;
            B = B.runSimulation;
        end
        
        %% Run Simulation without Updating Inputs
        function B = runSimulation(B)
            B.simulationFinished = false;
            B = B.batteryModel.simulateNext(B);
        end
    end

    
    
end