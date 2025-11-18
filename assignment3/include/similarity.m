function [d] = similarity(sim, f1, f2, p1, p2, d1, d2, sigma)
% USAGE: [d] = similarity(sim, f1, f2, p1, p2, sigma)
%   computes the similarity between features f1 and f2 according to the measure 'sim'
%   sim       a string controlling the similarity function
%   f1 f2     positions of the features (1x2 vectors)
%   p1 p2     patches to be used for the computations, only for 'NCC' mode
%   d1 d2     SURF descriptors (128x1 vectors)
%   sigma     scale for the exponential when using positions
% returns the requested similarity value for the given pair of features

switch(sim)
        
    case 'POS' % ----------------------------------------------------------

        % euclidean distance between postions
        dist = sqrt((f1(1,1)-f2(1,1))^2 + (f1(1,2)-f2(1,2))^2);
        
        % exponential of the euclidean distance
        d = exp((-(dist.^2))/(2*(sigma^2)));

    case 'NCC' % ----------------------------------------------------------
        
        p1 = double(p1);
        p2 = double(p2);

        W = size(p1,1);

        % normalize the patches
        p1norm = (p1 - mean2(p1))/std2(p1);
        p2norm = (p2 - mean2(p2))/std2(p2);
        
        % normalized cross-correlation between patches
        ncc = 1/(W*W)* (sum(sum(p1norm.*p2norm)));
        
        % set to the range [0 1]
        d = ((ncc + 1)/2);
    
    case 'POSNCC'

        % euclidean distance between postions
        dist = sqrt((f1(1,1)-f2(1,1))^2 + (f1(1,2)-f2(1,2))^2);
        
        % combination of the two contribution
        ed = exp((-(dist.^2))/(2*(sigma^2)));

        p1 = double(p1);
        p2 = double(p2);

        W = size(p1,1);

        % normalize the patches
        p1norm = (p1 - mean2(p1))/std2(p1);
        p2norm = (p2 - mean2(p2))/std2(p2);
        
        % normalized cross-correlation between patches
        ncc = 1/(W*W)* (sum(sum(p1norm.*p2norm)));
        
        % set to the range [0 1]
        ncc = ((ncc + 1)/2);

        % combination of the two contributions
        d = ed .* ncc;

        
    case 'POSSURF' % ---------------------------------------------------------
        
        % euclidean distance between postions
        dist = sqrt((f1(1,1)-f2(1,1))^2 + (f1(1,2)-f2(1,2))^2);
        
        % combination of the two contribution
        ed = exp((-(dist.^2))/(2*(sigma^2)));

        ds = sum(min([d1';d2']))/(sum(max([d1';d2'])));

        d = ed .* ds;
        
    otherwise
        display('Unrecognized similarity function');
        display('Possible values of parameter "sim" are "corners", "NCC", "SIFT"');
    end

end