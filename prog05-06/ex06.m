%% 動的なネットワークでの逐次型訓練

clear
close all

%% 線形層(ニューロン)の設定
% net = newlin([-1 1],1,[0 1],0.1);   % ニューロンの入出力, 学習比: 0.1
net=linearlayer([0 1],0.1) ; % ネットワークの作成
net= configure(net,[0],[0]); % ネットワークの構成



net.IW{1,1} = [0 0];         % 重みの初期化
net.biasConnect = 0;         % バイアスの初期化
Xi ={1} ;                       % 遅延の初期条件の設定
X ={2 3 4} ;                        % 入力の連続データ列
T ={3 5 7} ;                        % ターゲットの連続データ列
[net,y,e,pf] = adapt(net,X,T,Xi)

y                         % ネットワークの出力
e                         % ネットワークエラー
net.IW{1,1}                         % 訓練後の重みの確認
