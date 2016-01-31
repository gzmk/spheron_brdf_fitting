%% Fits rho_s and alpha using a gridsearch

function loop_fitbrdf(iter)

% init 2 param fitting
LB_2 = [0.0, 0.0];
UB_2 = [1.0, 1.0];


bestParams = [];
bestfit_2pr = [];

fitname1 = '60percent_params.mat';

for i = 1:iter
    
    [XBest, BestF] = gridsearch(@renderIm_2params, LB_2, UB_2, 5, 0.5, 1e-4, 10, 1, 1);
    sprintf('This is XBest:');
    XBest;
    bestParams = [bestParams;XBest];
    bestfit_2pr = [bestfit_2pr;BestF];

    
    imname = strcat('/scratch/gk925/spheron_brdf_fitting_spray/gloss60_fit/fit_results/multispectral/', fitname1);
    save(imname, 'bestParams','bestfit_2pr');
    
end

return;
