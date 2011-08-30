function [gx,gy,gt]=gaussgradient(IM,size,sigma)
% GAUSSGRADIENT Gradient using first order derivative of Gaussian.
%  [gx,gy,gt]=gaussgradient(IM,sigma) outputs the gradient image gx,gy and
%  gt image IM using a 3D Gaussian kernel. Sigma is the standard deviation of
%  this kernel along all the three directions.
% IM
%   3D image cube
% size
%   The size of the Gaussian kernel
% sigma
%   The variance of Gaussian function

    % Generate 3-D Gaussian kernels along x/y/t directions
    halfsize = round(size/2);
    hx=zeros(size,size,size);
    hy=zeros(size,size,size);
    ht=zeros(size,size,size);
    for i=1:size
        for j=1:size
            for k=1:size
                u=[i-halfsize-1 j-halfsize-1 k-halfsize-1];
                hx(i,j,k)=gauss(u(1),sigma)*gauss(u(3),sigma)*dgauss(u(2),sigma);
                hy(i,j,k)=gauss(u(2),sigma)*gauss(u(3),sigma)*dgauss(u(1),sigma);
                ht(i,j,k)=gauss(u(1),sigma)*gauss(u(2),sigma)*dgauss(u(3),sigma);
            end
        end
    end
    hx = hx/sqrt(sum(sum(sum(abs(hx).*abs(hx)))));
    hy = hy/sqrt(sum(sum(sum(abs(hy).*abs(hy)))));
    ht = ht/sqrt(sum(sum(sum(abs(ht).*abs(ht)))));

    % 3D filtering
    gx = imfilter(IM,hx,'replicate','corr');
    gy = imfilter(IM,hy,'replicate','corr');
    gt = imfilter(IM,ht,'replicate','corr');

end


function y = gauss(x,sigma)
% GAUSS Gaussian function
    y = exp(-x^2/(2*sigma^2)) / (sigma*sqrt(2*pi));
end

function y = dgauss(x,sigma)
% DGAUSS first order derivative of Gaussian
    y = -x * gauss(x,sigma) / sigma^2;
end