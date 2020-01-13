# ML_AE_relocation
Use machine learning (ML) methods to relocate acoustic emission (AE) events on a laboratory fault surface.

## File description

### Data files:

* AE_test_arrivals.mat - P-wave arrival pickings of 96 AE events recorded during the slip test.

* AE_train.mat - Locations (x,z) of pencil break events in the training data and their relative P-wave arrival pickings.

* AErelocNet_2D_Deploy.mat - ANNs trained to output AE source location on the laboratory fault (x,z).

* AE_sensor_loc.mat - Locations of AE sensors in 3D.

* AE_signal_data.mat - Raw data for traning AE signals, locations and arrival pickings.

### Code files:
* AErelocNet_train_ANN.m	- train the ANN model

* AErelocNet_train_ANN_picking_quality_test.m - check sensitivity of the ANN model to arrival picking quality.

* AErelocNet_train_ANN_with_Xvalid.m  - ANN model accuracy estimation with ten-fold cross-validation.

* AEreloc_ANN.m	- apply the ANN model to the deployed ANN model for AE relocation.

* AEreloc_SVM_picking_quality_test.m	- check sensitivity of the SVM models to arrival picking quality.

* AEreloc_single_target_SVM.m	- train and apply SVM models for AE relocation.

* plotonfault.m - for plotting the AE eveents on the fault surface.
.
* disp_signal_and_picking.m - for plotting AE signals and arrivals.

### Image files:

* fault_surf_impose.jpg - Relocated AE locations plotted  on top of the image of the laboratory fault after slip test.

* sample_after_slip.jpg - Raw image of the laboratory fault after the slip test.

* training_data_on_surf.pdf - Training data on laboratory fault surface with event IDs.

* sensors_on_block.pdf - AE sensors plotted with the rock block in 3D with sensor IDs.

## Requirement

The ML methods are realized using MATLAB R2018a. The MATLAB neural network Toolbox and Statistics and Machine Learning Toolbox are required.
