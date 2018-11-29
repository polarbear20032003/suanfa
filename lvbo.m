InputFilename='LNBSCC3H0FF100241-dQ-ALL.xlsx';  %带评估的容量曲线
ALLInput2=xlsread(InputFilename);
[m,n]=size(ALLInput2); 
data1=ALLInput2(:,5:n)
for i=1:m
    cc=data1(i,:)
    h=smooth( cc,8,'lowess');
   
