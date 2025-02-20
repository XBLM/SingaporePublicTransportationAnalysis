clc;clear;

bus_vol_data = csvread("bus_vol-178.csv");
bus_vol_WD = [];
bus_vol_H = [];
for i=1:length(bus_vol_data(:,1))
    if(bus_vol_data(i,1) == 0)
        %WD
        bus_vol_WD = [bus_vol_WD; bus_vol_data(i,:)];
    else
        %H
        bus_vol_H = [bus_vol_H; bus_vol_data(i,:)];
    end
end
% 对重复的时间段压力值取均值
pressure_WD = zeros(3,25);
pressure_H = zeros(3,25);
count=zeros(3,25);
mouth = [202107 202108 202109];
% WD
for j=1:3
    for i=1:length(bus_vol_WD(:,j))
        if(bus_vol_WD(i,6) == mouth(j))
            pressure_WD(j,bus_vol_WD(i,2)+1) = pressure_WD(j,bus_vol_WD(i,2)+1) + bus_vol_WD(i,4) + bus_vol_WD(i,5)*0.5;
            count(j,bus_vol_WD(i,2)+1) = count(j,bus_vol_WD(i,2)+1) + 1;
        end
    end
end
pressure_WD = pressure_WD ./ count;
pressure_WD = pressure_WD';
count = zeros(3,25);

% H
for j=1:3
    for i=1:length(bus_vol_H(:,j))
        if(bus_vol_H(i,6) == mouth(j))
            pressure_H(j,bus_vol_H(i,2)+1) = pressure_H(j,bus_vol_H(i,2)+1) + bus_vol_H(i,4) + bus_vol_H(i,5)*0.5;
            count(j,bus_vol_H(i,2)+1) = count(j,bus_vol_H(i,2)+1) + 1;
        end
    end
end

pressure_H = pressure_H ./ count;
pressure_H = pressure_H';

subplot(2,1,1)
plot(pressure_H);
legend('202107','202108','202109')
title('Transport Pressure in Holiday')
subplot(2,1,2)
plot(pressure_WD)
title('Transport Pressure in Workday')
legend('202107','202108','202109')

writematrix(pressure_WD, "pressure_WD.csv");
writematrix(pressure_H, "pressure_H.csv");