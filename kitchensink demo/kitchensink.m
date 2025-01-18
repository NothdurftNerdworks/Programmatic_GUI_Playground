classdef kitchensink < matlab.mixin.SetGet
    %GUI Summary of this class goes here
    %   Detailed explanation goes here
    
    %% --- PROPERTIES ------------------------------------------------------------------------------
    properties %(SetAccess = immutable)
        appName     string  = "All The Bits"
        appVersion  string  = "1.0"
        verbose     logical = true  % if TRUE then interactions are announced to stdout     

    end

    properties (Dependent, AbortSet)
        mouseCoordsVisible logical % toggle display of mouse coordinates (primarily for dev/debug)

    end

    properties (SetAccess = private)
        uifig matlab.ui.Figure = matlab.ui.Figure.empty
        components struct = struct() % struct to hold the various gui components

    end

    %% --- EVENTS ----------------------------------------------------------------------------------
    events
        UserInteraction

    end
    
    %% --- METHODS ---------------------------------------------------------------------------------
    methods % constructor/destructor
        function obj = kitchensink
            % build the gui
            obj.makefigure
            obj.addcomponents
            obj.layout

            % make visible
            obj.uifig.Visible = "on";

            % turn on mouse coords
            obj.mouseCoordsVisible = true;

        end

        function delete(obj)


        end

        function closegui(obj, varargin)
            % close uifigure if it exists
            isFigPresent = ishandle(obj.uifig) && isvalid(obj.uifig);
            if isFigPresent
                delete(obj.uifig)

            end

            % now delete the object
            obj.delete

        end

    end % constructor/destructor

    %% ---------------------------------------------------------------------------------------------
    methods % get/set
        function value = get.mouseCoordsVisible(obj)
                value = isfield(obj.components, 'mousecoords');

        end % get.mouseCoordsVisible

        function set.mouseCoordsVisible(obj, value)
            if value == true
                disp('turn on mouse coords')
                % make coords location visible
                obj.components.mousecoords = uitextarea( ...
                    parent          = obj.uifig, ...
                    Position        = [5 5 110 20], ...
                    BackgroundColor = [0.81 1.00 0.02], ...
                    FontName        = 'Courier', ...
                    FontSize        = 12, ...
                    WordWrap        = 'off', ...
                    Editable        = 'off', ...
                    BusyAction      = 'cancel');

                % turn on callback
                obj.uifig.WindowButtonMotionFcn = {@dispmousecoords, obj};               

            else
                disp('turn off mouse coords')
                % turn off callback
                obj.uifig.WindowButtonMotionFcn = '';

                % make coords location hidden
                delete(obj.components.mousecoords);

            end

            function dispmousecoords(~, ~, obj)
                cursorPos = obj.uifig.CurrentPoint;
                locString = sprintf('X: %3d Y: %3d', cursorPos(1), cursorPos(2));
                obj.components.mousecoords.Value = locString;

            end % dispmousecoords

        end % set.mouseCoordsVisible

    end % methods get/set

    %% ---------------------------------------------------------------------------------------------
    methods (Access = private) % private
        function makefigure(obj)
            % figure particulars
            figWidth = 400;
            figHeight = 400;
            resizeStatus = "on";

            % coordinates to center the figure
            screenPos = get(0,'ScreenSize');
            wScreen = screenPos(3);
            hScreen = screenPos(4);
            left = wScreen/2 - figWidth/2;
            bottom = hScreen/2 - figHeight/2;

            % create main figure
            obj.uifig = uifigure( ...
                Visible         = "off", ...
                CloseRequestFcn = @obj.closegui, ...                % closing figure also deletes the object
                DeleteFcn       = @obj.closegui, ...                % if figure is destroyed by other means, delete the object
                Name            = strcat(obj.appName, " ", obj.appVersion), ...
                Position        = [left bottom figWidth, figHeight], ...
                Resize          = resizeStatus, ...
                AutoResizeChildren = 'off', ...
                SizeChangedFcn  = @obj.layout);

        end % makefigure

        function addcomponents(obj)
            % ADDCOMPONENTS add UI components to the main figure
            %   For this project we aim to add examples for all available UI components in current MATLAB
            %
            %   List of components can be found at:
            %   https://www.mathworks.com/help/matlab/creating_guis/choose-components-for-your-app-designer-app.html

            % common components
            commonComponents = ["uibutton", "uicheckbox", "uicolorpicker", "uisetcolor"]

            % List of common UI components in MATLAB as a string array
            uiComponents = [
                "uicontrol", ...
                "uifigure", ...

                "uiknob", ...
                "uidropdown", ...
                "uipanel", ...
                "uitab", ...
                "uitabgroup", ...

                "uiflowcontainer", ...
                "uigridlayout", ...

                "uimenu", ...
                "uitoolbar", ...
                "uicontextmenu"
                ];

            %% common components
            % "uibutton" style can be "push" or "state".
            btn = uibutton;

            % "uicheckbox"
            cbx = uicheckbox;

            % "uicolorpicker"
            c = uicolorpicker; % 2024A
            c = uisetcolor;

            % "uidatepicker"
            d = uidatepicker;

            % "uidropdown"
            dd = uidropdown;

            % "uieditfield" style can be "text" or "numeric"
            ef = uieditfield;

            % "hlink"
            hlink = uihyperlink;

            % "uiimage"
            im = uiimage;

            % "uilabel"
            lbl = uilabel;

            % "uilistbox"
            lb = uilistbox;

            % "uibuttongroup"
            %   https://www.mathworks.com/help/matlab/ref/uibuttongroup.html
            %   https://www.mathworks.com/help/matlab/ref/uiradiobutton.html
            bg = uibuttongroup;
            rb = uiradiobutton;

            % "uislider" style can be "slider" or "range"
            %   https://www.mathworks.com/help/matlab/ref/uislider.html
            sld = uislider;

            % "uispinner"
            %   https://www.mathworks.com/help/matlab/ref/uispinner.html
            spn = uispinner;

            % "uitable"
            %   https://www.mathworks.com/help/matlab/ref/uitable.html
            uit = uitable;

            % "uitextarea"
            %   https://www.mathworks.com/help/matlab/ref/uitextarea.html
            txa = uitextarea;

            % "uitogglebutton"
            %   https://www.mathworks.com/help/matlab/ref/uibuttongroup.html
            %   https://www.mathworks.com/help/matlab/ref/uitogglebutton.html
            bg = uibuttongroup;
            tb = uitogglebutton;

            % "uitree" style can be 'tree' or 'checkbox'
            %   https://www.mathworks.com/help/matlab/ref/uitree.html
            %   https://www.mathworks.com/help/matlab/ref/uitreenode.html
            t = uitree;
            node = uitreenode;

            %% axes
            % "uiaxes"
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.control.uiaxes-properties.html
            ax = uiaxes;

            % "axes"
            %   https://www.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html
            ax = axes;

            % "geoaxes"
            %   https://www.mathworks.com/help/matlab/ref/matlab.graphics.axis.geographicaxes-properties.html
            gx = geoaxes;

            % "polaraxes"
            %   https://www.mathworks.com/help/matlab/ref/matlab.graphics.axis.polaraxes-properties.html
            px = polaraxes;

            %% containers and figure tools
            % "uigridlayout"
            %   https://www.mathworks.com/help/matlab/ref/uigridlayout.html
            g = uigridlayout;

            % "uipanel"
            %   https://www.mathworks.com/help/matlab/ref/uipanel.html
            p = uipanel;


        end % addcomponents

        function layout(obj, ~, ~)

        end % layout

    end % methods private

    methods (Static)
        function killfigures
            close all force

        end % killfigures

    end % methods static

end

