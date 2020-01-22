function y = testfft(x)

m = nextpow2(length(x));%��x���ȶ�Ӧ��2����ʹ���
N = 2^m;
if(length(x) < N)
	x = [x,zeros(1,length(x))];%FFT�㷨xn���в���
end

change = bin2dec(fliplr(dec2bin([1:N]-1,m))) + 1;%ʮ����ת2���ƣ����з�ת��֮����ת��ʮ���ƣ��൱�������������������
y = x(change);%y�ǰ������Ʒ�ת����xn��

for s = 1:m %m�λ�2�ֽ⣬��ÿ�ηֽ������㣨����˵�ֳ���m������
	Nr = 2^s; %ÿ�������е��кŲ�
	u = 1; %��ת����,��ʼΪWN^0����1
	WN = exp(-complex(0,1)*2*pi/Nr);%�ֽ�Ļ���DFT���ӣ�����������ɣ�

	for j = 1:Nr/2
		for k = j:Nr:N
			kp = k + Nr/2;
			g = y(kp) * u;
			y(kp) = y(k) - g;
			y(k) = y(k) + g;
		end
		u = u * WN;
	end
end
end
%p161 5.6ͼ�����˼·һ��