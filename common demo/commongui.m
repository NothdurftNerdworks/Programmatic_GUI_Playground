classdef commongui < matlab.mixin.SetGet
    %GUI Summary of this class goes here
    %   Detailed explanation goes here
    
    %% --- PROPERTIES ------------------------------------------------------------------------------
    properties %(SetAccess = immutable)
        appName     string  = "Common Gui Components Demo"
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
        function obj = commongui
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
            % here we add the components and static styling
            % NOTE: we avoid 'position' arguments as these are set in layout independently

            % common params
            ComParams = struct();
            ComParams.FontName = "Arial";
            ComParams.FontSize = 12;
            ComParams.FontColor = [0 0 0];

            % "uipanel" p = uipanel;
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel.html
            C = uipanel(obj.uifig);
            C.Title = "CONTROLS";
            C.BackgroundColor = [0.2 0.2 0.4];
            obj.components.pnl_ctrl = C;

            % "uilabel"
            %   https://www.mathworks.com/help/matlab/ref/uilabel.html
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.control.label.html
            C = uilabel(obj.uifig, ComParams);
            C.Text = "My Label";
            obj.components.lbl = C;

            % "uibutton" btn = uibutton; (push)
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.control.button.html
            C = uibutton(obj.components.pnl_ctrl, ComParams);
            C.Text = "My Button";
            C.Icon = rand([20 20 3]);
            C.IconAlignment = "top";
            obj.components.pbn = C;

            % "uicheckbox" cbx = uicheckbox;
            %   https://www.mathworks.com/help/matlab/ref/uicheckbox.html
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.control.checkbox.html
            C = uicheckbox(obj.components.pnl_ctrl, ComParams);
            C.Text = "My Checkbox";
            obj.components.cbx = C;
            
            % "uieditfield" ef = uieditfield;
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.control.editfield.html
            C = uieditfield(obj.components.pnl_ctrl, ComParams);
            C.Placeholder = "(placeholder text)";
            obj.components.ef = C;

            % "uitextarea" txa = uitextarea;
            % "uiaxes" ax = uiaxes;
            % "uimenu" m = uimenu;

        end % addcomponents

        function layout(obj, ~, ~)
            % here we determine position of components relative to figure and one another
            % NOTE: separation of layout concerns makes dynamic resizing more straightforward
            obj.components.lbl.Position(1:2) = [20 100];
            obj.components.btn.Position(1:2) = [20 150];
            obj.components.cbx.Position(1:2) = [20 160];

        end % layout

    end % methods private

    methods (Static)
        function killfigures
            close all force

        end % killfigures

    end % methods static

end

