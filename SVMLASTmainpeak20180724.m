clc;
clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TempFilename='271��׼dqv.xlsx'; %��׼���ݵ���������
data2=xlsread(TempFilename);
InputFilename='output/LNBSCC3H8FF100293-dQ-ALL.xlsx';  %����������������
ALLInput2=xlsread(InputFilename);
[m1,n1]=size(ALLInput2); 
data1=ALLInput2(:,5:n1)
e=data2(1,:);
h=smooth(e,8,'lowess');
plot(h);
TempInput=h'
OUTPUT=[];
[m,n]=size(data1); 
S=96 % SΪ��ذ�����
maxVTemp=4.2*S; % ������﮵��Ϊ3.8�� ��Ԫ���Ϊ4.2
minVTemp=2.75*S; % ��﮵��Ϊ2.5����Ԫ���Ϊ2.8
diffVTemp=0.005*S
Vtemp=minVTemp:diffVTemp:maxVTemp;
[pks,locs,w,p] =findpeaks(TempInput);
FMZHI = [113,139];%��׼���ݴη�λ������λ
%��ѹ��ʼ��
Vb=109
ALLInput=[]
for i = 1:m
   c=data1(i,:);
   f= smooth(c,10,'lowess');
%plot(c);
%hold on; 
Input=f'
ALLInput=[ALLInput;Input];
end

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
  TMLCD = find(ALLInput(i,:) ~= 0);%���ݼ����ֵ
  [~,flag]=max(ALLInput(i,:))
  
  flag1 = flag - FMZHI(1);
  flag2 = flag - FMZHI(2);

   y = ALLInput(i,flag-5:flag+4)';
  
  x1 = TempInput(FMZHI(1)-5:FMZHI(1)+4);
  x2 = TempInput(FMZHI(2)-5:FMZHI(2)+4);


  PS(1) = abs(corr(x1',y,'type','pearson'));
  PS(2) = abs(corr(x2',y,'type','pearson'));
  
  if(flag1 < 0)%ƫ��������0��
      PS(1) = 0;
  end
  if(flag2 < 0)
      PS(2) = 0;
  end
 
   [Pearson(i),state] = max(PS);%�������ϵ��ѡ��
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

         r=[]
        if a<0
            c=corr(TempInput(1,n)',ALLInput(i,n+a)');
          for j=FMZHI(2)-a-5:n
                if TempInput(1,j)>0 && ALLInput(i,j+a)>0
                    r=[r,ALLInput(i,j+a)/TempInput(1,j)];
                end 
          end
        else
            c=corr(TempInput(1,n-a)',ALLInput(i,n)');
            for j=FMZHI(2)-a-5:n-a
               if TempInput(1,j)>0 && ALLInput(i,j+a)>0
                    r=[r,ALLInput(i,j+a)/TempInput(1,j)];
               end 
            end
         end
          rmax=max(r)
          rmin=min(r)
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
        for j=1:Vb
                Yt2(j)= 0
        end
           for j=Vb:n
               if ALLInput(i,j)==0 && TempInput(1,j)>0
                 Yt2(j)= Yt(j)
               else
                 Yt2(j)=ALLInput(i,j);
               end  
           end
        ICA2=Yt2;
        Cap=sum(ICA2)*diffVTemp;
        OUTPUT=[OUTPUT;[ALLInput2(i,1),Cap,ICA2]];
end
OutputFilename='output/LNBSCC3H8FF100293-Vb-lvbo-output.xlsx';
xlswrite(OutputFilename,OUTPUT);


