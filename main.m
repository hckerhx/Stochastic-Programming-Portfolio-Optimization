<<<<<<< HEAD

clc
clear all
format long

% Program Start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Read input files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the stock weekly prices and factors weekly returns
adjClose = readtable('Project1_Data_adjClose.csv');
adjClose.Properties.RowNames = cellstr(datetime(adjClose.Date));
size_adjClose = size(adjClose);
adjClose = adjClose(:,2:size_adjClose(2));

% Load the factors for Fama French Model and Risk Free rate
factorRet = readtable('Project1_Data_FF_factors.csv'); 
factorRet.Properties.RowNames = cellstr(datetime(factorRet.Date));
size_factorRet = size(factorRet);
factorRet = factorRet(:,2:size_factorRet(2));

riskFree = factorRet(:,4);
factorRet = factorRet(:,1:3);

% Identify the tickers and the dates 
tickers = adjClose.Properties.VariableNames';
dates   = datetime(factorRet.Properties.RowNames);

% Calculate the stocks' weekly EXCESS returns
prices  = table2array(adjClose);
returns_raw = ( prices(2:end,:) - prices(1:end-1,:) ) ./ prices(1:end-1,:);
returns = returns_raw - ( diag( table2array(riskFree) ) * ones( size(returns_raw) ) );
returns = array2table(returns);
returns.Properties.VariableNames = tickers;
returns.Properties.RowNames = cellstr(datetime(factorRet.Properties.RowNames));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Define your initial parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start of in-sample calibration period 
calStart = datetime('2012-01-01');
calEnd   = calStart + calmonths(36) - days(1);

% Start of out-of-sample test period 
testStart = datetime('2015-01-01');
testEnd   = testStart + calmonths(6) - days(1);
       
% Number of investment periods (each investment period is 6 months long)
NoPeriods = 6;

% Initialize list of Functions
funNames  = {'optimal Value Srategy' 'Stochastic Programming'}; % WRITE THE NAME OF YOUR FUNCTION
NoMethods = length(funNames);

funList = {'op_Val_Srategy' '#######'};% WRITE THE NAME OF YOUR FUNCTION
funList = cellfun(@str2func, funList, 'UniformOutput', false);

% Maximum number of assets used
card = 12;

% Determine hyperparameters based on adjClose
[NoTotalDates, NoAssets] = size(adjClose);

% period returns and prices from 2012 Jan to 2014 Dec
periodReturns = table2array( returns( calStart <= dates & dates <= calEnd, :) );
lastYearReturns = periodReturns = table2array( returns( calStart+calmonths(24)-days(1) <= dates & dates <= calEnd, :) );

currentRiskFree = table2array( riskFree( ( calEnd - days(7) ) <= dates ... 
                                                & dates <= calEnd, :));
periodPrices = table2array( adjClose( calStart <= dates ... 
                                                & dates <= calEnd, :))'; 
                                            
% Data Mean
mu_entire_training = geomean(1+periodReturns, 1) - 1;
mu_last_year = geomean(1+lastYearReturns, 1) - 1;
                                 
% Data Variance
cov_entire_training = cov(periodReturns);
cov_last_Year = cov(lastYearReturns);


