clear all
close all
clc

kfun = 'linear';
KFolds = 10;
%% ========================= load training data ===========================
load('AE_train.mat')

%% ===================== training and validation z ========================
inputTable = array2table(trainingData', 'VariableNames', {'trel1', 'trel2', 'trel3', 'trel4', 'trel5', 'trel6', 'trel7', 'trel8', 'trel9', 'trel10', 'trel11', 'coorx', 'coorz'});
predictorNames = {'trel1', 'trel2', 'trel3', 'trel4', 'trel5', 'trel6', 'trel7', 'trel8', 'trel9', 'trel10', 'trel11'};
predictors = inputTable(:, predictorNames);
response = inputTable.coorz;
responseScale = iqr(response);

% optimizing boxConstraint, epsilon, and KernelScale
for nb = 1:9
    for ne = 1:9
        for nk = 1:9
            
        zboxConstraint(nb) = (responseScale/1.349)*(1+0.1*(nb-5));
        zepsilon(ne) = (responseScale/13.49)*(1+0.1*(ne-5));
        zKernelScale(nk) = 1*(1+0.1*(nk-5));

        regressionSVM = fitrsvm(predictors,response, ...
        'KernelFunction', kfun, ...
        'KernelScale', zKernelScale(nk), ...
        'BoxConstraint', zboxConstraint(nb), ...
        'Epsilon', zepsilon(ne), ...
        'Standardize', true);

        % Create the result struct with predict function
        predictorExtractionFcn = @(x) array2table(x', 'VariableNames', predictorNames);
        svmPredictFcn = @(x) predict(regressionSVM, x);
        trainedModelz.predictFcn = @(x) svmPredictFcn(predictorExtractionFcn(x));
        trainedModelz.RegressionSVM = regressionSVM;

        % Perform cross-validation
        cvp = cvpartition(size(response, 1), 'KFold', KFolds);
        % Initialize the predictions to the proper sizes
        validationPredictions = response;
        for fold = 1:KFolds
            trainingPredictors = predictors(cvp.training(fold), :);
            trainingResponse = response(cvp.training(fold), :);
        %     foldIsCategoricalPredictor = isCategoricalPredictor;

            regressionSVM = fitrsvm(...
                trainingPredictors, ...
                trainingResponse, ...
                'KernelFunction', kfun, ...
                'KernelScale', zKernelScale(nk), ...
                'BoxConstraint', zboxConstraint(nb), ...
                'Epsilon', zepsilon(ne), ...
                'Standardize', true);

            % Create the result struct with predict function
            svmPredictFcn = @(x) predict(regressionSVM, x);
            validationPredictFcn = @(x) svmPredictFcn(x);

            % Add additional fields to the result struct

            % Compute validation predictions
            validationPredictors = predictors(cvp.test(fold), :);
            foldPredictions = validationPredictFcn(validationPredictors);

            % Store predictions in the original order
            validationPredictions(cvp.test(fold), :) = foldPredictions;
        end
        % Compute validation RMSE
        isNotMissing = ~isnan(validationPredictions) & ~isnan(response);
        zvalidationRMSE(nb,ne,nk) = sqrt(nansum(( validationPredictions - response ).^2) / numel(response(isNotMissing) ));
        % update the best model
        if zvalidationRMSE(nb,ne,nk)<= min(min(min(zvalidationRMSE)))
            trainedModelz.zvalidation_RMSE = zvalidationRMSE(nb,ne,nk);
            zregressionSVMmodel = trainedModelz;
        end
        end
    end
end

[mxv,idx] = min(zvalidationRMSE(:));
[r,c,p] = ind2sub(size(zvalidationRMSE),idx)

% best model
zboxConstraint = (responseScale/1.349)*(1+0.1*(r-5));
zepsilon = (responseScale/13.49)*(1+0.1*(c-5));
zKernelScale = 0.1*(1+0.1*(p-5));
optzRMSE = zvalidationRMSE(r,c,p)
        
%% ===================== training and validation x ========================
response = inputTable.coorx;
responseScale = iqr(response);
% optimizing boxConstraint, epsilon, and KernelScale
for nb = 1:9
    for ne = 1:9
        for nk = 1:9
            
        xboxConstraint(nb) = (responseScale/1.349)*(1+0.1*(nb-5));
        xepsilon(ne) = (responseScale/13.49)*(1+0.1*(ne-5));
        xKernelScale(nk) = 1*(1+0.1*(nk-5));
        
        regressionSVM = fitrsvm(...
                predictors, ...
                response, ...
                'KernelFunction', kfun, ...
                'KernelScale', xKernelScale(nk), ...
                'BoxConstraint', xboxConstraint(nb), ...
                'Epsilon', xepsilon(ne), ...
                'Standardize', true);

        % Create the result struct with predict function
        predictorExtractionFcn = @(x) array2table(x', 'VariableNames', predictorNames);
        svmPredictFcn = @(x) predict(regressionSVM, x);
        trainedModelx.predictFcn = @(x) svmPredictFcn(predictorExtractionFcn(x));

        % Add additional fields to the result struct
        trainedModelx.RegressionSVM = regressionSVM;
        inputTable = array2table(trainingData', 'VariableNames', {'trel1', 'trel2', 'trel3', 'trel4', 'trel5', 'trel6', 'trel7', 'trel8', 'trel9', 'trel10', 'trel11', 'trel12', 'trel13'});

        predictorNames = {'trel1', 'trel2', 'trel3', 'trel4', 'trel5', 'trel6', 'trel7', 'trel8', 'trel9', 'trel10', 'trel11'};

        % Perform cross-validation
        cvp = cvpartition(size(response, 1), 'KFold', KFolds);
        % Initialize the predictions to the proper sizes
        validationPredictions = response;
        for fold = 1:KFolds
            trainingPredictors = predictors(cvp.training(fold), :);
            trainingResponse = response(cvp.training(fold), :);
        %     foldIsCategoricalPredictor = isCategoricalPredictor;
        
        regressionSVM = fitrsvm(...
            trainingPredictors, ...
            trainingResponse, ...
            'KernelFunction', kfun, ...
            'KernelScale', xKernelScale(nk), ...
            'BoxConstraint', xboxConstraint(nb), ...
            'Epsilon', xepsilon(ne), ...
            'Standardize', true);

            % Create the result struct with predict function
            svmPredictFcn = @(x) predict(regressionSVM, x);
            validationPredictFcn = @(x) svmPredictFcn(x);

            % Add additional fields to the result struct

            % Compute validation predictions
            validationPredictors = predictors(cvp.test(fold), :);
            foldPredictions = validationPredictFcn(validationPredictors);
            % Store predictions in the original order
            validationPredictions(cvp.test(fold), :) = foldPredictions;
        end

        % Compute validation RMSE
        isNotMissing = ~isnan(validationPredictions) & ~isnan(response);
        xvalidationRMSE(nb,ne,nk) = sqrt(nansum(( validationPredictions - response ).^2) / numel(response(isNotMissing) ));
        % update the best model       
        if xvalidationRMSE(nb,ne,nk)<= min(min(min(xvalidationRMSE)))
            trainedModelx.xvalidation_RMSE = xvalidationRMSE(nb,ne,nk);
            xregressionSVMmodel = trainedModelx;
        end
        end
    end
end

[mxv,idx] = min(xvalidationRMSE(:));
[r,c,p] = ind2sub(size(xvalidationRMSE),idx)

% best model
xboxConstraint = (responseScale/1.349)*(1+0.1*(r-5));
xepsilon = (responseScale/13.49)*(1+0.1*(c-5));
xKernelScale = 0.1*(1+0.1*(p-5));
optxRMSE = xvalidationRMSE(r,c,p)

%% ============================= application ==============================
% load testing data
load('AE_test_arrivals.mat')
zpredict = zregressionSVMmodel.predictFcn(slip_test_data);
xpredict = xregressionSVMmodel.predictFcn(slip_test_data);

% plot
plotonfault(xpredict,zpredict)

%% saving and printing
save('SVMmodels.mat','xregressionSVMmodel','zregressionSVMmodel')
print(figure(1),'-djpeg','-r300','./fault_surf_impose_SVM.jpg');