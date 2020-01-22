function [start,end_point] = vad(x)
%有静音测试的双门限法
%幅度归一化到[-1,1]
x = double(x);
x = x / max(abs(x));
%常数设置
FrameLen = 240;%帧长为240点
FrameInc = 80;%帧移为80点
amp1 = 10;%初始短时能量高门限%-----------------------------
amp2 =2;%初始短时能量低门限
% zcr1 = 10;%初始短时过零率高门限
zcr2 =2;%初始短时过零率低门限
maxsilence = 8;  % 8*10ms  = 80ms   语音段中允许的最大静音长度
minlen  =15;    % 15*10ms = 150ms  语音段的最短长度，若语音段长度小于此值，则认为其为一段噪音
status  = 0;     %初始状态为静音状态
count   = 0;     %初始语音段长度为0
silence = 0;     %初始静音段长度为0
%计算过零率
tmp1  = enframe(x(1:end-1), FrameLen, FrameInc);
tmp2  = enframe(x(2:end)  , FrameLen, FrameInc);
signs = (tmp1.*tmp2)<0;
diffs = (tmp1 -tmp2)>0.02;
zcr   = sum(signs.*diffs, 2);
%计算短时能量
amp = sum(abs(enframe(x, FrameLen, FrameInc)), 2);
%调整能量门限
amp1 = min(amp1, max(amp)/2);%-------------------------------
amp2 = min(amp2, max(amp)/8);
subplot(311)    %subplot(3,1,1)表示将图排成3行1列，最后的一个1表示下面要画第1幅图
plot(x)
axis([1 length(x) -1 1])    
ylabel('Speech');
subplot(312)   
plot(amp);
axis([1 length(amp) 0 max(amp)])
ylabel('Energy');
subplot(313)
plot(zcr);
axis([1 length(zcr) 0 max(zcr)])
ylabel('ZCR');
%开始端点检测
x1 = 0;
x2 = 0;
start=1;
end_point=length(x);
for n=1:length(zcr)
   switch status
   case {0,1}                   % 0 = 静音, 1 = 可能开始
      if amp(n) > amp1          % 确信进入语音段
         x1 = max(n-count-1,1);
         status  = 2;
         silence = 0;
         count   = count + 1;
      elseif amp(n) > amp2 || zcr(n) > zcr2 % 可能处于语音段
         status = 1;
         count  = count + 1;
      else                       % 静音状态
         status  = 0;
         count   = 0;
      end
   case 2                       % 2 = 语音段
      if amp(n) > amp2 ||  zcr(n) > zcr2% 保持在语音段
         count = count + 1;
      else                       % 语音将结束
         silence = silence+1;
         if silence < maxsilence % 静音还不够长，尚未结束
            count  = count + 1;
         elseif count < minlen   % 语音长度太短，认为是噪声
            status  = 0;
            silence = 0;
            count   = 0;
         else                    % 语音结束
              count = count-silence/2;
              x2 = x1 + count -1;
              %绘制语音信号端点
                subplot(311)  
                line([x1*FrameInc+FrameLen x1*FrameInc+FrameLen], [min(x),max(x)], 'Color', 'red');
                line([x2*FrameInc+FrameLen x2*FrameInc+FrameLen], [min(x),max(x)], 'Color', 'blue');
              
                subplot(312)  
                line([x1 x1], [min(amp),max(amp)], 'Color', 'red');
                line([x2 x2], [min(amp),max(amp)], 'Color', 'blue');

                subplot(313)  
                line([x1 x1], [min(zcr),max(zcr)], 'Color', 'red');
                line([x2 x2], [min(zcr),max(zcr)], 'Color', 'blue');
                start=x1*FrameInc;
                end_point=x2*FrameInc+FrameLen;
                status  = 0;
             break
         end
      end
   case 3
        break;
   end
end  
