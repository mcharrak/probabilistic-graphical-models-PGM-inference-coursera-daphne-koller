% FactorMaxMarginalization Max-marginalizes a factor 
% by taking the max over a given set variables.
% 
%   B = FactorMaxMarginalization(A,V) computes the factor with the variables
%   in V maxed out. The factor data structure has the following fields:
%       .var    Vector of variables in the factor, e.g. [1 2 3]
%       .card   Vector of cardinalities corresponding to .var, e.g. [2 2 2]
%       .val    Value table of size prod(.card)
%
%   B.var will be A.var minus V.
%   For each assignment in B, its value is the maximum value in A 
%   of all assignments in A consistent with that assignment in B.
%
%   The resultant factor should have at least one variable remaining or this
%   function will throw an error.
%
%   This is exactly the same as FactorMarginalization, 
%   but with the sum replaced by a max.
% 
%   See also FactorMarginalization.m, IndexToAssignment.m, and AssignmentToIndex.m
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function B = FactorMaxMarginalization(A, V)

% Check for empty factor or variable list
if (isempty(A.var) || isempty(V)), B = A; return; end

% Construct the output factor over A.var \ V (the variables in A.var that are not in V)
% and mapping between variables in A and B
[B.var, mapB] = setdiff(A.var, V);
%mapB tells us what columns of the initial factor we will keep in the newly
%created Max-marginalized factor

% Check for empty resultant factor
if isempty(B.var)
  error('Error: Resultant factor has empty scope');
end

% initialization
% you should set them to the correct values in your code
B.card = [];
B.val = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
% Correctly set up and populate the factor values of B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialization
% you should set them to the correct values in your code
B.card = A.card(mapB);
B.val = zeros(1,prod(B.card));

% Compute some helper indices
% These will be very useful for calculating C.val
% so make sure you understand what these lines are doing
assignments = IndexToAssignment(1:length(A.val), A.card);
%retrieve rel. indices for new factor B but! relative to initial
%factor A
indxB = AssignmentToIndex(assignments(:, mapB), B.card);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
% Correctly set up and populate the factor values of B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(B.val)
    % find returns row and column indices
    [rel_row_idxs,~] = find(indxB == i);
    rel_values = A.val(rel_row_idxs);
    max_value = max(rel_values);
    B.val(i) = max_value;
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%% SLOWER ALT.SOLUTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%old_assignments = IndexToAssignment(1:prod(A.card),A.card);
%new_assignments = IndexToAssignment(1:prod(B.card),B.card);
%adjust length of new_assignemnts to old_assignments s.t. same length
%repeat_factor = length(old_assignments)/length(new_assignments);
%new_assignments = repmat(new_assignments,repeat_factor,1);

% for i = 1:length(B.val)
%     [q,~] = ismember(old_assignments(:,mapB), new_assignments(i,:),'rows');
%     rel_idxs = find(q);
%     rel_assignments = old_assignments(q,:);
%     rel_values = GetValueOfAssignment(A,rel_assignments);
%     max_value = max(GetValueOfAssignment(A,rel_assignments));
%     disp("relevant indices:")
%     disp(rel_idxs)
%     disp("relevant values:")
%     disp(rel_values)
%     %disp(A.val(indx))
%     disp("chosen value:")
%     disp(max(rel_values))
%     %disp(max(A.val(indx)))
%     disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
%     B.val(i) = max_value;
% end    


% % initialization
% % you should set them to the correct values in your code
% B.card = [];
% B.val = [];
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % YOUR CODE HERE
% % Correctly set up and populate the factor values of B
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% B.card = A.card(mapB);
% B.val = log(zeros(1,prod(B.card))); % Note: default value is -Inf instead of zero
% 
% assignments = IndexToAssignment(1:length(A.val), A.card);
% indxB = AssignmentToIndex(assignments(:, mapB), B.card);
% 
% for i = 1:length(A.val),
%     B.val(indxB(i)) = max(B.val(indxB(i)), A.val(i));
% end


% % initialization
% % you should set them to the correct values in your code
% B.card = [];
% B.val = [];
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % YOUR CODE HERE
% % Correctly set up and populate the factor values of B
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % Initialize B.card and B.val
% B.card = A.card(mapB);
% B.val = zeros(1,prod(B.card));
% 
% % Compute some helper indices
% assignments = IndexToAssignment(1:length(A.val), A.card);
% indxB = AssignmentToIndex(assignments(:, mapB), B.card);
% 
% for i = 1:length(B.val)
%     [indx, dummy] = find(indxB == i);
%      B.val(i)  = max(A.val(indx));
% end

