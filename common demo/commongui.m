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
        mouseCoordsVisible logical  % toggle display of mouse coordinates (primarily for dev/debug)
        pageLayout string           % "doublewide", "wide", "tall", or <missing>

    end

    properties (SetAccess = private)
        uifig matlab.ui.Figure = matlab.ui.Figure.empty
        components struct = struct()        % struct to hold the various gui components
        prevPageLayout string = missing     % track when necessary to redo layout

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
        function value = get.pageLayout(obj)
            if isvalid(obj.uifig)
                w = obj.uifig.Position(3);
                h = obj.uifig.Position(4);
                if w >= h
                    if w >= 2 * h
                        value = 'doublewide';

                    else
                        value = "wide";

                    end

                else
                    value = "tall";

                end

            else
                value = missing;

            end

        end % get.pageLayout

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

            % build the tree
            C.grid          = uigridlayout(obj.uifig);
            C.pnl_ctrl          = uipanel(C.grid);
            C.grid_ctrl             = uigridlayout(C.pnl_ctrl);
            C.lbl_newmsg                = uilabel(C.grid_ctrl);
            C.edt_newmsg                = uieditfield(C.grid_ctrl);
            C.pbn_sendmsg               = uibutton(C.grid_ctrl);
            C.cbx_resize                = uicheckbox(C.grid_ctrl);
            C.ax                = uiaxes(C.grid);
            C.pnl_msgs          = uipanel(C.grid);
            C.grid_msgs             = uigridlayout(C.pnl_msgs);               
            C.txta_msgs                 = uitextarea(C.grid_msgs);


            C.grid_msgs.BackgroundColor = [0.3 0.3 0.3];
            C.grid_msgs.Padding = 0;
            C.grid_msgs.RowSpacing = 0;
            C.grid_msgs.ColumnSpacing = 0;

            C.pnl_ctrl.Title = "Control Panel";
            C.pnl_msgs.Title = "Message Panel";

            %{
            % common params
            ComParams = struct();
            ComParams.FontName = "Arial";
            ComParams.FontSize = 10;
            ComParams.FontColor = [0 0 0];

            % "uipanel" p = uipanel;
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel.html
            
            C.pnl_ctrl.Title = "CONTROLS";
            C.pnl_ctrl.BackgroundColor = [0.2 0.2 0.4];

            % "uilabel"
            %   https://www.mathworks.com/help/matlab/ref/uilabel.html
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.control.label.html
            
            C.Text = "My Label";
            obj.components.lbl = C;

            % "uibutton" btn = uibutton; (push)
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.control.button.html
            C.Text = "My Button";
            C.Icon = rand([20 20 3]);
            C.IconAlignment = "top";
            obj.components.pbn = C;

            % "uicheckbox" cbx = uicheckbox;
            %   https://www.mathworks.com/help/matlab/ref/uicheckbox.html
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.control.checkbox.html
            C.Text = "My Checkbox";
            obj.components.cbx = C;
            
            % "uieditfield" ef = uieditfield;
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.control.editfield.html
            C.Placeholder = "(placeholder text)";
            obj.components.ef = C;

            % "uitextarea" txa = uitextarea;
            %   https://www.mathworks.com/help/matlab/ref/matlab.ui.control.textarea.html
            C 
            C.Placeholder = "(placeholder text)";
            obj.components.txa = C;

            % "uiaxes" ax = uiaxes;
            % "uimenu" m = uimenu;
            %}

            obj.components = C;

        end % addcomponents

        function layout(obj, ~, ~)
            % here we determine position of components relative to figure and one another
            % NOTE: separation of layout concerns makes dynamic resizing more straightforward

            isRefreshNeeded = ismissing(obj.prevPageLayout) || ~strcmp(obj.pageLayout, obj.prevPageLayout);
            if isRefreshNeeded
                % prep
                C = obj.components;

                switch obj.pageLayout
                    case "doublewide"
                        % main grid
                        C.grid.RowHeight    = {'1x'};
                        C.grid.ColumnWidth  = {120, '1x', '1x'};
                        setlayout(C.pnl_ctrl,   1,      1);
                        setlayout(C.ax,         1,      2);
                        setlayout(C.pnl_msgs,   1,      3);

                        % subgrid 'ctrl'
                        C.grid_ctrl.RowHeight    = {'fit', 'fit', 'fit' 'fit', '1x'};
                        C.grid_ctrl.ColumnWidth  = {'1x'};
                        setlayout(C.lbl_newmsg,     1,  1);
                        setlayout(C.edt_newmsg,     2,  1);
                        setlayout(C.pbn_sendmsg,    3,  1);
                        setlayout(C.cbx_resize,     4,  1);

                        % subgrid 'msgs'
                        C.grid_msgs.RowHeight    = {'1x'};
                        C.grid_msgs.ColumnWidth  = {'1x'};
                        setlayout(C.txta_msgs,      1,  1);

                    case "wide"
                        % main grid
                        C.grid.RowHeight    = {'1x', 120};
                        C.grid.ColumnWidth  = {120, '1x'};
                        setlayout(C.pnl_ctrl,   1:2,    1);
                        setlayout(C.ax,         1,      2);
                        setlayout(C.pnl_msgs,   2,      2);

                        % subgrid 'ctrl'
                        C.grid_ctrl.RowHeight    = {'fit', 'fit', 'fit' 'fit', '1x'};
                        C.grid_ctrl.ColumnWidth  = {'1x'};
                        setlayout(C.lbl_newmsg,     1,  1);
                        setlayout(C.edt_newmsg,     2,  1);
                        setlayout(C.pbn_sendmsg,    3,  1);
                        setlayout(C.cbx_resize,     4,  1);

                        % subgrid 'msgs'
                        C.grid_msgs.RowHeight    = {'1x'};
                        C.grid_msgs.ColumnWidth  = {'1x'};
                        setlayout(C.txta_msgs,      1,  1);

                    case "tall"
                        % main grid
                        C.grid.RowHeight    = {120, '1x', 120};
                        C.grid.ColumnWidth  = {'1x'};
                        setlayout(C.pnl_ctrl,   1,      1);
                        setlayout(C.ax,         2,      1);
                        setlayout(C.pnl_msgs,   3,      1);

                        % subgrid 'ctrl'
                        C.grid_ctrl.RowHeight    = {'1x'};
                        C.grid_ctrl.ColumnWidth  = {'1x', '1x', '1x', '1x'};
                        setlayout(C.lbl_newmsg,     1,  1);
                        setlayout(C.edt_newmsg,     1,  2);
                        setlayout(C.pbn_sendmsg,    1,  3);
                        setlayout(C.cbx_resize,     1,  4);

                        % subgrid 'msgs'
                        C.grid_msgs.ColumnWidth  = {'1x'};
                        C.grid_msgs.RowHeight    = {'1x'};
                        setlayout(C.txta_msgs,      1,  1);

                    otherwise

                end % switch

            end % if refresh needed

            function setlayout(thing, rows, cols)
                thing.Layout.Row = rows;
                thing.Layout.Column = cols;

            end

        end % layout

    end % methods private

    methods (Static)
        function killfigures
            close all force

        end % killfigures

    end % methods static

end

