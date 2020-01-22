clc;
clear;
disp('准备好录音后请按下任意键');
pause();
disp('请说话');
samplerate=44100;
rec=audiorecorder(samplerate,16,1);
recordblocking(rec, 2);
disp('stop');
data=getaudiodata(rec);
pathname=sprintf('C:\\Users\\%s\\Desktop\\MobaXterm_Portable_v11.1',getenv('username'));
a=[1 -0.97];
b=[1];%预加重滤波器为1-0.97*Z^(-1)
[start_point,end_point]=vad(data);
data=data(start_point:end_point,1);
length_data=length(data);
data=interp1(linspace(1,samplerate,length_data),data,1:samplerate,'linear')';%%插值操作时
m=sqrt(sum(data.^2));
data=10*data./m;%能量归一化
data=filter(b,a,data);%预加重
framelen=512;%matlab切片前后都算
frameint=218;%帧移
len=0;
start=1;
while(start+framelen<length(data))
        start=start+frameint;
        len=len+1;
end%计算帧数
start=1;
num=24;%Mel滤波器组数
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
fid = fopen(sprintf('%s\\rect_mfcc.txt',pathname),'w');
fprintf(fid,'%.8f ',reshape(data_rect,[len*12,1]));
fclose(fid);

fid = fopen(sprintf('%s\\hanning_mfcc.txt',pathname),'w');
fprintf(fid,'%.8f ',reshape(data_hann,[len*12,1]));
fclose(fid);

fid = fopen(sprintf('%s\\hamming_mfcc.txt',pathname),'w');
fprintf(fid,'%.8f ',reshape(data_hamm,[len*12,1]));
fclose(fid);