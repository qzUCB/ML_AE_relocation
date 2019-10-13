# ML_AE_relocation
File description:


Data files:
AE_locations.mat	
AE_test_arrivals.mat - P-wave arrival pickings of 96 AE events recorded during the slip test.
AE_train.mat - Locations (x,z) of pencil break events in the training data and their relative P-wave arrival pickings.
AErelocNet_2D_Deploy.mat - ANNs trained to output AE source location on the laboratory fault (x,z).

Code files:
AErelocNet_train_ANN.m	
AErelocNet_train_ANN_picking_quality_test.m
AErelocNet_train_ANN_with_Xvalid.m
AEreloc_ANN.m	
AEreloc_SVM_picking_quality_test.m	
AEreloc_single_target_SVM.m	
plotonfault.m

Image files:
fault_surf_impose.jpg - Relocated AE locations plotted  on top of the image of the laboratory fault after slip test.
sample_after_slip.jpg - Raw image of the laboratory fault after the slip test.
