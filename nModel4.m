% Dictator game
% Step 2
clear 
condition={'allAOE'};
path=['D:\博士论文写作202107\1大论文中\RESULTS\6_rDG_modeling_AOE\'];
 
for con=1
clearvars -except condition path con
load([path,condition{con},'_data.mat']);
sum=[90,90,100,100,80,80,75,75,60,60,60,40,40,200,150,150,120,120,120,100]' ;
mul = [1,3;3,1;1,3;3,1;3,1;1,3;2,1;1,2;1,1;2,1;1,2;3,1;1,3;1,1;2,1;1,2;1,2;1,1;2,1;1,1];

ms=data_ot(:,[2:2:40]);
subjects =data_ot(:,1);
%fill for blank
for sub=1:size(ms,1)
   clearvars pos i
   pos=find(isnan(ms(sub,:))==1);
   for i=1:length(pos)
   clearvars type 
    type=find((mul(:,1)==mul(pos(i),1) & mul(:,2)==mul(pos(i),2))==1);
    ms(sub,pos(i))=sum(pos(i))*nanmean(ms(sub,type)./sum(type)');
   end
end
ms=round(ms);
%change the format for model 
data_all=[];
for sub=1:size(ms,1)
data=[];
data(:,1)=repmat(subjects(sub,1),20,1);
data(:,2)=repmat(1,20,1);
data(:,[3:5])=[sum,mul];
data(:,6)=ms(sub,:)';
data_all=[data_all;data];
end
% bootstrap
nboot = 200;
[bootstat,bootsam] = bootstrp(nboot,@mean,subjects);
results = [];
for n = 1:nboot    
bootSubjects =  subjects(bootsam(:,n));  
% for model input
for k=1:size(bootSubjects,1)
bootData(k*20-19:k*20,:) = data_all(find(data_all(:,1)==bootSubjects(k,1)),:);
end
result = nmodel_4(bootData);
results_ot.params(n,1:4) =  [n, 0, result.params]; 
results_ot.confirm(n,1:5) =  [n, 1, result.pseudoR2,result.loglike,result.bic]; 
display(n)
end
save([path,'nmodel_thesis_4_ot_',condition{con}],'results_ot');
end

clear 
condition={'allAOE'};
path=['D:\博士论文写作202107\1大论文中\RESULTS\6_rDG_modeling_AOE\'];
 
for con=1
%  for con=1:length(condition)
clearvars -except condition path con
load([path,condition{con},'_data.mat']);
% if con==3
% data_ot=data_C;
% data_pl=data_M;
% end
sum=[90,90,100,100,80,80,75,75,60,60,60,40,40,200,150,150,120,120,120,100]' ;
mul = [1,3;3,1;1,3;3,1;3,1;1,3;2,1;1,2;1,1;2,1;1,2;3,1;1,3;1,1;2,1;1,2;1,2;1,1;2,1;1,1];

ms=data_pl(:,[2:2:40]);
subjects =data_pl(:,1);
%fill for blank
for sub=1:size(ms,1)
   clearvars pos i
   pos=find(isnan(ms(sub,:))==1);
   for i=1:length(pos)
   clearvars type 
    type=find((mul(:,1)==mul(pos(i),1) & mul(:,2)==mul(pos(i),2))==1);
    ms(sub,pos(i))=sum(pos(i))*nanmean(ms(sub,type)./sum(type)');
   end
end
ms=round(ms);
%change the format for model 
data_all=[];
for sub=1:size(ms,1)
data=[];
data(:,1)=repmat(subjects(sub,1),20,1);
data(:,2)=repmat(1,20,1);
data(:,[3:5])=[sum,mul];
data(:,6)=ms(sub,:)';
data_all=[data_all;data];
end
% bootstrap
nboot = 200;
[bootstat,bootsam] = bootstrp(nboot,@mean,subjects);
results = [];
for n = 1:nboot    
bootSubjects =  subjects(bootsam(:,n));  
% for model input
for k=1:size(bootSubjects,1)
bootData(k*20-19:k*20,:) = data_all(find(data_all(:,1)==bootSubjects(k,1)),:);
end
result = nmodel_4(bootData);
results_pl.params(n,1:4) =  [n, 0, result.params]; 
results_pl.confirm(n,1:5) =  [n, 1, result.pseudoR2,result.loglike,result.bic]; 
display(n)
end
save([path,'nmodel_thesis_4_pl_',condition{con}],'results_pl');
end