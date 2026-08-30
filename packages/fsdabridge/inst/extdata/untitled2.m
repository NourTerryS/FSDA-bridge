load('stackloss');
y = stackloss.stack_loss;
X = stackloss{:, 1:3};
[outLXS] = LXS(y, X);

out_dir = 'C:/Users/HP/Desktop/sh/FSDA-bridge/packages/fsdabridge/inst/extdata/LXS';
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end
save(fullfile(out_dir, 'LXS_ref.mat'), 'outLXS');