% 该函数用于生成大量市场出清场景
% bid矩阵为2*6矩阵，1st行为二次项系数，2nd行为一次项系数，6列代表6个机组
clear;clc;
res = loadcase('case30');
bid = [res.gencost(:,5)'; res.gencost(:,6)']; %初始成本报价
Iteration = 300;

for j = 1:Iteration
    
    for bid_i = 1:2
        for bid_j = 1:6
            bid_in(bid_i,bid_j) = bid(bid_i,bid_j)*(1 + rand(1)); %考虑收益利润后的基于成本报价
        end
    end
    
    bid_m1(:,j) = bid_in(:,1);
    bid_m2(:,j) = bid_in(:,2);
    bid_m3(:,j) = bid_in(:,3);
    bid_m4(:,j) = bid_in(:,4);
    bid_m5(:,j) = bid_in(:,5);
    bid_m6(:,j) = bid_in(:,6);
    
    [Z(j,:), Unit_Out(j,:), Gen_node, Gen_num] = Market_Clearing_Result(bid_in);
    Local_Node_Margin_Price(j,:) = -Z(j,:);
    
    for i = 1:Gen_num
        Profit(j,i) = Local_Node_Margin_Price(j,Gen_node(i)) * Unit_Out(j,i) - (1/2 * bid(1,i) * Unit_Out(j,i)^2 + bid(2,i) * Unit_Out(j,i));
    end
    
end

Local_Node_Margin_Price =  Local_Node_Margin_Price'; %转置方便绘图
x = zeros(30,300);
for i = 1:30
    for j = 1:300
        x(i,j) = j;
    end
end
s1 = scatter(x(1,:), Local_Node_Margin_Price(1,:)); hold on;
s2 = scatter(x(2,:), Local_Node_Margin_Price(2,:));
s22 = scatter(x(22,:), Local_Node_Margin_Price(22,:));
s27 = scatter(x(27,:), Local_Node_Margin_Price(27,:));
s23 = scatter(x(23,:), Local_Node_Margin_Price(23,:));
s13 = scatter(x(13,:), Local_Node_Margin_Price(13,:));
s1.LineWidth = 0.2;
s1.MarkerEdgeColor = 'r';
s1.MarkerFaceColor = 'r';
s2.LineWidth = 0.2;
s2.MarkerEdgeColor = 'g';
s2.MarkerFaceColor = 'g';
s22.LineWidth = 0.2;
s22.MarkerEdgeColor = 'b';
s22.MarkerFaceColor = 'b';
s27.LineWidth = 0.2;
s27.MarkerEdgeColor = 'k';
s27.MarkerFaceColor = 'k';
s23.LineWidth = 0.2;
s23.MarkerEdgeColor = 'm';
s23.MarkerFaceColor = 'm';
s13.LineWidth = 0.2;
s13.MarkerEdgeColor = 'c';
s13.MarkerFaceColor = 'c';
