% Dictator game
% modeling

function result = nmodel_1(bootData)    
% random starts for parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rho = rand(1);
sigma = -rand(1);
lambda = rand(1);
inx0 = [rho sigma lambda];
try
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lb = [-1, -1, 0];
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
bic = 2*loglike + 1*log(length(bootData')) + ...
    log(length(find( bootData(:,6).*bootData(:,4)>=((bootData(:,3)-bootData(:,6)).*bootData(:,5) ) )))+...
    log(length(find( bootData(:,6).*bootData(:,4)<((bootData(:,3)-bootData(:,6)).*bootData(:,5) ) )));

result.thisloglike = loglike;    
catch           % returns the last error message generated by MATLAB
lasterr
end;
result.params = b;
result.pseudoR2 = pseudoR2;
result.loglike = loglike;
result.bic = bic;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [loglike, prob_chosen] = DG_m2(q0,bootData)
rho = q0(1);
sigma = q0(2);
lambda = q0(3);

for t=1:size(bootData,1)
Ts = 0:bootData(t,3); 	% possible choices for self
Ms = Ts * bootData(t,4);	% possible payoff for self
Mo = (bootData(t,3) - Ts) * bootData(t,5);	% possible payoff for other
U =Ms - ((Ms>=Mo)*rho) .* (Ms-Mo) - ((Ms<Mo)*sigma) .* (Mo-Ms);

%  U = ((Ms>=Mo)*rho + (Ms<Mo)*sigma) .* Mo +  (1 - (Ms>=Mo)*rho - (Ms<Mo)*sigma) .* Ms;
prob = exp(lambda * U) / nansum(exp(lambda * U));
prob_chosen(t,1) = prob(bootData(t,6)+1);
end
loglike = -nansum(log(prob_chosen));
end
