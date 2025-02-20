clc;clear;

bus_line_data = csvread("bus_line-178.csv",1,2);
bus_vol_data = csvread("bus_vol.csv",1,1);
% stop_id: (:,3)
stop_ids = bus_line_data(:,3)';
bus_vol_178_data = [];
for i=1:length(bus_vol_data(:,1))
    i
    for j=1:length(stop_ids)
        if(bus_vol_data(i,3) == stop_ids(j))
            bus_vol_178_data = [bus_vol_178_data; bus_vol_data(i,:)];
            break;
        end
    end
end
writematrix(bus_vol_178_data, "bus_vol-178.csv")