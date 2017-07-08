function testUSSeqAffine()
    load('../data/usseq.mat');
    load('../results/usseqrects-wcrt.mat');
    sampleIndex = [5 25 50 75 100];
    
    for i = 1:length(sampleIndex)
        rect = int32(rects(sampleIndex(i),:));
        x1 = rect(1);
        y1 = rect(2);
        x2 = rect(3);
        y2 = rect(4);
        img1 = frames(y1:y2, x1:x2, i);
        img2 = frames(y1:y2, x1:x2, i+1);
        mask = SubtractDominantMotion(img1, img2);
        shiftedMask = zeros(size(frames, 1), size(frames, 2));
        shiftedMask(y1:y2, x1:x2) = mask;
        fusedImg = imshow(imfuse(frames(:,:,sampleIndex(i)), shiftedMask));
        hold on;
        filename = sprintf('../results/q33b_%d', sampleIndex(i));
        saveas(fusedImg, filename);
        close
    end
end
