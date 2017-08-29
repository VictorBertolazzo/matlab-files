function createFancyPlot(test,names,string,foe)
seq = cell(1,size(string,2));
for i=1:size(string,2)
st = char(string(1,i));
var=getfield(test,st);
seq(1,i) = {horzcat(test.Time(1:foe)',var(1:foe)')};
ind = find(ismember(names(:,1),st));
str(1,i) = names(ind,2);
end
plotTimeSeries(seq)
%ylabel(str_AccelPed_Frac_Cmd)
legend(str,'Location','Best')
end