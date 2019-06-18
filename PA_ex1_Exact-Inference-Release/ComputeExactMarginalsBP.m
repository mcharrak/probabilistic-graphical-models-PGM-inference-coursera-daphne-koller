%COMPUTEEXACTMARGINALSBP Runs exact inference and returns the marginals
%over all the variables (if isMax == 0) or the max-marginals (if isMax == 1). 
%
%   M = COMPUTEEXACTMARGINALSBP(F, E, isMax) takes a list of factors F,
%   evidence E, and a flag isMax, runs exact inference and returns the
%   final marginals for the variables in the network. If isMax is 1, then
%   it runs exact MAP inference, otherwise exact inference (sum-prod).
%   It returns an array of size equal to the number of variables in the 
%   network where M(i) represents the ith variable and M(i).val represents 
%   the marginals of the ith variable. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function M = ComputeExactMarginalsBP(F, E, isMax)

% initialization
% you should set it to the correct value in your code
%M = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Implement Exact and MAP Inference.

% create clique tree
P = CreateCliqueTree(F, E);
% calibrate clique tree
P_cali = CliqueTreeCalibrate(P, isMax);
n_cliques = length(P_cali.cliqueList);
% create LUT for each (var_i - {C_i}) s.t var_i in scope(C_i)
n_vars = length(unique(cell2mat({F(:).var})));
% create output object
M = repmat(struct('var', [], 'card', [], 'val', []), n_vars, 1);
LUT_var_to_C = cell(n_vars,1);
for a = 1:n_vars
    buf = [];
    for b = 1:n_cliques
        curr_scope = P_cali.cliqueList(b).var;
        if ismember(a,curr_scope)
            buf = [buf , b];
        end  
    end
    LUT_var_to_C{a} = buf;
end

for b = 1:n_vars
    % from all candidate cliques, choose smallest clique
    best_clique_idx = min(LUT_var_to_C{b});
    clique = P_cali.cliqueList(best_clique_idx);
    clique_vars = clique.var;
    factor_var = b;
    marg_out_vars = setdiff(clique_vars,factor_var);
    if isMax
        marginal = FactorMaxMarginalization(clique,marg_out_vars);
    else
        marginal = FactorMarginalization(clique,marg_out_vars);
        Z = sum(marginal.val);
        marginal.val = marginal.val/Z;   
    end
    M(b) = marginal;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
