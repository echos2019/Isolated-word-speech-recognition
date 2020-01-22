function y = testfft(x)

m = nextpow2(length(x));%求x长度对应的2的最低次幂
N = 2^m;
if(length(x) < N)
	x = [x,zeros(1,length(x))];%FFT算法xn序列补零
end

change = bin2dec(fliplr(dec2bin([1:N]-1,m))) + 1;%十进制转2进制，进行反转，之后再转回十进制，相当于是做了数组索引编号
y = x(change);%y是按二进制反转过的xn了

for s = 1:m %m次基2分解，对每次分解做运算（就是说分成了m个级）
	Nr = 2^s; %每个蝶形中的行号差
	u = 1; %旋转因子,初始为WN^0等于1
	WN = exp(-complex(0,1)*2*pi/Nr);%分解的基本DFT因子（各级可以想成）

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
%p161 5.6图和这个思路一致