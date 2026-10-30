% This script does something useful

addpath(genpath(absfromrel('../../tools',fileparts(mfilename('fullpath')))));
%load cache/input-table.mat
create_input_table;
srt_infer_results = aggregate_inferstats(T);
clearvars -except srt_infer_results
