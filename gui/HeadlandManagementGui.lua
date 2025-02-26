--
-- Headland Management for LS 25
--
-- Jason06 / Glowins Modschmiede
--

HeadlandManagementGui = {}
local HeadlandManagementGui_mt = Class(HeadlandManagementGui, YesNoDialog)

-- constructor
function HeadlandManagementGui:new()
	local gui = YesNoDialog:new(nil, HeadlandManagementGui_mt)
	dbgprint("HeadlandManagementGui created:", 1)
	dbgprint_r(gui.target, 2, 0)
	return gui
end

-- set current values
function HeadlandManagementGui.setData(self, vehicleName, spec, gpsEnabled, debug, showKeys)
	dbgprint("HeadlandManagementGui: setData", 2)
	self.spec = spec
	self.gpsEnabled = gpsEnabled
	
	dbgprint_r(self.spec, 4, 1)
		
	self.yesButton.onClickCallback=HeadlandManagementGui.onClickOk
	self.noButton.onClickCallback=HeadlandManagementGui.onClickBack
		
	-- Titel
	dbgprint_r(self.guiTitle, 2, 0)
	self.guiTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_title")..vehicleName)

	-- General Settings
	self.alarmControl:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_alarmControl"))
	self.alarmTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_beep"))
	self.alarmSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.alarmSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on")
	})
	self.alarmSetting:setState(self.spec.beep and 2 or 1)

	self.alarmVolumeTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_beepVol"))
	local values={}
	for i=1,10 do values[i] = tostring(i*10).." %" end 
	self.alarmVolumeSetting:setTexts(values)
	self.alarmVolumeSetting:setState(self.spec.beepVol)
	self.alarmVolumeSetting:setDisabled(not self.spec.beep)
	
	self.inputbindingsTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_keys"))
	self.inputbindingsSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on")
	})
	self.inputbindingsSetting:setState(showKeys and 2 or 1)

	-- SpeedControl
	self.speedControl:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_speedControl"))
	self.speedControlOnOffTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_speedControl"))
	self.speedControlOnOffSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.speedControlOnOffSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on")
	})
	self.speedControlOnOffSetting:setState(self.spec.useSpeedControl and 2 or 1)
	
	self.speedControlUseSCModTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_speedControlMod"))
	self.speedControlUseSCModSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.speedControlUseSCModSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on")
	})
	self.speedControlUseSCModSetting:setState((self.spec.useModSpeedControl and (self.spec.modSpeedControlFound or self.spec.modECCFound)) and 2 or 1)
	self.speedControlUseSCModSetting:setDisabled(not self.spec.useSpeedControl or (not self.spec.modSpeedControlFound and not self.spec.modECCFound))
	self.speedControlUseSCModTitle:setVisible(self.spec.modSpeedControlFound or self.spec.modECCFound)
	self.speedControlUseSCModSetting:setVisible(self.spec.modSpeedControlFound or self.spec.modECCFound)
	self.speedControlModTT:setVisible(self.spec.modSpeedControlFound or self.spec.modECCFound)
	
	self.speedControlTurnSpeedTitle1:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_speedSetting"))
	local speedTable = {} --create speedTable with -10..-1,1..40
	for n=1,10 do
		speedTable[n] = tostring(n-11)
	end
	for n=1,40 do
		speedTable[n+10] = tostring(n)
	end
	self.speedControlTurnSpeedSetting1:setTexts(speedTable)
	local turnSpeedSetting
	if self.spec.turnSpeed < 0 then 
		turnSpeedSetting = math.floor(self.spec.turnSpeed) + 11
	else
		turnSpeedSetting = math.floor(self.spec.turnSpeed) + 10
	end
	self.speedControlTurnSpeedSetting1:setState(not self.spec.useModSpeedControl and turnSpeedSetting or 15)
	local disableSpeedcontrolMod
	if not self.spec.modSpeedControlFound and not self.spec.modECCFound then
		disableSpeedcontrolMod = true
	else 
		disableSpeedcontrolMod = not self.spec.useModSpeedControl or not self.spec.useSpeedControl
	end
	self.speedControlTurnSpeedSetting1:setDisabled(not disableSpeedcontrolMod or not self.spec.useSpeedControl)
	
	self.speedControlTurnSpeedTitle2:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_speedControlModSetting"))
	self.speedControlTurnSpeedSetting2:setTexts({"1","2","3"})
	self.speedControlTurnSpeedSetting2:setState(self.spec.useModSpeedControl and self.spec.turnSpeed or 1)
	self.speedControlTurnSpeedSetting2:setDisabled(disableSpeedcontrolMod) -- or (not self.spec.modSpeedControlFound and not self.spec.modECCFound))
	self.speedControlTurnSpeedTitle2:setVisible(self.spec.modSpeedControlFound or self.spec.modECCFound)
	self.speedControlTurnSpeedSetting2:setVisible(self.spec.modSpeedControlFound or self.spec.modECCFound)
	self.speedControlModSettingTT:setVisible(self.spec.modSpeedControlFound or self.spec.modECCFound)
	
	-- Implement control
	self.implementControl:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_implementControl"))
	
	self.raiseTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_raise"))
	
	self.raiseSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.raiseSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_both"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_seq"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_front"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_back"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off")
	})
	local raiseState = 5
	if self.spec.useRaiseImplementF and self.spec.useRaiseImplementB then raiseState = 1 end
	if self.spec.useRaiseImplementF and self.spec.useRaiseImplementB and self.spec.waitOnTrigger then raiseState = 2 end
	if self.spec.useRaiseImplementF and not self.spec.useRaiseImplementB then raiseState = 3 end
	if not self.spec.useRaiseImplementF and self.spec.useRaiseImplementB then raiseState = 4 end
	self.raiseSetting:setState(raiseState)
	
	self.turnPlowTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_plow"))
	self.turnPlowSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_plowFull"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_plowCenter"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_plowOff")
	})
	local plowState
	if self.spec.useTurnPlow and not self.spec.useCenterPlow then plowState = 1; end
	if self.spec.useTurnPlow and self.spec.useCenterPlow then plowState = 2; end
	if not self.spec.useTurnPlow then plowState = 3; end
	self.turnPlowSetting:setState(plowState)
	self.turnPlowSetting:setDisabled(raiseState == 5)

	self.stopPtoTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_pto"))
	self.stopPtoSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_both"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_front"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_back"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off")
	})
	local ptoState = 4
	if self.spec.useStopPTOF and self.spec.useStopPTOB then ptoState = 1; end
	if self.spec.useStopPTOF and not self.spec.useStopPTOB then ptoState = 2; end
	if not self.spec.useStopPTOF and self.spec.useStopPTOB then ptoState = 3; end
	self.stopPtoSetting:setState(ptoState)
		
	self.ridgeMarkerTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_ridgeMarker"))
	self.ridgeMarkerSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.ridgeMarkerSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on")
	})
	self.ridgeMarkerSetting:setState(self.spec.useRidgeMarker and raiseState ~= 5 and 2 or 1)
	self.ridgeMarkerSetting:setDisabled(raiseState == 5)
	
--[[
	self.emptyBalersSettingTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_emptyBaler"))
	self.emptyBalersSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off")
	})
	self.emptyBalersSetting:setState(self.spec.stopEmptyBaler and 1 or 2)
	self.emptyBalersSetting:setDisabled(true)
--]]

	-- Contour Guidance control
	self.contourControl:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourControl"))
	
	self.contourOnOffTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourOnOff"))
	self.contourOnOffSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.contourOnOffSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contour_On1Pass"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contour_OnMPass")
	})
	local contourOnOffSetting = 1
	if self.spec.contour ~= 0 then
		if self.spec.contourMultiMode then 
			contourOnOffSetting = 3
		else
			contourOnOffSetting = 2
		end
	end	
	self.contourOnOffSetting:setState(contourOnOffSetting)
	self.contourFrontTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourFront"))
	self.contourFrontSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.contourFrontSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on"),
	})
	self.contourFrontSetting:setDisabled(contourOnOffSetting == 1 or self.spec.contourWorkedArea)
	self.contourFrontSetting:setState((contourOnOffSetting ~= 1 and (self.spec.contourFrontActive or self.spec.contourWorkedArea)) and 2 or 1)
	
	self.contourWorkedAreaTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourWorkedArea"))
	self.contourWorkedAreaSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.contourWorkedAreaSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourFieldBorder"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourWorkArea"),
	})
	self.contourWorkedAreaSetting:setDisabled(contourOnOffSetting == 1)
	self.contourWorkedAreaSetting:setState(self.spec.contourWorkedArea and 2 or 1)
	
	self.contourSettingTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourSetting"))
	self.contourSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.contourSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contour_nextRight"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contour_nextLeft"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contour_alwaysRight"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contour_alwaysLeft")
	})
	self.contourSetting:setDisabled(contourOnOffSetting == 1)
	local contourMode = 1 
	if self.spec.contour > 0 then contourMode = 2 end
	if self.spec.contourNoSwap then contourMode = contourMode + 2 end
	self.contourSetting:setState(contourMode)
	
	self.contourWidthSettingTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourWidthSetting"))
	self.contourWidthSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.contourWidthSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contour_keepDistance"),
		tostring(math.floor(self.spec.vehicleWidth * 0.5)).." m",
		tostring(math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 0.5).." m",
		tostring(math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 1).." m",
		tostring(math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 2).." m",
		tostring(math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 3).." m",
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contour_manualWidth")
	})
	
	self.contourWidthSetting:setDisabled(contourOnOffSetting == 1)
	local widthMode = self.spec.contourWidthManualMode and 7 or 1
	if self.spec.contourWidth == math.floor(self.spec.vehicleWidth * 0.5) then widthMode = 2 end
	if self.spec.contourWidth == math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 0.5 then widthMode = 3 end
	if self.spec.contourWidth == math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 1 then widthMode = 4 end
	if self.spec.contourWidth == math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 2 then widthMode = 5 end
	if self.spec.contourWidth == math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 3 then widthMode = 6 end
	self.contourWidthSetting:setState(widthMode)
	
	self.contourWidthSettingInputTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourWidthSettingInputTitle"))
	self.contourWidthSettingInput:setText(tostring(self.spec.contourWidthManualInput))
	self.contourWidthSettingInput:setDisabled(widthMode ~= 7)
	self.contourWidthSettingInput.onEnterPressedCallback = HeadlandManagementGui.onContourWidthInput
	
	self.contourWidthChangeSettingTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourWidthChangeSetting"))
	self.contourWidthChangeSettingTitle.onClickCallback = HeadlandManagementGui.logicalCheck
	self.contourWidthChangeSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on")
	})
	local contourWidthChangeDisabled = contourOnOffSetting == 1 or widthMode == 1 or self.spec.contourWorkedArea
	self.contourWidthChangeSetting:setDisabled(contourWidthChangeDisabled)
	self.contourWidthChangeSetting:setState(not contourWidthChangeDisabled and self.spec.contourWidthAdaption and not self.spec.contourWorkedArea and 2 or 1)
		
	-- GPS control
	self.gpsControl:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsControl"))
	self.gpsOnOffTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsSetting"))
	self.gpsOnOffSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.gpsOnOffSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on")
	})
	self.gpsOnOffSetting:setState(self.spec.useGPS and 2 or 1)
		
	self.gpsSettingTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsType"))
	self.gpsSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	
	self.showGPS = true
	
	-- gpsSetting: 1: auto-mode, 2: gs-mode, 3: vca-mode, 4: vca-turn-left, 5: vca-turn-right, 6: ev-mode, 7: ev-mode autoturn
	local lastGPSSetting = self.spec.gpsSetting
	self.gpsVariant = 0
	
	if self.spec.modGuidanceSteeringFound and self.spec.modVCAFound and not self.spec.modEVFound then -- 1 1 0
		if self.spec.gpsSetting >= 6 then self.spec.gpsSetting = 1 end
		self.gpsSetting:setTexts({
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_gs"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vca"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vcaL"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vcaR"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vanilla")
		})
		self.gpsVariant = 6
	end
	if self.spec.modGuidanceSteeringFound and not self.spec.modVCAFound and not self.spec.modEVFound then -- 1 0 0
		if self.spec.gpsSetting ~= 2 then self.spec.gpsSetting = 1 end
		self.gpsSetting:setTexts({
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_gs"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vanilla")
		})
		self.gpsVariant = 4
	end
	if not self.spec.modGuidanceSteeringFound and self.spec.modVCAFound and not self.spec.modEVFound then -- 0 1 0
		if self.spec.gpsSetting >= 6 then self.spec.gpsSetting = 1 end
		if self.spec.gpsSetting > 1 then self.spec.gpsSetting = self.spec.gpsSetting - 1 end
		self.gpsSetting:setTexts({
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vca"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vcaL"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vcaR"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vanilla")
		})
		self.gpsVariant = 2
	end
	if not self.spec.modGuidanceSteeringFound and not self.spec.modVCAFound and not self.spec.modEVFound then -- 0 0 0
		self.gpsSetting:setTexts({
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vanilla")
		})
		self.showGPS = false
		self.spec.gpsSetting = 1
	end
	if self.spec.modGuidanceSteeringFound and self.spec.modVCAFound and self.spec.modEVFound then -- 1 1 1
		self.gpsSetting:setTexts({
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_gs"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vca"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vcaL"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vcaR"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_ev"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_ev_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vanilla")
		})
		self.gpsVariant = 7
	end
	if self.spec.modGuidanceSteeringFound and not self.spec.modVCAFound and self.spec.modEVFound then -- 1 0 1
		if self.spec.gpsSetting > 2 and self.spec.gpsSetting < 6 then self.spec.gpsSetting = 1 end
		if self.spec.gpsSetting >= 6 then self.spec.gpsSetting = self.spec.gpsSetting - 3 end
		self.gpsSetting:setTexts({
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_gs"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_ev"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_ev_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vanilla")
		})
		self.gpsVariant = 5
	end
	if not self.spec.modGuidanceSteeringFound and self.spec.modVCAFound and self.spec.modEVFound then -- 0 1 1
		if self.spec.gpsSetting > 1 then self.spec.gpsSetting = self.spec.gpsSetting - 1 end
		self.gpsSetting:setTexts({
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vca"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vcaL"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vcaR"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_ev"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_ev_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vanilla")
		})
		self.gpsVariant = 3
	end
	if not self.spec.modGuidanceSteeringFound and not self.spec.modVCAFound and self.spec.modEVFound then -- 0 0 1
		if self.spec.gpsSetting > 1 and self.spec.gpsSetting < 6 then self.spec.gpsSetting = 1 end
		if self.spec.gpsSetting >= 6 then self.spec.gpsSetting = self.spec.gpsSetting - 4 end
		self.gpsSetting:setTexts({
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_ev"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_ev_auto"),
			g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_vanilla")
		})
		self.gpsVariant = 1
	end
	self.gpsSetting:setState(self.spec.gpsSetting)
	
	local gpsDisabled
	if not self.spec.modGuidanceSteeringFound and not self.spec.modVCAFound and not self.spec.modEVFound then
		gpsDisabled = true
	else
		gpsDisabled = not self.spec.useGPS
	end
	self.gpsSetting:setDisabled(gpsDisabled or not self.showGPS or self.spec.useEVTrigger)
	--self.gpsSetting:setVisible(self.spec.modGuidanceSteeringFound or self.spec.modVCAFound or self.spec.modEVFound)
	
	-- VCA direction switching
	self.gpsDisableDirSwitchTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_vcaDirSwitch"))
	self.gpsEnableDirSwitchSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on")
	})
	local disableDirSwitchSetting = not self.spec.modVCAFound or lastGPSSetting < 4 or lastGPSSetting >= 6
	self.gpsEnableDirSwitchSetting:setState(not disableDirSwitchSetting and self.spec.vcaDirSwitch and 2 or 1)
	self.gpsEnableDirSwitchSetting:setDisabled(disableDirSwitchSetting)
	self.gpsDisableDirSwitchTitle:setVisible(self.spec.modVCAFound)
	self.gpsEnableDirSwitchSetting:setVisible(self.spec.modVCAFound)
	self.gpsDirSwitchTT:setVisible(self.spec.modVCAFound)
	
	-- Headland automatic
	self.gpsAutoTrigger:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsAutoTriggerSetting"))
	self.gpsAutoTriggerSubTitle:setText(string.format(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsAutoTriggerSubTitle"),self.spec.vehicleLength,self.spec.vehicleWidth,self.spec.maxTurningRadius))
	self.gpsAutoTriggerTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsAutoTriggerSetting"))
	self.gpsAutoTriggerSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	local triggerAnz = 2
	local triggerTexts = ({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on")
	})
	if self.spec.modGuidanceSteeringFound then 
		triggerAnz = triggerAnz + 1
		triggerTexts[triggerAnz] = g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_gs") 
	end
	--if self.spec.modEVFound then 
	--	triggerAnz = triggerAnz + 1
	--	triggerTexts[triggerAnz] = g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gps_ev") 
	--end
	self.gpsAutoTriggerSetting:setTexts(triggerTexts)
	self.gpsAutoTriggerSetting:setDisabled(self.spec.useEVTrigger)
	
	local triggerSetting = 1
	triggerAnz = 2
	
	if self.spec.useHLMTriggerF or self.spec.useHLMTriggerB then 
		triggerSetting = 2
	end
	
	if self.spec.modGuidanceSteeringFound then
		triggerAnz = triggerAnz + 1 
		if self.spec.useGuidanceSteeringTrigger then triggerSetting = triggerAnz end
	end
	--if self.spec.modEVFound then
	--	triggerAnz = triggerAnz + 1
	--	if self.spec.useEVTrigger then triggerSetting = triggerAnz end
	--end
	self.gpsAutoTriggerSetting:setState(triggerSetting)
	
	self.gpsAutoTriggerOffsetTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsAutoTriggerOffsetSetting"))
	self.gpsAutoTriggerOffsetSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.gpsAutoTriggerOffsetSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_front"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_back")
	})	
	local offsetSetting = 1
	if self.spec.modGuidanceSteeringFound and triggerSetting == 3 and self.spec.useGuidanceSteeringOffset then 
		offsetSetting = 1 
	elseif triggerSetting == 2 and self.spec.useHLMTriggerB then 
		offsetSetting = 2
	end
	self.gpsAutoTriggerOffsetSetting:setState(offsetSetting)
	self.gpsAutoTriggerOffsetSetting:setDisabled(triggerSetting == 1 or (triggerSetting == 3 and self.gpsEnabled) or (triggerSetting == 3 and not self.spec.modGuidanceSteeringFound) or triggerSetting == 4 or self.spec.useEVTrigger)
	
	self.gpsAutoTriggerOffsetWidthTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsAutoTriggerOffsetWidth"))
	self.gpsAutoTriggerOffsetWidthInput:setText(tostring(self.spec.headlandDistance))
	self.gpsAutoTriggerOffsetWidthInput.onEnterPressedCallback = HeadlandManagementGui.onWidthInput
	self.gpsAutoTriggerOffsetWidthInput:setDisabled(triggerSetting ~= 2 or self.spec.useEVTrigger)
	
	self.gpsResumeTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_autoResume"))
	self.gpsResumeSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on")
	})
	local resumeSettingDisabled = (not self.spec.modGuidanceSteeringFound and triggerSetting == 3) or triggerSetting == 4 or self.spec.useEVTrigger
	self.gpsResumeSetting:setState(not resumeSettingDisabled and self.spec.autoResume and 2 or 1)
	self.gpsResumeSetting:setDisabled(resumeSettingDisabled)
	
	-- Vehicle control
	self.vehicleControl:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_vehicleControl"))
	
	-- Diff control
	self.diffControlOnOffTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_diffLock"))
	self.diffControlOnOffSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on")
	})
	local diffControlOnOffSettingDisabled = not self.spec.modVCAFound and not self.spec.modEVFound
	self.diffControlOnOffSetting:setState(not diffControlOnOffSettingDisabled and self.spec.useDiffLock and 2 or 1)
	self.diffControlOnOffSetting:setDisabled(diffControlOnOffSettingDisabled)
	--self.diffControlOnOffSetting:setVisible(self.spec.modVCAFound or self.spec.modEVFound)
	
	-- CrabSteering control
	self.crabSteeringTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_crabSteering"))
	self.crabSteeringSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_csDirect"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_csTwoStep"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off")
	})
	local csState = 2
	if self.spec.useCrabSteering and not self.spec.useCrabSteeringTwoStep then csState = 1; end
	if self.spec.useCrabSteering and self.spec.useCrabSteeringTwoStep then csState = 2; end
	if not self.spec.useCrabSteering then csState = 3; end
	self.crabSteeringSetting:setState(csState)
	self.crabSteeringSetting:setDisabled(not self.spec.crabSteeringFound)
	--self.crabSteeringSetting:setVisible(self.spec.crabSteeringFound)
	
	-- Debug
	self.debug:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_debug"))
	self.debugTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_debugTitle"))
	self.debugSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off")
	})
	self.debugSetting:setState(debug and 1 or 2)
	
	self.debugFlagTitle:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_debugFlagTitle"))
	self.debugFlagSetting:setTexts({
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_on"),
		g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_off")
	})
	self.debugFlagSetting.onClickCallback = HeadlandManagementGui.logicalCheck
	self.debugFlagSetting:setState(self.spec.debugFlag and 1 or 2)
	self.debugFlagSetting:setDisabled(raiseState ~= 2)
	
	-- Set ToolTip-Texts
	self.alarmTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_alarmTT"))
	self.inputbindingsTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_inputbindingsTT"))
	self.alarmVolumeTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_beepVolTT"))
	self.raiseTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_raiseTT"))
	self.plowTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_plowTT"))
	self.ptoTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_ptoTT"))
	self.ridgeMarkerTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_ridgeMarkerTT"))
	--self.emptyBalersSettingTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_emptyBalersSettingTT"))
	self.diffLockTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_diffLockTT"))
	self.csTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_csTT"))
	self.contourOnOffTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourOnOffTT"))
	self.contourSettingTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourSettingTT"))
	self.contourWidthSettingTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourWidthSettingTT"))
	self.contourWidthSettingInputTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourWidthSettingInputTT"))
	self.contourWidthChangeSettingTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_contourWidthChangeSettingTT"))
	self.gpsTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsTT"))
	self.gpsTypeTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsTypeTT"))
	self.gpsAutoTriggerTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsAutoTriggerTT"))
	self.gpsAutoTriggerOffsetTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsAutoTriggerOffsetTT"))
	self.gpsAutoTriggerOffsetWidthTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsAutoTriggerOffsetWidthTT"))
	self.speedControlTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_speedControlTT"))
	self.speedControlModTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_speedControlModTT"))
	self.speedSettingTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_speedSettingTT"))
	self.speedControlModSettingTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_speedControlModSettingTT"))
	self.gpsDirSwitchTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_VCADirSwitchTT"))
	self.gpsResumeTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_gpsAutoResumeTT"))
	self.debugTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_debugTT"))
	self.debugFlagTT:setText(g_i18n.modEnvironments[HeadlandManagement.MOD_NAME]:getText("hlmgui_debugFlagTT"))
end

-- check logical dependencies
function HeadlandManagementGui:logicalCheck()
	dbgprint("HeadlandManagementGui: logicalCheck", 3)
	
	local useBeep = self.alarmSetting:getState() == 2
	self.alarmVolumeSetting:setDisabled(not useBeep)
	
	local useSpeedControl = self.speedControlOnOffSetting:getState() == 2
	self.speedControlUseSCModSetting:setDisabled(not useSpeedControl or (not self.spec.modSpeedControlFound and not self.spec.modECCFound)) 
	
	local useModSpeedControl = self.speedControlUseSCModSetting:getState() == 2
	self.speedControlTurnSpeedSetting1:setDisabled(useModSpeedControl or not useSpeedControl)
	self.speedControlTurnSpeedSetting2:setDisabled(not useModSpeedControl or (not self.spec.modSpeedControlFound and not self.spec.modECCFound) or not useSpeedControl)
	
	local useRaiseImplement = self.raiseSetting:getState() ~= 5	
	self.turnPlowSetting:setDisabled(not useRaiseImplement)
	self.ridgeMarkerSetting:setDisabled(not useRaiseImplement)
	if not useRaiseImplement then
		self.ridgeMarkerSetting:setState(1)
	end
	
	local contourOnOffSetting = self.contourOnOffSetting:getState()
	local contourFrontSetting = self.contourFrontSetting:getState()
	local contourWorkedAreaSetting = self.contourWorkedAreaSetting:getState()
	local widthSetting = self.contourWidthSetting:getState()
	local widthChangeSetting = self.contourWidthChangeSetting:getState()
	self.contourWidthSettingInput:setDisabled(widthSetting ~= 7)
	self.contourSetting:setDisabled(contourOnOffSetting == 1)
	self.contourFrontSetting:setDisabled(contourOnOffSetting == 1 or contourWorkedAreaSetting == 2)	
	self.contourFrontSetting:setState(contourWorkedAreaSetting == 2 and 1 or contourFrontSetting)	
	self.contourWorkedAreaSetting:setDisabled(contourOnOffSetting == 1)
	self.contourWidthSetting:setDisabled(contourOnOffSetting == 1)
	self.contourWidthChangeSetting:setDisabled(contourOnOffSetting == 1 or widthSetting == 1 or contourWorkedAreaSetting == 2)
	self.contourWidthChangeSetting:setState(contourWorkedAreaSetting == 2 and 2 or widthChangeSetting)

	local useGPS = self.gpsOnOffSetting:getState() == 2
	local triggerSetting = self.gpsAutoTriggerSetting:getState()
	--local useEVTrigger = (triggerSetting == 3 and not self.spec.modGuidanceSteeringFound) or (triggerSetting == 4 and self.spec.modGuidanceSteeringFound)
	--self.gpsOnOffSetting:setDisabled(not self.spec.modGuidanceSteeringFound and not self.spec.modVCAFound and not self.spec.modEVFound or useEVTrigger)
	
	local gpsSetting = self.gpsSetting:getState()
	if not self.spec.modGuidanceSteeringFound and gpsSetting > 1 then
		gpsSetting = gpsSetting + 1
	end
	self.gpsSetting:setDisabled(not useGPS or not self.showGPS)
	
	self.gpsEnableDirSwitchSetting:setDisabled(not useGPS or not self.spec.modVCAFound or gpsSetting < 4 or gpsSetting > 5)
	
	self.gpsAutoTriggerOffsetSetting:setDisabled(triggerSetting == 1 or (triggerSetting == 3 and self.gpsEnabled))
	
	self.gpsAutoTriggerOffsetWidthInput:setDisabled(triggerSetting ~= 2)
	
	--self.gpsResumeSetting:setDisabled(useEVTrigger)
	
	--self.debugFlagSetting:setDisabled(self.raiseSetting:getState() ~= 2)
end

-- get width input
function HeadlandManagementGui:onWidthInput()
	dbgprint("onWidthInput : "..self.gpsAutoTriggerOffsetWidthInput:getText())
	local inputValue = tonumber(self.gpsAutoTriggerOffsetWidthInput:getText())
	if inputValue ~= nil then self.spec.headlandDistance = inputValue end
	dbgprint("onWidthInput : spec.headlandDistance: "..tostring(self.spec.headlandDistance), 2)
end

function HeadlandManagementGui:onContourWidthInput()
	dbgprint("onContourWidthInput : "..self.contourWidthSettingInput:getText())
	local inputValue = tonumber(self.contourWidthSettingInput:getText())
	if inputValue ~= nil then self.spec.contourWidthManualInput = inputValue end
	dbgprint("onContourWidthInput : spec.contourWidthManualInput: "..tostring(self.spec.contourWidthManualInput), 2)
end

-- close gui and send new values to callback
function HeadlandManagementGui:onClickOk()
	dbgprint("onClickOk", 3)
	
	-- speed control
	self.spec.useSpeedControl = self.speedControlOnOffSetting:getState() == 2
	self.spec.useModSpeedControl = self.speedControlUseSCModSetting:getState() == 2
	if self.spec.useModSpeedControl then
		self.spec.turnSpeed = self.speedControlTurnSpeedSetting2:getState()
	else 
		local turnSpeed = self.speedControlTurnSpeedSetting1:getState()
		if turnSpeed < 11 then 
			self.spec.turnSpeed = turnSpeed - 11
		else 
			self.spec.turnSpeed = turnSpeed - 10
		end
	end
	-- raise
	local raiseState = self.raiseSetting:getState()
	if raiseState == 1 then self.spec.useRaiseImplementF = true; self.spec.useRaiseImplementB = true; self.spec.waitOnTrigger = false; end
	if raiseState == 2 then self.spec.useRaiseImplementF = true; self.spec.useRaiseImplementB = true; self.spec.waitOnTrigger = true; end
	if raiseState == 3 then self.spec.useRaiseImplementF = true; self.spec.useRaiseImplementB = false; self.spec.waitOnTrigger = false; end
	if raiseState == 4 then self.spec.useRaiseImplementF = false; self.spec.useRaiseImplementB = true; self.spec.waitOnTrigger = false; end
	if raiseState == 5 then self.spec.useRaiseImplementF = false; self.spec.useRaiseImplementB = false; self.spec.waitOnTrigger = false; end
	-- pto
	self.spec.useStopPTOF = (self.stopPtoSetting:getState() == 1 or self.stopPtoSetting:getState() == 2)
	self.spec.useStopPTOB = (self.stopPtoSetting:getState() == 1 or self.stopPtoSetting:getState() == 3)
	-- plow
	local plowState = self.turnPlowSetting:getState()
	self.spec.useTurnPlow = (plowState < 3)
	self.spec.useCenterPlow = (plowState == 2)
	-- ridgemarker
	self.spec.useRidgeMarker = self.ridgeMarkerSetting:getState() == 2
	-- stop emptying balers
	--self.spec.stopEmptyBaler = self.emptyBalersSetting:getState() == 1
	-- crab steering
	self.spec.csState = self.crabSteeringSetting:getState()
	self.spec.useCrabSteering = (self.spec.csState ~= 3)
	self.spec.useCrabSteeringTwoStep = (self.spec.csState == 2)
	-- contour guidance
	local contour = self.contourOnOffSetting:getState() -- 1: off, 2: 1 row, 3: every row
	local contourMode = self.contourSetting:getState()  -- 1: next right, 2: next left, 3: always right, 4: always left
	self.spec.contour = 0
	self.spec.contourMultiMode = false
	self.spec.contourNoSwap = false
	if contourMode > 2 then
		self.spec.contourNoSwap = true
		contourMode = contourMode - 2
	end
	if contour == 3 then
		self.spec.contourMultiMode = true
	end
	if contour > 1 and contourMode == 1 then
		self.spec.contour = -1
	elseif contour > 1 and contourMode == 2 then
		self.spec.contour = 1
	end
	
	self.spec.contourFrontActive = self.contourFrontSetting:getState() == 2
	self.spec.contourWorkedArea = self.contourWorkedAreaSetting:getState() == 2
	
	local widthMode = self.contourWidthSetting:getState()
	if widthMode == 2 then 
		self.spec.contourWidth = math.floor(self.spec.vehicleWidth * 0.5)
		self.spec.contourWidthMeasurement = false
		self.spec.contourTrack = 1
		self.spec.contourWidthManualMode = false
	elseif widthMode == 3 then 
		self.spec.contourWidth = math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 0.5
		self.spec.contourWidthMeasurement = false
		self.spec.contourTrack = 1.5
		self.spec.contourWidthManualMode = false
	elseif widthMode == 4 then 
		self.spec.contourWidth = math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 1
		self.spec.contourWidthMeasurement = false
		self.spec.contourTrack = 2
		self.spec.contourWidthManualMode = false
	elseif widthMode == 5 then 
		self.spec.contourWidth = math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 2
		self.spec.contourWidthMeasurement = false
		self.spec.contourTrack = 3
		self.spec.contourWidthManualMode = false
	elseif widthMode == 6 then 
		self.spec.contourWidth = math.floor(self.spec.vehicleWidth * 0.5) + math.floor(self.spec.vehicleWidth) * 3
		self.spec.contourWidthMeasurement = false	
		self.spec.contourTrack = 4
		self.spec.contourWidthManualMode = false
	elseif widthMode == 7 then
		self.spec.contourWidth = self.spec.contourWidthManualInput
		self.spec.contourWidthMeasurement = false
		self.spec.contourTrack = 1
		self.spec.contourWidthManualMode = true
	else
		self.spec.contourWidth = 0
		self.spec.contourWidthMeasurement = true
		self.spec.contourTrack = 0
		self.spec.contourWidthManualMode = false
	end		
	self.spec.contourWidthAdaption = self.contourWidthChangeSetting:getState() == 2
	-- gps
	self.spec.useGPS = self.gpsOnOffSetting:getState() == 2
	local gpsSetting = self.gpsSetting:getState()
	-- 1: auto-mode, 2: gs-mode, 3: vca-mode, 4: vca-turn-left, 5: vca-turn-right, 6: ev-mode, 7: ev-mode with auto-turn
	self.spec.gpsSetting = 1
	if self.gpsVariant == 1 and gpsSetting >= 2 then self.spec.gpsSetting = gpsSetting + 4 end
	if self.gpsVariant == 2 and gpsSetting > 1 then self.spec.gpsSetting = gpsSetting + 1 end
	if self.gpsVariant == 3 and gpsSetting > 1 then self.spec.gpsSetting = gpsSetting + 1 end
	if self.gpsVariant == 4 then self.spec.gpsSetting = gpsSetting end
	if self.gpsVariant == 5 and gpsSetting < 3 then self.spec.gpsSetting = gpsSetting end
	if self.gpsVariant == 5 and gpsSetting >= 3 then self.spec.gpsSetting = gpsSetting + 3 end
	if self.gpsVariant == 6 then self.spec.gpsSetting = gpsSetting end
	if self.gpsVariant == 7 then self.spec.gpsSetting = gpsSetting end
	if self.gpsVariant == 0 and gpsSetting > 1 then self.spec.gpsSetting = 8 end
	-- headland automatic
	local triggerSetting = self.gpsAutoTriggerSetting:getState()
	local offsetSetting = self.gpsAutoTriggerOffsetSetting:getState()
	if triggerSetting == 1 then
		self.spec.useGuidanceSteeringTrigger = false
		self.spec.useGuidanceSteeringOffset = false
		self.spec.useHLMTriggerF = false
		self.spec.useHLMTriggerB = false
		--self.spec.useEVTrigger = false
	elseif triggerSetting == 2 and offsetSetting == 1 then
		self.spec.useGuidanceSteeringTrigger = false
		self.spec.useGuidanceSteeringOffset = false
		self.spec.useHLMTriggerF = true
		self.spec.useHLMTriggerB = false
		--self.spec.useEVTrigger = false
	elseif triggerSetting == 2 and offsetSetting == 2 then
		self.spec.useGuidanceSteeringTrigger = false
		self.spec.useGuidanceSteeringOffset = false
		self.spec.useHLMTriggerF = false
		self.spec.useHLMTriggerB = true
		--self.spec.useEVTrigger = false
	--elseif (triggerSetting == 3 and not self.spec.modGuidanceSteeringFound) or (triggerSetting == 4 and self.spec.modGuidanceSteeringFound) then
	--	self.spec.useGuidanceSteeringTrigger = false
	--	self.spec.useGuidanceSteeringOffset = false
	--	self.spec.useHLMTriggerF = false
	--	self.spec.useHLMTriggerB = false
	--	self.spec.useEVTrigger = true
	elseif triggerSetting == 3 and offsetSetting == 1 then
		self.spec.useGuidanceSteeringTrigger = true
		self.spec.useGuidanceSteeringOffset = false
		self.spec.useHLMTriggerF = false
		self.spec.useHLMTriggerB = false
		--self.spec.useEVTrigger = false
	elseif triggerSetting == 3 and offsetSetting == 2 then
		self.spec.useGuidanceSteeringTrigger = true
		self.spec.useGuidanceSteeringOffset = true
		self.spec.useHLMTriggerF = false
		self.spec.useHLMTriggerB = false
		--self.spec.useEVTrigger = false
	end
	-- VCA dir switch
	self.spec.vcaDirSwitch = self.gpsEnableDirSwitchSetting:getState() == 2
	-- Autoresume
	self.spec.autoResume = self.gpsResumeSetting:getState() == 2
	self.spec.autoResumeOnTrigger = self.spec.autoResume and (self.spec.useHLMTriggerF or self.spec.useHLMTriggerB)
	-- diffs
	self.spec.useDiffLock = self.diffControlOnOffSetting:getState() == 2
	-- beep
	self.spec.beep = self.alarmSetting:getState() == 2
	self.spec.beepVol = self.alarmVolumeSetting:getState()
	-- showKeys
	local showKeys = self.inputbindingsSetting:getState() == 2
	-- debug
	local debug = self.debugSetting:getState() == 1
	self.spec.debugFlag = self.debugFlagSetting:getState() == 1
	dbgprint("gpsSetting (GUI): "..tostring(self.spec.gpsSetting), 3)
	self:close()
	self.callbackFunc(self.target, self.spec, debug, showKeys)
end

-- just close gui
function HeadlandManagementGui:onClickBack()
	dbgprint("onClickBack", 3)
	self:close()
end
