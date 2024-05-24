1. Training: train_manual.py
Test: test_manual.py or test_manual_VPCC.py
2. Network framework: model_new.py
3. Since each bit rate is trained separately, please modify the bit rate point in the first line of main function bits = 'R01_' during training.
When testing, please modify the rate point around line 20 c = '1'.
4. When training, need to pay attention to the input parameters: '--pth_path' model output location, '--log_path' log file location,
'--resume' whether to read checkpoint, '--data_path' training set location (put txt file in the same folder as h5 file,
Each line of the txt file is the full name of each h5 file, such as loot_vox10_1200_r01.h5), '--validData_path' validates the set location.
5. When testing, pay attention to the input parameters: '--log_path' log file location, '--data_path' record the original point cloud txt file location,
'--pretrain_Y' is the Y-component model position, '--pretrain_U' is the U-component model position, '--pretrain_V' is the V-component model position,
'--ori_path' is the original point cloud (ply file) location, '--rec_path' is the reconstructed point cloud location, and '--pred_path' is the quality enhanced point cloud output location.
