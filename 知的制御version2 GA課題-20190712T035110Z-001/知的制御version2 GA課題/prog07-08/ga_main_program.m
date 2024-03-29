% ga_main_program.m


global  bound rng
%% パラメータの初期化　Initializing parameters
pops=10;                      % 個体数 population size
maxgen=5;                   % 世代数 maximum generation （終了条件の一つ）
crossp=0.8;                   % 交叉確率 crossover probability
mutatep=0.35;                 % 突然変異確率 mutation probability
%どう書いてもよい
bound=[0 20;0 20;0 20;0 20];%
%bound =
%    -1     1
%    -1     1
numvar=size(bound,1);         % 染色体の長さ chromosome length (number of variables)
% numvar = 2
rng=(bound(:,2)-bound(:,1))'; % 変数の範囲 variable range
% rng = 2  2

%.................population initialization.................

pop=zeros(pops,numvar);       % 個体の初期化 pop = initial population
%値を個体に入れる　制約条件を付ける必要がある
%popは個体群
pop(:,1:numvar)=(ones(pops,1)*rng).*(rand(pops,numvar))+(ones(pops,1)*bound(:,1)'); % 個体の生成

%%
%......................世代の開始 start generation......................
for it=1:maxgen
     fpop=gafuriko(pop);% 関数gafurikoの呼び出し、fpop:適応度
%適応度が最大のやつをエリートにする
    [cs,inds]=max(fpop); % エリート for elitism, cs:maximum value, inds: max index
%エリートをbchromに保存
    bchrom=pop(inds,:);  % エリートの値の格納 size(pop)=10 2の中からfpopの値が最大となる個体をbchromに格納
      
    % 選択........tournamet selection
    toursize=5;              % tournament size
    % 5人のプレーヤーをランダムに選んで適応度が最大のものを選択→トーナメント戦略
    
    players=ceil(pops*rand(pops,toursize));     % CEIL:正の無限大方向への丸め
    % pops*rand(pops,toursize)は10×5の行列を乱数で返す
    scores=fpop(players);%選択されたplayerの適応度をscoresに格納
    
    [a,m]=max(scores');

    % a(size: 1, pops): 各行の最大値，m(size: 1, pops): インデックス
    pind=zeros(1,pops);

    for i=1:pops
        pind(i)=players(i,m(i));    % 各行の最大値をpindに格納
        parent(i,:)=pop(pind(i),:); % 親の選択
    end
    
    % 交叉.............crossover
    %crossは確率
    child=cross(parent,crossp); 

    % 突然変異................mutation
    pop=mutate(child,mutatep);
     %学習結果を描画するためfigure２に必要な情報
    mm=gafuriko(pop);              % 各値をmmに格納
    maxf(it)=max(mm);               % 最大値をmaxfに格納
    meanf(it)=mean(mm);             % MEAN: 配列の平均値
    
    [bfit,bind]=max(mm);  % bfit=best fitness & bind=best fitness index
    bsol=pop(bind,:);
    
%     % 図の作成.....................plotting 3D surface....................
%     %figure1(71-86行目)
%     [x,y]=meshgrid([-1:0.05:1]);
%     r=sqrt(x.^2+y.^2);
%     s=sqrt((x-0.5).^2+y.^2);
%     ss=sqrt((x-0.8).^2+y.^2);
%     fff=exp(-2*r.^2)+2*exp(-1000*s.^2)+3*exp(-1000*ss.^2);
%     cla
%     mesh(x,y,fff),hold on
%     % 各個体の値をプロット....................plot all the points.............................
%     plot3( pop(:,1),pop(:,2),mm,'r+');
%     % 適応度の高い個体の値をプロット...................plot the optimum point.........................
%     plot3( bsol(1),bsol(2),bfit,'md');%hold on
%     axis([-1.5 ,1.5,-1.5 ,1.5])
%     xlabel(bsol(1))
%     ylabel(bsol(2))
%     zlabel(bfit)
    disp(['Generation=',num2str(it)])
    pause(0)
    %................................elitism.......................
   %エリートをもとに戻す
    pop(inds,:)=bchrom         % エリート保存　
    %最後はエリートだけのみを保存すればいいのでbchromを保存⇒保存した染色体を生成モデルとして利用
    %bchromが書き換わったのみデータとして保存した方がいい
    %..............................................................
end
%% 学習済み
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

% % 状態空間モデルを作成し、状態、入力、出力に名前を付ける
% states = {'x' 'th' 'dx' 'dth'};
% inputs = {'cart'};
% outputs = {'x' 'th'};
                
%% 設問５：最適レギュレータ法による状態フィードバックゲインの設計
% 閉ループ極
Q=diag([10,1,1,1]);
r=10;
K=lqr(A,B,Q,r);
eig(A-B*K)
net=linearlayer;
net= configure(net,[0;0;0;0],[0]);  % ネットワークの構成
net.b{1} = 0;
%% 数値シミュレーション(LQR)
x0=[0;0.5;0;0];
t=0.0:0.005:1.5;
tsize = size(t,2);
sys = ss(A-B*K,B,C,D);
[Y,T,X] = initial(sys,x0,t);%LQRのシミュレーション

%U = 0;
%% 数値シミュレーション(NN)
X_nn(1,:)=[0;0.1;0;0];
net.IW{1,1}=bchrom;
dt=0.005;
u_nn(1,:) = sim(net, X_nn(1,:)');
for i=1:tsize-1
    
    d1=A*X_nn(i,:)'+B*u_nn(i,:);
    d2=A*(X_nn(i,:)'+dt*d1/2)+B*u_nn(i,:);
    d3=A*(X_nn(i,:)'+dt*d2/2)+B*u_nn(i,:);
    d4=A*(X_nn(i,:)'+dt*d3)+B*u_nn(i,:);
    X_nn(i+1,:)=X_nn(i,:)+(dt*(d1+2*d2+2*d3+d4)/6)';
    u_nn(i+1,:) = sim(net, X_nn(i+1,:)');
end
%% ネットワークの出力
Y_nn=C*X_nn';

%% 結果の表示
figure(1)
plot(T,X)
legend('x', 'th', 'dx', 'dth');
grid on
figure(2)
subplot(311); plot(t,U);legend('lqr-input');grid on;
subplot(312); plot(t,u_nn);legend('nn-input');grid on;
subplot(313); plot(t,u_nn'-Y_nn(1,:));legend('error');grid on;
figure(3)
plot(T,X_nn(1:tsize,:))
legend('x', 'th','dx','dth');grid on


% disp(['x=',num2str(bsol(1))])       %  NUM2STR   数値を文字列に変換
% disp(['y=',num2str(bsol(2))])
% disp(['z=',num2str(bfit)])
% %...............................End generation.........................
% figure, plot(maxf), hold on, plot(meanf,'r-');
% xlabel('generation')
% ylabel('fitness')
% title('fitness preogress')
% legend('maximum fintness','meanftness')
