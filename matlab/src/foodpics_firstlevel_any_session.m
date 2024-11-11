function foodpics_firstlevel_any_session(subject_id, session_id, run_list)
%% function foodpics_firstlevel_any_session(subject_id, session_id, run_list)
%
% subject_id: BIDS-format subject ID, e.g., sub-204
% session_id: BIDS-format session ID, e.g., ses-01
% run_list: array containing list of runs to process
%   to process both runs: [1 2]
%   to process only run 1: [1]
%   to process only run 2: [2]
%
% This script runs a pipeline to analyze the ADAK foodpics data
% based on parameters determined by KC. The pipeline includes:
% Changes from adak_foodpics_spm:
% - Saves residuals if needed for AFNI analysis
% - Changed SPM masking threshold from 0.8 to 0.2
% - Saves output in folder 'adak_foodpics_kc'

if nargin ~= 3 
    error('Must specify subject_id, session_id and run_list');
end

%% Study specific variables to specify data folders and SPM settings
task_id='foodpics';
study_dir='/home/data/images/adak';								                % main study directory
onset_dir=fullfile(study_dir, 'code', ['adak_' task_id '_kc'],'matlab','src');  % directory with SPM onsets - same for all subjects in this study
bids_dir=fullfile(study_dir,'data','bids_data');					            % bids data directory
preproc_dir=fullfile(bids_dir, 'derivatives','fmriprep_3mm');		            % directory with preprocessed data
output_dir=fullfile(bids_dir,'derivatives',['adak_' task_id '_kc']);            % analysis output directory for fmriprep 3mm data

n_vols='172';                           % each run should contain 172 volumes
tr='2';                                 % repetition time = 2s
fwhm='6';                               % FWHM kernel size for smoothing
output_space='MNI152NLin6Asym_res-07';  % Use fmriprep output in MNI152NLin6Asym template space with custom 3mm resolution

disp(['Processing subject: ' subject_id ' session: ' session_id]);
disp(['n_vols: ' n_vols]);
disp(['tr: ' tr]);
disp(['fwhm: ' fwhm]);
disp(['output_space: ' output_space]);

%% Make output folder if it doesn't exist
out_dir=fullfile(output_dir, subject_id, session_id, [task_id '_firstlevel']);
if not(isfolder(out_dir))
    [status, msg] = mkdir(out_dir);
    if status == 0 
        error(msg);
    end
end

%% Loop over all runs

for r = 1:length(run_list)
    % Set file paths
    run_number = num2str(run_list(r));

    multi_conds=fullfile(onset_dir,['onsets_' task_id '_run-0' run_number '.mat']);	% onsets for foodpics run

    fmri=fullfile(preproc_dir,subject_id,session_id,'func', [subject_id '_' session_id '_' 'task-' task_id '_' 'run-0' run_number '_' 'space-' output_space '_' 'desc-preproc_bold.nii.gz']);
    confounds=fullfile(preproc_dir,subject_id,session_id,'func', [subject_id '_' session_id '_' 'task-' task_id '_' 'run-0' run_number '_' 'desc-confounds_timeseries.tsv']);    

    % Copy input files to out_dir
    [status, msg] = copyfile(fmri, out_dir);
    if status == 0 
        error(msg);
    end
    [status, msg] = copyfile(confounds, out_dir);
    if status == 0 
        error(msg);
    end
    [status, msg] = copyfile(multi_conds, out_dir);
    if status == 0 
        error(msg);
    end

end

%% Unzip nifti files for SPM
gunzip(fullfile(out_dir,'*.gz'))


%% Call firstlevel function
if length(run_list) == 2
    foodpics_firstlevel('fmri1_nii', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-01' '_' 'space-' output_space '_' 'desc-preproc_bold.nii']), ...
        'fmri2_nii', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-02' '_' 'space-' output_space '_' 'desc-preproc_bold.nii']), ...
        'confounds1', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-01' '_' 'desc-confounds_timeseries.tsv']), ...
        'confounds2', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-02' '_' 'desc-confounds_timeseries.tsv']), ...
        'multi_conds1', fullfile(out_dir, ['onsets_' task_id '_run-01.mat']), ...
        'multi_conds2', fullfile(out_dir, ['onsets_' task_id '_run-02.mat']), ...
        'tr', tr, ...
        'n_vols', n_vols, ...
        'fwhm', fwhm, ...
        'out_dir', out_dir)
else 
    foodpics_firstlevel('fmri1_nii', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-0' run_number '_' 'space-' output_space '_' 'desc-preproc_bold.nii']), ...
        'confounds1', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-0' run_number '_' 'desc-confounds_timeseries.tsv']), ...
        'multi_conds1', fullfile(out_dir, ['onsets_' task_id '_run-0' run_number '.mat']), ...
        'tr', tr, ...
        'n_vols', n_vols, ...
        'fwhm', fwhm, ...
        'out_dir', out_dir)

end
