%COMPUTEINITIALPOTENTIALS Sets up the cliques in the clique tree that is
%passed in as a parameter.
%
%   P = COMPUTEINITIALPOTENTIALS(C) Takes the clique tree skeleton C which is a
%   struct with three fields:
%   - nodes: cell array representing the cliques in the tree.
%   - edges: represents the adjacency matrix of the tree.
%   - factorList: represents the list of factors that were used to build
%   the tree. 
%   
%   It returns the standard form of a clique tree P that we will use through 
%   the rest of the assigment. P is struct with two fields:
%   - cliqueList: represents an array of cliques with appropriate factors 
%   from factorList assigned to each clique. Where the .val of each clique
%   is initialized to the initial potential of that clique.
%   - edges: represents the adjacency matrix of the tree. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = ComputeInitialPotentials(C)

% number of initial factors
F = C.factorList;
n_factors = length(F);
% number of cliques
N = length(C.nodes);
% initialize cluster potentials 
P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N, 1);
% copy adjacency matrix C.edges from input clique tree skeleton C
P.edges = C.edges;

% create LUT for var and cardinality
% extract all variables and corresponding cardinalities
vars = cell2mat({F.var})';
cards = cell2mat({F.card})';
LUT_var_card = unique([vars, cards],'rows');
clear vars
clear cards

% we only need cardinalities
card = LUT_var_card(:,2)';
% tranposed because .card is (1xn) array

% fill in variables fields and cardinality fields and dummy entries for
% cluster values (all ones)

% note down unassigned factors with one as we assign each factor only once
% to a specific cluster
unassigned_factors = ones(1,n_factors);

for i = 1:N
    clique_vars = C.nodes{i};
    P.cliqueList(i).var  = clique_vars;
    curr_card = card(C.nodes{i});
    P.cliqueList(i).card = curr_card;
    P.cliqueList(i).val  = ones(1,prod(curr_card));
    % above we fill everything with ones in case of missing variables at the
    % end of factor prodcut operation or cluster w/o assigned factors
    
    idx_unassigned_factors = find(unassigned_factors);
    for k = idx_unassigned_factors
        factor_vars = F(k).var;
        isSubset = isempty(setdiff(factor_vars, clique_vars));
        if isSubset
            % set factor k as assigned
            unassigned_factors(k) = 0;
            % fetch factor
            factor_k = F(k); 
            % perform factorproduct
            P.cliqueList(i) = FactorProduct(P.cliqueList(i),factor_k);
        end
    end
end
end

% function P = ComputeInitialPotentials(C)
% 
% % number of cliques
% N = length(C.nodes);
% 
% % initialize cluster potentials 
% P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N, 1);
% P.edges = zeros(N);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % YOUR CODE HERE
% %
% % First, compute an assignment of factors from factorList to cliques. 
% % Then use that assignment to initialize the cliques in cliqueList to 
% % their initial potentials. 
% 
% % C.nodes is a list of cliques.
% % So in your code, you should start with: P.cliqueList(i).var = C.nodes{i};
% % Print out C to get a better understanding of its structure.
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nFactor = length(C.factorList);
% 
% card = [];
% for i = 1:nFactor
%     card(C.factorList(i).var) = C.factorList(i).card;
% end
% 
% % flags(i) = 1 if factor(i) not assigned to clique
% flags = ones(1, nFactor);
% 
% for i=1:N
%     P.cliqueList(i) = struct('var', C.nodes{i}, 'card', card(C.nodes{i}), ...
%                     'val', ones(1, prod(card(C.nodes{i}))));
%     for k = find(flags)
%         if all(ismember(C.factorList(k).var, C.nodes{i}))
%             flags(k) = 0;
%             P.cliqueList(i) = FactorProduct(P.cliqueList(i), C.factorList(k));
%         end
%     end
% end
% 
% P.edges = C.edges;
% 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AMINE CODE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function P = ComputeInitialPotentials(C)
% % in order to pass submit tests for this assignment, we have to order the
% % factor vars in asending order
% n_factors = length(C.factorList);
% 
% F = C.factorList;
% F_new = ChangeVariablesOrder(F);
% 
% % number of cliques
% n_cluster = length(C.nodes);
% 
% % initialize cluster potentials 
% P.edges = zeros(n_cluster);
% P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), n_cluster, 1);
% 
% % 1.
% % adopt adjacency matrix C.edges from input clique tree skeleton C
% P.edges = C.edges;
% 
% % 2.
% % create LUT for var and cardinality
% % extract all variables and corresponding cardinalities
% vars = cell2mat({F_new.var})';
% cards = cell2mat({F_new.card})';
% LUT_var_card = unique([vars, cards],'rows');
% 
% % fill in variables fields and cardinality fields and dummy entries for
% % cluster values (all ones)
% for i = 1:n_cluster
%     P.cliqueList(i).var = C.nodes{i};
%     curr_vars = P.cliqueList(i).var;
%     P.cliqueList(i).card = LUT_var_card(curr_vars,2)';
%     % fill everything with ones in case of missing variables at the end of
%     % factor prodcut operation or cluster w/o assigned factors
%     n_val_entries = prod(P.cliqueList(i).card);
%     P.cliqueList(i).val = ones(1,n_val_entries); 
% end
% 
% factor_to_cluster = [];
% for j = 1:n_factors
%     % choose the correct variable from original factorlist (1st position)
%     factor_idx = F(j).var(1);
%     factor_vars = F_new(j).var;
% 
%     for cluster_idx = 1:n_cluster
%         clique_vars = P.cliqueList(cluster_idx).var;
%         %check if factor_vars is covered by clique_vars (Q: Is factor_vars
%         %subset of clique_vars?)
%         isSubset = isempty(setdiff(factor_vars, clique_vars));
%         if isSubset
%             factor_to_cluster = [factor_to_cluster; [factor_idx,cluster_idx]];
%         end  
%     end 
% end
% 
% % find unique first columns -> each factor is assigned to only one cluster
% [~, rows] = unique(factor_to_cluster(:, 1));
% % first col: factors / second col: cluster
% unique_factor_to_cluster = factor_to_cluster(rows,:);
% 
% for m = 1:n_cluster
%     idx_of_rel_factors = find(unique_factor_to_cluster(:,2) == m);
%     rel_factors = idx_of_rel_factors;
%     if isempty(rel_factors)
%         factor_product = P.cliqueList(m);        
%     elseif length(rel_factors) == 1
%         factor_product = P.cliqueList(m);
%         single_factor = F_new(rel_factors);
%         factor_product = FactorProduct(factor_product,single_factor);
%         P.cliqueList(m).val = factor_product.val;
%     else
%         factor_product = P.cliqueList(m);
%         for n = 1:length(rel_factors)
%             curr_factor_idx = rel_factors(n);
%             curr_factor = F_new(curr_factor_idx);
%             factor_product = FactorProduct(factor_product,curr_factor);
%         end        
%         P.cliqueList(m).val = factor_product.val;        
%     end
% end
% 
% 
