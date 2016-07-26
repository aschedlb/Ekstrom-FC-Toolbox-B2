function M = spm_klaff(Nf, Ng)
% Affine registration by minimising Kullback-Leibler Divergence
% FORMAT M = spm_klaff(Nf,Ng)
% Nf - NIfTI handle for one image
% Ng - Nifti handle for the other.  If not passed, then
%      spm*/toolbox/Seg/TPM.nii is used.
% M  - The voxel-for-voxel affine transform
%
% The images that are matched are tissue probability maps, in the
% same form as spm/tpm/TPM.nii or the Template files
% generated by Dartel.  To save some memory, no more than three
% (GM, WM and other) classes are matched together.
%
% Note that the code is very memory hungry because it stores a
% load of image gradients.  If it doesn't work because of this,
% the recommandation is to buy a more powerful computer.
%__________________________________________________________________________
% (c) Wellcome Trust Centre for NeuroImaging (2009)

% John Ashburner
% $Id: spm_klaff.m 5506 2013-05-14 17:13:43Z john $

if nargin<2,   Ng = fullfile(spm('Dir'),'tpm','TPM.nii'); end
if ischar(Nf), Nf = nifti(Nf); end
if ischar(Ng), Ng = nifti(Ng); end

deg = [2 2 2 1 1 1]; % Degree of interpolation to use

df = [size(Nf.dat),1,1];   % Dimensions of data
dg = [size(Ng.dat),1,1];   % Dimensions of data

nd = min([df(4)+1,dg(4)]); % Use the first nd volumes.
nd = min(nd,3);            % Just use GM, WM & other

g0 = loaddat(Ng,nd);

% Data structure for template
c  = cell(1,nd);
for k=1:nd,
    c{k} = zeros(dg(1:3),'single');
end
g  = struct('g',c,'dx',c,'dy',c,'dz',c);
clear c

[x,y,zz] = ndgrid(1:dg(1),1:dg(2),0);
for k=1:nd,
    c = spm_bsplinc(g0{k},deg);
    for z=1:dg(3),
        [tmp,dx,dy,dz] = spm_bsplins(c,x,y,z+zz,deg);
        g(k).g(:,:,z)  = single(exp(tmp));
        g(k).dx(:,:,z) = single(dx);
        g(k).dy(:,:,z) = single(dy);
        g(k).dz(:,:,z) = single(dz);
    end
    clear c tmp dx dy dz
end
clear g0

% Compute derivatives (see Eqn 12 of Ashburner & Friston (2009)).
for z=1:dg(3),
    sx = zeros(dg(1:2),'single');
    sy = zeros(dg(1:2),'single');
    sz = zeros(dg(1:2),'single');
    for k=1:nd,
        tmp = g(k).g(:,:,z);
        sx  = sx + g(k).dx(:,:,z).*tmp;
        sy  = sy + g(k).dy(:,:,z).*tmp;
        sz  = sz + g(k).dz(:,:,z).*tmp;
    end
    for k=1:nd,
        tmp = g(k).g(:,:,z);
        g(k).dx(:,:,z) = (g(k).dx(:,:,z) - sx).*tmp;
        g(k).dy(:,:,z) = (g(k).dy(:,:,z) - sy).*tmp;
        g(k).dz(:,:,z) = (g(k).dz(:,:,z) - sz).*tmp;
    end
    clear tmp sx sy sz
    drawnow
end


f = loaddat(Nf,nd);
for k=1:nd,
    f{k} =  spm_bsplinc(double(f{k}),deg);
end

M = Nf.mat\Ng.mat;

spm_plot_convergence('Init','KL Divergence Affine Registration',...
              'RMS Change', 'Iteration');

for it=1:64,

  % if it==1,
    AA = zeros(12); % Fisher Information matrix
  % end
    Ab = zeros(12,1);  % 1st derivatives
    kl = 0;
    nv = 0;
    for z=1:dg(3), % Loop over slices

        % Coordinates to sample f from
        x1 = M(1,1)*x + M(1,2)*y + M(1,3)*z + M(1,4);
        y1 = M(2,1)*x + M(2,2)*y + M(2,3)*z + M(2,4);
        z1 = M(3,1)*x + M(3,2)*y + M(3,3)*z + M(3,4);

        % These need to be in range, so create a mask
        msk = x1>=1 & x1<=df(1) &...
              y1>=1 & y1<=df(2) &...
              z1>=1 & z1<=df(3);
        if any(msk(:)),
            x1 = x1(msk);
            y1 = y1(msk);
            z1 = z1(msk);

            % Original coordinates, for use later
            X  = {x(msk);y(msk);z*ones(size(x1));ones(size(x1))};

            G  = cell(nd,1); % Masked g
            D  = cell(nd,3); % Masked gradients of g
            F  = cell(nd,1); % Masked f
            for k=1:nd,
                F{k}  = exp(spm_bsplins(f{k},x1,y1,z1,deg));
                tmp   = g(k).g(:,:,z);  G{k}   = tmp(msk);
                tmp   = g(k).dx(:,:,z); D{k,1} = tmp(msk);
                tmp   = g(k).dy(:,:,z); D{k,2} = tmp(msk);
                tmp   = g(k).dz(:,:,z); D{k,3} = tmp(msk);
            end

            % Re-normalise so that values sum to 1.
            sf = zeros(size(F{1}));
            for k=1:nd, sf   = sf + F{k}; end
            for k=1:nd, F{k} = F{k}./sf;  end

            for k=1:nd,
                DG  = cell(3,4); % dg/dm = dg/dx * dx/dm
                for i=1:3,
                    for j=1:4,
                        DG{i,j} = X{j}.*D{k,i};
                    end
                end
                DG  = DG(:);

                % Derivatives were derived using MATLAB symbolic toolbox.
                % First derivatives:
                % maple diff(f1(x1,x2)*log(f1(x1,x2)/g1) + g1*log(g1/f1(x1,x2)),x1)
                % This gives...
                %  diff(f1(x1,x2),x1)*log(f1(x1,x2)/g1)
                % +diff(f1(x1,x2),x1)
                % -g1*diff(f1(x1,x2),x1)/f1(x1,x2)
                % Because the gradients sum to zero at each point, the first
                % derivatives can be simplified to...
                % -diff(f1(x1,x2),x1)*(log(g1/f1(x1,x2))+g1/f1(x1,x2))
                %
                % Expectation of second derivatives:
                % maple diff(f1(x1,x2)*log(f1(x1,x2)/g1) + g1*log(g1/f1(x1,x2)),x1,x2)
                % This gives...
                % diff(f1(x1,x2),x1,x2)*log(f1(x1,x2)/g1)...
                % +diff(f1(x1,x2),x1)*diff(f1(x1,x2),x2)/f1(x1,x2)...
                % +diff(f1(x1,x2),x1,x2)...
                % -g1*diff(f1(x1,x2),x1,x2)/f1(x1,x2)...
                % +g1*diff(f1(x1,x2),x1)/f1(x1,x2)^2*diff(f1(x1,x2),x2)
                % For computing expectations, g1/f1(x1,x2) was set to 1.
                % This simplification loses terms requiring diff(f1(x1,x2),x1,x2)
                % giving nicely positive definite second derivatives.
                % 2*diff(f1(x1,x2),x1)*diff(f1(x1,x2),x2)/f1(x1,x2)
                %
                % Note that the workings in maple swapped around g and f.
                tmp  = F{k}./G{k};
                ltmp = log(tmp);
                tmp  = -(ltmp + tmp);
                kl   = kl + sum((F{k}-G{k}).*ltmp);
                nv   = nv + numel(ltmp);
                for i=1:12,
                    Ab(i) = Ab(i) + sum(DG{i}.*tmp);
                  % if it==1,
                    % Fisher information matrix could use the same data
                    % (irrespective of iteration number), so theoretically
                    % only needs to be computed the once.  However, the
                    % amount of overlap changes from iteration to iteration
                    % so I have chosen to recompute it each time.
                    for j=1:12,
                        AA(i,j) = AA(i,j) + 2*sum(DG{i}.*DG{j}./G{k});
                    end
                  % end
                    drawnow;
                end
            end
        end
    end

    % The derivatives are for an optimisation that minimises
    % D_{KL}(g(M x))||f'(x)) + D_{KL}(f'(x)||g(M x)))
    % The actual transform update we want is to match
    % f'(M^{-1} x)) with g(x), so an inverse is needed.
    % That was for the increment, whereby f'(x) = f(M_o x).
    % Therefore, for the whole thing, we are matching
    % f(M_o M^{-1} x) with g(x), so M_n = M_o M^{-1}, where
    % M = I - dM.  In the MATLAB code, M_n = M_o (I-dM) is
    % by M = M/(eye(4) - dM);
    dM = [reshape(AA\Ab,[3,4]); 0 0 0 0];
   %M = M/(eye(4) - dM);  % Theoretically correct according to LM-algorithm
   %M = M*(eye(4) + dM);  % Another possibility
    M = M*real(expm(dM)); % Forces the transform to have non-neg Jacobian
    fprintf('%3d  %15g  %15g\n', it, sqrt(sum(dM(:).^2)), kl/nv);
    spm_plot_convergence('Set', sqrt(sum(dM(:).^2)));
    if sum(dM(:).^2) < 1e-7, break; end
end
spm_plot_convergence('Clear');
%________________________________________________________

%________________________________________________________
function f = loaddat(N,d4)
% Load the first nd-1 volumes of the image, and create the
% last volume by subtracting the sum of the others from 1.
% Then take the logarithm.
d    = size(N.dat);
d(4) = d4;
f    = cell(1,d4);
fe   = ones(d(1:3),'single');

tol = 1e-6;
for k=1:d(4)-1,
    tmp  = single(N.dat(:,:,:,k));
    tmp  = max(tmp,tol);
    fe   = fe  - tmp;
    f{k} = tmp;
end
fe     = max(fe,tol);
f{end} = fe;

for k=1:d(4)-1, fe   = fe + f{k};     end
for k=1:d(4),   f{k} = log(f{k}./fe); end
%________________________________________________________

