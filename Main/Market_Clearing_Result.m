%该函数用于生成某一报价下的出清场景
%首先构建发电机组初始参数
function [Z, Unit_Out, Gen_node, Gen_num]=Market_Clearing_Result(Gen_Bid)
%% 采用MatPower7.1生成网络拓扑，此处采用IEEE-30节点
res = loadcase('case30');
Node_num = length(res.bus(:,1)); %网络节点数量
Node = res.bus(:,1); %网络节点编号
Load = res.bus(:,3)/100; %节点负荷有功标幺值
Gen_cap = res.gen(:,9)/100; %发电机有功容量标幺值
Gen_node = res.gen(:,1); %发电机所在节点
Gen_num = length(Gen_node); %发电机数量
Line_I = res.branch(:,1); %支路节点，下同
Line_J = res.branch(:,2);
Line_num = length(Line_I); %支路数目
Line_xij = res.branch(:,4); %支路阻抗
%% 下一步进行变量声明
Node_Theta = sdpvar(Node_num,1);
Unit_Out = sdpvar(Gen_num,1);
Gen_Out = sparse(Gen_node,ones(1,length(Gen_node)),Unit_Out,Node_num);
Node_Inj = sdpvar(Node_num,1);
P_av1 = sdpvar(Line_num,1); %辅助变量
P_av2 = sdpvar(Line_num,1); %辅助变量
Pij = sparse([Line_I;Line_J],[Line_J;Line_I],[P_av1;P_av2],Node_num,Node_num);
%% 下一步进行约束和目标函数的构建
con_nodebalance = []; %节点平衡约束
Geni = 1;
for i = 1:Node_num
    corrlbranchij = SearchNodeConnection(Line_I,Line_J,i);
    net_node_out(i) = sum(Pij(i,corrlbranchij(:,2)));
    if ismember(i,Gen_node)
    con_nodebalance = [con_nodebalance, Unit_Out(Geni)-Load(i) == net_node_out(i)];
    Geni = Geni + 1;
    else
    con_nodebalance = [con_nodebalance, -Load(i) == net_node_out(i)];
    end
end

con_powerflowcal = []; %支路潮流计算约束
for i = 1:length(Line_I)
    con_powerflowcal = [con_powerflowcal, Pij(Line_I(i),Line_J(i)) == (Node_Theta(Line_I(i))-Node_Theta(Line_J(i)))/Line_xij(i)];
    con_powerflowcal = [con_powerflowcal, Pij(Line_J(i),Line_I(i)) == (Node_Theta(Line_J(i))-Node_Theta(Line_I(i)))/Line_xij(i)];
end

con_gentech = []; %发电机物理运行约束
for i = 1:Gen_num
    con_gentech = [con_gentech, 0 <= Unit_Out(i) <= Gen_cap(i)];
end

con_pijcap = [-0.4 <= Pij <= 0.4]; %线路潮流容量约束

obj = 1/2*Gen_Bid(1,:)*Unit_Out.^2 + Gen_Bid(2,:)*Unit_Out; %目标函数构建
% obj = Gen_Bid(1,:)*Unit_Out; %目标函数构建
F = [con_nodebalance, con_powerflowcal, con_gentech, con_pijcap];
optimize(F, obj);
%变量可读化
Gen_Out = double(Gen_Out);
Unit_Out = double(Unit_Out);
Node_Theta = double(Node_Theta);
Pij = double(Pij);
% 求取对偶变量
for i = 1:30
   Z(i) = dual(F(i)); %对偶变量，此处物理含义为节点出清电价
end


end
