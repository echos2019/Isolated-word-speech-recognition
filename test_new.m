clc;
clear;
pathname=pwd;
selpath=sprintf('%s\\语音库_排序后\\测试',pathname);
testpath=sprintf('%s\\语音库_排序后\\模板',pathname);
loop=[65,96,96,47,96,96,96,96,96,96];
label_rect=zeros(96,10);
label_hann=zeros(96,10);
label_hamm=zeros(96,10);
label=zeros(96,10);
len=zeros(10,4);
template_rect=zeros(5000,10,4);
template_hann=zeros(5000,10,4);
template_hamm=zeros(5000,10,4);
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
acc_rect=zeros(10,1);
acc_hann=zeros(10,1);
acc_hamm=zeros(10,1);
acc=zeros(10,1);
for i=0:9
    for j=1:loop(i+1)
        data_rect=load(sprintf('%s\\rect\\%d.%d.mfcc.txt',selpath,i,j));
        data_hann=load(sprintf('%s\\hanning\\%d.%d.mfcc.txt',selpath,i,j));
        data_hamm=load(sprintf('%s\\hamming\\%d.%d.mfcc.txt',selpath,i,j));
        rect_tmplabel=zeros(4,1);
        hann_tmplabel=zeros(4,1);
        hamm_tmplabel=zeros(4,1);
        for l=1:4
            %%%%%%%%%%%%%%%
            for k=0:9
                %%%%%%%%%%%%%%%
                dist_rect(k+1) = dtw(reshape(data_rect,[length(data_rect)/12,12]),reshape(template_rect(1:len((k+1),l),k+1,l),[len((k+1),l)/12,12]));
                dist_hann(k+1) = dtw(reshape(data_hann,[length(data_hann)/12,12]),reshape(template_hann(1:len((k+1),l),k+1,l),[len((k+1),l)/12,12]));
                dist_hamm(k+1) = dtw(reshape(data_hamm,[length(data_hamm)/12,12]),reshape(template_hamm(1:len((k+1),l),k+1,l),[len((k+1),l)/12,12]));
             end
                %%%%%%%%%%%%%%%
                [~,rect_tmplabel(id)]=min(dist_rect);%matlab数组开头是1
                [~,hann_tmplabel(id)]=min(dist_hann);
                [~,hamm_tmplabel(id)]=min(dist_hamm);
                dist_rect=zeros(10,1);
                dist_hann=zeros(10,1);
                dist_hamm=zeros(10,1);
                id=id+1;%标记出第几个随机数模板
        end
        [label_rect(j,i+1),weight_rect]=mode(rect_tmplabel);%matlab数组开头是1
        [label_hamm(j,i+1),weight_hamm]=mode(hamm_tmplabel);
        [label_hann(j,i+1),weight_hann]=mode(hann_tmplabel);
        label_rect(j,i+1)=label_rect(j,i+1)-1;
        label_hamm(j,i+1)=label_hamm(j,i+1)-1;
        label_hann(j,i+1)=label_hann(j,i+1)-1;
        label(j,i+1)=mode([hann_tmplabel;hamm_tmplabel;rect_tmplabel])-1;
        id=1;
    end
    acc_rect(i+1)=sum(label_rect((1:(loop(i+1))),i+1)==i)/(loop(i+1));
    acc_hann(i+1)=sum(label_hann((1:(loop(i+1))),i+1)==i)/(loop(i+1));
    acc_hamm(i+1)=sum(label_hamm((1:(loop(i+1))),i+1)==i)/(loop(i+1));
    acc(i+1)=sum(label((1:(loop(i+1))),i+1)==i)/loop(i+1);
    fprintf('%d的正确率为\nrect hanning hamming 综合\n%.2f  %.2f    %.2f   %.2f \n',i,acc_rect(i+1),acc_hann(i+1),acc_hamm(i+1),acc(i+1));
end