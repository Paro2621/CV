function F = EightPointsAlgorithmN(P1, P2)
    % task 1.2.1 - normalization
    [newpts1, T1] = normalise2dpts(P1);
    [newpts2, T2] = normalise2dpts(P2);
    
    % task 1.2.2 - EightPointsAlgorithm 
    n = size(P1,2);

    m2 = [1 0 0; 1 0 0; 1 0 0; 0 1 0; 0 1 0; 0 1 0; 0 0 1; 0 0 1; 0 0 1];
    m1 = [1 0 0; 0 1 0; 0 0 1; 1 0 0; 0 1 0; 0 0 1; 1 0 0; 0 1 0; 0 0 1];
    
    A = zeros(n,9);
    
    % task 1.1.1 - write matrix A
    for i = 1:n        
        A(i, :) = (m2*newpts2(:, i))' .* (m1*newpts1(:, i))' ;
    end

    % task 1.1.2 - SVD decomposition and solution selection
    [~, ~, V] = svd(A);
    
    V_end = V(:, end);
    
    F = [V_end(1:3)'; V_end(4:6)'; V_end(7:9)'];
    
    % task 1.1.3 - rank 2 enforcement and F recomputation
    [U1, D1, V1] = svd(F);   
    D1(3, 3) = 0;
    
    F_tilde = U1*D1*V1';

    % task 1.2.3 - de-normalization
    F = T2'*F_tilde*T1;
end