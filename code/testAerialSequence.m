function testAerialSequence()
    load('../data/aerialseq.mat');
    nFrames = size(frames,3);
    
    sampleIndex = [30,60,90,120];
    
    for i = 1:length(sampleIndex)
        mask = SubtractDominantMotion(frames(:,:,sampleIndex(i)), frames(:,:,sampleIndex(i)+1));
        img = imshow(imfuse(frames(:,:,sampleIndex(i)), mask));
        hold on;
        filename = sprintf('../results/q33_%d', sampleIndex(i));
        saveas(img, filename);
        close
    end
end
