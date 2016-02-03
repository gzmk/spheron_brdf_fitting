%fitting brdf to images

% Idea: I might be able to store the params in an array and write them into
% the conditions file at each iteration - take a look at this
function costIm = renderIm_2params(var)
%% to write new conditions file with replaced params
% write to file in tabular form
% var = XBest; % this is to re-render the best fits
% var = [0.0760; 0.2168; 0.0472]; % this is for test

% THIS IS FOR MONOCHROMATIC RENDERING

% ro_s = var(1)/(var(1)+var(2));
% ro_d = var(2)/(var(1)+var(2));
% % alphau = var(3);
% alphau = fixedalpha;
% light = (var(1)+var(2));

% ro_s = ['300:',num2str(var(1)),' 800:',num2str(var(1))];
% ro_d = ['300:', num2str(1-var(1)), ' 800:', num2str(1-var(1))];
ro_s = var(1);
ro_d = 1-var(1);
alphau = var(2); % alphau and alphav should always be the same value for isotropic brdf
% light = ['300:', num2str(1), ' 800:',num2str(1)];
% mycell = {ro_s, ro_d, alphau,light};
mycell = {ro_s, ro_d, alphau};


T = cell2table(mycell, 'VariableNames', {'ro_s' 'ro_d' 'alphau'});
writetable(T,'/scratch/gk925/spheron_brdf_fitting/gloss50_fit/sphere_3params_Conditions.txt','Delimiter','\t')
% writetable(T,'/Local/Users/gizem/Documents/Research/GlossBump/Wendy_brdf_fitting_spray/gloss100_fit/sphere_3params_Conditions.txt','Delimiter','\t')

%% Rendering bit

% Set preferences
setpref('RenderToolbox3', 'workingFolder', '/scratch/gk925/spheron_brdf_fitting/gloss50_fit');
% setpref('RenderToolbox3', 'workingFolder', '/Local/Users/gizem/Documents/Research/GlossBump/Wendy_brdf_fitting_spray/gloss100_fit');

% use this scene and condition file. 
parentSceneFile = 'spheron_sphere6.dae';
% WriteDefaultMappingsFile(parentSceneFile); % After this step you need to edit the mappings file

conditionsFile = 'sphere_3params_Conditions.txt';
% mappingsFile = 'sphere_3params_DefaultMappings.txt';
mappingsFile = '50gloss_DefaultMappings.txt';

% Make sure all illuminants are added to the path. 
addpath(genpath(pwd))

% Choose batch renderer options.

hints.imageWidth = 5414;% this is isotropic scaling (orig. size divided by 4)
hints.imageHeight = 2707;
hints.renderer = 'Mitsuba';

datetime=datestr(now);
datetime=strrep(datetime,':','_'); %Replace colon with underscore
datetime=strrep(datetime,'-','_');%Replace minus sign with underscore
datetime=strrep(datetime,' ','_');%Replace space with underscore
%hints.recipeName = ['Test-SphereFit' datetime];
hints.recipeName = ['Test-SphereFit' date];

ChangeToWorkingFolder(hints);

% nativeSceneFiles = MakeSceneFiles(parentSceneFile, '', mappingsFile, hints);
nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);

%comment all this out
toneMapFactor = 10;
isScale = true;
montageName = sprintf('%s (%s)', 'Test-SphereFit', hints.renderer);
montageFile = [montageName '.png'];
% [SRGBMontage, XYZMontage] = ...
%     MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);

% load the monochromatic image and display it
% imPath = ['/Local/Users/gizem/Documents/Research/GlossBump/Wendy_brdf_fitting_spray/gloss100_fit/', hints.recipeName, '/renderings/Mitsuba/test_sphere-001.mat']
imPath = ['/scratch/gk925/spheron_brdf_fitting/gloss50_fit/', hints.recipeName, '/renderings/Mitsuba/spheron_sphere6-001.mat']
load(imPath, 'multispectralImage');
im2 = multispectralImage;
% figure;imshow(im2(:,:,1))

%% calculate the ssd (error) between two images
% dcraw command: -4 -d -v -w -b 3.0 DSC_0111_70gloss.pgm
% -b 3.0 makes it 3 times brighter
% gloss40 = imread('registered_photo.pgm','pgm');
% gloss = imread('registered40.pgm','pgm'); % turn this into a variable

% prepare a mask image for %40
mask = zeros(380,380);
mask(260:380, 1:380)=1;
mask = logical(mask);
mask = ~mask;
% imshow(mask)

cx=179;cy=207;ix=379;iy=380;r1=121;r2=121; 
[x,y]=meshgrid(-(cx-1):(ix-cx),-(cy-1):(iy-cy));
c_mask=(((x.^2.*r1^2)+(y.^2.*r2^2))<=r1^2*r2^2);

load('registered50_fit.mat') % make this a variable
photo = J;
% imshow(c_mask.*photo)
newmask = mask&c_mask;

masked_photo = newmask.*photo;

mean_photo = mean(mean(masked_photo));
photoNorm = masked_photo./(mean_photo);

% black = imread('DSC_0112.pgm')';
% imblack = imresize(black, [1005,668]);
% imblack2 = double(imblack)/65535;
% image1 = photo-imblack2;

renderedIm = im2; %for multispectral rendering
renderedIm = imcrop(renderedIm, [2517 0 379 2707]);
render_ball = imcrop(renderedIm, [1 1192 380 379]);
render_ball = render_ball.*10;
masked_render = newmask.*render_ball;
mean_render = mean(mean(masked_render));
renderedImNorm = masked_render./(mean_render);


diff = photoNorm-renderedImNorm;
costIm = sum(sum(diff.^2));

return;



