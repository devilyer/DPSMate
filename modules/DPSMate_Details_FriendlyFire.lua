-- Global Variables
DPSMate.Modules.DetailsFF = {}

-- Local variables
local DetailsArr, DetailsTotal, DmgArr, DetailsUser, DetailsSelected  = {}, 0, {}, "", 1
local PieChart = true
local g, g2
local curKey = 1
local db, cbt = {}, 0
local _G = getglobal
local tinsert = table.insert

function DPSMate.Modules.DetailsFF:UpdateDetails(obj, key)
	curKey = key
	db, cbt = DPSMate:GetMode(key)
	if (PieChart) then
		g2=DPSMate.Options.graph:CreateGraphLine("LineGraph",DPSMate_Details_FF_DiagramLine,"CENTER","CENTER",0,0,850,230)
		PieChart = false
	end
	DetailsUser = obj.user
	DPSMate_Details_FF_Title:SetText("Friendly fire by "..obj.user)
	DPSMate_Details_FF:Show()
	self:ScrollFrame_Update()
	self:SelectCreatureButton(1)
	self:SelectDetailsButton(1,1)
	self:UpdateLineGraph()
end

function DPSMate.Modules.DetailsFF:ScrollFrame_Update()
	local line, lineplusoffset
	local path = "DPSMate_Details_FF_LogCreature"
	local obj = _G(path.."_ScrollFrame")
	local pet, len = "", DPSMate:TableLength(DetailsArr)
	DetailsArr, DetailsTotal, DmgArr = DPSMate.RegistredModules[DPSMateSettings["windows"][curKey]["CurMode"]]:EvalTable(DPSMateUser[DetailsUser], curKey)
	FauxScrollFrame_Update(obj,len,10,24)
	for line=1,10 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(obj)
		if DetailsArr[lineplusoffset] ~= nil then
			local user = DPSMate:GetUserById(tonumber(DetailsArr[lineplusoffset]))
			local r,g,b,img = DPSMate:GetClassColor(DPSMateUser[user][2])
			_G(path.."_ScrollButton"..line.."_Name"):SetText(user)
			_G(path.."_ScrollButton"..line.."_Name"):SetTextColor(r,g,b)
			_G(path.."_ScrollButton"..line.."_Value"):SetText(DmgArr[lineplusoffset][1].." ("..string.format("%.2f", (DmgArr[lineplusoffset][1]*100/DetailsTotal)).."%)")
			_G(path.."_ScrollButton"..line.."_Icon"):SetTexture("Interface\\AddOns\\DPSMate\\images\\class\\"..img)
			if len < 10 then
				_G(path.."_ScrollButton"..line):SetWidth(235)
				_G(path.."_ScrollButton"..line.."_Name"):SetWidth(125)
			else
				_G(path.."_ScrollButton"..line):SetWidth(220)
				_G(path.."_ScrollButton"..line.."_Name"):SetWidth(110)
			end
			_G(path.."_ScrollButton"..line):Show()
		else
			_G(path.."_ScrollButton"..line):Hide()
		end
		_G(path.."_ScrollButton"..line.."_selected"):Hide()
		if DetailsSelected == lineplusoffset then
			_G(path.."_ScrollButton"..line.."_selected"):Show()
		end
	end
end

function DPSMate.Modules.DetailsFF:SelectCreatureButton(i)
	local line, lineplusoffset
	local path = "DPSMate_Details_FF_Log"
	local obj = _G(path.."_ScrollFrame")
	obj.index = i
	local pet, len = "", DPSMate:TableLength(DmgArr[i][2])
	FauxScrollFrame_Update(obj,len,10,24)
	for line=1,10 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(obj)
		if DmgArr[i][2][lineplusoffset] ~= nil then
			local ability = DPSMate:GetAbilityById(DmgArr[i][2][lineplusoffset])
			_G(path.."_ScrollButton"..line.."_Name"):SetText(ability)
			_G(path.."_ScrollButton"..line.."_Value"):SetText(DmgArr[i][3][lineplusoffset].." ("..string.format("%.2f", (DmgArr[i][3][lineplusoffset]*100/DetailsTotal)).."%)")
			_G(path.."_ScrollButton"..line.."_Icon"):SetTexture(DPSMate.BabbleSpell:GetSpellIcon(strsub(ability, 1, (strfind(ability, "%(") or 0)-1) or ability))
			if len < 10 then
				_G(path.."_ScrollButton"..line):SetWidth(235)
				_G(path.."_ScrollButton"..line.."_Name"):SetWidth(125)
			else
				_G(path.."_ScrollButton"..line):SetWidth(220)
				_G(path.."_ScrollButton"..line.."_Name"):SetWidth(110)
			end
			_G(path.."_ScrollButton"..line):Show()
		else
			_G(path.."_ScrollButton"..line):Hide()
		end
		_G(path.."_ScrollButton"..line.."_selected"):Hide()
		_G(path.."_ScrollButton1_selected"):Show()
	end
	for p=1, 10 do
		_G("DPSMate_Details_FF_LogCreature_ScrollButton"..p.."_selected"):Hide()
	end
	_G("DPSMate_Details_FF_LogCreature_ScrollButton"..i.."_selected"):Show()
	DPSMate.Modules.DetailsFF:SelectDetailsButton(i,1)
end

function DPSMate.Modules.DetailsFF:SelectDetailsButton(p,i)
	local obj = _G("DPSMate_Details_FF_Log_ScrollFrame")
	local lineplusoffset = i + FauxScrollFrame_GetOffset(obj)
	
	DetailsSelected = lineplusoffset
	for p=1, 10 do
		_G("DPSMate_Details_FF_Log_ScrollButton"..p.."_selected"):Hide()
	end
	-- Performance?
	local ability = tonumber(DmgArr[p][2][lineplusoffset])
	local creature = tonumber(DetailsArr[p])
	_G("DPSMate_Details_FF_Log_ScrollButton"..i.."_selected"):Show()
	
	local path = db[creature][DPSMateUser[DetailsUser][1]][ability]
	local hit, crit, miss, parry, dodge, resist, hitMin, hitMax, critMin, critMax, hitav, critav = path[1], path[5], path[9], path[10], path[11], path[12], path[2], path[3], path[6], path[7], path[4], path[8]
	local total, max = hit+crit+miss+parry+dodge+resist, DPSMate:TMax({hit, crit, miss, parry, dodge, resist})
	
	-- Hit
	_G("DPSMate_Details_FF_LogDetails_Amount2_Amount"):SetText(hit)
	_G("DPSMate_Details_FF_LogDetails_Amount2_Percent"):SetText(ceil(100*hit/total).."%")
	_G("DPSMate_Details_FF_LogDetails_Amount2_StatusBar"):SetValue(ceil(100*hit/max))
	_G("DPSMate_Details_FF_LogDetails_Amount2_StatusBar"):SetStatusBarColor(0.9,0.0,0.0,1)
	_G("DPSMate_Details_FF_LogDetails_Average2"):SetText(ceil(hitav))
	_G("DPSMate_Details_FF_LogDetails_Min2"):SetText(hitMin)
	_G("DPSMate_Details_FF_LogDetails_Max2"):SetText(hitMax)
	
	-- Crit
	_G("DPSMate_Details_FF_LogDetails_Amount3_Amount"):SetText(crit)
	_G("DPSMate_Details_FF_LogDetails_Amount3_Percent"):SetText(ceil(100*crit/total).."%")
	_G("DPSMate_Details_FF_LogDetails_Amount3_StatusBar"):SetValue(ceil(100*crit/max))
	_G("DPSMate_Details_FF_LogDetails_Amount3_StatusBar"):SetStatusBarColor(0.0,0.9,0.0,1)
	_G("DPSMate_Details_FF_LogDetails_Average3"):SetText(ceil(critav))
	_G("DPSMate_Details_FF_LogDetails_Min3"):SetText(critMin)
	_G("DPSMate_Details_FF_LogDetails_Max3"):SetText(critMax)
	
	-- Miss
	_G("DPSMate_Details_FF_LogDetails_Amount4_Amount"):SetText(miss)
	_G("DPSMate_Details_FF_LogDetails_Amount4_Percent"):SetText(ceil(100*miss/total).."%")
	_G("DPSMate_Details_FF_LogDetails_Amount4_StatusBar"):SetValue(ceil(100*miss/max))
	_G("DPSMate_Details_FF_LogDetails_Amount4_StatusBar"):SetStatusBarColor(0.0,0.0,1.0,1)
	_G("DPSMate_Details_FF_LogDetails_Average4"):SetText("-")
	_G("DPSMate_Details_FF_LogDetails_Min4"):SetText("-")
	_G("DPSMate_Details_FF_LogDetails_Max4"):SetText("-")
	
	-- Parry
	_G("DPSMate_Details_FF_LogDetails_Amount5_Amount"):SetText(parry)
	_G("DPSMate_Details_FF_LogDetails_Amount5_Percent"):SetText(ceil(100*parry/total).."%")
	_G("DPSMate_Details_FF_LogDetails_Amount5_StatusBar"):SetValue(ceil(100*parry/max))
	_G("DPSMate_Details_FF_LogDetails_Amount5_StatusBar"):SetStatusBarColor(1.0,1.0,0.0,1)
	_G("DPSMate_Details_FF_LogDetails_Average5"):SetText("-")
	_G("DPSMate_Details_FF_LogDetails_Min5"):SetText("-")
	_G("DPSMate_Details_FF_LogDetails_Max5"):SetText("-")
	
	-- Dodge
	_G("DPSMate_Details_FF_LogDetails_Amount6_Amount"):SetText(dodge)
	_G("DPSMate_Details_FF_LogDetails_Amount6_Percent"):SetText(ceil(100*dodge/total).."%")
	_G("DPSMate_Details_FF_LogDetails_Amount6_StatusBar"):SetValue(ceil(100*dodge/max))
	_G("DPSMate_Details_FF_LogDetails_Amount6_StatusBar"):SetStatusBarColor(1.0,0.0,1.0,1)
	_G("DPSMate_Details_FF_LogDetails_Average6"):SetText("-")
	_G("DPSMate_Details_FF_LogDetails_Min6"):SetText("-")
	_G("DPSMate_Details_FF_LogDetails_Max6"):SetText("-")
	
	-- Resist
	_G("DPSMate_Details_FF_LogDetails_Amount7_Amount"):SetText(resist)
	_G("DPSMate_Details_FF_LogDetails_Amount7_Percent"):SetText(ceil(100*resist/total).."%")
	_G("DPSMate_Details_FF_LogDetails_Amount7_StatusBar"):SetValue(ceil(100*resist/max))
	_G("DPSMate_Details_FF_LogDetails_Amount7_StatusBar"):SetStatusBarColor(0.0,1.0,1.0,1)
	_G("DPSMate_Details_FF_LogDetails_Average7"):SetText("-")
	_G("DPSMate_Details_FF_LogDetails_Min7"):SetText("-")
	_G("DPSMate_Details_FF_LogDetails_Max7"):SetText("-")
end

function DPSMate.Modules.DetailsFF:UpdateLineGraph()
	local sumTable = self:GetSummarizedTable(db)
	local max = DPSMate:GetMaxValue(sumTable, 2)
	local time = DPSMate:GetMaxValue(sumTable, 1)
	
	g2:ResetData()
	g2:SetXAxis(0,time)
	g2:SetYAxis(0,max+200)
	g2:SetGridSpacing(time/10,max/7)
	g2:SetGridColor({0.5,0.5,0.5,0.5})
	g2:SetAxisDrawing(true,true)
	g2:SetAxisColor({1.0,1.0,1.0,1.0})
	g2:SetAutoScale(true)
	g2:SetYLabels(true, false)
	g2:SetXLabels(true)

	local Data1={{0,0}}
	for cat, val in sumTable do
		tinsert(Data1, {val[1],val[2], {}})
	end

	g2:AddDataSeries(Data1,{{1.0,0.0,0.0,0.8}, {1.0,0.0,0.0,0.8}}, {})
end

function DPSMate.Modules.DetailsFF:CreateGraphTable()
	local lines = {}
	for i=1, 8 do
		-- Horizontal
		lines[i] = DPSMate.Options.graph:DrawLine(DPSMate_Details_FF_Log, 252, 270-i*30, 617, 270-i*30, 20, {0.5,0.5,0.5,0.5}, "BACKGROUND")
		lines[i]:Show()
	end
	-- Vertical
	lines[9] = DPSMate.Options.graph:DrawLine(DPSMate_Details_FF_Log, 302, 260, 302, 15, 20, {0.5,0.5,0.5,0.5}, "BACKGROUND")
	lines[9]:Show()
	
	lines[10] = DPSMate.Options.graph:DrawLine(DPSMate_Details_FF_Log, 437, 260, 437, 15, 20, {0.5,0.5,0.5,0.5}, "BACKGROUND")
	lines[10]:Show()
	
	lines[11] = DPSMate.Options.graph:DrawLine(DPSMate_Details_FF_Log, 497, 260, 497, 15, 20, {0.5,0.5,0.5,0.5}, "BACKGROUND")
	lines[11]:Show()
	
	lines[12] = DPSMate.Options.graph:DrawLine(DPSMate_Details_FF_Log, 557, 260, 557, 15, 20, {0.5,0.5,0.5,0.5}, "BACKGROUND")
	lines[12]:Show()
end

function DPSMate.Modules.DetailsFF:GetSummarizedTable(arr)
	local sumTable, a = {}, {}
	for cat, val in DetailsArr do
		for ca, va in arr[val][DPSMateUser[DetailsUser][1]]["i"][1] do
			if sumTable[va[1]] then
				sumTable[va[1]] = sumTable[va[1]]+va[2]
			else
				sumTable[va[1]] = va[2]
			end
		end
	end
	for cat, val in sumTable do
		local i = 1
		while true do
			if (not a[i]) then
				tinsert(a, i, {cat, val})
				break
			else
				if a[i][1] > cat then
					tinsert(a, i, {cat, val})
					break
				end
			end
			i=i+1
		end
	end
	return DPSMate.Sync:GetSummarizedTable(a)
end

