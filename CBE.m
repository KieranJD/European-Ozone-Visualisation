    %%
    % Create some data
    [X] = 30.05:0.1:69.95; % create X value
    [Y] = -24.95:0.1:44.95;% create Y values
    % create a mesh of values
    
    % The data you will have from the NetCDF files will be X, Y and Z where
    % X & Y are the Lat and Lon values in a vector form
    % Z represents the ozone in a 2D array
    % The data provided here as X, Y, Z is in the corresponding formats.

    %% Create a display of the data from the NetCDF files like this
    [X,Y] = meshgrid(X, Y);

    figure(1);
    clf
    % Create the map
    ax = worldmap('Europe'); % set the part of the earth to show

    load coastlines
    plotm(coastlat,coastlon)

    land = shaperead('landareas', 'UseGeoCoords', true);
    geoshow(gca, land, 'FaceColor', [0.5 0.7 0.5])

    lakes = shaperead('worldlakes', 'UseGeoCoords', true);
    geoshow(lakes, 'FaceColor', 'blue')

    rivers = shaperead('worldrivers', 'UseGeoCoords', true);
    geoshow(rivers, 'Color', 'blue')

    cities = shaperead('worldcities', 'UseGeoCoords', true);
    geoshow(cities, 'Marker', '.', 'Color', 'red')

    % colourblind mode
    dlgTitle    = 'User Question';
    dlgQuestion = 'Do you need colourblind mode?';
    choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');
    disp(choice);
    if strcmpi(choice, 'Yes')
        colMap = bone;
    else
        colMap = jet;
    end
    
    % Setting up color map
    colormap(flipud(colMap))
    cb = colorbar
    cb.Position = cb.Position + [.05 0 0 0]; %Reposition colourbar
    caxis([-0.2 1])
    ylabel(cb,'\fontsize{16}Ozone Levels (0~Low,1~High)')

    %Fixes graph to always fit when zooming
    ax.Clipping = 'off';
    h = zoom;
    h.Motion = 'horizontal';
    h.Enable = 'on';

    % Importing the ozone data 
    map = gcf;
    AvailableFiles = dir((fullfile('./', '*.csv'))); % list available data files
    Z = importdata(AvailableFiles(1).name);

    % Plot the data
    ozone = surfm(X, Y, Z, 'EdgeColor', 'none',...
        'FaceAlpha', 0.5) % edge colour outlines the edges, 'FaceAlpha', sets the transparency

%% https://uk.mathworks.com/help/matlab/creating_plots/how-to-work-with-graphics-objects.html
% Loads each ozone hour onto the static Eupoean map, leading to quicker execution due to only onzone data being loaded
hour = 1;
while hour <= 25
    % Shows which hour is being displayed
    title({'Eupoean Ozone Levels';['Hour ',num2str(hour)]});
    key_press = waitforbuttonpress;
    if key_press && strcmp(get(map,'CurrentKey'),'rightarrow')
        if hour == 25
            hour = 1;
        else
            hour = hour + 1;
        end
        Z = importdata(AvailableFiles(hour).name);
        disp(AvailableFiles(hour).name);
        ozone.CData = Z;
    else if key_press && strcmp(get(map,'CurrentKey'),'leftarrow')
        if hour == 1
            hour = 25;
        else 
            hour = hour - 1;
        end
        Z = importdata(AvailableFiles(hour).name);
        disp(AvailableFiles(hour).name);
        ozone.CData = Z;
    end
end

end
