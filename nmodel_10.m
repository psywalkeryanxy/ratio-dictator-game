% Dictator game
% modeling

function result = nmodel_10(bootData)

nLoops = 1; %number of random starts
bestRsq = 0;

for i = 1:nLoops
%     disp(i)    
% random starts for parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rho = rand(1);
sigma = rand(1);
lambda = rand(1);
inx0 = [rho sigma lambda];


try

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lb = [0,0,0];
ub = [1,1,inf];
[b, fval] = fmincon(@DG_m2,inx0,[],[],[],[],lb ,ub ,[], optimset('Algorithm', 'interior-point'),bootData);
[loglike, prob_chosen] = DG_m2(b, bootData);

params = b;
modelLL = -loglike;      %loglikelihood here should be negative for model
randp=1./bootData(:,3);
nullLL=nansum(log(randp));
pseudoR2 = 1 -  modelLL/nullLL; %0 to 1 
% nullLL = log(0.5)*length(bootData'); %null model
% pseudoR2 = 1 -  nullLL/ modelLL; %0 to 1 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mon_s = bootData(:,6) .* bootData(:,4);	% possible payoff for self
% Mon_o = (bootData(:,3) - bootData(:,6)) .* bootData(:,5);	% possible payoff for other
bic = 2*loglike + 3*log(length(bootData')) ;
result.thisloglike(i) = loglike;

catch           % returns the last error message generated by MATLAB
lasterr
end;

% if pseudoR2 > bestRsq
    bestRsq = pseudoR2;
    result.params = b;
    result.pseudoR2 = pseudoR2;
    result.loglike = loglike;
    result.bic = bic;
% else
% end

end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [loglike, prob_chosen] = DG_m2(q0,bootData)
rho = q0(1);
sigma = q0(2);
lambda = q0(3);

for t=1:size(bootData,1)

Ts = 0:bootData(t,3); 	% possibel choices for self
Ms = Ts * bootData(t,4);	% possible payoff for self
Mo = (bootData(t,3) - Ts) * bootData(t,5);	% possible payoff for other

U =(1-rho)*Ms+rho*(sigma*min(Ms,Mo)+(1-sigma)*(Ms+Mo));

prob = exp(lambda * U) / nansum(exp(lambda * U));
prob_chosen(t,1) = prob(bootData(t,6)+1);
end

loglike = -nansum(log(prob_chosen));

end

