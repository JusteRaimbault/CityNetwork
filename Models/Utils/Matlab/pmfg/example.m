% example of construction and visualization of a PMFG

% -1- 
% load data for correlation marix and labels for the 100 stock studied in 
% M. Tumminello, T. Aste, T. Di Matteo, R.N. Mantegna, 
% A tool for filtering information in complex systems, 
% Proceedings of the National Academy of Sciences of the United States 
% of America (PNAS) 102 (2005) 10421-10426. 
load('100Stocks.mat') 

% -2-
% computes the PMFG
% "matlab_bgl" package from 
%  http://www.mathworks.com/matlabcentral/fileexchange/10922
% must be installed and in the path
PMFG = pmfg(r); % r is the correlation matrix

% -3-
% plot the rsult in 2D
[xy]=drawPMFG2(PMFG,labels);

% -4-
% plot the rsult in 3D
[xyz]=drawPMFG3(PMFG,labels);