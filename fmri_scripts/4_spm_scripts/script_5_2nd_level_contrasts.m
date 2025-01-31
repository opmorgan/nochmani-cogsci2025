%% CONFIG
% Set up the SPM defaults, just in case
spm('defaults', 'fmri');

BIDS_DIR = '/Users/fmri/proj/SSH/BIDS_dataset';
FIRST_LEVEL_DIR = fullfile(BIDS_DIR, 'derivatives', 'spm-1st-level');
SECOND_LEVEL_DIR = fullfile(BIDS_DIR, 'derivatives', 'spm-2nd-level');

CON_SPM = ['con_0001'; 'con_0002';
    'con_0003'; 'con_0004';
    'con_0005'; 'con_0006';
    'con_0007'; 'con_0008';
    'con_0009'; 'con_0010';
    'con_0011'; 'con_0012';
    'con_0013'; 'con_0014';
    'con_0015'; 'con_0016';
    'con_0017'; 'con_0018';
    'con_0019'; 'con_0020';
    'con_0021'; 'con_0022';
    'con_0023'; 'con_0024';
    ];
CON_SHORT = ['con-01'; 'con-02';
    'con-03'; 'con-04';
    'con-05'; 'con-06';
    'con-07'; 'con-08';
    'con-09'; 'con-10';
    'con-11'; 'con-12';
    'con-13'; 'con-14';
    'con-15'; 'con-16';
    'con-17'; 'con-18';
    'con-19'; 'con-20';
    'con-21'; 'con-22';
    'con-23'; 'con-24';
    ];
CON_LABEL = {'approach > baseline'; 'approach < baseline';
    'avoid > baseline'; 'avoid < baseline';
    'approach > avoid'; 'approach < avoid';
    'approach-pos > avoid-neg'; 'approach-pos < avoid-neg';
    'approach-neg > avoid-pos'; 'approach-neg < avoid-pos';
    'pos > baseline'; 'pos < baseline';
    'neg > baseline'; 'neg < baseline';
    'pos > neg'; 'pos < neg';
    'approach-pos > baseline'; 'approach-pos < baseline';
    'approach-neg > baseline'; 'approach-neg < baseline';
    'avoid-pos > baseline'; 'avoid-pos < baseline';
    'avoid-neg > baseline'; 'avoid-neg < baseline';
    };

CON_TAB = table(CON_SPM, CON_SHORT, CON_LABEL);

SUBJECTS = {
    'sub-SD',...
    'sub-KP',...
    'sub-003',...
    'sub-020',...
    'sub-035',...
    'sub-039',...
    'sub-040',...
    'sub-043',...
    'sub-048',...
    'sub-053',...
    'sub-055',...
    'sub-057',...
    'sub-058',...
    'sub-059',...
    'sub-081',...
    'sub-096',...
    'sub-098',...
    'sub-103',...
    'sub-108',...
    'sub-110',...
    'sub-111',...
    'sub-122',...
    'sub-155',...
    };

% Create 2nd level output directory, if it doesn't exist
% Make input and output directories, if they don't exist already
if ~exist(SECOND_LEVEL_DIR, 'dir')
    mkdir(SECOND_LEVEL_DIR);
end

%% Loop through each condition
%for i = 1
for i = 1:size(CON_TAB, 1)
    disp(CON_TAB(i,"CON_LABEL"));
    disp(CON_TAB(i,"CON_SPM"));
    disp(CON_TAB(i,"CON_SHORT"));

    con_dir_name = [CON_TAB{i,"CON_SHORT"} ' | ' CON_TAB{i,"CON_LABEL"}{1}];
    % Set output directory; make it if it doesn't exist
    CON_OUT_DIR = fullfile(SECOND_LEVEL_DIR, con_dir_name);
    if ~exist(CON_OUT_DIR, 'dir')
        mkdir(CON_OUT_DIR);
    end

    % Specify contrast output directory
    matlabbatch{1}.spm.stats.factorial_design.dir = {CON_OUT_DIR};

    % Loop through each subject to create array of 1st level contrast paths
    nii_paths = cell(numel(SUBJECTS),1);
    for j = 1:numel(SUBJECTS)
        disp(SUBJECTS{j})
        sub_dir = fullfile(FIRST_LEVEL_DIR, SUBJECTS{j});
        sub_path = fullfile(sub_dir, strcat(CON_TAB{i, "CON_SPM"}, '.nii'));

        nii_paths{j} = strcat(sub_path, ',1');
    end

    % Specify 1st level contrast files
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(nii_paths);

    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = '1';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = '-1';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = -1;
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;

    % Run the batch!
    spm_jobman('run', matlabbatch)
    clear matlabbatch % clear matlabbatch

end


