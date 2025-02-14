classdef DynamicGridView < dynamicprops
    %GUI Summary of this class goes here
    %   Detailed explanation goes here
    
    %% --- PROPERTIES ------------------------------------------------------------------------------
    % references
    properties (Constant)
        appName     string  = "Dynamic Grid View Demo"
        appVersion  string  = "1.0"

    end

    % behavior flags
    properties (Access = public)
        verbose     logical = true  % if TRUE then interactions are announced to stdout

    end

    % dependent properties
    properties (Dependent, AbortSet)
        mouseCoordsVisible logical  % toggle display of mouse coordinates (primarily for dev/debug)
        viewOrientation string      % "doublewide", "wide", "tall", or <missing>

    end

    % view elements
    properties (SetAccess = private)
        uifig           matlab.ui.Figure
        grid_fig            matlab.ui.container.GridLayout
        pnl_ctrl                matlab.ui.container.Panel
        grid_ctrl                   matlab.ui.container.GridLayout
        lbl_newmsg                      matlab.ui.control.Label
        edt_newmsg                      matlab.ui.control.EditField
        pbn_sendmsg                     matlab.ui.control.Button
        cbx_resize                      matlab.ui.control.CheckBox
        ax                      matlab.ui.control.UIAxes
        pnl_msgs                matlab.ui.container.Panel
        grid_msgs                   matlab.ui.container.GridLayout
        txta_msgs                       matlab.ui.control.TextArea

    end

    %% --- EVENTS ----------------------------------------------------------------------------------
    events
        UserInteraction

    end
    
    %% --- METHODS ---------------------------------------------------------------------------------
    methods % constructor/destructor
        function obj = DynamicGridView
            % build the gui
            obj.makefigure
            obj.addcomponents
            obj.layout

            % make visible
            obj.uifig.Visible = "on";

            % turn on mouse coords
            obj.mouseCoordsVisible = true;

        end

        function delete(~)

        end % delete

        function closegui(obj, varargin)
            % close uifigure if it exists
            isFigPresent = ishandle(obj.uifig) && isvalid(obj.uifig);
            if isFigPresent
                delete(obj.uifig)

            end

            % now delete the object
            obj.delete

        end % closegui

    end % constructor/destructor

    %% ---------------------------------------------------------------------------------------------
    methods % get/set
        function value = get.viewOrientation(obj)
            if isvalid(obj.uifig)
                w = obj.uifig.Position(3);
                h = obj.uifig.Position(4);
                if      w >= 2 * h;     value = 'doublewide';
                elseif  w >= h;         value = 'wide';
                else;                   value = "tall";
                end

            else
                value = missing;

            end

        end % get.viewOrientation

        function value = get.mouseCoordsVisible(obj)
                value = isprop(obj, "txta_mousecoords");

        end % get.mouseCoordsVisible

        function set.mouseCoordsVisible(obj, value)
            persistent DP
            if value == true
                % make coords location
                DP = addprop(obj, "txta_mousecoords");
                obj.txta_mousecoords = uitextarea( ...
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

                % remove coords location
                delete(obj.txta_mousecoords);
                delete(DP);

            end

            function dispmousecoords(~, ~, obj)
                cursorPos = obj.uifig.CurrentPoint;
                locString = sprintf('X: %3d Y: %3d', cursorPos(1), cursorPos(2));
                obj.txta_mousecoords.Value = locString;

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
            obj.grid_fig        = uigridlayout(obj.uifig);
            obj.pnl_ctrl            = uipanel(obj.grid_fig);
            obj.grid_ctrl               = uigridlayout(obj.pnl_ctrl);
            obj.lbl_newmsg                  = uilabel(obj.grid_ctrl);
            obj.edt_newmsg                  = uieditfield(obj.grid_ctrl);
            obj.pbn_sendmsg                 = uibutton(obj.grid_ctrl);
            obj.cbx_resize                  = uicheckbox(obj.grid_ctrl);
            obj.ax                  = uiaxes(obj.grid_fig);
            obj.pnl_msgs            = uipanel(obj.grid_fig);
            obj.grid_msgs               = uigridlayout(obj.pnl_msgs);               
            obj.txta_msgs                   = uitextarea(obj.grid_msgs);

            % set component details
            obj.pnl_ctrl.Title = "Control Panel";

            obj.edt_newmsg.Placeholder = "(placeholder text)";

            obj.pnl_msgs.Title = "Message Panel";

            obj.grid_msgs.BackgroundColor = [0.3 0.3 0.3];
            obj.grid_msgs.Padding = 0;
            obj.grid_msgs.RowSpacing = 0;
            obj.grid_msgs.ColumnSpacing = 0;

            obj.txta_msgs.Placeholder = "(placeholder text)";

        end % addcomponents

        function layout(obj, ~, ~)
            % here we determine position of components relative to figure and one another
            % NOTE: separation of layout concerns makes dynamic resizing more straightforward
            persistent prevOrientation % track previous state, scope limited to this method
            currentOrientation = obj.viewOrientation;

            isRefreshNeeded = isempty(prevOrientation) || ~strcmp(currentOrientation, prevOrientation);
            if isRefreshNeeded
                switch currentOrientation
                    case "doublewide"
                        % main grid
                        obj.grid_fig.RowHeight    = {'1x'};
                        obj.grid_fig.ColumnWidth  = {120, '1x', '1x'};
                        setlayout(obj.pnl_ctrl,     1,      1);
                        setlayout(obj.ax,           1,      2);
                        setlayout(obj.pnl_msgs,     1,      3);

                        % subgrid 'ctrl'
                        obj.grid_ctrl.RowHeight    = {'fit', 'fit', 'fit' 'fit', '1x'};
                        obj.grid_ctrl.ColumnWidth  = {'1x'};
                        setlayout(obj.lbl_newmsg,   1,      1);
                        setlayout(obj.edt_newmsg,   2,      1);
                        setlayout(obj.pbn_sendmsg,  3,      1);
                        setlayout(obj.cbx_resize,   4,      1);

                        % subgrid 'msgs'
                        obj.grid_msgs.RowHeight    = {'1x'};
                        obj.grid_msgs.ColumnWidth  = {'1x'};
                        setlayout(obj.txta_msgs,    1,      1);

                    case "wide"
                        % main grid
                        obj.grid_fig.RowHeight    = {'1x', 120};
                        obj.grid_fig.ColumnWidth  = {120, '1x'};
                        setlayout(obj.pnl_ctrl,     1:2,    1);
                        setlayout(obj.ax,           1,      2);
                        setlayout(obj.pnl_msgs,     2,      2);

                        % subgrid 'ctrl'
                        obj.grid_ctrl.RowHeight    = {'fit', 'fit', 'fit' 'fit', '1x'};
                        obj.grid_ctrl.ColumnWidth  = {'1x'};
                        setlayout(obj.lbl_newmsg,   1,      1);
                        setlayout(obj.edt_newmsg,   2,      1);
                        setlayout(obj.pbn_sendmsg,  3,      1);
                        setlayout(obj.cbx_resize,   4,      1);

                        % subgrid 'msgs'
                        obj.grid_msgs.RowHeight    = {'1x'};
                        obj.grid_msgs.ColumnWidth  = {'1x'};
                        setlayout(obj.txta_msgs,    1,      1);

                    case "tall"
                        % main grid
                        obj.grid_fig.RowHeight    = {120, '1x', 120};
                        obj.grid_fig.ColumnWidth  = {'1x'};
                        setlayout(obj.pnl_ctrl,     1,      1);
                        setlayout(obj.ax,           2,      1);
                        setlayout(obj.pnl_msgs,     3,      1);

                        % subgrid 'ctrl'
                        obj.grid_ctrl.RowHeight    = {'1x'};
                        obj.grid_ctrl.ColumnWidth  = {'1x', '1x', '1x', '1x'};
                        setlayout(obj.lbl_newmsg,   1,      1);
                        setlayout(obj.edt_newmsg,   1,      2);
                        setlayout(obj.pbn_sendmsg,  1,      3);
                        setlayout(obj.cbx_resize,   1,      4);

                        % subgrid 'msgs'
                        obj.grid_msgs.ColumnWidth  = {'1x'};
                        obj.grid_msgs.RowHeight    = {'1x'};
                        setlayout(obj.txta_msgs,    1,      1);

                    otherwise

                end % switch

                % keep track
                prevOrientation = currentOrientation;

            end % if refresh needed

            % --- internal helper function(s) ---
            function setlayout(thing, rows, cols)
                thing.Layout.Row = rows;
                thing.Layout.Column = cols;

            end % setlayout

        end % layout

    end % methods private

    methods (Static)
        function killfigures
            close all force

        end % killfigures

    end % methods static

end

