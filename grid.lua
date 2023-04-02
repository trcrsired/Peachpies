local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies",true)
if not Peachpies then return end
Peachpies.grid = {}
local LSM = LibStub("LibSharedMedia-3.0")

local default =
{
	Lock = false,
	Enable = true,
	Left = 700,
	Bottom = 800,
	Size = 60,
	CenterTextFont = LSM:GetDefault("font"),
	CenterTextSize = 30,
	BottomTextFont = LSM:GetDefault("font"),
	BottomTextSize = 15,
	
	LowColorR = 1,
	LowColorG = 1,
	LowColorB = 1,
	LowColorA = 1,
	
	MidColorR = 0,
	MidColorG = 0,
	MidColorB = 1,
	MidColorA = 1,
	
	HighColorR = 1,
	HighColorG = 0,
	HighColorB = 0,
	HighColorA = 1,
	
	BottomTextColorR = 1,
	BottomTextColorG = 1,
	BottomTextColorB = 1,
	BottomTextColorA = 1,
}
default.__index = default

Peachpies.modulesdefaultmetatable.grid = default

function Peachpies.CreateGrid(name,co,secure)
	local t =Peachpies.grid
	t[name] = co
	local secure_frame = CreateFrame("Frame",nil,UIParent)
	local actionbutton,hider
	if secure then
		actionbutton = CreateFrame("CheckButton",nil,secure_frame,"SecureActionButtonTemplate")
		actionbutton:SetAttribute("type","spell")
		actionbutton:SetAttribute("spell",secure)
		actionbutton:SetMouseClickEnabled(true)
		actionbutton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
		actionbutton:SetAllPoints(secure_frame)
		actionbutton:SetFrameStrata("BACKGROUND")
		hider = CreateFrame("Button",nil,secure_frame)
		hider:SetFrameStrata("LOW")
		hider:SetAllPoints(secure_frame)
	end
	local frme = CreateFrame("Frame",nil,secure_frame)
	frme:Hide()
	frme:SetFrameStrata("MEDIUM")
	frme:SetClampedToScreen(true)
	frme:SetAllPoints(secure_frame)
	local b =  frme : CreateTexture(nil, "BACKGROUND")
	b:SetAllPoints(frme)
	b:SetTexCoord(0.1,0.9,0.1,0.9)	
	local ct = frme:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	ct:SetPoint("Center", frme, "CENTER",0, 0)
	local btmt = frme:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	btmt:SetPoint("Bottom", frme, "Bottom",0, 0)
	local cd = CreateFrame("Cooldown", nil, frme, "CooldownFrameTemplate")
	cd:SetHideCountdownNumbers(true)
	return frme,b,ct,btmt,cd,secure_frame,actionbutton,hider
end

function Peachpies.GridConfig(t,frame,background,center_text,bottom_text,cd,secure_frame)
	if secure_frame:IsForbidden() then return end
	local tb = t.grid
	if tb == nil then
		tb = {}
		t.grid = tb
	end
	setmetatable(tb,default)
	if tb.Enable then
		secure_frame:Show()
	else
		secure_frame:Hide()
	end
	secure_frame:SetScript("OnMouseDown", secure_frame.StartMoving)
	secure_frame:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing()
		rawset(tb,"Left",self:GetLeft())
		rawset(tb,"Bottom",self:GetBottom())
	end)
	secure_frame:SetScript("OnDragStop", secure_frame.StopMovingOrSizing)
	secure_frame:SetMovable(not tb.Lock)
	secure_frame:EnableMouse(not tb.Lock)
	secure_frame:SetSize(tb.Size,tb.Size)
	secure_frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",tb.Left,tb.Bottom)
	center_text:SetFont(LSM:HashTable("font")[tb.CenterTextFont], tb.CenterTextSize, "OUTLINE")
	bottom_text:SetFont(LSM:HashTable("font")[tb.BottomTextFont], tb.BottomTextSize, "OUTLINE")
	return tb
end

function Peachpies.GridCenter(tb,count,L,M,center_text,format)
	if tb == nil then
		return
	end
	if count < L then
		center_text:SetTextColor(tb.HighColorR,tb.HighColorG,tb.HighColorB,tb.HighColorA)
	elseif count < M then
		center_text:SetTextColor(tb.MidColorR,tb.MidColorG,tb.MidColorB,tb.MidColorA)
	else
		center_text:SetTextColor(tb.LowColorR,tb.LowColorG,tb.LowColorB,tb.LowColorA)
	end
	if format then
		center_text:SetFormattedText(format,count)
	else
		center_text:SetText(count)
	end
end
