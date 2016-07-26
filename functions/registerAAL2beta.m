function registerAAL2beta(betaDir)

% Uses SPM to coregister/reslice AAL mask to subject space

global subjID

file = dir([betaDir,'/',subjID{1},'/beta*']);

matlabbatch{1}.spm.spatial.coreg.write.ref = {file(1).name};
matlabbatch{1}.spm.spatial.coreg.write.source = {[which('ROI_MNI_V5.nii'),',1']};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0; % nearest neighbor rather than interpolation
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

spm_jobman('run',matlabbatch);

end