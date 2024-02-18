%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICEnableTRNSFilter
%
% This function sends a request to the NIC Remote Stimulation Server to
% implement a filter in the generated signal while using tRNS
% Four different differents can generated according to the type paramter
%
%  'alpha'    -> Configures a FIR filter with a characteristic in the form 
%  H(f) = 1/(f^alpha) where alpha corresponds to param1
%  'bandpass' -> Configures a bandpass FIR filter with param1, param2 as cut-off frequencies
%  'low'      -> Configures a lowpass FIR filter with param1 as cut-off frequency
%  'high'     -> Configures a highpass FIR filter with param1 as cut-off frequency
%
% Input:
% type   : type of filter requested 
% param1 : 
% socket : The socket variable that is returned by the MatNICConnect
% function.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
%       -1: No connection with the host
%       -3: Error on parameters
%       -2: Command Successful
%       -5: Error writing command to the server.
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 21 Apr 2014
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = MatNICEnableTRNSFilter (type, param1, param2, socket)


    % Return value
    ret = 0;

    if nargin < 3
        disp('ERROR: Not enough arguments')
        return;
    end
    
    % Check that parameters obtained are correct
    if strcmp(type, 'bandpass') == true & nargin == 4
        % Do nothing
    else
        socket = param2;        
    end
    

    
    % Calculate coefficients according to the type requested
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Alpha filter
    if strcmp(type,'alpha') == true
        disp('INFO: Selected "alpha" filter type')
        alpha = param1;
        % Check the number of parameters
        if nargin ~= 3
            disp(' ERROR: You should provide an alpha parameter to use this function')
            ret = -3;
            return;
        end;

        % Check alpha correctness
        if( (abs(alpha) > 3) || (abs(alpha) < 0.5)  )
           disp(' ERROR: alpha parameter must be in range [-3,-0.5],[0.5,3]')
           ret = -3
           return
        end

        % Collect filter coefficients
        [filterCoefficients, normalization] = MatNICGenerateFilterColoredNoise(alpha);
        
    end
    
    % Bandpass filter
    if strcmp(type,'bandpass') == true
        disp('INFO: Selected "bandpass" filter type')
        
        % Check the number of parameters
        if nargin ~= 4
            disp(' ERROR: You should provide an fc1, fc2 parameter to use this function')
            ret = -3;
            return;
        end;
        
        [filterCoefficients, normalization] = MatNICGenerateFilterPass(param1, param2);
        
    end
    
    % Lowpass filter
    if strcmp(type,'low') == true
        disp('INFO: Selected "lowpass" filter type')
        
        % Check the number of parameters
        if nargin ~= 3
            disp(' ERROR: You should provide an fc1 parameter to use this function')
            ret = -3;
            return;
        end;
        
        [filterCoefficients, normalization] = MatNICGenerateFilterPass(0, param1);
        
    end
    
    % Highpass filter
    if strcmp(type,'high') == true
        disp('INFO: Selected "high" filter type')
        
        % Check the number of parameters
        if nargin ~= 3
            disp(' ERROR: You should provide an fc1 parameter to use this function')
            ret = -3;
            return;
        end;
        
        [filterCoefficients, normalization] = MatNICGenerateFilterPass(param1, 0);
        
    end
    

          
    
    % Prevent starting/stopping EEG when in stimulation mode
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [retValue, status] = MatNICQueryStatus (socket);
    switch status
        case 'CODE_STATUS_STIMULATION_READY'
        case 'CODE_STATUS_STIMULATION_FULL'
        otherwise
            ret = -4;
            disp('NIC is NOT Stimulating. Abort operation')
            return;
    end

    
    
    % Send parameters to NIC
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    % Create parameter
    filterCoefficientsStr = sprintf('%d', filterCoefficients(1));    
    for i = 2:length(filterCoefficients)
        filterCoefficientsStr = sprintf('%s;%d', filterCoefficientsStr, filterCoefficients(i));        
    end
    
    % Create energy parameter
    normalizationStr = sprintf('%d', normalization);
    
    % Verify socket is still operative
    try
        outputStream = socket.getOutputStream;
        dOutputStream= java.io.DataOutputStream(outputStream);
    catch
        ret = -1;
        return
    end

    % Recover ProtocolSet
    [protocolSet] = MatNICProtocolSet();
    
    % Send command ID
    try        
        %dOutputStream.writeByte(246);
        commandID = protocolSet('CODE_COMMAND_ENABLE_TRNS_FILTER');
        dOutputStream.writeByte( commandID );
        dOutputStream.flush;
    catch
        ret = -5;
        return;
    end
    
    
    % Send parameters
    try        
        dOutputStream.writeBytes(filterCoefficientsStr);
        dOutputStream.writeBytes(';');
        dOutputStream.writeBytes(normalizationStr);
        % The name of the template shall be ended with one of the following
        % characters:
        % '\0', '\n', '\r' so the server can know when the template name
        % finishes.
        dOutputStream.writeByte(0); % string terminator character for the NIC
                                    % to start processing the template name
        dOutputStream.flush;
    catch
        ret = -2;
        return
    end
    
       
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name     : MatNICGenerateFilterPass
%
% Overview : Generates the coefficients of a FIR of type 'high' (fc2 == 0), 
% 'low' (fc1 == 0) or 'bandpass' according to the values of fc1 and fc2.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [filterCoefficients, normalization] = MatNICGenerateFilterPass(fc1, fc2)

    % Fitler Default Order
    N = 100;
    % Random noise generator frequency
    fs = 1000;
    % Coefficients resolution
    coef_res = [-128, 127];

    % Wrong Parametrization
    if fc1==0 && fc2 == 0

        disp('Error: Wrong cut-off frequencies')
        return;

    % Low Pass Filter    
    elseif fc1 == 0

       filterCoefficients = fir1(N, fc2/fs*2,'low');

    % High Pass Filter    
    elseif fc2 == 0

        filterCoefficients = fir1(N, fc1/fs*2,'high');

    % Band Pass filter    
    else
        filterCoefficients = fir1(N, [fc1/fs*2, fc2/fs*2],'bandpass');
    end

    % Normalization of the filter coefficients
    filterCoefficients = (filterCoefficients./max(filterCoefficients))* coef_res(2);
    filterCoefficients = round(filterCoefficients);
    filterCoefficients(find(filterCoefficients)<coef_res(1))=coef_res(1);
    

    % Calculate normalization
    [H, f]= freqz(filterCoefficients, 1, 0:0.1:500, fs);
    maxGain = max(abs(H));
    normalization  = cast(maxGain, 'int16');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %figure;
    %plot(f,10*log10(abs(H)./maxGain));
    %figure;
    %plot(filterCoefficients);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name     : MatNICGenerateFilterColoredNoise
%
% Overview : Generates the coefficients of a FIR filter with a response
% in the form A(f) = 1/(f^alpha)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [stm_flt_coefs, stm_flt_div] = MatNICGenerateFilterColoredNoise(alpha)

	% Parameters
	qnbit = 8;

	fs    = 1000;
	fw_n  = 50;
	N     = 2*fw_n;

	df    = fs/N;

	flt_fd = zeros(N,1);

	flt_fd(2:1+N/2+1) = 1.0./power(df*(1:N/2+1), alpha);
	flt_fd(1+N/2+1:N) = flt_fd(1+N/2:-1:3);
	flt_fd(1)         = 2*flt_fd(2) + flt_fd(3);

	flt_td            = fftshift(real(ifft(sqrt(flt_fd)))).*hanning(N);

	flt_td            = flt_td/max(flt_td);
	flt_td            = round(flt_td*(power(2.0, qnbit-1)-1));

	flt_norm          = round( sqrt(sum(flt_td.*flt_td)) );

    % Add a 'magic' coefficient. 
    % NOTE: Antonio did generate a filter with 100 coefficients but 101 are
    % necessary
    flt_td = [flt_td; 0];
	    
    % Calculate the filter gain
    [H, f]= freqz(flt_td, 1, 0:0.1:500, fs);
    %figure;
    %plot(f,abs(H)./max(abs(H)))

    % Assign output variables
    stm_flt_div    = max(abs(H));
    stm_flt_coefs  = flt_td;

	%
	% These matlab calls are used for verifying the proper operation of the
	% filter
	%
	%
	% sig     = randn(1, 1e6);
	% sig_flt = conv(sig, flt_td)/flt_norm;
	% 
	% [hs, f] = pwelch(sig_flt, 4096, 0.5, 4096, 1000);
	% semilogx(f, 10*log10(abs(hs)));
	% grid on;
    
    
    %{
% INIT: Cheating
    % Set the default filter (STM_FLT_COEF)
    defaultFilter = [];
	defaultFilter = [defaultFilter 00 00 00 00 00 00 00 00 00 00]; % 00 - 09
	defaultFilter = [defaultFilter 00 00 00 00 01 01 01 01 01 01]; % 10 - 19
	defaultFilter = [defaultFilter 01 01 02 02 02 02 02 02 03 03]; % 20 - 29
	defaultFilter = [defaultFilter 03 03 04 04 04 05 05 06 06 07]; % 30 - 39
	defaultFilter = [defaultFilter 07 08 09 10 11 13 15 19 24 42]; % 40 - 49
	defaultFilter = [defaultFilter 127]; % 50
    filterCoefficients = defaultFilter;
    
    % Calculate filter energy (STM_FLT_DIV)
    normalization0 = 0;
    normalization1 = 154;
% END: Cheating
%}
    
end