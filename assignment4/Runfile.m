clc;
close all;
clear;
%addpath('C:\Users\pedem\Desktop\computer vision\Assignments\videos\');
addpath('videos\');
video3="DibrisHall_3part.mp4";
video2="tennis_2part.mp4";
segmantAndTrack(video3,15,0.5,10)
%compareCDAlgo(video3,20,0.02,5)
% compareCDOF(video2,35,0.2,20,8)