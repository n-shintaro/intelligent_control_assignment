% multipeak.m

function f= multipeak(pop)%function 関数の定義(注意.関数名とファイル名は同じ)
%10×2の情報を10列のベクトルに変換
x=pop(:,1);
y=pop(:,2);
r=sqrt(x.^2+y.^2);
s=sqrt((x-0.5).^2+y.^2);
ss=sqrt((x-0.8).^2+y.^2);
f=exp(-2*r.^2)+2*exp(-1000*s.^2)+3*exp(-1000*ss.^2);%f: 適応度、右辺は適応度関数(評価関数)
