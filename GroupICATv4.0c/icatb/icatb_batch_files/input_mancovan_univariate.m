%% Use full path for directories and files wherever needed. After entering parameters, use command icatb_mancovan_batch(input_file);

%% Output directory to place results 
outputDir = 'C:\Users\srrac\gsu\srinivas\results\test_mancovan\batch\univ';

%% ICA parameter file 
ica_param_file = 'C:\Users\srrac\gsu\srinivas\data\mancova_sample_data\ica_output\rest_hcp_ica_parameter_info.mat';

%% Features. Options avaialble are spatial maps, timecourses spectra, fnc correlations
features = {'spatial maps', 'timecourses spectra', 'fnc correlations'};

%% Average runs. Use dataset numbers for each subject. If there are no runs to average, comment out the variable or leave it as empty.
avg_runs = {(1), (2), (3), (4), 5, 6, 7, 8, 9, 10};

%% Cell array of dimensions number of covariates by 4. The 4 columns are as follows:
% a. name - Covariate name
% b. type - Covariate type continuous or categorical
% c. value - You could enter the vector by hand or use Ascii file for continuous covariates and text file with new line delimiter for
% categorical covariates.
% d. Transformation function - Enter transformation function to be applied
% on the continuous covariate 
covariates = {'Age', 'continuous', 'C:\Users\srrac\gsu\srinivas\data\mancova_sample_data\covariates\age.txt', 'log';
             'Gender', 'categorical', 'C:\Users\srrac\gsu\srinivas\data\mancova_sample_data\covariates\gender.txt', '';
             'motion_avg_trans', 'continuous', 'C:\Users\srrac\gsu\srinivas\data\mancova_sample_data\covariates\motion_avg_trans.txt', 'log';
             'motion_avg_rot', 'continuous', 'C:\Users\srrac\gsu\srinivas\data\mancova_sample_data\covariates\motion_avg_rot.txt', 'log';
             'spatialnorm_rho_S', 'continuous', 'C:\Users\srrac\gsu\srinivas\data\mancova_sample_data\covariates\spatialnorm_rho_S.txt', 'atanh'};

%% Cell array of dimensions number of network names by 2. Don't duplicate components in different
% network names
comp_network_names = {'BG', 21;                    % Basal ganglia 21st component
                      'AUD', 17;                   % Auditory 17th component
                      'SM', [7 23 24 29 38 56];    % Sensorimotor comps
                      'VIS', [39 46 48 59 64 67];  % Visual comps
                      'DMN', [25 50 53 68];        % DMN comps
                      'ATTN', [34 52 55 60 71 72]; % ATTN Comps
                      'FRONT', [20 42 47 49]};     % Frontal comps
                  
            
                  
 %% Univariate tests. If specified, multivariate tests will be skipped 
 % Specify covariate to test in a new row. Columns description are below:
 % a. Covariate to test. Include interaction terms only if you have
 % specified interactions list in interactions.
 % b. nuisance covariates in a cell array if you have multiple covariates.
 % Leave it empty if none specified.
 % If you are using T-tests only, examples are shown below:
 %univariate_tests = {'Ttest', {(1:50)}, {'Group'}}; % One sample t-test
 %univariate_tests = {'Ttest', {(1:25), (26:50)}, {'Cond 1', 'Cond 2'}}; %
 %Paired t-test (runs are not averaged. Dataset numbers will be first
 %subject sessions followed by second subject sessions, etc.
 %univariate_tests = {'Ttest2', {(1:25), (26:50)}, {'Group 1', 'Group 2'}}; % Two sample t-test

 univariate_tests = {'Gender',                             {'Age'}; % Reduced model contains gender and age terms. Age is used as a nuisance covariate.
                      'Age',                               {'Gender'}; % Reduced model contains age and gender terms. Gender is used as a nuisance covariate. 
                     'Gender_X_Age',                       {'motion_avg_trans', 'motion_avg_rot'}; % Gender Age interaction term. No nuisance covariates are used.
                     'spatialnorm_rho_S_X_motion_avg_rot', {}}; % Another interaction term example               
                                           
%% Significance threshold
p_threshold = 0.2;

%% TR of the experiment
TR = 2;


%% Feature defaults

% Spatial map defaults
%
% 1. sm_center - Center the distribution of subject component
% maps. Options are 'yes' and 'no'.
% 2. sm_mask - Specify an external mask or leave empty to select the default
% mask. Default mask could be computed using T statistic or Z-statistic. If
% you select T statistic, threshold is automatically computed using the
% t distribution. With Z statistic you have the option to specify
% threshold.

% 3. stat_threshold_maps - Statistic for thresholding. Options are 'T' or 'Z'.
% 4. z_threshold_maps - Threshold when using Z-statistic. 
feature_params.sm_center = 'yes';
feature_params.sm_mask = [];
feature_params.stat_threshold_maps = 'T';
feature_params.z_threshold_maps = 1;


% Spectra defaults
%
% 1. spectra_detrend - Detrend number used to remove the trends in timecourses.
% Options are 0, 1, 2 and 3.
% 2. spectra_tapers - A numeric vector [TW K] where TW is the time-bandwidth product and K is the number of 
%tapers to be used (less than or equal to 2TW-1).
% 3. spectra_sampling_freq - Sampling frequency in Hz. For fMRI it will be 1/TR.
% 4. spectra_freq_band - Frequency band. Usually it is [0, 1/(2*TR)]
% 5. spectra_normalize_subs - Normalize spectra. Options are 'yes' and 'no'.
% 6. spectra_transform - Use log transformation of spectra. Options are 'yes' and 'no'.
feature_params.spectra_detrend = 3;
feature_params.spectra_tapers = [3, 5];
feature_params.spectra_sampling_freq = 1/TR;
feature_params.spectra_freq_band = [0, 1/(2*TR)];
feature_params.spectra_normalize_subs = 'yes';
feature_params.spectra_transform = 'yes';


% FNC correlation defaults
%
% 1. fnc_tc_detrend - Detrend number used to remove the trends in timecourses.
% Options are 0, 1, 2 and 3.
% 2. fnc_tc_despike - Remove spikes from the timecourses. Options are 'yes' and
% 'no'.
% 3. fnc_tc_filter - High frequency cutoff in Hz.

feature_params.fnc_tc_detrend = 3;
feature_params.fnc_tc_despike = 'yes';
feature_params.fnc_tc_filter = 0.15;



%% Display settings
display.freq_limits = [0.1, 0.15];
display.structFile = fullfile(fileparts(which('gift.m')), 'icatb_templates', 'ch2bet.nii');
% features display threshold (spatial maps)
display.t_threshold = 5;
% p-threshold on the univariate maps,spectra,etc
display.p_threshold = 0.05;
% image values
display.image_values = 'Positive';
% options are fdr and none used in univariate results
display.threshdesc = 'none';
% Display connectogram
display.display_connectogram = 1;
