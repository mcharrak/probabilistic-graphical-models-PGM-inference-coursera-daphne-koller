%BLOCKLOGDISTRIBUTION
%
%   LogBS = BlockLogDistribution(V, G, F, A) returns the log of a
%   block-sampling array (which contains the log-unnormalized-probabilities of
%   selecting each label for the block), given variables V to block-sample in
%   network G with factors F and current assignment A.  Note that the variables
%   in V must all have the same dimensionality.
%
%   Input arguments:
%   V -- an array of variable indices.
%   G -- the graph with the following fields:
%     .names - a cell array where names{i} = name of variable i in the graph 
%     .card - an array where card(i) is the cardinality of variable i
%     .edges - a matrix such that edges(i,j) shows if variables i and j 
%              have an edge between them (1 if so, 0 otherwise)
%     .var2factors - a cell array where var2factors{i} gives an array where the
%              entries are the indices of the factors including variable i
%   F -- a struct array of factors.  A factor has the following fields:
%       F(i).var - names of the variables in factor i
%       F(i).card - cardinalities of the variables in factor i
%       F(i).val - a vectorized version of the CPD for factor i (raw probability)
%   A -- an array with 1 entry for each variable in G s.t. A(i) is the current
%       assignment to variable i in G.
%
%   Each entry in LogBS is the log-probability that that value is selected.
%   LogBS is the P(V | X_{-v} = A_{-v}, all X_i in V have the same value), where
%   X_{-v} is the set of variables not in V and A_{-v} is the corresponding
%   assignment to these variables consistent with A.  In the case that |V| = 1,
%   this reduces to Gibbs Sampling.  NOTE that exp(LogBS) is not normalized to
%   sum to one at the end of this function (nor do you need to worry about that
%   in this function).
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function LogBS = BlockLogDistribution(V, G, F, A)
if length(unique(G.card(V))) ~= 1
    disp('WARNING: trying to block sample invalid variable set');
    return;
end

% d is the dimensionality of all the variables we are extracting
d = G.card(V(1));
blocklen = length(V);

LogBS = zeros(1, d);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
% Compute LogBS by multiplying (adding in log-space) in the correct values from
% each factor that includes some variable in V.  
%
% NOTE: As this is called in the innermost loop of both Gibbs and Metropolis-
% Hastings, you should make this fast.  You may want to make use of
% G.var2factors, repmat,unique, and GetValueOfAssignment.
%
% Also you should have only ONE for-loop, as for-loops are VERY slow in matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% using the init. assignment create all possible alt blockassignments
assignments = repmat(A,d,1);
% if d = 2, then we have two different assignments to process
% for the vars in V (block), we need to create all labels variations
assignments(:,V) = repmat((1:d)',1,blocklen);

% for each variable in V, fetch factors that contain V_i in scope
idx_rel_factors = [G.var2factors{V}];
unique_idx_rel_factors = unique(idx_rel_factors);

% summation of factor-values of each factor within the log-space
nFactors = length(unique_idx_rel_factors);
for n = 1:nFactors
    curr_factor_idx = unique_idx_rel_factors(n);
    % fetch current relevant factor
    curr_factor = F(curr_factor_idx);
    curr_assignments = assignments(:,curr_factor.var);
    factor_vals = GetValueOfAssignment(curr_factor,curr_assignments);
    LogBS = LogBS + log(factor_vals);
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Re-normalize to prevent underflow when you move back to probability space
LogBS = LogBS - min(LogBS);


% determine block length of variables to be sampled simultaneously
% blocklen = length(V);
% for each variable idx V_i, fetch factors that contain V_i in scope
% rel_factors = cell(blocklen,1);
% M_blanket = cell(blocklen,1);
% for v = 1:blocklen
%     var_idx = V(v);
%     factor_idxs = G.var2factors{var_idx};
%     rel_factors{v} = factor_idxs;
%     for each variable in V we find the Markov Blanket using G.edges matrix
%     blanket_idxs = find(G.edges(v,:));
%     M_blanket{v} = blanket_idxs;
% end    
% clear("factor_idxs","v","var_idx","blanket_idxs");