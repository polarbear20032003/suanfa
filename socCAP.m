Files = [20180607]; 
		%, 201705, 201707，因为这两个月的数据没有生成，所以去除了这两个月的数据

Output=[];
		%, 201705, 201707，因为这两个月的数据没有生成，所以去除了这两个月的数据

for fileidx=1:1
	InputFilename=strcat('线上数据评估/亦庄事故车计算后-', num2str(Files(fileidx)), 'X.xlsx')
	DataInput1=xlsread(InputFilename,'Sheet2');
	DataInput2=xlsread(InputFilename,'Sheet3');
	for i=1:size(DataInput1,1)
		if DataInput1(i,7)>-100 && DataInput1(i,7)<-5 
            Output=[Output;[DataInput1(i,8),DataInput1(i,9),DataInput1(i,10),DataInput2(:,i+1)']];
		end
	end
end
[m,n]=size(Output); 
output2=[]
S=96
diffVTemp=0.005*S;
for i = 1:m
soccap=sum(Output(i,4:n))*100*diffVTemp/Output(i,3);
output2=[output2,[soccap]]
end
OutputFilename='线上数据评估/亦庄事故车-SOC计算后-ALL.xlsx';
xlswrite(OutputFilename,output2);

