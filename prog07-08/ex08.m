function f=sim_pend(pop)




%% �ݖ�P�F��ԋ�ԃ��f��
%% �|���U�q�̏�ԋ�ԃ��f��(MIMO���f��)

m=0.023;      % Mass
J=3.20e-4;	% Inertia moment
L=0.2;		% Length
mu=2.74e-5;	% Damping coefficient
zeta=240;     % Physical parameter of DC motor
xi=90;		% Physical parameter of DC motor
g=9.81;       % Gravity accel.

p1=m*L/(J+m*L*L); p2=mu/(J+m*L*L);
A=[0 0 1 0;0 0 0 1;0 0 -zeta 0; 0 p1*g p1*zeta -p2];
B=[0;0;xi;-p1*xi];
C=[1 0 0 0;0 1 0 0];
D=[0;0];

% % ��ԋ�ԃ��f�����쐬���A��ԁA���́A�o�͂ɖ��O��t����
% states = {'x' 'th' 'dx' 'dth'};
% inputs = {'cart'};
% outputs = {'x' 'th'};
                
%% �ݖ�T�F�œK���M�����[�^�@�ɂ���ԃt�B�[�h�o�b�N�Q�C���̐݌v
% ���[�v��
Q=diag([10,1,1,1]);
r=10;
K=lqr(A,B,Q,r);
eig(A-B*K)
net=linearlayer([0 1]);

%% ���l�V�~�����[�V����(LQR)
x0=[0;0.1;0;0];
t=0.0:0.005:1.5;
tsize = size(t,2);

sys = ss(A-B*K,B,C,D);
[Y,T,X] = initial(sys,x0,t);%LQR�̃V�~�����[�V����
for i=1:pop %�̐������V�~�����[�V�����̂��߂�for��
    net.IW=po
%pop�̏�񂾂�net.IW�Ɋi�[

%U = 0;
%% ���l�V�~�����[�V����(NN)
X_nn(1,:)=[0;0.1;0;0];
dt=0.005;

for i=1:tsize
    u_nn(i,:) = sim(net, X_nn(i,:)');
    d1=A*X_nn(i,:)'+B*u_nn(i,:);
    d2=A*(X_nn(i,:)'+dt*d1/2)+B*u_nn(i,:);
    d3=A*(X_nn(i,:)'+dt*d2/2)+B*u_nn(i,:);
    d4=A*(X_nn(i,:)'+dt*d3)+B*u_nn(i,:);
    X_nn(i+1,:)=X_nn(i,:)+(dt*(d1+2*d2+2*d3+d4)/6)';
end
%% �l�b�g���[�N�̏o��
Y_nn=C*X_nn';

f=�����Œ�` %�K���x�A�E�ӂ͓K���x�֐�(�]���֐�)
% %% ���ʂ̕\��
% figure(1)
% plot(T,X)
% legend('x', 'th', 'dx', 'dth');
% grid on
% figure(2)
% subplot(311); plot(t,U);legend('lqr-input');grid on;
% subplot(312); plot(t,u_nn);legend('nn-input');grid on;
% subplot(313); plot(t,u_nn'-Ynn(1,:));legend('error');grid on;
% figure(3)
% plot(T,X_nn(1:tsize,:))
% legend('x', 'th','dx','dth');grid on
