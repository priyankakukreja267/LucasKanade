function [u,v] = LucasKanadeInverseCompositional(It, It1, rect)

    % input - image at time t, image at t+1, rectangle (top left, bot right coordinates)
    % output - movement vector, [u,v] in the x- and y-directions.
    rect = int32(rect);
    x1 = rect(1);
    y1 = rect(2);
    x2 = rect(3);
    y2 = rect(4);
    rowsW = y2-y1+1;
    colsW = x2-x1+1;
    n = rowsW*colsW; % 'n' is the total number of pixels in the template

    T = double(It(y1:y2, x1:x2));
    I = double(It1);

    rowsI = size(I, 1);
    colsI = size(I, 2);

    X = repmat((1:colsI), rowsI, 1);
    Y = repmat((1:rowsI)', 1, colsI);
    V = I;

    % Precompute gradient of T, J, steepest Descent and H
    [gradTx, gradTy] = gradient(T);
    grad = [reshape(gradTx, [n,1]), reshape(gradTy, [n,1])]; % grad is nX2 matrix
    J = [1 0; 0 1]; % J is 2X2
    sDescent = grad*J; % sDescent is nX2
    H = sDescent'*sDescent; %H is 2X2

    p0 = 0;
    p1 = 0;

    e = 1;
    while e > 0.75
        templateX = repmat((x1+p0:x2+p0), rowsW, 1);
        templateX = double(templateX);
        size(templateX);

        templateY = repmat((y1+p1:y2+p1)', 1, colsW);
        templateY = double(templateY);
        size(templateY);

        warpedI = interp2(X,Y,V,templateX,templateY);
        size(warpedI);

        errorImg = warpedI - T; % errorImg is rowsW X colsW
        errorImg = reshape(errorImg, [n, 1]); % errorImg is nX1

        M7 = sDescent'*errorImg; % M7 is 2X1

        deltaP = inv(H)*M7; %deltaP is 2X1
        p0 = p0 - deltaP(1);
        p1 = p1 - deltaP(2);
        
        e = sqrt( (deltaP(1)*deltaP(1)) + (deltaP(2)*deltaP(2)) );
    end

    u = p0;
    v = p1;
end