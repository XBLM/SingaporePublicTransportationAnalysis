clc;clear;

P_WD_Pred = csvread("P_WD_Pred.csv");
P_H_Pred = csvread("P_H_Pred.csv");

Bus_Load_Person = 180;
Bus_P = 180 * 4.5;

Start_Time = 5*60;
End_Time = 23*60;

Carbon_Realize_perBus = 23.51 % kg
%% 均匀发车
Bus_Departure_Gap_Time = 10; % 十分钟发车间隔
Bus_Count = (End_Time-Start_Time)/Bus_Departure_Gap_Time % 108
Bus_Count_Array = [];

% 等待时长
All_Wait_Time = 0;
Now_P = 0;
Stop_P_Array = [];
for i=1:23
    New_P = P_WD_Pred(i,2);
    if(i < 5 || i > 23) % 还未到上班时间
        Now_P = Now_P + New_P;
        Stop_P_Array = [Stop_P_Array; Now_P];
        Bus_Count_Array = [Bus_Count_Array; 0];
    else
        % 模拟一个小时内的等待情况
        Now_P = Now_P + New_P;
        P = rand([1,fix(Now_P)])*60; % 乘客到达时间
        P_Sort = sort(60 - P);
        Bus_All_P = Bus_P * (60 / Bus_Departure_Gap_Time);
        if(length(P_Sort) > Bus_All_P) % 超出小时内承载量
            Now_P = Now_P - Bus_All_P;
            All_Wait_Time = All_Wait_Time + sum(mod(P_Sort(1:Bus_All_P),Bus_Departure_Gap_Time)) + sum(mod(P_Sort(Bus_All_P + 1:end),Bus_Departure_Gap_Time));
        else
            All_Wait_Time = All_Wait_Time + sum(mod(P_Sort,Bus_Departure_Gap_Time));
            Now_P = 0;
        end
        Stop_P_Array = [Stop_P_Array; Now_P];
        Bus_Count_Array = [Bus_Count_Array; 60 / Bus_Departure_Gap_Time];
    end
end
P_Wait_Time = All_Wait_Time / sum(P_WD_Pred(:,2))
subplot(2,2,1)
plot(Stop_P_Array)
hold on
plot(P_WD_Pred(:,2))
subplot(2,2,3)
bar(Bus_Count_Array);

%% 优化发车
PredData = P_WD_Pred(:,1);
ActuData = P_WD_Pred(:,2);
New_P = 0;
Now_Actu_P = 0;
Now_Pred_P = 0;
Bus_Count = 0;
Stop_P_Array = [];
Bus_Count_Array = [];
for i=1:23
    if(i < 5 || i > 23) % 不在营业时段
        New_P = New_P + ActuData(i);
        Stop_P_Array = [Stop_P_Array; New_P];
        Bus_Count_Array = [Bus_Count_Array; 0];
    else
        % 决策发车间隔
        Now_Pred_P = New_P + PredData(i);
        Bus_Departure_Gap_Time = 60 / (fix(Now_Pred_P / Bus_P)+1);
        Bus_Count = Bus_Count + fix(Now_Pred_P / Bus_P);
        Bus_Count_Array = [Bus_Count_Array; fix(Now_Pred_P / Bus_P)];
        % 模拟一个小时内等待情况
        Now_Actu_P = New_P + ActuData(i);
        P = rand([1,fix(Now_Actu_P)])*60;
        P_Sort = sort(60 - P);
        Bus_All_P = Bus_P * (60 / Bus_Departure_Gap_Time);
        if(length(P_Sort) > Bus_All_P)
            New_P = Now_Actu_P - Bus_All_P;
            All_Wait_Time = All_Wait_Time + sum(mod(P_Sort(1:Bus_All_P),Bus_Departure_Gap_Time)) + sum(mod(P_Sort(Bus_All_P + 1:end),Bus_Departure_Gap_Time));
        else
            All_Wait_Time = All_Wait_Time + sum(mod(P_Sort,Bus_Departure_Gap_Time));
            New_P = 0;
        end
        Stop_P_Array = [Stop_P_Array; New_P];
    end
end
Bus_Count
P_Wait_Time = All_Wait_Time / sum(P_WD_Pred(:,2))
subplot(2,2,2)
plot(Stop_P_Array)
hold on
plot(P_WD_Pred(:,2))
subplot(2,2,4)
bar(Bus_Count_Array);

Carbon_Realize_Saved_All = (108 - Bus_Count) * Carbon_Realize_perBus





% plot(P_WD_Pred)
% legend