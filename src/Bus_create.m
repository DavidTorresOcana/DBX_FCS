

% Bus inputs de Inictial conditions
Model_init_cond_bus = Simulink.Bus.createObject('DBX_controlled_fw','DBX_controlled_fw/Initial Conds/Bus Creator')


% Bus output del modelo
Model_out_bus = Simulink.Bus.createObject('DBX_model_all','DBX_model_all/formateo_out_bus/Bus Creator2')