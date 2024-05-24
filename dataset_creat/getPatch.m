clear;
clc;
ori_path='/media/vim/941bfed3-dbb1-4e73-80a7-a5601b4f9505/Wangweiwei/weiwei/TMC/MPEG_CTC/Cat1_A/';
rec_base_path='/media/vim/941bfed3-dbb1-4e73-80a7-a5601b4f9505/Wangweiwei/weiwei/TMC/compress_code/V9.0/cfg/octree-predlift/lossless-geom-lossy-attrs/';
%rec_path='/home/vim/weiwei/pointcloud/imageEnhancement/rec_dataset/';
txt_path='/media/vim/941bfed3-dbb1-4e73-80a7-a5601b4f9505/Wangweiwei/weiwei/TMC/MPEG_CTC/Cat1_A/trainFile.txt';
file=importdata(txt_path);
%sequences=dir([ori_path,'*.ply']);
sequence_number=length(file);
for i=1:sequence_number    
    ori_name=sequences(i).name;
    ori_onlyName=ori_name(1:end-4);
    tempSplit=strsplit(ori_onlyName,'_');
    rec_onlyName=[ori_onlyName,'_rec',tempSplit{end}];
    ori=pcread([ori_path,ori_name]);
    ori_loc=ori.Location;
    pointNumber=length(ori_loc);
    num_Sample=round(pointNumber/1024);
    h5create([ori_path,'train',num2str(i),'.h5'],'/data',[32,32,3,num_Sample]);  % 为每一个序列创建一个h5文件
    h5create([ori_path,'train',num2str(i),'.h5'],'/label',[32,32,3,num_Sample]);
    box_label=zeros(1024,1,num_Sample);
    box_data=zeros(1024,1,num_Sample);
    centroid=FPS(ori_loc,num_Sample);
    kdtreeObj=KDTreeSearcher(ori_loc,'distance','euclidean');
    %[idx,dist]=knnsearch(ori_loc,ori_loc,'dist','euclidean','k',1024);
    idxnn=knnsearch(kdtreeObj,ori_loc,'k',1024);   % 索引按照距离centroid的由小到大的顺序排列
    patchIdx=idxnn(centroid,:);
    ori_color=ori.Color;
    rec_path=[rec_base_path,ori_onlyName,'/r01/reconstruct/'];
    rec=pcread([rec_path,rec_onlyName,'.ply']);
    rec_color=rec.Color;
    [h,w]=size(patchIdx);
    for m=1:h
        curIdx=patchIdx(m,:);    % 一个patch的索引
        curColor_label=ori_color(cur_Idx,:);   % [1024,3]
        curColor_label0=reshape(curColor_label,[32,32,3]);
        box_label(:,:,:,m)=curColor_label0;
        curColor_data=rec_color(cur_Idx,:);
        curColor_data0=reshape(curColor_data,[32,32,3]);
        box_data(:,:,:,m)=curColor_data0;
    end
    h5write([ori_path,'train',num2str(i),'.h5'],'/data',box_data);
    h5write([ori_path,'train',num2str(i),'.h5'],'/label',box_label);
end