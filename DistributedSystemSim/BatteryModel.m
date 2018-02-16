%  Xiwang Li Battery model
% 07/01/15


classdef BatteryModel < handle
    %% Class to perform operations on a battery instance
    % Battery objects should remain consistent through development while
    % this can be updated as the battery model gets more detailed, this
    % shoudl allow code written to access the Battery class to be
    % independent of the Battery Model so that it doesn't break even when
    % the model is updated

    properties
       % We'll initialize all the set values for the battery model,
        % this allows us to change them, then create a new handle to a
        % new battery model. The Battery object that the model is
        % modified by will not be modified by changes to the Battery
        % Model, only during operation will there be a difference.
        expectedCycles = 3000;
        ratedCapacity = 40; % Ah
        
        
        bottomV = 1.05;
        topV = 1.65;
        initV = 1.65;
        
        powerTolerance = 0.02;
        ratedDischargeTime = 6; %hours
        ratedChargeTime
        
        
        % strings pointing to the csv files saved by writetable storing the cleaned data for each part of the discharge data
        dischargeDataFile = 'dischargeData.csv';
        chargeCCDataFile = 'chargeCCData.csv';
        chargeCVDataFile = 'chargeCVData.csv';
        restDataFile
        
        % scatteredInterpolant object that acts as function to calculate Voltage from inputs V = dischargeV({rate,SOD,temperature})
        dischargeV 
        chargeV_CC
        chargeV_CV
        restV 
        
        
        chargeCCCurrent = -2.6677;
        chargeCCRate
        internalTimeStep = 1/60; % 1 minute in hours

        inverterEfficiency
        mode  = 'interp';
        
    end
    methods 
        %% Initialize a BatteryModel 
        function BM = BatteryModel(mode)
         
            
            
            %these may eventually be updated with curves or something like
            %it
            
            BM.inverterEfficiency = 0.96;
            if nargin >0
                BM.mode =mode;
            end
            
            
            %these have been updated with curves, in fact, they are
            %functions derived from the curves using the
            %scatteredInterpolant class 
            if strcmp(BM.mode,'nn')
                BM.dischargeV =MapNNtoInterp;
                
            elseif strcmp(BM.mode,'interp')
                BM.dischargeV = makeInterpolant(BM.dischargeDataFile,BM.ratedCapacity,BM.ratedDischargeTime);
                BM.chargeV_CC = makeCCChargeInterpolant(BM.chargeCCDataFile,BM.ratedCapacity,BM.ratedDischargeTime);
                BM.chargeV_CV = makeCVChargeInterpolant(BM.chargeCVDataFile,BM.ratedCapacity,BM.ratedDischargeTime);
            end
            BM.chargeCCRate = BM.chargeCCCurrent*BM.ratedDischargeTime/BM.ratedCapacity;
            
        end
        
        %% Initialize a new Battery Object that uses this Battery Model
        function B = initializeBattery(BM,B)
            %takes a  Battery Object with ratedEnergy, maxChargePower &
            %maxDischargePower set  and initializes the unset properties
            %that need initialization
            B.requestedPower = 0;
            B.batteryRate = 0;
            B.batteryVoltage = BM.initV;
            B.temperature = 293.15;
            B.batteryPower = 0;
            B.totalTime = 0;
            B.saveTime = 0;
            B.remainingEnergy = B.ratedEnergy;
            B.SOD = 0;
            B.SOH = BM.initializeSOH(B);
            B.batteryHistory = BatteryHistory(B);
            B.batteryStatus = 'initialized';
            
            
            
        end
        
        function SOH = initializeSOH(BM,B)
            SOH = 1;
        end
        
        
        %% Main Work of the Battery Model - simulates next timestep
        function B = simulateNext(BM,B)
            oldB = B; % save the oldB in case the simulation fails, we'll return B to its previous state, also for comparison if succeeds
            dT = B.deltaTime/(60*60); %convert the external timestep (in seconds) to hours
            ratedPower = B.ratedEnergy/BM.ratedDischargeTime; %Wh/h = W;
            tooLow = false;
            try
 
                if B.requestedPower >= 0 %Discharge
                    
                   [B] = BM.discharge(B,dT,ratedPower);
                elseif B.requestedPower < 0 %Charge
                    [B] = BM.charge(B,dT,ratedPower);
                    
                end
                if B.requestedPower == 0 %Rest
                end
                
                
                
                if B.save
                    B.batteryHistory.writeHistory(B);
                    B.saveTime = B.totalTime;
                end
                B.simulationFinished = true;
                B.batteryStatus = 'OK';
                
                return
            catch err
                rethrow(err);
                B.simulationFinished = true;
                oldB.batteryStatus = err;
                B = oldB;
                return
            end
            
           
        end
        
        %SUBFUNCTIONS
        
        function [B] = discharge (BM,B,dT,ratedPower)
            B.initChargeSOD = [0,0];%reset init SODs
            dcRequestedPower = B.requestedPower/BM.inverterEfficiency;    
            
            normRequestedPower = dcRequestedPower/ratedPower; %normalized requested power as a fraction of ratedPower and the total capacity

            rate = normRequestedPower/B.batteryVoltage;
            count = 0;
            if B.SOD < 0.001
                B.SOD = 0.001;
            end
            V = B.batteryVoltage;
            %% Loop to establish starting voltage for the discharge (deals with large changes in power )
            while  (count < 1 || abs((rate*V - normRequestedPower)/normRequestedPower)>BM.powerTolerance) && count < 100
                V = BM.dischargeV({rate,B.SOD,B.temperature});
                if isnan(V)
                    %EXCEPTION!%
                end
                rate = normRequestedPower/V;
                count = count +1;
            end
            B.batteryRate = rate;
            B.batteryVoltage = V; 


            internalPeriod =0;
            while BM.internalTimeStep*internalPeriod < dT
                count = 0; %reset Count 
                rate = normRequestedPower/B.batteryVoltage;

                while (count < 1 || abs((averageRate*V - normRequestedPower)/normRequestedPower)>BM.powerTolerance) && count <100
                    if count ==0
                        averageRate = (B.batteryRate + rate)/2;
                    end
                    SOD = B.SOD + (averageRate * BM.internalTimeStep)/BM.ratedDischargeTime/B.SOH;
                    V = BM.dischargeV({rate,SOD,B.temperature});
                    if isnan(V)
                        %EXCEPTION!%
                    end
                    rate = normRequestedPower/V;
                    averageRate = (B.batteryRate + rate)/2;
                    count = count +1;
                end
                B.batteryVoltage = V;
                B.batteryRate = rate;
                B.SOD = SOD;
                internalPeriod = internalPeriod + 1;
            end 
            normBatteryPower = B.batteryRate*B.batteryVoltage;
            dcBatteryPower = normBatteryPower*ratedPower;
            B.batteryPower = dcBatteryPower*BM.inverterEfficiency;
            B.remainingEnergy = B.remainingEnergy - B.batteryPower*dT/B.SOH;
            B.totalTime = B.totalTime + B.deltaTime;
        end
        
        function [B] = charge(BM,B,dT,ratedPower)
            dcRequestedPower = B.requestedPower*BM.inverterEfficiency;    %for charge we multiply
            normRequestedPower = dcRequestedPower/ratedPower; %normalized requested power as a fraction of ratedPower and the total capacity
           
            rate = BM.chargeCCRate;
            count = 0;
            
            internalPeriod=0;
            while BM.internalTimeStep*internalPeriod < dT
                if B.SOD <0
                    B.batteryRate = 0;
                    return
                end
                if B.batteryVoltage < 1.649 %CC Charge 
                    B.batteryRate = BM.chargeCCRate;
                    if B.initChargeSOD(1) ==0
                        B.initChargeSOD(1) =B.SOD;% set the initial SOD for this charge
                    end
                    
                    B.batteryVoltage = BM.chargeV_CC({B.initChargeSOD(1),B.SOD,B.temperature});
                     if isnan(B.batteryVoltage)
                        %EXCEPTION!%
                    end
                    B.SOD = B.SOD + (B.batteryRate * BM.internalTimeStep)/BM.ratedDischargeTime;
                    

                else 
                    B.batteryVoltage = 1.65;
                    
                    if B.initChargeSOD(2) ==0
                        B.initChargeSOD(2) =B.SOD;% set the initial SOD for this charge
                    end
                    B.batteryRate = BM.chargeV_CV({B.initChargeSOD(2),B.SOD,B.temperature});
                    B.SOD = B.SOD + (B.batteryRate * BM.internalTimeStep)/BM.ratedDischargeTime;
                end
                internalPeriod = internalPeriod + 1;
            end
            normBatteryPower = B.batteryRate*B.batteryVoltage;
            dcBatteryPower = normBatteryPower*ratedPower;
            B.batteryPower = dcBatteryPower/BM.inverterEfficiency;
            B.remainingEnergy = B.remainingEnergy - B.batteryPower*dT/B.SOH;
            B.totalTime = B.totalTime + B.deltaTime;
        end
        
        %% Prediction Functions 
        function dcurves = makeDischargeCurves(BM,B)
            P = B.maxDischargePower.*[1/5; 2/5;3/5;4/5;1];
            dcurves =[P,B.remainingEnergy*ones(5,1),100*ones(5,1)];
        end
        function ccurves = makeChargeCurves(BM,B)
            Wh = (B.ratedEnergy-B.remainingEnergy);
            id = [B.maxChargePower/2,Wh/(B.maxChargePower/2)*60*60,Wh,0,0,0];
            max = id.*2;
            max(3) = Wh;
            ccurves=[id;max];
        end
    end
        
        %% Static Methods For Use within class or otherwise
    methods (Static)
        
        
        
    end
        
   
    
    
end