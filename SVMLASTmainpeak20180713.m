clc;
clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TempFilename='线上数据评估/EC180-孚能科技-32-标准.xlsx';
data2=xlsread(TempFilename);
InputFilename='线上数据评估/出厂-dq-ALL.xlsx';
InputFilename2='线上数据评估/出厂-dSOC-ALL.xlsx';
ALLInput2=xlsread(InputFilename2)
%ALLInput2=xlsread(InputFilename);
ALLInput=xlsread(InputFilename)
e=data2(1,:);
h=smooth(e,3,'lowess');
plot(h);
TempInput=h'
OUTPUT=[];
[m,n]=size(ALLInput); 
maxVTemp=130;
minVTemp=100;
diffVTemp=0.5;
%diffVTemp=1;
Vtemp=minVTemp:diffVTemp:maxVTemp;
[pks,locs,w,p] =findpeaks(TempInput);
FMZHI = [20,29];%标准数据峰值
for i = 1:m
     for j=1:n
         t=1
        if ALLInput(i,j)>0 && ALLInput(i,j+1)==0
            ALLInput(i,j)=0
        end
         if ALLInput(i,j)>0 && ALLInput(i,j-1)==0
             chaB(t)=j
         end
     end
     ALLInput(i,chaB(1))=0
  TMLCD = find(ALLInput(i,:) ~= 0);%数据计算峰值
  [~,flag]=max(ALLInput(i,:))
  %[~,flag]  = max(ALLInput(i,TMLCD(1):TMLCD(end)));
  %value = TMLCD(1) + flag;
  
  flag1 = flag - FMZHI(1);
  flag2 = flag - FMZHI(2);
  %flag1 = value - FMZHI(1);%计算偏移量； 
  %flag2 = value - FMZHI(2);
  
  %y = ALLInput(i,value-5:value+4)';
   y = ALLInput(i,flag-5:flag+4)';
  
  x1 = TempInput(FMZHI(1)-5:FMZHI(1)+4);
  x2 = TempInput(FMZHI(2)-5:FMZHI(2)+4);

  
  PS(1) = abs(corr(x1',y,'type','pearson'));
  PS(2) = abs(corr(x2',y,'type','pearson'));
 
  
  if(flag1 < 0)%偏移量大于0；
      PS(1) = 0;
  end
  if(flag2 < 0)
      PS(2) = 0;
  end
 
   [Pearson(i),state] = max(PS);%根据相关系数选择
   if( state == 1)
      KE = mean((x1/y'));
     ALLInput(i,1:flag1-1) = ones(flag1-1,1)' * TempInput(1);
      a=flag1
   end
  
   if( state == 2)
      KE = mean((x2/y'));
      ALLInput(i,1:flag2-1) = ones(flag2-1,1)' * TempInput(1);
      a=flag2
   end
   
     c=[flag1,flag2];
     a=min(c)
  %if a<0
     % c=[flag1,flag2];
      %s=abs(c);
      %a=min(s);
  %end
  if a>10 
      c=[flag1,flag2];
      s=abs(c);
      a=min(s);
  end
  if a>20 ;
      a=0;
  end
         r=[]
        if a<0
          for j=FMZHI(2)-a-5:n
                if TempInput(1,j)>0 && ALLInput(i,j+a)>0
                    r=[r,ALLInput(i,j+a)/TempInput(1,j)];
                end 
          end
        else
            for j=FMZHI(2)-5:n-a
               if TempInput(1,j)>0 && ALLInput(i,j+a)>0
                    r=[r,ALLInput(i,j+a)/TempInput(1,j)];
               end 
            end
         end
          rmax=max(r)
          rmin=min(r)
           %  end
       X=[Vtemp,Vtemp]';
       Y=zeros(length(X),1);
       if a<0
              for j=1:n+a
                 if ALLInput(i,j)==0;
                    Y(j)=rmax*TempInput(1,j-a);
                    Y(n+j)=rmin*TempInput(1,j-a);
                 else
                    Y(j)=ALLInput(i,j);
                    Y(n+j)=ALLInput(i,j);
                 end
              end
              for j=n+a:n
                 Y(j)=0;
                    Y(n+j)=0;
              end
       else
           for j=1+a:n
                if ALLInput(i,j)==0;
                    Y(j)=rmax*TempInput(1,j-a);
                    Y(n+j)=rmin*TempInput(1,j-a);
                 else
                    Y(j)=ALLInput(i,j);
                    Y(n+j)=ALLInput(i,j);
                 end
           end
            for j=1:1+a
                 Y(j)=0;
                    Y(n+j)=0;
            end
              %for j=n-a:n
                 % Y(j)=ALLInput(i,1);
            %  end   
       end
        type='function estimation';
       [Yp,alpha,b,gam,sig2,model] =lssvm(X,Y,type);                                                                                                                                   
        Xt = Vtemp';
        Yt = simlssvm({X,Y,type,gam,sig2,'RBF_kernel'},{alpha,b},Xt);
           for j=1:n
               if ALLInput(i,j)==0 && TempInput(1,j)>0
                 Yt2(j)= Yt(j)
               else
                 Yt2(j)=ALLInput(i,j);
               end   
           end
        ICA=Yt2;
        cc=ICA
         f= smooth(cc,3,'lowess'); 
         ICA2=f'
        Cap=sum(ICA2)*diffVTemp;
        CAPSOC=sum(ALLInput2(i,4:n))*100*diffVTemp/ALLInput2(i,3);
        %OUTPUT=[OUTPUT;[ALLInput2(i,1:4),Cap,ICA]];
        OUTPUT=[OUTPUT;[CAPSOC,Cap,ICA2]];
end
OutputFilename='线上数据评估/出厂-lvbo-output2.xlsx';
xlswrite(OutputFilename,OUTPUT);


