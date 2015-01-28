function [ R, t ] = umeyama( X, Y, plotResult )
%UMEYAMA Corresponding point set registration with Umeyama method.
%
% [R, t] = umeyama(X, Y)   returns the rotation matrix R and translation
% vector t that approximate X = R * Y + t using least-squares estimation. X
% and Y are in format [3xn] and point X(:,i) corresponds to point Y(:,i)
% for all i.
%
% [R, t] = umeyama(X, Y, true)  returns the same result but in addition a
% figure is created plotting the registration result and the average
% registration error.
%
% Author: Christoph Graumann, 2015
%   Chair for Computer Aided Medical Procedures and Augmented Reality
%   Technische Universität München (Munich, Germany) and 
%   Johns Hopkins University (Baltimore, MD, USA)

assert(size(X,1)==size(Y,1) && size(X,2)==size(Y,2),'Dimensions of matrices must match!');

%% Demean
m = size(X,1);
n = size(X,2);
mean_X = mean(X,2);
mean_Y = mean(Y,2);
X_demean = X - repmat(mean_X,1,size(X,2));
Y_demean = Y - repmat(mean_Y,1,size(Y,2));

%% SVD
sigma = 1/n*X_demean*Y_demean';
[U,~,V] = svd(sigma);

%% Define S
S = eye(m);
if det(sigma) < 0 || (rank(sigma) == m-1 && det(U)*det(V) < 0)
    S(m,m) = -1;
end

%% Bootstrap
R = U*S*V';
t = mean_Y - R*mean_X;

%% Plotting
if nargin>2 && plotResult
    figure('name','Result of Umeyama registration');
    scatter3(X(1,:),X(2,:),X(3,:),'g*');
    hold on;
    scatter3(Y(1,:),Y(2,:),Y(3,:),'b*');
    Y_prime = [R t; 0 0 0 1] * [Y;ones(1,size(Y,2))];
    scatter3(Y_prime(1,:),Y_prime(2,:),Y_prime(3,:),'r*');
    axis equal tight;
    legend('Destination points','Source points','Transformation result');
    MEAN_REGISTRATION_ERROR = norm(mean(X - Y_prime(1:3,:),2))
end

end
