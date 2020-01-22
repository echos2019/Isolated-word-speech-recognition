function Dist=dtw(r,t)%要开启画图功能，添加pflag参数
%保证给的矩阵中列数一致
[row1,M]=size(r); 
[row2,N]=size(t); 
if(M~=N)
    fprintf('矩阵维度不一致');
end
d=zeros(row1,row2);
for i=1:row1
    for j=1:row2
        tmp_r=r(i,:);
        tmp_t=t(j,:);
        d(i,j)=norm(tmp_r-tmp_t);
    end
end
D=zeros(size(d));
D(1,1)=d(1,1);
for m=2:row1
    D(m,1)=d(m,1)+D(m-1,1);
end
for n=2:row2
    D(1,n)=d(1,n)+D(1,n-1);
end
for m=2:row1
    for n=2:row2
        D(m,n)=d(m,n)+min(D(m-1,n),min(D(m-1,n-1),D(m,n-1))); 
    end
end 
Dist=D(row1,row2);
end