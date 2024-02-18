# Manual for Neuroelectric Closed-Loop setup
This README file outlines the setup for a closed-loop tRNS system that incorporates a non-aperiodic component from EEG data. It leverages Bayesian optimization to dynamically adjust stimulation parameters—specifically amplitude and frequency—based on real-time analysis of EEG signals. This method ensures optimal stimulation settings are identified and applied, enhancing tRNS effectiveness and specificity by adapting to the individual’s neural state.
___
Authors: Alejandro Perez, Shachar Hochman and Roi Cohen Kadosh
___
This document provides a detailed, step-by-step guide designed to help users implement the setup from scratch.
Below, you will find a list of the essential components required for the setup, along with the specific versions used during development:

* MATLAB software (*Version 2023b*).
* NIC2 application (*Version 2.1.3.5*). [Link to Download](https://www.neuroelectrics.com/resources/software)
* MatNIC2 (*Version 4.10*, paid version). Included in the folder 'MatNIC2_v4.10_quoted version' on this repository.
* Lab Streaming Layer (LSL) library for Matlab. Included in the folder 'liblsl-Matlab' on this repository. 
* Starstim device.
* A PC equipped with WiFi and running Windows OS (Windows 11 Pro).


  * Subitem 2.1
  * Subitem 2.2
    
*This text* is italicized.
_This text_ is also italicized.

<u>This text is underlined.</u>

**This text** is bold.
__This text__ is also bold.

# Heading 1
## Heading 2
### Heading 3

To create a link, wrap the link text in brackets [], followed by the URL in parentheses (). For example:
[GitHub](http://github.com)

To add images, use an exclamation mark !, followed by the alt text in brackets [], and the path or URL to the image in parentheses (). For example:

![This is an image](http://url/to/image.png)

To insert a horizontal line, use three or more asterisks ***, dashes ---, or underscores ___ on a new line. 



