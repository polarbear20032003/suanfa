clc;
clear;
Output1=[]
Output3=[]

	InputFilename='Inputdata1/LNBSCC3H8FF100293X.xlsx'
	DataInput1=xlsread(InputFilename,'Sheet2');
	DataInput2=xlsread(InputFilename,'Sheet3');
	for i=1:size(DataInput1,1)
             Output1=[Output1;[DataInput1(i,1),DataInput1(i,9),DataInput2(:,i+1)']]
		if  DataInput1(i,6)<-10 &&  DataInput1(i,7)<38  && DataInput1(i,9)>40
            Output3=[Output3;[DataInput1(i,1),DataInput1(i,7),DataInput1(i,9),DataInput1(i,12),DataInput2(:,i+1)']];
		end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Êä³ö
[m,n]=size(Output1); 
output2=[]
S=96
diffVTemp=0.005*S;
for i = 1:m
SOCcap=sum(Output1(i,3:n))*100*diffVTemp/Output1(i,2);
output2=[output2;[DataInput1(i,1),SOCcap,DataInput1(i,4),DataInput1(i,5),DataInput1(i,6),DataInput1(i,7),DataInput1(i,9),DataInput1(i,10),DataInput1(i,11),DataInput1(i,12)]]
end
OutputFilename='output/LNBSCC3H8FF100293-dQ-ALL.xlsx';
OutputFilename2='output/LNBSCC3H8FF100293-dSOC-ALL.xlsx'
xlswrite(OutputFilename,Output3);
xlswrite(OutputFilename2,output2);
