function spm_subtract_cons(con_nii_1, con_nii_2, new_con_nii, batch_dir)

% Setup file lists for spm
[new_con_path, new_con_name, new_con_ext]=fileparts(new_con_nii);           % new con file parts
batchfile=fullfile(batch_dir,['spm_subtract_cons_' new_con_name '.mat']);   % save batch job here

% cd(out_dir);

% Get spm defaults and start
spm('defaults', 'FMRI');
spm_get_defaults('cmdline',false);
spm_jobman('initcfg');
% F=spm_figure('GetWin','Graphics');

% Setup batch structure
clear matlabbatch;

% Create spm batch
matlabbatch{1}.spm.util.imcalc.input = {con_nii_1
                                        con_nii_2
                                        };
matlabbatch{1}.spm.util.imcalc.output = new_con_nii;
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = 'i1-i2';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;


% Save and run batch
save(batchfile, 'matlabbatch');
spm_jobman('run', matlabbatch);

% spm_figure('Print',F)

end
