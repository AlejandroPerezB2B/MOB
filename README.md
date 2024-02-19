# Neuroelectric Closed-Loop setup
This README file outlines the setup for a closed-loop tRNS system that incorporates a non-aperiodic component from EEG data. It leverages Bayesian optimization to dynamically adjust stimulation parameters—specifically amplitude and frequency—based on real-time analysis of EEG signals. This method ensures optimal stimulation settings are identified and applied, enhancing tRNS effectiveness and specificity by adapting to the individual’s neural state.
___
This document provides a detailed, step-by-step guide designed to help users implement the setup from scratch.
Below, you will find a list of the essential components required for the setup, along with the specific versions used during development:

* MATLAB software (*Version 2023b*).
* MatNIC2 (*Version 4.10*, paid version). Included in the folder 'MatNIC2_v4.10_quoted version' on this repository.
* Lab Streaming Layer (LSL) library for Matlab. Included in the folder 'liblsl-Matlab' on this repository.
* FOOOF Matlab wrapper (*v1.0.0*) [Link to repository](https://github.com/fooof-tools/fooof_mat/releases/tag/v1.0.0)
* NIC2 application (*Version 2.1.3.5*). [Link to Download](https://www.neuroelectrics.com/resources/software)
* Starstim device.
* A PC equipped with WiFi and running Windows OS (*Windows 11 Pro*).

<u> MatNIC/Matlab and the NIC2 software are running on the same computer. </u>

## Step 1

Install Matlab on the PC.
Download the 'MatNIC2_v4.10_quoted version' and the 'liblsl-Matlab' folders and add them to the path.
Download 'FOOOF Matlab wrapper' for Spectral Parameterization. To measure periodic and aperiodic properties of electrophysiological data. ADD to the path.

  * Subitem 2.1
  * Subitem 2.2
    
## Step 2

Install NIC2 app.







