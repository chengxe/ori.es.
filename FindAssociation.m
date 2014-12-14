%
%
%
function [candidateIdxes, etas] = FindAssociation(imgSize, measurements, gatePoints)

    candidateIdxes = []; etas = [];
    if ( ~isempty(find(gatePoints(1,:)>imgSize(1))) || ~isempty(find(gatePoints(2,:)>imgSize(2))) || ...
         ~isempty(find(gatePoints(1,:)<1)) || ~isempty(find(gatePoints(2,:)<1)) )
        return;
    end
    try
        occupiedPixelList = sub2ind(imgSize, gatePoints(2,:), gatePoints(1, :));
        regionLimit = cat(2, measurements.d1limit);
        idx1 = find(regionLimit(1,:)>=min(occupiedPixelList)); idx2 = find(regionLimit(2,:)<=max(occupiedPixelList));
        idxes = intersect(idx1, idx2);
        for i=1:length(idxes)
            overlapped = measurements(idxes(i)).d1pixels(ismember(measurements(idxes(i)).d1pixels, occupiedPixelList));
            if ( 0 == isempty(overlapped) )
                candidateIdxes = [candidateIdxes, idxes(i)];
                etas = [etas, length(overlapped) / length(measurements(idxes(i)).d1pixels)];
            end
            clear overlapped;
        end
    catch
        warning('max [%d;%d], min [%d;%d]',max(gatePoints(1,:)), max(gatePoints(2,:)), min(gatePoints(1,:)), min(gatePoints(2,:)));
        candidateIdxes = []; etas = []; return;
    end
    
    
end