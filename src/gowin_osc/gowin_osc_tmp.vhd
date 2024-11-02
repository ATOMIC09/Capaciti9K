--Copyright (C)2014-2024 Gowin Semiconductor Corporation.
--All rights reserved.
--File Title: Template file for instantiation
--Tool Version: V1.9.9.03 Education (64-bit)
--Part Number: GW1NR-LV9QN88PC6/I5
--Device: GW1NR-9
--Device Version: C
--Created Time: Fri Nov  1 13:56:17 2024

--Change the instance name and port connections to the signal names
----------Copy here to design--------

component Gowin_OSC
    port (
        oscout: out std_logic
    );
end component;

your_instance_name: Gowin_OSC
    port map (
        oscout => oscout
    );

----------Copy end-------------------
