function wizard_steganography_dashboard()
    % --- Main Figure Setup ---
    fig = uifigure('Name', 'Step-by-Step Steganography Wizard', 'Position', [100 100 800 600], 'Color', [0.9 0.95 1]);

    % State Variables
    selectedRole = '';
    selectedMedia = '';

    % --- PANEL CONTAINERS ---
    pnlRole = uipanel(fig, 'Position', [100 100 600 400], 'BackgroundColor', [1 1 1], 'Visible', 'on');
    pnlMedia = uipanel(fig, 'Position', [100 100 600 400], 'BackgroundColor', [1 1 1], 'Visible', 'off');
    pnlWorkspace = uipanel(fig, 'Position', [50 50 700 500], 'BackgroundColor', [1 1 1], 'Visible', 'off');

    %% --- STEP 1: ROLE SELECTION ---
    uilabel(pnlRole, 'Text', 'STEP 1: Choose Your Role', 'Position', [100 320 400 30], 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    uibutton(pnlRole, 'Text', 'SENDER (Hide Data)', 'Position', [100 180 180 60], 'FontSize', 14, ...
        'BackgroundColor', [0.8 1 0.8], 'ButtonPushedFcn', @(btn,e) setRole('Sender'));
    uibutton(pnlRole, 'Text', 'RECEIVER (Extract Data)', 'Position', [320 180 180 60], 'FontSize', 14, ...
        'BackgroundColor', [1 0.9 0.8], 'ButtonPushedFcn', @(btn,e) setRole('Receiver'));

    %% --- STEP 2: MEDIA SELECTION ---
    uilabel(pnlMedia, 'Text', 'STEP 2: Choose Media Type', 'Position', [100 320 400 30], 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    uibutton(pnlMedia, 'Text', 'IMAGE', 'Position', [50 180 140 60], 'FontSize', 14, 'ButtonPushedFcn', @(btn,e) setMedia('Image'));
    uibutton(pnlMedia, 'Text', 'AUDIO', 'Position', [230 180 140 60], 'FontSize', 14, 'ButtonPushedFcn', @(btn,e) setMedia('Audio'));
    uibutton(pnlMedia, 'Text', 'VIDEO', 'Position', [410 180 140 60], 'FontSize', 14, 'ButtonPushedFcn', @(btn,e) setMedia('Video'));
    uibutton(pnlMedia, 'Text', '< Back to Step 1', 'Position', [20 20 120 30], 'ButtonPushedFcn', @(btn,e) resetToRole());

    %% --- STEP 3: DYNAMIC WORKSPACE ---
    lblTitle = uilabel(pnlWorkspace, 'Text', 'Workspace', 'Position', [150 450 400 30], 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    btnBack = uibutton(pnlWorkspace, 'Text', '< Back to Step 2', 'Position', [20 460 120 30], 'ButtonPushedFcn', @(btn,e) resetToMedia());
    
    % Workspace UI Elements
    btnAction1 = uibutton(pnlWorkspace, 'Position', [20 380 200 30]);
    btnAction2 = uibutton(pnlWorkspace, 'Position', [240 380 200 30], 'Enable', 'off');
    txtArea = uitextarea(pnlWorkspace, 'Position', [20 280 420 80]);
    axPreview = uiaxes(pnlWorkspace, 'Position', [460 100 220 220]); axis(axPreview, 'off');
    lblStatus = uilabel(pnlWorkspace, 'Text', 'Status: Ready', 'Position', [20 20 400 22], 'FontColor', 'blue');

    % Shared Data Variables
    mediaData1 = []; mediaData2 = []; filePath = '';

    %% --- NAVIGATION LOGIC ---
    function setRole(r)
        selectedRole = r;
        pnlRole.Visible = 'off';
        pnlMedia.Visible = 'on';
    end

    function setMedia(m)
        selectedMedia = m;
        pnlMedia.Visible = 'off';
        pnlWorkspace.Visible = 'on';
        configureWorkspace();
    end

    function resetToRole()
        pnlRole.Visible = 'on';
        pnlMedia.Visible = 'off';
    end

    function resetToMedia()
        pnlMedia.Visible = 'on';
        pnlWorkspace.Visible = 'off';
        cla(axPreview);
        txtArea.Value = '';
    end

    %% --- WORKSPACE CONFIGURATION ---
    function configureWorkspace()
        lblTitle.Text = [upper(selectedRole) ' : ' upper(selectedMedia) ' MODE'];
        lblStatus.Text = 'Status: Ready';
        btnAction2.Enable = 'off';
        cla(axPreview);

        if strcmp(selectedRole, 'Sender')
            btnAction1.Text = ['1. Select Cover ' selectedMedia];
            btnAction2.Text = '2. Hide Message & Save';
            txtArea.Editable = 'on';
            txtArea.Placeholder = 'Type your secret message here...';
            txtArea.Value = '';
            
            btnAction1.ButtonPushedFcn = @(btn,e) loadFileSender();
            btnAction2.ButtonPushedFcn = @(btn,e) executeSender();
        else
            btnAction1.Text = ['1. Select Stego ' selectedMedia];
            btnAction2.Text = '2. Extract Message';
            txtArea.Editable = 'off';
            txtArea.Placeholder = 'Extracted message will appear here...';
            txtArea.Value = '';
            
            btnAction1.ButtonPushedFcn = @(btn,e) loadFileReceiver();
            btnAction2.ButtonPushedFcn = @(btn,e) executeReceiver();
        end
    end

    %% --- SENDER LOGIC ---
    function loadFileSender()
        if strcmp(selectedMedia, 'Image')
            [f, p] = uigetfile('*.png;*.jpg;*.bmp');
            if ischar(f), mediaData1 = imresize(imread(fullfile(p,f)), [512 512]); imshow(mediaData1, 'Parent', axPreview); end
        elseif strcmp(selectedMedia, 'Audio')
            [f, p] = uigetfile('*.wav');
            if ischar(f), [mediaData1, mediaData2] = audioread(fullfile(p,f)); plot(axPreview, mediaData1(:,1)); end
        elseif strcmp(selectedMedia, 'Video')
            [f, p] = uigetfile('*.mp4;*.avi');
            if ischar(f), filePath = fullfile(p,f); imshow(readFrame(VideoReader(filePath)), 'Parent', axPreview); end
        end
        if ischar(f), btnAction2.Enable = 'on'; lblStatus.Text = ['Loaded: ' f]; end
    end

    function executeSender()
        if isempty(txtArea.Value{1}), uialert(fig, 'Please enter a message.', 'Error'); return; end
        lblStatus.Text = 'Processing... Please wait.'; drawnow;
        
        bits = textToBits(txtArea.Value{1});
        payload = [dec2bin(length(bits),32)-'0', MLEA_Encrypt(bits)];

        if strcmp(selectedMedia, 'Image')
            % Prompt user to choose filename and location
            [saveFile, savePath] = uiputfile('*.png', 'Save Stego Image As');
            if saveFile == 0
                lblStatus.Text = 'Status: Save Cancelled.';
                return; % Stop if user cancels the save dialog
            end
            
            B = permute(flipud(mediaData1),[2 1 3]); Blue = B(:,:,3); [~,idx] = sort(reshape(magic(512),[],1));
            for k=1:length(payload), Blue(idx(k)) = bitset(Blue(idx(k)), 1, payload(k)); end
            B(:,:,3) = Blue; 
            
            imwrite(flipud(permute(B,[2 1 3])), fullfile(savePath, saveFile));
            uialert(fig, ['Successfully saved as ' saveFile], 'Success');

        elseif strcmp(selectedMedia, 'Audio')
            % Prompt user to choose filename and location
            [saveFile, savePath] = uiputfile('*.wav', 'Save Stego Audio As');
            if saveFile == 0
                lblStatus.Text = 'Status: Save Cancelled.';
                return;
            end
            
            y_int = int16(mediaData1(:,1) * 32767);
            for k=1:length(payload), y_int(k) = bitset(y_int(k), 1, payload(k)); end
            
            audiowrite(fullfile(savePath, saveFile), double(y_int)/32767, mediaData2);
            uialert(fig, ['Successfully saved as ' saveFile], 'Success');

        elseif strcmp(selectedMedia, 'Video')
            % Prompt user to choose filename and location
            [saveFile, savePath] = uiputfile('*.avi', 'Save Stego Video As');
            if saveFile == 0
                lblStatus.Text = 'Status: Save Cancelled.';
                return;
            end
            
            d = uiprogressdlg(fig, 'Title', 'Writing Full Video', 'Message', 'Processing frames...','Indeterminate','on');
            vr = VideoReader(filePath);
            vw = VideoWriter(fullfile(savePath, saveFile), 'Uncompressed AVI'); open(vw);
            fIdx = 1;
            while hasFrame(vr)
                f = readFrame(vr);
                f = imresize(f, [512 512]); 
                if fIdx == 1
                    B = f(:,:,3); [~,idx] = sort(reshape(magic(512),[],1));
                    for k=1:length(payload), B(idx(k)) = bitset(B(idx(k)), 1, payload(k)); end
                    f(:,:,3) = B;
                end
                writeVideo(vw, f);
                fIdx = fIdx + 1;
            end
            close(vw); close(d);
            uialert(fig, ['Successfully saved as ' saveFile], 'Success');
        end
        lblStatus.Text = 'Status: Done!';
    end

    %% --- RECEIVER LOGIC ---
    function loadFileReceiver()
        if strcmp(selectedMedia, 'Image')
            [f, p] = uigetfile('*.png');
            if ischar(f), mediaData1 = imread(fullfile(p,f)); imshow(mediaData1, 'Parent', axPreview); end
        elseif strcmp(selectedMedia, 'Audio')
            [f, p] = uigetfile('*.wav');
            if ischar(f), mediaData1 = audioread(fullfile(p,f)); plot(axPreview, mediaData1(:,1)); end
        elseif strcmp(selectedMedia, 'Video')
            [f, p] = uigetfile('*.avi;*.mp4');
            if ischar(f), filePath = fullfile(p,f); imshow(readFrame(VideoReader(filePath)), 'Parent', axPreview); end
        end
        if ischar(f), btnAction2.Enable = 'on'; lblStatus.Text = ['Loaded Stego File: ' f]; end
    end

    function executeReceiver()
        lblStatus.Text = 'Extracting... Please wait.'; drawnow;
        try
            if strcmp(selectedMedia, 'Image')
                B = permute(flipud(mediaData1),[2 1 3]); Blue = B(:,:,3); [~,idx] = sort(reshape(magic(512),[],1));
                len = bin2dec(char(arrayfun(@(k) bitget(Blue(idx(k)),1), 1:32)+'0'));
                mBits = MLEA_Decrypt(arrayfun(@(k) bitget(Blue(idx(k+32)),1), 1:len));

            elseif strcmp(selectedMedia, 'Audio')
                y_int = int16(mediaData1(:,1) * 32767);
                len = bin2dec(char(arrayfun(@(k) bitget(y_int(k),1), 1:32)+'0'));
                mBits = MLEA_Decrypt(arrayfun(@(k) bitget(y_int(k+32),1), 1:len));

            elseif strcmp(selectedMedia, 'Video')
                vr = VideoReader(filePath); f = readFrame(vr); f = imresize(f, [512 512]);
                B = f(:,:,3); [~,idx] = sort(reshape(magic(512),[],1));
                len = bin2dec(char(arrayfun(@(k) bitget(B(idx(k)),1), 1:32)+'0'));
                mBits = MLEA_Decrypt(arrayfun(@(k) bitget(B(idx(k+32)),1), 1:len));
            end
            
            txtArea.Value = {bitsToText(mBits)};
            lblStatus.Text = 'Status: Extraction Successful!';
        catch
            uialert(fig, 'Failed to extract data. File might not contain a hidden message or is corrupted.', 'Extraction Error');
            lblStatus.Text = 'Status: Extraction Failed.';
        end
    end

    %% --- UTILITIES ---
    function b = textToBits(t), b = reshape(dec2bin(t,8)',1,[])-'0'; end
    function t = bitsToText(b), t = char(bin2dec(reshape(char(b+'0'),8,[])'))'; end
    
    function cipher = MLEA_Encrypt(bits)
        s1 = bitxor(bits, 1); 
        rem = mod(length(s1),8); if rem>0, s1=[s1, zeros(1,8-rem)]; end
        s2 = s1;
        for i=1:(length(s2)/8)
            idx=(i-1)*8+1; chunk=s2(idx:idx+7); s2(idx:idx+7)=[chunk(5:8), chunk(1:4)];
        end
        cipher = circshift(s2, -1);
    end

    function plain = MLEA_Decrypt(cipher)
        s1 = circshift(cipher, 1);
        for i=1:(length(s1)/8)
            idx=(i-1)*8+1; chunk=s1(idx:idx+7); s1(idx:idx+7)=[chunk(5:8), chunk(1:4)];
        end
        plain = bitxor(s1, 1);
    end
end