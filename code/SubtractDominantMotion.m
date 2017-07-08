function mask = SubtractDominantMotion(image1, image2)

% input - image1 and image2 form the input image pair
% output - mask is a binary image of the same size
    M = LucasKanadeAffine(image1, image2);
    rowsI1 = size(image1,1);
    colsI1 = size(image1,2);
    warpedI2 = warpImage(image2, M);
    diff = image1 - warpedI2;
    for i = 1:colsI1
        for j = 1:rowsI1
            sprintf('%d %d', i,j);
            if diff(j,i) >= 75
                diff(j,i) = 0;
            else
                diff(j,i) = 255;
            end
        end
    end
    mask = diff;
end

function warpedI = warpImage(I, M)
    % I = im2double(I);
    V = double(I);

    rowsI = size(I, 1);
    colsI = size(I, 2);

    [pX, pY] = meshgrid(1:1:colsI, 1:1:rowsI);
    pX = reshape(pX,[rowsI*colsI,1]);
    pY = reshape(pY, [ rowsI*colsI,1]);
    P = [pX'; pY'; ones(1,rowsI*colsI)];

    warpedP = M\P;

    warpedI = interp2(V, warpedP(1, :)', warpedP(2, :)');
    warpedI(isnan(warpedI)) = 0;
    warpedI = reshape(warpedI', [rowsI colsI]);
    warpedI = uint8(warpedI);
end
