ncolumns=10;
str='\begin{tabular}{';
for ct=1:ncolumns+1
    str=[str,'|c'];
end
str=[str,'|}'];

ctexperiment=1;
ctexperiment2=1;
ctexperiment3=1;

for ctrows=1:ncolumns
    str=[str,'Solution number &'];
    for ct=1:ncolumns
        str=[str, num2str(ctexperiment),'&'];
        ctexperiment=ctexperiment+1;
    end
            str=[str,'\hline \\ '];
            str=[str,'\Q &'];
   for ct=1:ncolumns
        str=[str, num2str(-Q(ctexperiment2)),'&'];
         ctexperiment2=ctexperiment2+1;
   end
           str=[str,'\hline \\ '];
           str=[str,'\Qhat &'];
   for ct=1:ncolumns
        str=[str, num2str(-Q(ctexperiment3)/length(author)),'&'];
        ctexperiment3=ctexperiment3+1;
   end
            str=[str,'\hline \\ '];
end

str=[str,'\end{tabular}']
    