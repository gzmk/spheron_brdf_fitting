%% Fits rho_s and alpha using a gridsearch

function loop_fitbrdf(iter)

% init 2 param fitting
LB_2 = [0.0, 0.01];
UB_2 = [1.0, 0.3];


bestParams = [];
bestfit_2pr = [];

fitname1 = '0percent_params.mat';

for i = 1:iter
    
    [XBest, BestF] = gridsearch(@renderIm_2params, LB_2, UB_2, 5, 0.35, 1e-3, 5, 1, 1);
    sprintf('This is XBest:');
    XBest;
    bestParams = [bestParams;XBest];
    bestfit_2pr = [bestfit_2pr;BestF];

    
    imname = strcat('/scratch/gk925/spheron_brdf_fitting/gloss0_fit/fit_results/multispectral/', fitname1);
    save(imname, 'bestParams','bestfit_2pr');
    
end

return;
