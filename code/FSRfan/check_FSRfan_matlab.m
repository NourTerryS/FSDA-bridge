% Generate the MATLAB/FSDA oracle for FSRfan.

clear;
clc;

script_path = mfilename('fullpath');
script_dir = fileparts(script_path);
reference_dir = fullfile(script_dir, 'reference');

% Load the official FSDA wool dataset.
wool_path = fullfile(reference_dir, 'wool.txt');
XX = load(wool_path);

y = XX(:, end);
X = XX(:, 1:end-1);

% Run the real MATLAB/FSDA implementation.
out = FSRfan(y, X, 'plots', 0, 'msg', false);

% Save the main numerical result.
Score_fsda = out.Score;
la = out.la;

% Save Score matrix as CSV.
writematrix(Score_fsda, ...
    fullfile(reference_dir, 'FSRfan_Score_check.csv'));

% Save lambda values as CSV.
writematrix(la(:), ...
    fullfile(reference_dir, 'FSRfan_la_check.csv'));

fprintf('=== FSRfan MATLAB/FSDA oracle ===\n');
fprintf('Rows       : %d\n', size(Score_fsda, 1));
fprintf('Columns    : %d\n', size(Score_fsda, 2));
fprintf('Lambda     : ');
fprintf('%.6g ', la);
fprintf('\n');
fprintf('Score CSV  : %s\n', ...
    fullfile(reference_dir, 'FSRfan_Score_check.csv'));
fprintf('Lambda CSV : %s\n', ...
    fullfile(reference_dir, 'FSRfan_la_check.csv'));