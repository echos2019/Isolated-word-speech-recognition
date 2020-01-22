function mfcc_out=mfcc_cal(in,num,samplerate,n)
%inΪ�����֡,numΪ�˲���������samplerateΪ�����ʣ������ж������Ƶ��8000Hz�����Ƶ��300Hz,nΪmfcc����
%���Ϊmfccϵ��
fl=300;
fh=4000;
Mel_out=zeros(num,1);
len=length(in);
out=zeros(num,1);
Mel_out(1)=fl/samplerate*len;
Mel_out(len+2)=fh/samplerate*len;
for m=2:num+1
    Mel_out(m)=len/samplerate*700*(exp((mel(fl)+(m-1)*(mel(fh)-mel(fl))/(num+1))/1125)-1);
end
sum=0;
for i=1:num
    for j=1:len
        sum=sum+Mel_filter(Mel_out(i),Mel_out(i+1),Mel_out(i+2),j)*in(j);
    end
    out(i)=sum;
    sum=0;
end
mfcc_out=0;
for i=1:num
    mfcc_out=mfcc_out+log(out(i))*cos((pi*n*(2*i-1))/(2*num));
end
mfcc_out=mfcc_out*sqrt(2/num);
end
%%
function out=Mel_filter(fl,f,fh,k)
%�����Ӧ��melƵ�׵�ֵ
if(k<fl)
    out=0;
elseif(k>=fl&&k<f)
    out=(invMel(k)-invMel(fl))/(invMel(f)-invMel(fl));
elseif(k>=f&&k<fh)
    out=(invMel(fh)-invMel(f))/(invMel(fh)-invMel(f));
else
    out=0;
end
end
function out=invMel(f)
out=700*(exp(f/1125)-1);
end
function y=mel(x)
y=2595*log10(1+x/700);
end