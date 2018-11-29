clc;
clear;
[ndata,text,alldata]=xlsread('../Inputdata1/LNBSCC3H8FF100293.xlsx','sheet1');

UDATE = text(:,1); %时间列，包含第一行的表头
n = length(UDATE);

dt=zeros(n-2,1);

for i=2:n-1    %用dt矩阵存储时间序列的前后两个时间的秒级差距

    value1 = UDATE(i);
    temptime= value1{1};

    detetimeTemp1 =temptime(1:23);

    value2 = UDATE(i+1);
    temptime= value2{1};

    detetimeTemp2 =temptime(1:23);

    dnb = datevec(detetimeTemp1);

    dna = datevec(detetimeTemp2);

    dt(i-1)=etime(dna,dnb);

end
SOC=ndata(:,1); %soc数据是第2列，不含表头，以此类推
V=ndata(:,2);
I=ndata(:,3);
VMAX=ndata(:,4);
VMIN=ndata(:,5);
TMAX=ndata(:,6);
TMIN=ndata(:,7);
ODO=ndata(:,8)
N=length(V);
Vd=VMAX-VMIN
Td=TMAX-TMIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 时间
dt=[dt;0]; %末尾增加一行0
% 更新充电标志位FLAG
FLAG=zeros(N,1);
ChargeNum=1;
if N>20
    i=1;
    while i<=N-20
        if I(i)<0 && I(i+1)<0 && I(i+2)<0 && I(i+3)<0 && I(i+4)<0 && ...
                I(i+5)<0 && I(i+6)<0 && I(i+7)<0 && I(i+8)<0 && I(i+9)<0 ...
                && I(i+10)<0 && I(i+11)<0 && I(i+12)<0 && I(i+13)<0 && I(i+14)<0 ...
                && I(i+15)<0 && I(i+16)<0 && I(i+17)<0 && I(i+18)<0 && I(i+19) && I(i+20)<0
            for j=i:N
                if I(j)<0
                    FLAG(j)=ChargeNum;
                else
                    ChargeNum=ChargeNum+1;
                    break;
                end
            end
            i=j;
        else
            i=i+1;
        end
    end
end
ChargeNum=max(FLAG);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 内阻R=|dV/dI|
dV=[diff(V);0];
dI=[diff(I);0];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 输出Sheet1
%tempDT=zeros(length(dt)+1,1);
OUTPUT1=[ndata,dt,FLAG,Vd,Td];
if ChargeNum==0
    OutputFilename=strcat('../Inputdata1/LNBSCC3H8FF100293XX2.xlsx');
else
OutputFilename='../Inputdata1/LNBSCC3H8FF100293X2.xlsx';
delete(OutputFilename);
xlswrite(OutputFilename,OUTPUT1,'Sheet1');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 输出Sheet2
% 输出：NUM; chaB; chaE; Tup; Tdown; Iavg; Vup; Vdown; pV; dQmax
NUM=1:ChargeNum;
NUM=NUM';
i=1;
j=1;
if FLAG(i)==NUM(j)
    chaB(j)=i;
end
for i=2:N-1
    if FLAG(i-1)==0 && FLAG(i)==NUM(j)
        chaB(j)=i;
    end
    if FLAG(i+1)==0 && FLAG(i)==NUM(j)
        chaE(j)=i;
        if j<ChargeNum
            j=j+1;
        end
    end
end
i=N;
if FLAG(i)==NUM(j)
    chaE(j)=i;
end
chaB=chaB';
chaE=chaE';
S=96;
maxVTemp=4.2*S;
minVTemp=2.75*S;
diffVTemp=0.005*S;
VTempOut=minVTemp:diffVTemp:maxVTemp;
VdQ=VTempOut';
for i=1:ChargeNum
    Tm(i)=max(TMAX(chaB(i):chaE(i)));
    Tmi(i)=min(TMAX(chaB(i):chaE(i)));
    Tup(i)=Tm(i)-Tmi(i);
    Tdown(i)=max(Td(chaB(i):chaE(i)));
    Iavg(i)=sum(I(chaB(i):chaE(i)).*dt(chaB(i):chaE(i)))...
        /sum(dt(chaB(i):chaE(i)));
    Vdmax(i)=max(Vd(chaB(i):chaE(i)));
    %Tdmax=max(Td(chaB(i):chaE(i)));
    %Vdavg(i)=mean(Vd(chaB(i):chaE(i))) 期望值
    Vdavg(i)=(sum(Vd(chaB(i):chaE(i))))/(length(Vd(chaB(i):chaE(i))))
    SOCb(i)=SOC(chaB(i))
    SOCE(i)=SOC(chaE(i))
    dSOC(i)=SOCE(i)-SOCb(i)
    ODOE(i)=ODO(chaB(i))
    Ts(i)=TMIN(chaB(i))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    VTemp=V(chaB(i):chaE(i));
    dQTemp=-I(chaB(i):chaE(i)).*dt(chaB(i):chaE(i))/3600;
    NTemp=length(VTemp);
    %MTemp=round((maxVTemp-minVTemp)/1+1);
    MTemp=round((maxVTemp-minVTemp)/diffVTemp+1);
    %MTemp=round((maxVTemp-minVTemp)/0.1+1);
    dQTempOut=zeros(1,MTemp);
    for j=1:NTemp
        k=round((VTemp(j)-minVTemp)/diffVTemp+1);
        dQTempOut(k)=dQTempOut(k)+dQTemp(j);
    end
    VdQ=[VdQ,dQTempOut'/diffVTemp];
end
Tup=Tup';
Tdown=Tdown';
Iavg=Iavg';
Date=UDATE(chaB);
SOCb=SOCb'
SOCE=SOCE'
Vdmax=Vdmax'
Vdavg=Vdavg'
dSOC=dSOC'
ODOE=ODOE'
Ts=Ts'
%OUTPUT2=[NUM,Date,chaB,chaE,Tup,Tdown,Tdmax,Iavg,SOCb,SOCE,dSOC,Vdmax,Vdavg,ODOB];
OUTPUT2=[NUM,chaB,chaE,Tup,Tdown,Iavg,SOCb,SOCE,dSOC,Vdmax,Ts,ODOE]; %Tup温升 Tdown 最大温差，Ts 充电起始温度
xlswrite(OutputFilename,OUTPUT2,'Sheet2');
OUTPUT3=VdQ;
xlswrite(OutputFilename,OUTPUT3,'Sheet3');
