clear;
clc;
ori_path='../data_ori/';
rec_path='./data_rec/';
reordered_recPath='./data_rec/same_order/';
% ori_path='../data_ori/';
% rec_path='./data_rec/';
% reordered_recPath='../data_ori/same_order/';
txt_path='./data_rec/trainFile_test.txt';
% sequences=dir([rec_path,'*.ply']);
sequences=importdata(txt_path);

sequence_number=length(sequences);
for i=1:sequence_number
    ori_name=sequences{i};
    ori_onlyName=ori_name(1:end-4);
    fprintf('The %d -th sequence: %s \n',i,ori_name);
    for j=1:5
        tempSplit=strsplit(ori_onlyName,'_');
        rec_onlyName=[ori_onlyName,'_r0',num2str(j)];
        ori=pcread([ori_path,ori_name]);
        rec=pcread([rec_path,rec_onlyName,'.ply']);
        ori_loc=ori.Location;
        ori_color=ori.Color;
        rec_loc=rec.Location;
        numPoint=length(ori_loc);
        kdtreeObj_ori=KDTreeSearcher(ori_loc,'distance','euclidean');
        [idxnn_ori,dis]=knnsearch(kdtreeObj_ori,rec_loc,'k',1);

        reorder_loc=ori_loc(idxnn_ori,:);
        reorder_color=ori_color(idxnn_ori,:);
        reorder_pt=pointCloud(reorder_loc, 'Color',reorder_color);
        pcwrite(reorder_pt,[reordered_recPath,ori_onlyName,'_r0',num2str(j),'.ply']);
    end
end
