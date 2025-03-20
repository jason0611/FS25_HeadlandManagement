--
-- Register Headland Management for LS 25
--
-- Jason06 / Glowins Modschmiede 
-- Version 3.0.0.0
--

local specName = g_currentModName..".HeadlandManagement"

-- add specialization
if g_specializationManager:getSpecializationByName("HeadlandManagement") == nil then
  	g_specializationManager:addSpecialization("HeadlandManagement", "HeadlandManagement", g_currentModDirectory.."headlandManagement.lua", nil)
  	dbgprint("Specialization 'HeadlandManagement' added", 2)
end

-- add configuration
if g_vehicleConfigurationManager.configurations["headlandManagement"] == nil then		
	g_vehicleConfigurationManager:addConfigurationType("headlandManagement", g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("text_HLM_configuration"), "headlandManagement", VehicleConfigurationItem, nil, nil, nil, 2000)
	dbgprint("Configuration 'HeadlandManagement' added", 2)
end

for typeName, typeEntry in pairs(g_vehicleTypeManager.types) do
    if
    		SpecializationUtil.hasSpecialization(Drivable, typeEntry.specializations) 
		and	SpecializationUtil.hasSpecialization(Enterable, typeEntry.specializations)
		and	SpecializationUtil.hasSpecialization(Motorized, typeEntry.specializations)
    
    	and not SpecializationUtil.hasSpecialization(Locomotive, typeEntry.specializations)
    
    then
     	g_vehicleTypeManager:addSpecialization(typeName, specName)
		dbgprint(specName.." registered for "..typeName)
    end
end
