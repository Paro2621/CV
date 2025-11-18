function [list] = imageMatching(img1, img2, method, threshold, flag, sigma)

    list = findMatches(img1, img2, method, threshold, flag, sigma);
    figure(200), show_matches(img1, img2, list, 0, 200);
