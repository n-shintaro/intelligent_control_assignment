% multipeak.m

function f= multipeak(pop)%function �֐��̒�`(����.�֐����ƃt�@�C�����͓���)
%10�~2�̏���10��̃x�N�g���ɕϊ�
x=pop(:,1);
y=pop(:,2);
r=sqrt(x.^2+y.^2);
s=sqrt((x-0.5).^2+y.^2);
ss=sqrt((x-0.8).^2+y.^2);
f=exp(-2*r.^2)+2*exp(-1000*s.^2)+3*exp(-1000*ss.^2);%f: �K���x�A�E�ӂ͓K���x�֐�(�]���֐�)