function [x, w] = gausslegendre(n)
            beta = 0.5./sqrt(1-(2*(1:n-1)).^(-2));
            [Q,D] = eig(diag(beta,1) + diag(beta,-1));
            [x, i] = sort(diag(D));
            w = 2*Q(1,i).^2';
end