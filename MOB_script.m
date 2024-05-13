%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          %
%          SETUP           %
%                          % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Connect to the NIC software using the local host address.
% This command establishes a connection and returns the socket information for subsequent commands.
[~, ~, socket] = MatNICConnect('localhost');


% Connect to the EEG system via an LSL stream to receive EEG data.
% 'LSLOutletStreamName' is the name of the EEG data stream, and this command
% sets up a link to that stream and returns a handle.
[ret, intletEEG] = MatNICEEGConnectLSL('LSLOutletStreamName');

% Connect to an LSL stream for receiving marker data.
% 'MatNICMarkerConnectLSL(name) makes the connection to the software with a stream indicated by name.
[ret, outlet] = MatNICMarkerCatConnectLSL('LSLMarkersInletStreamName1');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          %
%           EEG            %
%                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Load a predefined protocol named 'MtMBO-CLEAN' from the NIC.
% This protocol involves a pre-stimulation EEG measurement.
ret = MatNICLoadProtocol('MtMBO-CLEAN', socket);

% Record EEG data for 15 seconds using 8 channels, 

eeg = MatNICEEGRecord(15, 8, 1, 1, 1, 'localhost', 1234, 0);

% Unload the current protocol from the NIC system.
% This step is crucial to ensure that the system is ready to load another stimulation protocol.
ret = MatNICUnloadProtocol(socket);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          %
%           FOOOF          %
%                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          %
%          tRNS            %
%                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Load a stimulation protocol named 'BlankStim'. This could be a template with neutral settings
% which will be configured later in the code to apply specific stimulation settings.
ret = MatNICLoadProtocol('BlankStim', socket);

% Start the loaded stimulation protocol.
% Initiates the stimulation sequence as per the parameters defined in the 'BlankStim' protocol.
ret = MatNICStartProtocol(socket);

% Set the protocol parameters for the stimulation.
n_channels = 8; % Number of channels in the current device.
amplitude = 500; % Desired amplitude of the stimulation for certain channels (in μA).

% Create the amplitude array for all channels with current conservation.
% Example setup: Alternate between positive and negative to ensure current conservation.
amplitudeArray = zeros(1, n_channels);
amplitudeArray(1:2:end) = amplitude;   % Set positive amplitude for odd-numbered channels.
amplitudeArray(2:2:end) = -amplitude;  % Set negative amplitude for even-numbered channels.

% Change the amplitude of the channels using the earlier created array.
% This command sends the new amplitude settings to the NIC for real-time adjustment.
ret = MatNICOnlineAtrnsChange(amplitudeArray, n_channels, socket);

% Finally, unload the stimulation protocol.
% Ensures that the system is clean and no residual configurations affect subsequent operations.
ret = MatNICUnloadProtocol(socket);
