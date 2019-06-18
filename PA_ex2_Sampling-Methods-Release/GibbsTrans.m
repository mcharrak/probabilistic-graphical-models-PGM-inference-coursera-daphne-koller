% GIBBSTRANS
%
%  MCMC transition function that performs Gibbs sampling.
%  A - The current joint assignment.  This should be
%      updated to be the next assignment
%  G - The network
%  F - List of all factors
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function A = GibbsTrans(A, G, F)

% loop over all variables in the network and update its assignment value
for i = 1:length(G.names)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    % For each variable in the network sample a new value for it given everything
    % else consistent with A.  Then update A with this new value for the
    % variable.  NOTE: Your code should call BlockLogDistribution().
    % IMPORTANT: you should call the function randsample() exactly once
    % here, and it should be the only random function you call.
    %
    % Also, note that randsample() requires arguments in raw probability space
    % be sure that the arguments you pass to it meet that criteria
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    V = i;
    %nLabels var X_i equals to cardinality of variable X_i
    nLabels_X_i = G.card(V);
    
    log_prob_dist = BlockLogDistribution(V,G,F,A);
    % because log_prob is the log-probability dist. randsample() requires 
    % raw-probability dist. -> exp(log_prob_dist)
    raw_prob_dist = exp(log_prob_dist);
    % sample new assignment value for current variable X_i
    new_value = randsample(nLabels_X_i,1,true,raw_prob_dist);
    % update A with new value for the variable X_i
    A(V) = new_value;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
