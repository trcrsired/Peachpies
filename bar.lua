local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies",true)
if not Peachpies then return end
Peachpies.bar = {}
local LSM = LibStub("LibSharedMedia-3.0")

local default =
{
	Lock = false,
	Enable = true,
	Left = 400,
	Bottom = 500,
	PercentageFont = LSM:GetDefault("font"),
	PercentageFontSize = 15,
	AmountFont = LSM:GetDefault("font"),
	AmountFontSize = 15,
	
	Width = 150,
	Height = 30,
	
	Low = 0.4,
	High = 0.8,
	
	LowColorR = 0,
	LowColorG = 0,
	LowColorB = 1,
	LowColorA = 1,
	
	MidColorR = 0,
	MidColorG = 1,
	MidColorB = 0,
	MidColorA = 1,
	
	HighColorR = 1,
	HighColorG = 0,
	HighColorB = 0,
	HighColorA = 1,
	
	StatusBar = LSM:GetDefault("statusbar"),
	Background = "Blizzard Dialog Background"
}
default.__index = default

Peachpies.modulesdefaultmetatable.bar = default

function Peachpies.CreateBar(name,co)
	local t =Peachpies.bar
	t[name] = co
	local frme = CreateFrame("Frame",nil,UIParent)
	frme:Hide()
	frme:SetFrameStrata("MEDIUM")
	frme:SetClampedToScreen(true)
	frme:SetPoint("CENTER", UIParent, "CENTER",0,0)
	local b =  frme : CreateTexture(nil, "BACKGROUND")
	b:SetAllPoints(frme)
	local br =  CreateFrame("StatusBar",nil,frme)
	br:SetFrameLevel(br:GetFrameLevel()-1)
	br:SetMinMaxValues(0,1)
	br:SetAllPoints(frme)
	local per = frme:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	per:SetPoint("RIGHT", frme, "RIGHT",0, 0)
	local amt = frme:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	amt:SetPoint("RIGHT", frme, "CENTER",0, 0)
	return frme,b,br,per,amt
end

function Peachpies.BarConfig(t,frame,background,statusbar,percentage,amount)
	local tb = t.bar
	if tb == nil then
		tb = {}
		t.bar = tb
	end
	setmetatable(tb,default)
	if tb.Enable then
		frame:Show()
	else
		frame:Hide()
	end
	frame:SetScript("OnMouseDown", frame.StartMoving)
	frame:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing()
		rawset(tb,"Left",self:GetLeft())
		rawset(tb,"Bottom",self:GetBottom())
		rawset(tb,"Width",self:GetWidth())
		rawset(tb,"Height",self:GetHeight())
	end)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetMovable(not tb.Lock)
	frame:EnableMouse(not tb.Lock)
	frame:SetSize(tb.Width,tb.Height)
	frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",tb.Left,tb.Bottom)
	statusbar:SetStatusBarTexture(LSM:HashTable("statusbar")[tb.StatusBar])
	background:SetTexture(LSM:HashTable("background")[tb.Background])
	percentage:SetFont(LSM:HashTable("font")[tb.PercentageFont],tb.PercentageFontSize, "OUTLINE")
	amount:SetFont(LSM:HashTable("font")[tb.AmountFont],tb.AmountFontSize, "OUTLINE")
	return tb
end

function Peachpies.BarSet(tb,current,max,statusbar,percentage,amount)
	local percent = current/max
	statusbar:SetValue(percent)
	percentage:SetText(("%.0f%%"):format(100*percent))
	amount:SetText(("%.0f"):format(current))
	if percent< tb.Low then
		statusbar:SetStatusBarColor(tb.LowColorR,tb.LowColorG,tb.LowColorB,tb.LowColorA)
	elseif percent < tb.High then
		statusbar:SetStatusBarColor(tb.MidColorR,tb.MidColorG,tb.MidColorB,tb.MidColorA)
	else
		statusbar:SetStatusBarColor(tb.HighColorR,tb.HighColorG,tb.HighColorB,tb.HighColorA)
		return true
	end
end
