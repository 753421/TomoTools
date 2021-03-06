function mod_hdl = ShortScanAlignment_addin(handles)

% Panel addin for Alignment of projection images using an additional short scan
% Written by: Rob S. Bradley (c) 2015



%% LOAD DEFAULTS FOR SIZING COMPONENTS =================================
margin = handles.defaults.margin_sz;
button_sz = handles.defaults.button_sz;
edit_sz = handles.defaults.edit_sz;
info_sz = handles.defaults.info_sz;
axes_sz = handles.defaults.axes_sz;
status_sz = handles.defaults.status_sz;
central_pos = handles.defaults.central_pos;
panel_pos =  handles.defaults.panel_pos;
subpanel_pos = handles.defaults.subpanel_pos;
menu_sz_ratio = handles.defaults.menu_sz_ratio;

label_sz = [0 0 2*button_sz(1) edit_sz(2)];
control_sz =   [0 0 1.5*button_sz(1) edit_sz(2)];  

%Load file read defaults
FT = handles.defaults.file_types;
FLM = handles.defaults.loadmethods;


%% PANEL NAME==========================================================
mod_hdl.name = 'Short scan alignment';
mod_hdl.version = '1.0';
mod_hdl.target = 'P';
mod_hdl.FULLDATA = [];
mod_hdl.SSDATA = [];
mod_hdl.getSSDATA = @getSSDATA;
mod_hdl.apply_ff = [];

%% MAIN Panel=========================================================
mod_hdl.panel = uipanel('Parent', handles.action_panel, 'Units', 'normalized', 'Position', subpanel_pos, 'Title', 'Short scan alignment', 'visible', 'off');
set(handle(mod_hdl.panel), 'BorderType', 'line',  'HighlightColor', handles.defaults.border_colour, 'BorderWidth', handles.defaults.border_width, 'Units', 'pixels');  
subpanel_sz = get(mod_hdl.panel, 'Position');

%Load short scan
mod_hdl.Load_btn = uicontrol('Style', 'pushbutton', 'Parent', mod_hdl.panel, 'String', 'Load short scan', 'units', 'pixels', 'Callback', @load_short_scan);
set(mod_hdl.Load_btn, 'position', [0 0 1.5*button_sz(1) button_sz(2)], 'HorizontalAlignment', 'left', 'UserData', [1 1]); 
mod_hdl.File_label = uicontrol('Style', 'text', 'Parent', mod_hdl.panel, 'String', repmat(' ', [1 256]), 'units', 'pixels', 'Visible', 'off');
set(mod_hdl.File_label, 'position', [0 0 edit_sz(1) edit_sz(2)], 'HorizontalAlignment', 'left', 'UserData', [2 1]);

%View short scan
mod_hdl.ViewSS_btn = uicontrol('Style', 'pushbutton', 'Parent', mod_hdl.panel, 'String', 'View short scan', 'units', 'pixels', 'enable', 'off', 'Callback', @shortscan_preview);
set(mod_hdl.ViewSS_btn, 'position', [0 0 1.5*button_sz(1) button_sz(2)], 'HorizontalAlignment', 'left', 'UserData', [1 2]); 

%Image step
mod_hdl.ImageStep_label = uicontrol('Style', 'text', 'Parent', mod_hdl.panel, 'String', 'Image step:', 'units', 'pixels', 'enable', 'on');
set(mod_hdl.ImageStep_label, 'position', label_sz, 'HorizontalAlignment', 'right', 'UserData', [1 3]); 
mod_hdl.ImageStep = uicontrol('Style', 'edit', 'Parent', mod_hdl.panel, 'String', '1', 'units', 'pixels', 'enable', 'on');
set(mod_hdl.ImageStep, 'position', control_sz, 'HorizontalAlignment', 'left', 'UserData', [2.1 3], 'BackgroundColor', [1 1 1]); 

%Pyramid levels
mod_hdl.PyramidLevels_label = uicontrol('Style', 'text', 'Parent', mod_hdl.panel, 'String', 'Pyramid levels:', 'units', 'pixels', 'enable', 'on');
set(mod_hdl.PyramidLevels_label, 'position', label_sz, 'HorizontalAlignment', 'right', 'UserData', [1 4]); 
mod_hdl.PyramidLevels = uicontrol('Style', 'edit', 'Parent', mod_hdl.panel, 'String', '2', 'units', 'pixels', 'enable', 'on');
set(mod_hdl.PyramidLevels, 'position', control_sz, 'HorizontalAlignment', 'left', 'UserData', [2.1 4], 'BackgroundColor', [1 1 1]);

%Optimizer intitial radius
mod_hdl.OptRadius_label = uicontrol('Style', 'text', 'Parent', mod_hdl.panel, 'String', 'Optimizer radius:', 'units', 'pixels', 'enable', 'on');
set(mod_hdl.OptRadius_label, 'position', label_sz, 'HorizontalAlignment', 'right', 'UserData', [1 5]); 
mod_hdl.OptRadius = uicontrol('Style', 'edit', 'Parent', mod_hdl.panel, 'String', '0.0005', 'units', 'pixels', 'enable', 'on');
set(mod_hdl.OptRadius, 'position', control_sz, 'HorizontalAlignment', 'left', 'UserData', [2.1 5], 'BackgroundColor', [1 1 1]);


%View shifts
mod_hdl.SemiAutoMode_btn = uicontrol('Style', 'pushbutton', 'Parent', mod_hdl.panel, 'String', 'Semi-auto mode', 'units', 'pixels', 'enable', 'on', 'Callback', @SemiAuto_mode);
set(mod_hdl.SemiAutoMode_btn, 'position', [0 0 1.5*button_sz(1) button_sz(2)], 'HorizontalAlignment', 'left', 'UserData', [1 7]); 
mod_hdl.ViewShifts_btn = uicontrol('Style', 'pushbutton', 'Parent', mod_hdl.panel, 'String', 'View shifts', 'units', 'pixels', 'enable', 'on', 'Callback', @view_shifts);
set(mod_hdl.ViewShifts_btn, 'position', [0 0 1.5*button_sz(1) button_sz(2)], 'HorizontalAlignment', 'left', 'UserData', [2 7]); 


ch = findobj('Parent', mod_hdl.panel, 'Style', 'text');
uitextsize(ch);

simple_layout(mod_hdl.panel, 'LT-LM', margin*[3 4 1 1]);

%% RUN FUNCTION ========================================================            
mod_hdl.run_function = @(h,q) run_alignment(h, mod_hdl,q);     %FIX!!!!
mod_hdl.load_function = @(h) file_load(h, mod_hdl);  % function to run on file load

%% NESTED LOAD and VIEW
    function load_short_scan(~,~)
        path = get(mod_hdl.File_label, 'String');
        if isempty(path)
            path = handles.defaults.data_dir;
        end
        [filename, dir] = uigetfile(FT, 'Select file',path);
        if isnumeric(filename)
            return; 
        end
        %Determine file type
        [pathstr, name, ext] = fileparts(filename);        
        if ~isempty(regexpi(ext,'x*m'));
            %xradia file
            mod_hdl.filetype = 1;
        elseif ~isempty(regexpi(ext,'vg'));
            %xtek file
            mod_hdl.filetype = 2;
        else
            mod_hdl.filetype = 3;
        end

        
        
        [~, hdr_short] = feval(handles.defaults.loadmethods{mod_hdl.filetype,1}, [dir filename]);      
        
        if mod_hdl.filetype<3    
            FileContents = hdr_short.FileContents;    
        else
            FileContents = hdr_short.StackContents;
        end
        
        %Check short scan file contains projection images
        if ~strcmpi(FileContents(1), 'P')
            errordlg('Please select a file containing projection images');
            return;
        end
        %Check short scan image dimensions match that of full data  
        mod_hdl.FULLDATA = handles.getDATA();
        if ~isequal(mod_hdl.FULLDATA.dimensions(1:2), [hdr_short.ImageHeight hdr_short.ImageWidth])
            errordlg('Size of projection images does not match that of full data');
            return;
        end
        %Check short scan image dimensions match that of full data        
        if (mod_hdl.FULLDATA.dimensions(3)< hdr_short.NoOfImages)
            errordlg('Short scan contains more projections that full data!');
            return;
        end
        
        %PUT IN A CONTRAINT ON PIXEL SIZE??
        
        %CREATE SHORT SCAN DATA HANDLE
        mod_hdl.SSDATA = DATA3D([dir filename], hdr_short); 
        mod_hdl.SSDATA.apply_shifts = 1;
        set(mod_hdl.File_label, 'String', [dir filename]);
        if mod_hdl.SSDATA.apply_ff_default==1 & mod_hdl.FULLDATA.apply_ff_default          
            mod_hdl.apply_ff=1;
        else
            mod_hdl.apply_ff=0;
        end
        set(mod_hdl.ViewSS_btn, 'enable', 'on');
        set(mod_hdl.File_label, 'Visible', 'on', 'String', [dir filename]);
        
        msgbox('File successfully loaded.', [mod_hdl.name ' ' mod_hdl.version]);

    end
    
    
    function shortscan_preview(~,~)

        imager(mod_hdl.SSDATA);
        
    end

    function SS = getSSDATA
       
        SS = mod_hdl.SSDATA;
        
    end


    function load_shifts(~,~)
        shifts = get(mod_hdl.recon_Shifts, 'Value');
        switch shifts
            case 3
                %'Get variables from base'
                var = evalin('base', 'who');
                [s,ok] = listdlg('PromptString','Select a variable:',...
                'SelectionMode','single',...
                'ListString',var);
                if ok
                    custom_AlignmentShifts = evalin('base', var{s});
                end
        end
        
    end

    function view_shifts(~,~)
        shifts = getappdata(handles.fig, 'ShortScanAlignment_shifts');
        ts = sprintf('%0.0f', clock);
        if ~isempty(shifts)
            figure('NumberTitle','off','Name','Short Scan alignment: x shifts','Color', handles.defaults.panel_colour, 'CloseRequestFcn', {@update_shifts, ['SSAx ' ts]});
            plot(shifts.xshifts(:,1), shifts.xshifts(:,2), '-ob', 'Tag', ['SSAx ' ts]);xlabel('image number');ylabel('x shifts (pixels)');
            brush on;
            figure('NumberTitle','off','Name','Short Scan alignment: y shifts','Color', handles.defaults.panel_colour, 'CloseRequestFcn', {@update_shifts, ['SSAy ' ts]});
            plot(shifts.yshifts(:,1),shifts.yshifts(:,2), '-ob', 'Tag', ['SSAy ' ts]);xlabel('image number');ylabel('y shifts (pixels)');
            brush on;
        else
           errordlg('Alignment shifts not yet calculated.'); 
        end
            
        
    end

    function update_shifts(hObject,~,tag)
          p = findobj('Tag', tag);
          px = get(p, 'XData');
          py = get(p, 'YData');
          net = [px(:) py(:)];
          shifts = getappdata(handles.fig, 'ShortScanAlignment_shifts');
          switch tag(4)
              case 'x'
                  orig_shifts = shifts.xshifts;
                  fn = 'xshifts';
              case 'y'
                  orig_shifts = shifts.yshifts;
                  fn = 'yshifts';
          end
          
          if ~isequal(net, orig_shifts)
             btn = questdlg('Shifts have changed. Save changes?', 'Short Scan Alignment');
             if strcmpi(btn, 'Yes')
                 shifts.(fn) = net;              
             end
          end
          
          setappdata(handles.fig, 'ShortScanAlignment_shifts', shifts);
          delete(hObject);
    end

    function SemiAuto_mode(~,~)
        options.ImageStep = str2num(get(mod_hdl.ImageStep, 'String'));
        options.InitialRadius = str2num(get(mod_hdl.OptRadius, 'String'));
        options.PyramidLevels = str2num(get(mod_hdl.PyramidLevels, 'String'));    
        options.ManualCrop = 1;
        
        %mod_hdl.FULLDATA = handles.getDATA();
        [shifts, tformC, matching_inds]= alignDATA3D(mod_hdl.SSDATA,mod_hdl.FULLDATA,options,1);
        
        shifts_struct.mode = 'add on';
        size(matching_inds(:)')
        size(shifts(:,1))
        shifts_struct.xshifts = [matching_inds(:),shifts(:,1)];
        shifts_struct.yshifts = [matching_inds(:),-shifts(:,2)];
        shifts_struct.tform = tformC;
        setappdata(handles.fig, 'ShortScanAlignment_shifts', shifts_struct);   
    end



end

function file_load(handles,mod_hdl)
    %Store current directory in File text
    dpath = fileparts(handles.DATA.file);
    set(mod_hdl.File_label, 'String', dpath, 'Visible', 'off'); 
    set(mod_hdl.ViewSS_btn, 'enable', 'off');
    mod_hdl.FULDATA = handles.DATA;
end

%NEED TO PUT ALL handles things in DATA properties
function queued = run_alignment(handles,mod_hdl,queue)
    %FUNCTION TO ALIGN DATA

     options.ImageStep = str2num(get(mod_hdl.ImageStep, 'String'));
     options.InitialRadius = str2num(get(mod_hdl.OptRadius, 'String'));
     options.PyramidLevels = str2num(get(mod_hdl.PyramidLevels, 'String'));    

    if queue
        errordlg('The feature is not yet available.')
        return
        %Add job to queue        
        queued.function = mod_hdl.name;
        queued.version = mod_hdl.version;
        queued.filename = handles.DATA.file;
        queued.filetype = handles.filetype;
        queued.mstring = ['DATA.ROI = ' mat2str(handles.DATA.ROI) sprintf(';\n')];        
        queued.mstring = [queued.mstring 'DATA.data_range = ' mat2str(handles.DATA.data_range) sprintf(';\n')];
        queued.mstring = [queued.mstring func2mstring('DATA3D_export', '#DATA', write_fn, outputfn, output_datatype)];
        
        handles.add2queue(queued);
                           
    else  
        %Run alignment     
        [shifts, tformC, matching_inds]= alignDATA3D(mod_hdl.getSSDATA(),handles.DATA,options,1);
        shifts_struct.mode = 'add on';
        shifts_struct.xshifts = [matching_inds(:),shifts(:,1)];
        shifts_struct.yshifts = [matching_inds(:),-shifts(:,2)];
        shifts_struct.tform = tformC;
        setappdata(handles.fig, 'ShortScanAlignment_shifts', shifts_struct);        
    end
 

end
