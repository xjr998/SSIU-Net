clear;
clc,close all;
ori_path='/media/vim/941bfed3-dbb1-4e73-80a7-a5601b4f9505/Wangweiwei/weiwei/TMC/MPEG_CTC/Cat1_A/';
%ori_path='/media/vim/941bfed3-dbb1-4e73-80a7-a5601b4f9505/Wangweiwei/weiwei/pointcloud/code/Enhancement_MPEG/data/OriData_train/';
rec_base_path='/media/vim/941bfed3-dbb1-4e73-80a7-a5601b4f9505/Wangweiwei/weiwei/TMC/compress_code/V9.0/cfg/octree-raht/lossless-geom-lossy-attrs/';
%rec_path='/media/vim/941bfed3-dbb1-4e73-80a7-a5601b4f9505/Wangweiwei/weiwei/pointcloud/code/Enhancement_MPEG/data/OriData_train/OriData_train_rec_raht_r05/';
h5_train='/media/vim/941bfed3-dbb1-4e73-80a7-a5601b4f9505/Wangweiwei/weiwei/pointcloud/code/Enhancement_MPEG/data/TrainData/positive_manual_y_256/';
% h5_test='/media/vim/941bfed3-dbb1-4e73-80a7-a5601b4f9505/Wangweiwei/weiwei/pointcloud/code/Enhancement_MPEG/data/TrainData/r06_manual/test/';
txt_path='/media/vim/941bfed3-dbb1-4e73-80a7-a5601b4f9505/Wangweiwei/weiwei/TMC/MPEG_CTC/Cat1_A/trainFile.txt';
file=importdata(txt_path);
sequences=dir([ori_path,'*.ply']);
sequence_number=length(file);
h1=waitbar(0,'read from sequences...');
mkdir(h5_train);
for i=1:sequence_number 
    str1=['reading sequences...',num2str(i/sequence_number),'%'];
    waitbar( i/sequence_number,h1,str1);
   % ori_name=sequences(i).name;
    ori_name=file{i};
    fprintf('The %d -th sequence：%s \n',i,ori_name);
    ori_onlyName=ori_name(1:end-4);
    % tempSplit=strsplit(ori_onlyName,'_');
    ori=pcread([ori_path,ori_name]);
    ori_loc=ori.Location;
    ori_color=ori.Color;
    ori_color_yuv=rgb2yuv(ori_color);
    pointNumber=length(ori_loc);
    num_Sample=round(pointNumber/256);
%     train_sample=round(num_Sample*0.8);
%     test_sample=num_Sample-train_sample;
    h5create([h5_train,ori_onlyName,'_positive.h5'],'/data_snake',[32,32,1,num_Sample]);
    h5create([h5_train,ori_onlyName,'_positive.h5'],'/label_snake',[32,32,1,num_Sample]);
    h5create([h5_train,ori_onlyName,'_positive.h5'],'/data_hui',[32,32,1,num_Sample]);
    h5create([h5_train,ori_onlyName,'_positive.h5'],'/label_hui',[32,32,1,num_Sample]);
    box_label_train_hui=zeros(32,32,1,num_Sample);
    box_data_train_hui=zeros(32,32,1,num_Sample);
    box_label_train_snake=zeros(32,32,1,num_Sample);
    box_data_train_snake=zeros(32,32,1,num_Sample); 
    centroids_ori=FPS(ori_loc,num_Sample);                        %FPS algorithm select the index of the represent point
    h2=waitbar(0,'match the data');
    kdtreeObj_ori=KDTreeSearcher(ori_loc,'distance','euclidean');             % build the object for kdtree
    centroid_loc=ori_loc(centroids_ori,:);
    [idxnn_ori,dis]=knnsearch(kdtreeObj_ori,centroid_loc,'k',1024);   % 索引按照距离centroid的由小到大的顺序排列,[num_sample,1024]
   % kdtreeObj_rec=KDTreeSearcher(rec_loc,'distance','euclidean');
    for j=1:num_Sample
        str2=['matching...',num2str(j/num_Sample),'%'];
        waitbar(j/num_Sample,h2,str2);
        curPatchIdx_ori=idxnn_ori(j,:);        % 1024
        curPatchLoc_ori=ori_loc(curPatchIdx_ori,:);
        curPatchCol_ori=ori_color_yuv(curPatchIdx_ori,1);
        curPatchCol_ori_snake=reshape(curPatchCol_ori,[32,32,1]);
        curPatchCol_ori_hui=rectangular(curPatchCol_ori,32);
    %    [idx_rec,dis_rec]=knnsearch(kdtreeObj_rec,curPatchLoc_ori,'k',1);    % corresponding idx in reconstruction point cloud in the same patch with the original pt
     %   curPatchLoc_rec=rec_loc(idx_rec,:);
      %  curPatchCol_rec=rec_color_yuv(idx_rec,1);
       % curPatchCol_rec_snake=reshape(curPatchCol_rec,[32,32,1]);
        %curPatchCol_rec_hui=rectangular(curPatchCol_rec,32);
       % if(curPatchLoc_ori~=curPatchLoc_rec)
       %     error('rec not equal to ori when doing train dataset');
       % end
        
        box_label_train_snake(:,:,:,j)=curPatchCol_ori_snake;
        box_data_train_snake(:,:,:,j)=curPatchCol_ori_snake;
        box_label_train_hui(:,:,:,j)=curPatchCol_ori_hui;
        box_data_train_hui(:,:,:,j)=curPatchCol_ori_hui;
       
    end
    close(h2);
    clear f;
    h5write([h5_train,ori_onlyName,'_positive.h5'],'/data_snake',box_data_train_snake);
    h5write([h5_train,ori_onlyName,'_positive.h5'],'/label_snake',box_label_train_snake);
    h5write([h5_train,ori_onlyName,'_positive.h5'],'/data_hui',box_data_train_hui);
    h5write([h5_train,ori_onlyName,'_positive.h5'],'/label_hui',box_label_train_hui);
end
close(h1);
