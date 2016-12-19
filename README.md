# Instrument-Control
Instrument Control for Microscopes and Accessories

ScanImageB is a software developed for the control of a 2P resonant scanning microscope. The adapters for stage controller and pockels cell as well as the look and feel of the GUI are taken from Scanimage 4.2, a freely accessible software developed in the group of Karel Svoboda in Janelia and continued semi-commercially by http://vidriotechnologies.com/.
Under the hood, I changed the main processing lines, mostly inspired by scanbox.wordpress.com, developed in the lab of Dario Ringach. I'm using a Alazar 9440 DAQ board for laser-pulse timed acquisition at 80 MHz and NI 6321 DAQ boards for synchronization and instrument control.
The reason for putting this software online is 1) version control for myself and 2) offering the possibility to point other researchers/programmers to interesting parts of the code. The software as a whole is NOT supposed to be self-explanatory - this would require too much work for me.
This software has been used for calcium imaging 2P in the following paper: https://www.osapublishing.org/boe/abstract.cfm?uri=boe-7-5-1656. Some interesting lines of code are pointed out in this blog post of mine: https://ptrrupprecht.wordpress.com/2016/12/01/matlab-code-for-instrument-control-of-a-resonant-scanning-microscope/.

The Voice Coil Control Loop is a small control script used for positional control of a voice coil motor for fast z-scanning as described in a research paper published in Biomedical Optics Express: https://www.osapublishing.org/boe/abstract.cfm?uri=boe-7-5-1656 .

The Reglo ICC Matlab Class is a Matlab adapter to control a 4-wheel digitally controlled peristaltic pump (http://www.ismatec.com/int_e/pumps/t_reglo/reglo.htm). The company provides a control software and a Labview control VI, but no Matlab control interface. I used the serial commands provided by the pump manual to write this adapter.
