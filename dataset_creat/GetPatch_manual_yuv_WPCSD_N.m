clear;
clc,close all;
% ori_path='D:\XJR\GAP\GAPCN\dataset_creat\data\original_PCs/';
% rec_base_path='D:\XJR\GAP\GAPCN\dataset_creat\data\lift_WPCSD\';
% h5_train='h5/';
% txt_path='D:\XJR\GAP\GAPCN\dataset_creat\data\original_PCs\trainFile.txt';

ori_path='../data_ori_test/';
rec_base_path='data_rec_test_LT/';
h5_train='h5_test/';
txt_path='../data_ori_test/testFile.txt';

file=importdata(txt_path);
%sequences=dir([ori_path,'*.ply']);
sequence_number=length(file);
h1=waitbar(0,'read from sequences...');
rate = {'_r01','_r02', '_r03', '_r04', '_r05'};
% rate = {'_r03'};
mkdir(h5_train);
for i=1:sequence_number
    for jj=1:length(rate)
        str1=['reading sequences...',num2str(i/sequence_number),'%'];
        waitbar(i/sequence_number,h1,str1);
        %ori_name=sequences(i).name;
        ori_name=file{i};
        fprintf('The %d -th sequence - %s \n',i,ori_name);
        ori_onlyName=ori_name(1:end-4);
        % tempSplit=strsplit(ori_onlyName,'_');
        rec_onlyName=[ori_onlyName,rate{jj}];
        % rec_onlyName=[ori_onlyName,'_rec-',tempSplit{end}];
        ori=pcread([ori_path,ori_name]);
        ori_loc=ori.Location;
        ori_color=ori.Color;
        ori_color_yuv=rgb2yuv(ori_color);
        pointNumber=length(ori_loc);
        num_Sample=round(pointNumber/4096);
        %     train_sample=round(num_Sample*0.8);
        %     test_sample=num_Sample-train_sample;
        %    rec_path=[rec_base_path,ori_onlyName,'/r06/reconstruct/'];
        %rec_path=[ori_path,'OriData_train_rec_raht_r06/'];
        rec=pcread([rec_base_path,rec_onlyName,'.ply']);
        rec_color=rec.Color;
        rec_color_yuv=rgb2yuv(rec_color);
        rec_loc=rec.Location;

        h5create([h5_train,ori_onlyName,rate{jj},'.h5'],'/data_hui',[64,64,3,num_Sample]);
        h5create([h5_train,ori_onlyName,rate{jj},'.h5'],'/label_hui',[64,64,3,num_Sample]);
        box_label_train_hui=zeros(64,64,3,num_Sample);
        box_data_train_hui=zeros(64,64,3,num_Sample);

        centroids_ori=FPS(ori_loc,num_Sample);                        %FPS algorithm select the index of the represent point
        kdtreeObj_ori=KDTreeSearcher(ori_loc,'distance','euclidean');             % build the object for kdtree
        centroid_loc=ori_loc(centroids_ori,:);
        [idxnn_ori,dis]=knnsearch(kdtreeObj_ori,centroid_loc,'k',4096);   % 索引按照距离centroid的由小到大的顺序排列,[num_sample,1024]
        kdtreeObj_rec=KDTreeSearcher(rec_loc,'distance','euclidean');
        for j=1:num_Sample
            str2=['matching...',num2str(j/num_Sample),'%'];
            curPatchIdx_ori=idxnn_ori(j,:);        % 1024
            curPatchLoc_ori=ori_loc(curPatchIdx_ori,:);
            curPatchCol_ori=ori_color_yuv(curPatchIdx_ori,:);
            %         curPatchCol_ori_snake=reshape(curPatchCol_ori,[32,32,1]);
            curPatchCol_ori_hui=rectangular(curPatchCol_ori,64);
            %         corresponding idx in reconstruction point cloud in the same patch with the original pt
            [idx_rec,dis_rec]=knnsearch(kdtreeObj_rec,curPatchLoc_ori,'k',1);
            curPatchLoc_rec=rec_loc(idx_rec,:);
            curPatchCol_rec=rec_color_yuv(idx_rec,:);
            %         curPatchCol_rec_snake=reshape(curPatchCol_rec,[32,32,1]);
            curPatchCol_rec_hui=rectangular(curPatchCol_rec,64);
%             if mod(j,150) == 0
%                 A = uint8( yuv2rgb(curPatchCol_ori_hui) );
%                 imwrite(A, ['.\ori_pic\A_', num2str(j), '.png']);
%                 B = uint8( yuv2rgb(curPatchCol_rec_hui) );
%                 imwrite(B, ['.\pic\A_', num2str(j), '.png']);
%             end
            if(curPatchLoc_ori~=curPatchLoc_rec)
                error('rec not equal to ori when doing train dataset');
            end
            
            %         box_label_train_snake(:,:,:,j)=curPatchCol_ori_snake;
            %         box_data_train_snake(:,:,:,j)=curPatchCol_rec_snake;
            box_label_train_hui(:,:,:,j)=curPatchCol_ori_hui;
            box_data_train_hui(:,:,:,j)=curPatchCol_rec_hui;
            
            
            
        end
        clear f;
        %     h5write([h5_train,ori_onlyName,'.h5'],'/data_snake',box_data_train_snake);
        %     h5write([h5_train,ori_onlyName,'.h5'],'/label_snake',box_label_train_snake);
        h5write([h5_train,ori_onlyName,rate{jj},'.h5'],'/data_hui',box_data_train_hui);
        h5write([h5_train,ori_onlyName,rate{jj},'.h5'],'/label_hui',box_label_train_hui);
    end
end
close(h1);
