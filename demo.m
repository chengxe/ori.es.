close all
clc;

%%
clear all
dataset = [3,299];  startSeq = 1;

type = 'nonortho'

load ([type,'\simu028\stereoModel.mat']);
load ([type,'\simu028\trajectories.mat']);
for i = 1 : length(trajectories)
    trajectories(i).rec = [];
end

[x,y,z] = sphere(25);
gateSphere = 6*[x(:)';y(:)';z(:)'];

isdebug = 0;
%% ------------------------------------------------------
starts = cat(2, trajectories.start); ends = cat(2, trajectories.end);
for n = dataset(1) : dataset(2)
    t = n-startSeq+1;  clear cams
    display(['processing image ',num2str(n),' at time ',num2str(t)]); tic
    %------------------------------------------------------
    cams(1).image = imread(sprintf('%s\\simu028\\camx\\imx%03d.jpg',type,n));
    cams(1).measurements = GetMeasurement(cams(1).image);
    if ( isdebug )
        figure(1); clf; subplot(131); imshow(cams(1).image); hold on;
        for m = 1 : length(cams(1).measurements)
            DrawEllipseWithAxis(cams(1).measurements(m).ellipse, '-g');
        end
    end
    
    cams(2).image = imread(sprintf('%s\\simu028\\camy\\imy%03d.jpg',type,n));
    cams(2).measurements = GetMeasurement(cams(2).image);
    if ( isdebug )
        subplot(132); imshow(cams(2).image); hold on;
        for m = 1 : length(cams(2).measurements)
            DrawEllipseWithAxis(cams(2).measurements(m).ellipse, '-g');
        end    
    end
    
    cams(3).image = imread(sprintf('%s\\simu028\\camz\\imz%03d.jpg',type,n));
    cams(3).measurements = GetMeasurement(cams(3).image);
    if ( isdebug )
        subplot(133); imshow(cams(3).image); hold on;
        for m = 1 : length(cams(3).measurements)
            DrawEllipseWithAxis(cams(3).measurements(m).ellipse, '-g');
        end    
    end
    idx1 = find(starts<=t); idx2 = find(ends>=t); active = intersect(idx1, idx2);
    for idx = active
        target = trajectories(idx);
        d3Location = target.pts(:, t-target.start+1); d3Velocity = target.vel(:, t-target.start+1);
        
        aSphere = bsxfun(@plus, gateSphere, d3Location);
        %-----------------------
        d2GateCam1 = stStereoModel.cams(1).projection * [aSphere; ones(1, size(aSphere, 2))]; 
        d2GateCam1(1:2, :) = d2GateCam1(1:2, :) ./ repmat(d2GateCam1(3, :), 2, 1); d2GateCam1 = floor(d2GateCam1(1:2,:)); d2GateCam1 = unique(d2GateCam1', 'rows')';
        if ( isdebug )
            subplot(131); plot(d2GateCam1(1,:), d2GateCam1(2,:), '-c'); end
        [candidateCam1, etaCam1] = FindAssociation(size(cams(1).image), cams(1).measurements, d2GateCam1);
        if ( isempty(candidateCam1) )
            continue; end
        %-----------------------
        d2GateCam2 = stStereoModel.cams(2).projection * [aSphere; ones(1, size(aSphere, 2))]; 
        d2GateCam2(1:2, :) = d2GateCam2(1:2, :) ./ repmat(d2GateCam2(3, :), 2, 1); d2GateCam2 = floor(d2GateCam2(1:2,:)); d2GateCam2 = unique(d2GateCam2', 'rows')';
        [candidateCam2, etaCam2] = FindAssociation(size(cams(2).image), cams(2).measurements, d2GateCam2);
        if ( isdebug )
            subplot(132); plot(d2GateCam2(1,:), d2GateCam2(2,:), '-c'); end
        if ( isempty(candidateCam2) )
            continue; end
        %-----------------------
        d2GateCam3 = stStereoModel.cams(3).projection * [aSphere; ones(1, size(aSphere, 2))]; 
        d2GateCam3(1:2, :) = d2GateCam3(1:2, :) ./ repmat(d2GateCam3(3, :), 2, 1); d2GateCam3 = floor(d2GateCam3(1:2,:)); d2GateCam3 = unique(d2GateCam3', 'rows')';
        [candidateCam3, etaCam3] = FindAssociation(size(cams(3).image), cams(3).measurements, d2GateCam3);
        if ( isdebug )
            subplot(133); plot(d2GateCam3(1,:), d2GateCam3(2,:), '-c'); end
        if ( isempty(candidateCam3) )
            continue; end
        
        %----------------------------------------------------------------------------
        candidateOrientations = [];
        for i1 = candidateCam1
            gammas(1) = cams(1).measurements(i1).ellipse.radii(2) / cams(1).measurements(i1).ellipse.radii(1);
            for i2 = candidateCam2
                gammas(2) = cams(2).measurements(i2).ellipse.radii(2) / cams(2).measurements(i2).ellipse.radii(1);
                for i3 = candidateCam3
                    gammas(3) = cams(3).measurements(i3).ellipse.radii(2) / cams(3).measurements(i3).ellipse.radii(1);
                    
                    [~, ix] = sort(gammas, 'descend'); ix = ix(1:2); ix = sort(ix, 'ascend'); idd = [i1, i2, i3];
                    
                    d3Orientation = ReconstructOrientation(stStereoModel.cams(ix(1)), stStereoModel.cams(ix(2)), cams(ix(1)).measurements(idd(ix(1))).ellipse, cams(ix(2)).measurements(idd(ix(2))).ellipse);
                    [theta, phi, ~] = cart2sph(d3Orientation(1),d3Orientation(2),d3Orientation(3)); 
                    if ( phi < 0 ) d3Orientation = -d3Orientation; end
                    candidateOrientations = [candidateOrientations, d3Orientation];
                    
%                     if ( gamma1 < 1.3 )
%                         % 2 & 3
%                         d3Orientation = ReconstructOrientation(stStereoModel.cam2, stStereoModel.cam3, cams(2).measurements(i2).ellipse, cams(3).measurements(i3).ellipse);
%                         if ( acos( unit(d3Orientation)' * unit(d3Velocity) ) > pi/2 )
%                             d3Orientation = -d3Orientation; end
%                         candidateOrientations = [candidateOrientations, d3Orientation];
%                         continue;
%                     end
%                     if ( gamma2 < 1.3)  
%                         % 1 & 3
%                         d3Orientation = ReconstructOrientation(stStereoModel.cam1, stStereoModel.cam3, cams(1).measurements(i1).ellipse, cams(3).measurements(i3).ellipse);
%                         if ( acos( unit(d3Orientation)' * unit(d3Velocity) ) > pi/2 )
%                             d3Orientation = -d3Orientation; end
%                         candidateOrientations = [candidateOrientations, d3Orientation];
%                         continue;
%                     end
%                     % 1 & 2
%                     d3Orientation = ReconstructOrientation(stStereoModel.cam1, stStereoModel.cam2, cams(1).measurements(i1).ellipse, cams(2).measurements(i2).ellipse);
%                     if ( acos( unit(d3Orientation)' * unit(d3Velocity) ) > pi/2 )
%                         d3Orientation = -d3Orientation; end
%                     candidateOrientations = [candidateOrientations, d3Orientation];
                end
            end
        end
        
        %----------------------------------------------------------------------------
        if ( size(candidateOrientations, 2) > 1 )
            [vTheta, ~, ~] = cart2sph(d3Velocity(1), d3Velocity(2), d3Velocity(3));
            sphOrientations = [];
            for i = 1 : size(candidateOrientations, 2)
                [sphOrientations(1,i), sphOrientations(2,i), ~] = cart2sph(candidateOrientations(1,i),candidateOrientations(2,i),candidateOrientations(3,i));
            end
            % dummy weighted flags, etaX should be incorprated.
            sphOrientations(1,:) = 1*(sphOrientations(1,:) - vTheta); sphOrientations(2,:) = 2*(sphOrientations(2,:) - pi/4);
            flags = sum(abs(sphOrientations)); [~, i] = min(flags);
            d3Orientation = candidateOrientations(:, i);
        else
            d3Orientation = candidateOrientations(:,1);
        end
        
        
         trajectories(idx).rec = [ trajectories(idx).rec, d3Orientation ];
    end
    
    toc
end

save([type,'\trajectories.mat'], 'trajectories');