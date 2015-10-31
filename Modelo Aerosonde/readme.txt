To run the aerosonde model, the aircraft data is required. 

Obtain by typing
       aerosonde=aerosonde_data
into the command interface

The aircraft can be trimmed using the script 
       aerosonde_trimlin.m
and the model 
        aerosonde_trimlin.mdl
        
The uncontroller airframe can be simulated using 
        aerosonde_uncontrolled.mdl
Some initial conditions are defined in 
       aerosonde_initial.m

A controller has been designed for tractory following. The 
controller airframe can be simulated using 
        aerosonde_controlled.mdl
Controller gains are defined in 
       aerosonde_initial.m
 
JF Whidborne
2 March 2011
