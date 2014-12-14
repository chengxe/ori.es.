function d3Orientation = ReconstructOrientation(cam1, cam2, cam1Ellipse, cam2Ellipse)


    major(:,1) = cam1Ellipse.center - cam1Ellipse.axis(:,2) * cam1Ellipse.radii(2);
    major(:,2) = cam1Ellipse.center + cam1Ellipse.axis(:,2) * cam1Ellipse.radii(2);
    rayActual1 = InlineGenerateRay(cam1,major(:,1));
    rayActual2 = InlineGenerateRay(cam1,major(:,2));
    %--------------------------------------------------
    major(:,1) = cam2Ellipse.center - cam2Ellipse.axis(:,2) * cam2Ellipse.radii(2);
    major(:,2) = cam2Ellipse.center + cam2Ellipse.axis(:,2) * cam2Ellipse.radii(2);
    rayDesire1 = InlineGenerateRay(cam2,major(:,1));
    rayDesire2 = InlineGenerateRay(cam2,major(:,2));
    %--------------------------------------------------
    normActual = cross(rayActual1.d, rayActual2.d); 
    normDesire = cross(rayDesire1.d,rayDesire2.d);
    orientation = cross(normActual,normDesire); 
    
    d3Orientation = unit(orientation);
end


%
%
function ray3d = InlineGenerateRay(cam, d2Point)
    Mi = inv(cam.projection(1:3,1:3)); p4 = cam.projection(:,4);
    ray3d.P0 = -Mi*p4;
    ray3d.d = unit(Mi*e2h(d2Point));
end