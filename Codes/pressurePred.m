clc;clear;

pressure_WD = csvread('pressure_WD.csv');
pressure_H = csvread('pressure_H.csv');

pressure_WD(find(isnan(pressure_WD)==1)) = 0;
pressure_H(find(isnan(pressure_H)==1)) = 0;

%% 划分训练测试集
P_WD_train = [[pressure_WD(2:25,1)',pressure_WD(2:25,2)']; [0:23,0:23]];
P_WD_test = [pressure_WD(2:25,3)'; 0:23];
P_H_train = [[pressure_H(2:25,1)',pressure_H(2:25,2)']; [0:23,0:23]];
P_H_test = [pressure_H(2:25,3)'; 0:23];

%% WD
% 归一化
[p_train, ps_input] = mapminmax(P_WD_train(2,:), 0, 1);
p_test = mapminmax('apply', P_WD_test(2,:), ps_input);
[t_train, ps_output] = mapminmax(P_WD_train(1,:), 0, 1);
t_test = mapminmax('apply', P_WD_test(1,:), ps_output);

p_test = p_test';
p_train = p_train';
t_test = t_test';
t_train = t_train';
% 设置随机森林参数
trees = 100; % 决策树的数量
leaf = 5; % 每个叶节点的最小样本数
OOBPrediction = 'on'; % 启用 OOB 预测
OOBPredictorImportance = 'on'; % 启用特征重要性评估
Method = 'regression'; % 指定为回归任务

% 创建随机森林模型
net = TreeBagger(trees, p_train, t_train, ...
    'OOBPredictorImportance', OOBPredictorImportance, ...
    'Method', Method, ...
    'OOBPrediction', OOBPrediction, ...
    'minleaf', leaf);

% 获取特征重要性
importance = net.OOBPermutedPredictorDeltaError;
% 对训练集和测试集进行预测
t_sim1 = predict(net, p_train);
t_sim2 = predict(net, p_test);

% 反归一化预测结果
T_sim1 = mapminmax('reverse', t_sim1, ps_output);
T_sim2 = mapminmax('reverse', t_sim2, ps_output);

% 计算训练集和测试集的性能指标
error1 = sqrt(mse(T_sim1 - P_WD_train(1,:)'))
error2 = sqrt(mse(T_sim2 - P_WD_test(1,:)'))
R1 = 1 - (norm(P_WD_train(1,:)' - T_sim1)^2 / norm(P_WD_train(1,:)' - mean(P_WD_train(1,:)'))^2)
R2 = 1 - (norm(P_WD_test(1,:)' - T_sim2)^2 / norm(P_WD_test(1,:)' - mean(P_WD_test(1,:)'))^2)

% 绘制训练集和测试集的实际值与预测值的对比图
subplot(2,2,1);
plot(P_WD_train(1,:)', 'r', 'LineWidth', 1);
hold on;
plot(T_sim1, 'b--', 'LineWidth', 1);
legend('Actual values', 'Predicted values');
title('Predicted Results in Training Group');
xlabel('Hour');
ylabel('Pressure in Workday');

subplot(2,2,2);
plot(P_WD_test(1,:)', 'r', 'LineWidth', 1);
hold on;
plot(T_sim2, 'b--', 'LineWidth', 1);
legend('Actual values', 'Predicted values');
title('Predicted Results in Testing Group');
xlabel('Hour');
ylabel('Pressure in Workday');

% 保存测试数据
writematrix([T_sim2 P_WD_test(1,:)'],"P_WD_Pred.csv")

%% H
% 归一化
[p_train, ps_input] = mapminmax(P_H_train(2,:), 0, 1);
p_test = mapminmax('apply', P_H_test(2,:), ps_input);
[t_train, ps_output] = mapminmax(P_H_train(1,:), 0, 1);
t_test = mapminmax('apply', P_H_test(1,:), ps_output);

p_test = p_test';
p_train = p_train';
t_test = t_test';
t_train = t_train';
% 设置随机森林参数
trees = 100; % 决策树的数量
leaf = 5; % 每个叶节点的最小样本数
OOBPrediction = 'on'; % 启用 OOB 预测
OOBPredictorImportance = 'on'; % 启用特征重要性评估
Method = 'regression'; % 指定为回归任务

% 创建随机森林模型
net = TreeBagger(trees, p_train, t_train, ...
    'OOBPredictorImportance', OOBPredictorImportance, ...
    'Method', Method, ...
    'OOBPrediction', OOBPrediction, ...
    'minleaf', leaf);

% 获取特征重要性
importance = net.OOBPermutedPredictorDeltaError;
% 对训练集和测试集进行预测
t_sim1 = predict(net, p_train);
t_sim2 = predict(net, p_test);

% 反归一化预测结果
T_sim1 = mapminmax('reverse', t_sim1, ps_output);
T_sim2 = mapminmax('reverse', t_sim2, ps_output);

% 计算训练集和测试集的性能指标
error1 = sqrt(mse(T_sim1 - P_H_train(1,:)'))
error2 = sqrt(mse(T_sim2 - P_H_test(1,:)'))
R1 = 1 - (norm(P_H_train(1,:)' - T_sim1)^2 / norm(P_H_train(1,:)' - mean(P_H_train(1,:)'))^2)
R2 = 1 - (norm(P_H_test(1,:)' - T_sim2)^2 / norm(P_H_test(1,:)' - mean(P_H_test(1,:)'))^2)

% 绘制训练集和测试集的实际值与预测值的对比图
subplot(2,2,3);
plot(P_H_train(1,:)', 'r', 'LineWidth', 1);
hold on;
plot(T_sim1, 'b--', 'LineWidth', 1);
legend('Actual values', 'Predicted values');
title('Predicted Results in Training Group');
xlabel('Hour');
ylabel('Pressure in Holiday');

subplot(2,2,4);
plot(P_H_test(1,:)', 'r', 'LineWidth', 1);
hold on;
plot(T_sim2, 'b--', 'LineWidth', 1);
legend('Actual values', 'Predicted values');
title('Predicted Results in Testing Group');
xlabel('Hour');
ylabel('Pressure in Holiday');

% 保存测试数据
writematrix([T_sim2 P_H_test(1,:)'],"P_H_Pred.csv")
