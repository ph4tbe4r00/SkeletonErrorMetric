%
% Decription: parses a Piet-generated XML file and loads it into matlab
%             data structures.
%

function breadcrumbs = loadPietData(filename, breadcrumbs, ...
    breadcrumbsOriginal, z, ...
    minX, maxX, minY, maxY, cropOff, downsample, verbose)
if nargin > 10,
    fVerbose = 1;
else
    fVerbose = 0;
end

% read in xml file
contour_root = parseXML(filename);
contours = contour_root(2).Children;

% loop through all processes
cnt = 1;
for i=1:length(contours),
    if (strcmp('contour', contours(i).Name)),
        attrib = contours(i).Attributes;
        name = '';
        
        % loop through contour attributes
        for j=1:length(attrib),
            if (strcmp(attrib(j).Name, 'name')),
                name = attrib(j).Value;
                if (fVerbose), 
                    fprintf(1, 'name: %s\n', name); 
                end
                break;
            elseif (strcmp(attrib(j).Name, 'class')),
                %fprintf(1, 'class: %s\n', attrib(j).Value);
            elseif (strcmp(attrib(j).Name, 'color')),
                %fprintf(1, 'color: %s\n', attrib(j).Value);
            elseif (strcmp(attrib(j).Name, 'visible')),
                %fprintf(1, 'visible: %s\n', attrib(j).Value);
            end
        end
        
        % loop through contour data
        contour_data = contours(i).Children;
        for j=1:length(contour_data),
            if (strcmp(contour_data(j).Name, 'value')),
                pt = contour_data(j).Children.Attributes;
                
                % add offset data
                crumbValue = offset(str2double(pt(1).Value), str2double(pt(2).Value), ...
                                z, minX, maxX, minY, maxY, cropOff, downsample);
                if (isKey(breadcrumbs, name)),
                    breadcrumbs(name) = [breadcrumbs(name); crumbValue];
                else
                    breadcrumbs(name) = [crumbValue];
                end
              
                % add original data
                crumbValue2 = offset(str2double(pt(1).Value), str2double(pt(2).Value), ...
                                z, NaN, NaN, NaN, NaN, NaN, NaN);
                if (isKey(breadcrumbsOriginal, name)),
                    breadcrumbsOriginal(name) = [breadcrumbsOriginal(name); crumbValue2];
                else
                    breadcrumbsOriginal(name) = [crumbValue2];
                end
                
                if (fVerbose),
                    fprintf(1, 'x: %i y: %i\n', breadcrumbs(name));
                end
                cnt = cnt+1;
            end
        end
    end
end

end

function [off] = offset(x, y, z, minX, maxX, minY, maxY, cropOff, downsample)
    if ~isnan(minX)
        off = zeros(1,3);
        off(1) = round(1/downsample*((x-minX)-cropOff));
        off(2) = round(1/downsample*((y-minY)-((maxY-minY)/(maxX-minX)*cropOff)));
        off(3) = z;
    else
        off = [x y z];
    end
end