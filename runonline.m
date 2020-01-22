clc;
clear;
disp('׼����¼�����밴�������');
pause();
disp('��˵��');
samplerate=44100;
rec=audiorecorder(samplerate,16,1);
recordblocking(rec, 2);
disp('stop');
data=getaudiodata(rec);
loop=[65,96,96,47,96,96,96,96,96,96];
a=[1 -0.97];
b=[1];%Ԥ�����˲���Ϊ1-0.97*Z^(-1)
[start_point,end_point]=vad(data);
data=data(start_point:end_point,1);
pathname=pwd;
selpath=sprintf('%s\\������_�����\\����',pathname);
testpath=sprintf('%s\\������_�����\\ģ��',pathname);
m=sqrt(sum(data.^2));
data=10*data./m;%������һ��
data=filter(b,a,data);%Ԥ����
framelen=512;%matlab��Ƭǰ����
frameint=218;%֡��
len=0;
start=1;
while(start+framelen<length(data))
        start=start+frameint;
        len=len+1;
end%����֡��
start=1;
num=24;%Mel�˲�������
data_rect=zeros(len,12);
data_hamm=zeros(len,12);
data_hann=zeros(len,12);
fft_rect_tmp=zeros(len,1);
fft_hann_tmp=zeros(len,1);
fft_hamm_tmp=zeros(len,1);
for j=1:len
    frame=data(start:start+framelen-1);
    start=start+frameint;
    rect=frame.*rectwin(framelen);
    hann=frame.*hanning(framelen);
    hamm=frame.*hamming(framelen);
    fft_rect_tmp=abs(testfft(rect));
    fft_hann_tmp=abs(testfft(hann));
    fft_hamm_tmp=abs(testfft(hamm));
    fft_rect_tmp=fft_rect_tmp.^2;
    fft_hann_tmp=fft_hann_tmp.^2;
    fft_hamm_tmp=fft_hamm_tmp.^2;
    for k=1:12
    data_rect(j,k)=mfcc_cal(fft_rect_tmp,num,samplerate,k);
    data_hann(j,k)=mfcc_cal(fft_hann_tmp,num,samplerate,k);
    data_hamm(j,k)=mfcc_cal(fft_hamm_tmp,num,samplerate,k);
    end
end
len=zeros(10,4);
template_rect=zeros(1500,10,4);
template_hann=zeros(1500,10,4);
template_hamm=zeros(1500,10,4);
for i=0:9
    for j=1:4
        tmp=load(sprintf('%s\\rect\\%d\\%d.%d.mfcc.txt',testpath,j,i,j));
        len(i+1,j)=length(tmp);
        template_rect(1:len((i+1),j),i+1,j)=tmp;
        template_hann(1:len((i+1),j),i+1,j)=load(sprintf('%s\\hanning\\%d\\%d.%d.mfcc.txt',testpath,j,i,j));
        template_hamm(1:len((i+1),j),i+1,j)=load(sprintf('%s\\hamming\\%d\\%d.%d.mfcc.txt',testpath,j,i,j));
    end
end
id=1;
dist_rect=zeros(10,1);
dist_hann=zeros(10,1);
dist_hamm=zeros(10,1);
rect_tmplabel=zeros(4,1);
hann_tmplabel=zeros(4,1);
hamm_tmplabel=zeros(4,1);
for l=1:4
    %%%%%%%%%%%%%%%
    for k=0:9
        %%%%%%%%%%%%%%%
        dist_rect(k+1) = dtw(data_rect,reshape(template_rect(1:len((k+1),l),k+1,l),[len((k+1),l)/12,12]));
        dist_hann(k+1) = dtw(data_hann,reshape(template_hann(1:len((k+1),l),k+1,l),[len((k+1),l)/12,12]));
        dist_hamm(k+1) = dtw(data_hamm,reshape(template_hamm(1:len((k+1),l),k+1,l),[len((k+1),l)/12,12]));
     end
        %%%%%%%%%%%%%%%
        [~,rect_tmplabel(id)]=min(dist_rect);%matlab���鿪ͷ��1
        [~,hann_tmplabel(id)]=min(dist_hann);
        [~,hamm_tmplabel(id)]=min(dist_hamm);
        dist_rect=zeros(10,1);
        dist_hann=zeros(10,1);
        dist_hamm=zeros(10,1);
        id=id+1;%��ǳ��ڼ���ģ��
end
label=mode([hann_tmplabel;hamm_tmplabel;rect_tmplabel])-1;
id=1;
fprintf('ʶ��Ϊ��%d\n',label);