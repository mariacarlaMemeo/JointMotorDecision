%Using data.output
b_col = 11;
y_col = 17;
c_col = 23;
target_col = 7;
% remove the header from the data.output
do = data.output(2:end,:);

disp(['B overall: ' ,num2str(100*sum([do{:,b_col}])/length([do{:,b_col}]))]);
disp(['Y overall: ' ,num2str(100*sum([do{:,y_col}])/length([do{:,y_col}]))]);
disp(['Coll overall: ' ,num2str(100*sum([do{:,c_col}])/length([do{:,c_col}]))]);

c1=[do{:,target_col}]==0.115;
c2=[do{:,target_col}]==0.135;
c3=[do{:,target_col}]==0.17;
c4=[do{:,target_col}]==0.25;

disp(' ');
%c1
disp(['B c1: ' ,num2str(100*sum([do{c1,b_col}])/length([do{c1,b_col}]))]);
disp(['Y c1: ' ,num2str(100*sum([do{c1,y_col}])/length([do{c1,y_col}]))]);
disp(['Coll c1: ' ,num2str(100*sum([do{c1,c_col}])/length([do{c1,c_col}]))]);


%c2
disp(['B c2: ' ,num2str(100*sum([do{c2,b_col}])/length([do{c2,b_col}]))]);
disp(['Y c2: ' ,num2str(100*sum([do{c2,y_col}])/length([do{c2,y_col}]))]);
disp(['Coll c2: ',num2str(100*sum([do{c2,c_col}])/length([do{c2,c_col}]))]);


%c3
disp(['B c3: ' ,num2str(100*sum([do{c3,b_col}])/length([do{c3,b_col}]))]);
disp(['Y c3: ' ,num2str(100*sum([do{c3,y_col}])/length([do{c3,y_col}]))]);
disp(['Coll c3: ',num2str(100*sum([do{c3,c_col}])/length([do{c3,c_col}]))]);


%c4
disp(['B c4: ' ,num2str(100*sum([do{c4,b_col}])/length([do{c4,b_col}]))]);
disp(['Y c4: ' ,num2str(100*sum([do{c4,y_col}])/length([do{c4,y_col}]))]);
disp(['Coll c4: ',num2str(100*sum([do{c4,c_col}])/length([do{c4,c_col}]))]);
