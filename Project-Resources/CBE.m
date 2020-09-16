main()
 
%% Function to generate European map and load ozone data onto it
% Inputs:
%    None
% References:
%   Math Works A (2020) How can I create a button that says yes & no? [online] available from
%       <https://uk.mathworks.com/matlabcentral/answers/165016-how-can-i-create-a-button-that-says-yes-no> [03/04/2020]
function main()
    % Create some data
    [X] = 30.05:0.1:69.95; % create X values
    [Y] = -24.95:0.1:44.95;% create Y values
    % create a mesh of values

    % The data you will have from the NetCDF files will be X, Y and Z where
    % X & Y are the Lat and Lon values in a vector form
    % Z represents the ozone in a 2D array
    % The data provided here as X, Y, Z is in the corresponding formats.

    %% Create a display of the data from the NetCDF files like this
    

    % Create the map
    ax = worldmap('Europe');                                            % set the part of the earth to show

    load coastlines
    plotm(coastlat,coastlon)                                            % Load European coastlines

    land = shaperead('landareas', 'UseGeoCoords', true);
    geoshow(gca, land, 'FaceColor', [0.5 0.7 0.5])                      % Load European coordinates

    lakes = shaperead('worldlakes', 'UseGeoCoords', true);
    geoshow(lakes, 'FaceColor', 'blue')                                 % Load European lakes

    rivers = shaperead('worldrivers', 'UseGeoCoords', true);
    geoshow(rivers, 'Color', 'blue')                                    % Load European rivers

    cities = shaperead('worldcities', 'UseGeoCoords', true);
    geoshow(cities, 'Marker', '.', 'Color', 'red')                      % Load European cities

    %% Ask user if they want colourblind mode
    dlgTitle    = 'User Question';
    dlgQuestion = 'Do you need colourblind mode?';
    choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');
    if strcmpi(choice, 'Yes')
        colMap = bone;
        settings(colMap,ax);
    else
        colMap = jet;
        settings(colMap,ax);
    end

    map = gcf;                                                          % Setting the current figure plot to equal map
    
    %% Choosing movie mode or step mode
    dlgTitle    = 'User Question';
    dlgQuestion = 'Do you want movie mode?';
    choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');          % Creates a question popup box, 'Yes' or 'No'
    hour = 1;
    if strcmpi(choice, 'Yes')                                           % If the user chooses 'Yes'
        movieMode(map,X,Y,hour);
    else
        stepMode(map,X,Y,hour);                                         % If the user chooses 'No'
    end
end

%% Function to generate colormap and allow for zoom
% Inputs:
%    colMap {colorbar} - colorbar colour set
%    ax {figure} - European map
% References:
%   Math Works B (2020) title string on vertical colorbar [online] available form
%       <https://uk.mathworks.com/matlabcentral/answers/11205-title-string-on-vertical-colorbar> [03/04/2020]
%   Math Works C (2020) Setting plot zoom mode? [online] available from
%       <https://uk.mathworks.com/matlabcentral/answers/18387-setting-plot-zoom-mode> [03/04/2020]
function settings(colMap,ax)
    colormap(flipud(colMap))                                            % Set colour of colormap
    cb = colorbar
    cb.Position = cb.Position + [.05 0 0 0];                            % Reposition colourbar
    caxis([-0.2 1])                                                     % Setting the colorbar range to fixed
    ylabel(cb,'Ozone Levels (0~Low,1~High)','FontSize',20);             % Creating a colorbar label

    %% Fixes plot to allow for zooming
    ax.Clipping = 'off';                                                % Prevents the plot from misshaping
    h = zoom;                                                            
    set(h,'Motion','horizontal','Enable','on');                         % Enables zoom feature
end

%% Function to load each ozone hour CSV file automatically in a loop
% Inputs:
%   map {figure} - current map figure
%   X {vector} - x plot values
%   Y {vector} - y plot values
%   hour {int} - which csv hour file to load
% References:
%   Math Works D (2020) Graphics Object Handles [online] available from
%       <https://uk.mathworks.com/help/matlab/creating_plots/how-to-work-with-graphics-objects.html> [03/04/2020]
%   Math Works E (2020) How to make MATLAB detect keyboard stroke? [online] available from
%       <https://uk.mathworks.com/matlabcentral/answers/335596-how-to-make-matlab-detect-keyboard-stroke> [03/04/2020]
%   Math Works F (2020) Splitlines [online] available from
%       <https://uk.mathworks.com/help/matlab/ref/splitlines.html> [03/04/2020]
%   Math Works G (2020) How can I create a text box alongside my plot? [online] available from
%       <https://uk.mathworks.com/matlabcentral/answers/385245-how-can-i-create-a-text-box-alongside-my-plot>
function movieMode(map,X,Y,hour)
    %% Importing the ozone data from the CSV files
    AvailableFiles = dir((fullfile('./', '*.csv')));                    % List available data files
    try
        Z = flip(importdata(AvailableFiles(1).name));                   % Importing the first hour CSV file

        %% Plot the data
        ozone = surfm(X, Y, Z, 'EdgeColor', 'none',...
            'FaceAlpha', 0.5)                                           % edge colour outlines the edges,
                                                                        % 'FaceAlpha', sets the transparency
    catch
        warning('Problem importing or plotting CBE file %d',1);         % Catches any errors and displays error message
        return;                                                         % Exits program 
    end
    while ishandle(map)                                                 % If the figure exists, i.e. not been deleted
        title({'European Ozone Levels';['Hour ',num2str(hour)]});       % Shows which hour is being displayed
        try
            Z = flip(importdata(AvailableFiles(hour).name));            % Imports the given hour CSV file
        catch
            warning('Problem importing CBE file %d',hour);              % Catches any errors and displays error message
            return;                                                     % Exits program 
        end
        disp(AvailableFiles(hour).name);                                % Displays the current CSV file to terminal
        try
            ozone.CData = Z;                                            % Updates the Z data of the plot
        catch
            warning('Problem plotting CBE file %d',hour);               % Catches any errors and displays error message
            return;                                                     % Exits program 
        end
        pause(0.2);                                                     % Pauses to show the different hours, otherwise no change perceived
        hour = hour +1;                                                 % Sets up to load next hour CSV file
        if hour > 25                                                    % If reached the last hour CSV file, start from 1 again
            hour = 1;
        end
    end
end

%% Function to load each ozone hour CSV file according with the users choice
% Inputs:
%   map {figure} - current map figure
%   X {vector} - x plot values
%   Y {vector} - y plot values
%   hour {int} - which csv hour file to load
% References:
%   Same as movieMode()
function stepMode(map,X,Y,hour)
    AvailableFiles = dir((fullfile('./', '*.csv')));                    % List available data files
    try
        Z = flip(importdata(AvailableFiles(1).name));                   % Importing the first hour CSV file

        %% Plot the data
        ozone = surfm(X, Y, Z, 'EdgeColor', 'none',...
            'FaceAlpha', 0.5)                                           % edge colour outlines the edges,
                                                                        % 'FaceAlpha', sets the transparency
    catch
        warning('Problem importing CBE file %d',1);                     % Catches any errors and displays error message
        return;                                                         % Exits program 
    end
    chr =  "Right Arrow ~ next hour" + "\n" + "Left Arrow ~ previous hour";
    annotation('textbox', [0.1, 0.8, 0.1, 0.1], 'String', compose(chr));
    while ishandle(map)                                                 % If the figure exists, i.e. not been deleted
        title({'European Ozone Levels';['Hour ',num2str(hour)]});       % Shows which hour is being displayed
        key_press = waitforbuttonpress;                                 % Waits for a key to be pressed
        if key_press && strcmp(get(map,'CurrentKey'),'rightarrow')      % If the rightarrow key is pressed
            if hour == 25
                hour = 1;
            else
                hour = hour + 1;
            end
            try
                Z = flip(importdata(AvailableFiles(hour).name));        % Imports the given hour CSV file
            catch
                warning('Problem importing CBE file %d',hour);          % Catches any errors and displays error message
                return;                                                 % Exits program 
            end    
            disp(AvailableFiles(hour).name);                            % Displays the current CSV file to terminal
            try
                ozone.CData = Z;                                        % Updates the Z data of the plot
            catch
                warning('Problem plotting CBE file %d',hour);           % Catches any errors and displays error message
                return;                                                 % Exits program 
            end
        else if key_press && strcmp(get(map,'CurrentKey'),'leftarrow')  % If the leftarrow key is pressed 
            if hour == 1
                hour = 25;
            else 
                hour = hour - 1;
            end
            try
                Z = flip(importdata(AvailableFiles(hour).name));        % Imports the given hour CSV file
            catch
                warning('Problem importing CBE file %d',hour);          % Catches any errors and displays error message
                return;                                                 % Exits program 
            end
            disp(AvailableFiles(hour).name);                            % Displays the current CSV file to terminal
            try
                ozone.CData = Z;                                        % Updates the Z data of the plot
            catch
                warning('Problem importing CBE file %d',hour);          % Catches any errors and displays error message
                return;                                                 % Exits program 
            end
        end
    end
end
end
