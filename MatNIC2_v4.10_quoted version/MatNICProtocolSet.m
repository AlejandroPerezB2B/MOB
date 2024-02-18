%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICProtocolSet
%
% Returns a hash table with the protocol (COMMAND, STATUS) present in 
% the NIC2.0 Application
%
% Input:
%
% Output:
% Command set selected for this application
%
% Author: Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 28 Nov 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [protocolSet] = MatNICProtocolSet()
   
    protocolSet = containers.Map;
    % Holds the current MatNIC version
    protocolSet('MATNIC_VERSION')                           = '04.07';
    
    % Command Codes
    protocolSet('CODE_COMMAND_QUERY_STATUS')                = 128;
    protocolSet('CODE_COMMAND_QUERY_STATUS_PROTOCOL')       = 129;
    protocolSet('CODE_COMMAND_READ_MATNIC_VERSION')         = 130;
    protocolSet('CODE_COMMAND_VERSION')                     = 131;
    protocolSet('CODE_COMMAND_READ_CHANNELS')               = 132;
    protocolSet('CODE_COMMAND_ENABLE_TRNS_FILTER')          = 133;     
    protocolSet('CODE_COMMAND_DISABLE_TRNS_FILTER')         = 134; 
    protocolSet('CODE_COMMAND_LOAD_PROTOCOL')               = 135;
    protocolSet('CODE_COMMAND_UNLOAD_PROTOCOL')             = 136;
    protocolSet('CODE_COMMAND_START_PROTOCOL')              = 137;
    protocolSet('CODE_COMMAND_ABORT_PROTOCOL')              = 138;
	protocolSet('CODE_COMMAND_PAUSE_PROTOCOL')              = 139;
    protocolSet('CODE_COMMAND_CHECK_IMPEDANCE')             = 140;
    protocolSet('CODE_COMMAND_CHECK_IMPEDANCE_ABORT')       = 141;
    protocolSet('CODE_COMMAND_GET_IMPEDANCE')               = 142;
    protocolSet('CODE_COMMAND_CONFIGURE_FILE')              = 143;
    protocolSet('CODE_COMMAND_CONFIGURE_MARKERS')           = 144;
    protocolSet('CODE_COMMAND_CONFIGURE_PATH_FILE')         = 145;
    protocolSet('CODE_COMMAND_ONLINE_ATDCS_CHANGE')         = 146;
    protocolSet('CODE_COMMAND_ONLINE_ATACS_CHANGE')         = 147;
    protocolSet('CODE_COMMAND_ONLINE_FTACS_CHANGE')         = 148; 
    protocolSet('CODE_COMMAND_ONLINE_PTACS_CHANGE')         = 149;
    protocolSet('CODE_COMMAND_ONLINE_TACS_CHANGE')          = 150; 
    protocolSet('CODE_COMMAND_ONLINE_ATRNS_CHANGE')         = 151;
    protocolSet('CODE_COMMAND_ONLINE_ATDCS_PEAK')           = 152;
    protocolSet('CODE_COMMAND_ONLINE_ATACS_PEAK')           = 153;
    protocolSet('CODE_COMMAND_PULSE_ENABLE')                = 154;
    protocolSet('CODE_COMMAND_PULSE_CONFIGURATION')         = 155;
    protocolSet('CODE_COMMAND_PULSE_START')                 = 156;
    protocolSet('CODE_COMMAND_PULSE_QUERY_STATUS')          = 157;
    protocolSet('CODE_COMMAND_IMPORT_PROTOCOL')             = 158;
    protocolSet('CODE_COMMAND_READ_DEVICE_SETTINGS')        = 159;


    
    
    
    % Status Codes    
    protocolSet('CODE_STATUS_REMOTE_CONTROL_ALLOWED')       = 200;
    protocolSet('CODE_STATUS_REMOTE_CONTROL_REJECTED')      = 201;
    protocolSet('CODE_STATUS_VERSION_RECEIVED')             = 202;
    protocolSet('CODE_STATUS_SYNCHRONIZING')                = 203;
    protocolSet('CODE_STATUS_IDLE')                         = 204;
    protocolSet('CODE_STATUS_PROTOCOL_NOT_LOADED')          = 205;
    protocolSet('CODE_STATUS_PROTOCOL_LOADING')             = 206;
    protocolSet('CODE_STATUS_PROTOCOL_LOADED')              = 207;
    protocolSet('CODE_STATUS_PROTOCOL_RUNNING')             = 208;
    protocolSet('CODE_STATUS_PROTOCOL_ERROR')               = 209;
    protocolSet('CODE_STATUS_PROTOCOL_FINISHED')            = 210;
    protocolSet('CODE_STATUS_PROTOCOL_PAUSED')              = 211;
    protocolSet('CODE_STATUS_PROTOCOL_ABORTED')             = 212;
    protocolSet('CODE_STATUS_PROTOCOL_ABORTING')            = 213;
    protocolSet('CODE_STATUS_EEG_ON')                       = 214;
    protocolSet('CODE_STATUS_EEG_OFF')                      = 215;
    protocolSet('CODE_STATUS_STIMULATION_RAMPUP')           = 216;
    protocolSet('CODE_STATUS_STIMULATION_FULL')             = 217;
    protocolSet('CODE_STATUS_STIMULATION_RAMPDOWN')         = 218;
    protocolSet('CODE_STATUS_STIMULATION_FINISHED')         = 219;
    protocolSet('CODE_STATUS_WAITING_FOR_SECOND_SHAM')      = 220;
    protocolSet('CODE_STATUS_CHECK_IMPEDANCE')              = 221;
    protocolSet('CODE_STATUS_CHECK_IMPEDANCE_FISNISHED')    = 222;
    protocolSet('CODE_STATUS_CHECK_IMPEDANCE_ABORTING')     = 223;
    protocolSet('CODE_STATUS_CHECK_IMPEDANCE_ABORTED')      = 224;
    protocolSet('CODE_STATUS_PULSE_DISABLE')                = 225;
    protocolSet('CODE_STATUS_PULSE_ENABLE')                 = 226;





end