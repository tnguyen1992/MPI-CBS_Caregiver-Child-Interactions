% function [ output_args ] = graph( input_args )
% %GRAPH Summary of this function goes here
% %   Detailed explanation goes here

%
% end
%%%%%%%%%FF
%clear all
clear cohin map mapping sensPos
cohin = data_wtc.coherences;

%% positions in map from real t value
% matrix of channel *1, each value represents the t value between task-rest comparison
map(7,7) = 0;

map(2,1)=cohin(1,4);
map(1,2)=cohin(2,4);
map(3,2)=cohin(3,4);
map(2,3)=cohin(4,4);

map(6,1)=cohin(5,4);
map(5,2)=cohin(6,4);
map(7,2)=cohin(7,4);
map(6,3)=cohin(8,4);

map(2,5)=cohin(9,4);
map(1,6)=cohin(10,4);
map(3,6)=cohin(11,4);
map(2,7)=cohin(12,4);

map(6,5)=cohin(13,4);
map(5,6)=cohin(14,4);
map(7,6)=cohin(15,4);
map(6,7)=cohin(16,4);

%% positions in map from averaged t value of neighbor channels.
map(1,1)=(cohin(1,4)+cohin(2,4))/2;
map(3,1)=(cohin(1,4)+cohin(3,4))/2;
map(1,3)=(cohin(2,4)+cohin(4,4))/2;
map(3,3)=(cohin(3,4)+cohin(4,4))/2;


map(5,1)=(cohin(5,4)+cohin(6,4))/2;
map(7,1)=(cohin(5,4)+cohin(7,4))/2;
map(5,3)=(cohin(6,4)+cohin(8,4))/2;
map(7,3)=(cohin(7,4)+cohin(8,4))/2;

map(1,5)=(cohin(9,4)+cohin(10,4))/2;
map(3,5)=(cohin(9,4)+cohin(11,4))/2;
map(1,7)=(cohin(10,4)+cohin(12,4))/2;
map(3,7)=(cohin(11,4)+cohin(12,4))/2;

map(5,5)=(cohin(13,4)+cohin(14,4))/2;
map(7,5)=(cohin(13,4)+cohin(15,4))/2;
map(5,7)=(cohin(14,4)+cohin(16,4))/2;
map(7,7)=(cohin(15,4)+cohin(16,4))/2;

map(2,2)=(cohin(1,4)+cohin(2,4)+cohin(3,4)+cohin(2,4))/4;
map(6,2)=(cohin(5,4)+cohin(6,4)+cohin(7,4)+cohin(8,4))/4;
map(2,6)=(cohin(9,4)+cohin(10,4)+cohin(11,4)+cohin(12,4))/4;
map(6,6)=(cohin(13,4)+cohin(14,4)+cohin(15,4)+cohin(16,4))/4;

mapping=interp2(map,8,'spline');
%clim=[-0.2 0.2];
imagesc(mapping);axis off;
%set(gca,'FontSize',12,'fontweight','Bold');

colormap(jet);
colorbar;

mappingSize = size(mapping, 1) - 1;
sensPos = 1/8 * [1,2,3,5,6,7] * mappingSize;

text(sensPos(1), sensPos(2), '\bullet 1', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(2), sensPos(1), '\bullet 2', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(2), sensPos(3), '\bullet 3', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(3), sensPos(2), '\bullet 4', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(4), sensPos(2), '\bullet 5', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(5), sensPos(1), '\bullet 6', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(5), sensPos(3), '\bullet 7', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(6), sensPos(2), '\bullet 8', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(1), sensPos(5), '\bullet 9', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(2), sensPos(4), '\bullet 10', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(2), sensPos(6), '\bullet 11', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(3), sensPos(5), '\bullet 12', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(4), sensPos(5), '\bullet 13', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(5), sensPos(4), '\bullet 14', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(5), sensPos(6), '\bullet 15', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(6), sensPos(5), '\bullet 16', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
   

% % Create textbox
% annotation('textbox',...
%     [0.364795918367346 0.694979899497488 0.0650510204081632 0.0577889447236181],...
%     'String',{'4'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.257653061224489 0.810557788944724 0.0650510204081632 0.0577889447236181],...
%     'String',{'1'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.150510204081633 0.694979899497488 0.0650510204081632 0.0577889447236181],...
%     'String',{'2'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.265306122448979 0.594477386934674 0.0650510204081632 0.0577889447236181],...
%     'String',{'3'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.59438775510204 0.815582914572864 0.0650510204081632 0.0577889447236181],...
%     'String',{'5'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.487244897959183 0.700005025125628 0.0650510204081633 0.0577889447236181],...
%     'String',{'6'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.701530612244896 0.700005025125628 0.0650510204081632 0.0577889447236181],...
%     'String',{'7'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.602040816326529 0.599502512562815 0.0650510204081632 0.0577889447236181],...
%     'String',{'8'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.249999999999999 0.395984924623116 0.0650510204081633 0.0577889447236181],...
%     'String',{'9'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.142857142857143 0.28040703517588 0.0803571428571428 0.0577889447236181],...
%     'String',{'10'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.357142857142857 0.28040703517588 0.0803571428571428 0.0577889447236181],...
%     'String',{'11'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.257653061224489 0.179904522613066 0.0803571428571428 0.0577889447236181],...
%     'String',{'12'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.602040816326529 0.398497487437186 0.0803571428571429 0.0577889447236181],...
%     'String',{'13'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.494897959183672 0.28291959798995 0.0803571428571428 0.0577889447236181],...
%     'String',{'14'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.709183673469386 0.28291959798995 0.0803571428571428 0.0577889447236181],...
%     'String',{'15'});
% 
% % Create textbox
% annotation('textbox',...
%     [0.609693877551019 0.182417085427136 0.0803571428571429 0.0577889447236181],...
%     'String',{'16'});