function [n_chunk, idx_chunk] = get_chunk(n_sweep, n_split)
% Split data into chunks with maximum size.
%     - n_sweep - number of data to be splitted in chunks
%     - n_split - number of data per chunk
%     - n_chunk - number of created chunks
%     - idx_chunk - cell with the indices of the chunks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init the data
idx = 1;
idx_chunk = {};

% create the chunks indices
while idx<=n_sweep
    idx_new = min(idx+n_split,n_sweep+1);
    vec = idx:(idx_new-1);
    idx_chunk{end+1} = vec;
    idx = idx_new;
end

% count the chunks
n_chunk = length(idx_chunk);

end