clear;
clc,close all;
% ori_path='data_ori/';
% rec_base_path='data_r06/';
% h5_train='h5/';
% txt_path='data_ori/trainFile.txt';
ori_path='../data_ori_test/';
rec_base_path='./data_rec/';
real_train='./real_PC/';
txt_path='../data_ori_test/testFile.txt';
rates = {'_r01','_r02', '_r03', '_r04', '_r05'};
% txt_path='./trainFile.txt';
% rates = {'_r01'};

file=importdata(txt_path);
sequence_number=length(file);
mkdir(real_train);
for i=1:sequence_number
    for k = 1:length(rates)
        ori_name=file{i};
        fprintf('The %d -th sequence- %s \n',i,ori_name);
        ori_onlyName=ori_name(1:end-4);
        write_name=[real_train,ori_onlyName,'_real',rates{k},'.ply'];
        % tempSplit=strsplit(ori_onlyName,'_');
        rec_onlyName=[ori_onlyName,rates{k}];
        % rec_onlyName=[ori_onlyName,'_rec-',tempSplit{end}];
        ori=pcread([ori_path,ori_name]);
        ori_loc=ori.Location;
        ori_color=ori.Color;
        pointNumber=length(ori_loc);
        kdtreeObj_ori=KDTreeSearcher(ori_loc,'distance','euclidean');             % build the object for kdtree
        
        rec=pcread([rec_base_path,rec_onlyName,'.ply']);
        rec_color=rec.Color;
        rec_loc=rec.Location;
        real_col = rec_color;
        [idxnn_ori,dis]=knnsearch(kdtreeObj_ori,rec_loc,'k',1);
        real_col = ori_color(idxnn_ori, :);
%         [idxnn_ori,dis]=knnsearch(kdtreeObj_ori,rec_loc,'k',2);
%         for m = 1:pointNumber
%             nn = 1;
%             cc = ori_color(idxnn_ori(m, 1), :);
%             dis_0 = dis(m ,1);
%             for jj = 2:2
%                 dis_t = dis(m, jj);
%                 if dis_t == dis_0 
%                 cc = cc + ori_color(idxnn_ori(m, jj), :);
%                 nn = nn + 1;
%                 end
%                 
%             end
%             cc = round(cc/nn);
%             real_col(m, :) = cc;
% 
%         end

        real_pt=pointCloud(rec_loc, 'Color',real_col);
        pcwrite(real_pt,write_name);
        
        %     close(h2);
        clear f;

        
    end
end
% close(h1);
