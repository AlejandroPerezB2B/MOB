% Both NIC2 and Matlab are running on the same machine 

[ret, status, socket] = MatNICConnect('localhost');

[ret , version, n_channels, deviceSettings] = MatNICSetUp (socket);

% [ret] = MatNICConfigureFileNameAndTypes (patientName, recordEasy, recordNedf, recordSD, recordEDF, socket)

ret = MatNICConfigureFileNameAndTypes ('Recording1', true, true, false, false, socket);

% This function sends a request to NIC. The request will define the path
% where the files will be saved.
[ret] = MatNICConfigurePathFile (pathFile, socket)

% Once connected with the software, the operator should first place the cap and electrodes on the subject and start loading an existing protocol through the following function:
% ProtocolName are: 'EEG_Protocol.neprot' and 'tRNS_Protocol.neprot'
ret = MatNICLoadProtocol(ProtocolName, socket);

% While the system is streaming EEG data when the protocol has been loaded, the user can make use of the function:
% [eeg] = MatNICEEGRecord(period, n_channel, parse_triggers, parse_timestamps, isAscii, host, port, asServer)
eeg = MatNICEEGRecord(1, 8, 1, 1, 1,'localhost', 1234,1);


