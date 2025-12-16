clc;
close all;
clear;
addpath('videos'); % put relevant functions inside the /include folder 

%% threshold too low
video="C:\Users\pedem\Desktop\computer vision\Assignments\videos\luce_vp_1part.mp4";
compareCDAlgo(video,10)
