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

function Peachpies.CreateBar(nameinfo)
	local bar_meta = {}
	Peachpies.AddComponentNameinfo("bar",bar_meta,nameinfo)
	local frme = CreateFrame("Frame",nil,UIParent)
	bar_meta.globalframe = frme
	frme:Hide()
	frme:SetFrameStrata("MEDIUM")
	frme:SetClampedToScreen(true)
	frme:SetPoint("CENTER", UIParent, "CENTER",0,0)
	local b =  frme : CreateTexture(nil, "BACKGROUND")
	b:SetAllPoints(frme)
	bar_meta.background = b
	local br =  CreateFrame("StatusBar",nil,frme)
	br:SetFrameLevel(br:GetFrameLevel()-1)
	br:SetMinMaxValues(0,1)
	br:SetAllPoints(frme)
	bar_meta.status_bar = br
	local per = frme:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	per:SetPoint("RIGHT", frme, "RIGHT",0, 0)
	bar_meta.percentage_text = per
	local amt = frme:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	amt:SetPoint("RIGHT", frme, "CENTER",0, 0)
	bar_meta.amount_text = amt
	return bar_meta
end

function Peachpies.BarConfig(t,bar_meta)
	local tb = t.bar
	if tb == nil then
		tb = {}
		t.bar = tb
	end
	setmetatable(tb,default)
	local frame = bar_meta.globalframe
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
	bar_meta.status_bar:SetStatusBarTexture(LSM:HashTable("statusbar")[tb.StatusBar])
	bar_meta.background:SetTexture(LSM:HashTable("background")[tb.Background])
	bar_meta.percentage_text:SetFont(LSM:HashTable("font")[tb.PercentageFont],tb.PercentageFontSize, "OUTLINE")
	bar_meta.amount_text:SetFont(LSM:HashTable("font")[tb.AmountFont],tb.AmountFontSize, "OUTLINE")
	return tb
end

function Peachpies.BarSet(tb,current,maxval,bar_meta)
	local percent = current/maxval
	bar_meta.percentage_text:SetText(("%.0f%%"):format(100*percent))
	bar_meta.amount_text:SetText(("%.0f"):format(current))
	local statusbar = bar_meta.status_bar
	statusbar:SetValue(percent)
	if percent< tb.Low then
		statusbar:SetStatusBarColor(tb.LowColorR,tb.LowColorG,tb.LowColorB,tb.LowColorA)
	elseif percent < tb.High then
		statusbar:SetStatusBarColor(tb.MidColorR,tb.MidColorG,tb.MidColorB,tb.MidColorA)
	else
		statusbar:SetStatusBarColor(tb.HighColorR,tb.HighColorG,tb.HighColorB,tb.HighColorA)
		return true
	end
end
