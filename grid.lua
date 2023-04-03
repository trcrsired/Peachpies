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

function Peachpies.CreateGrid(nameinfo,secure)
	local grid_meta = {}
	Peachpies.AddComponentNameinfo("grid",grid_meta,nameinfo)
	local secure_frame = CreateFrame("Frame",nil,UIParent)
	grid_meta.globalframe = secure_frame
	grid_meta.secure = secure
	if secure then
		local actionbutton = CreateFrame("CheckButton",nil,secure_frame,"SecureActionButtonTemplate")
		actionbutton:SetAttribute("type","spell")
		actionbutton:SetAttribute("spell",secure)
		actionbutton:SetMouseClickEnabled(true)
		actionbutton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
		actionbutton:SetAllPoints(secure_frame)
		actionbutton:SetFrameStrata("BACKGROUND")
		grid_meta.actionbutton = actionbutton
		local hider = CreateFrame("Button",nil,secure_frame)
		hider:SetFrameStrata("LOW")
		hider:SetAllPoints(secure_frame)
		grid_meta.actionbutton_hider = hider
	end
	local frme = CreateFrame("Frame",nil,secure_frame)
	grid_meta.frame = frme
	frme:Hide()
	frme:SetFrameStrata("MEDIUM")
	frme:SetClampedToScreen(true)
	frme:SetAllPoints(secure_frame)
	local b =  frme : CreateTexture(nil, "BACKGROUND")
	grid_meta.background = b
	b:SetAllPoints(frme)
	b:SetTexCoord(0.1,0.9,0.1,0.9)	
	local ct = frme:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	grid_meta.center_text = ct
	ct:SetPoint("Center", frme, "CENTER",0, 0)
	local btmt = frme:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	btmt:SetPoint("Bottom", frme, "Bottom",0, 0)
	grid_meta.buttom_text = btmt
	local cd = CreateFrame("Cooldown", nil, frme, "CooldownFrameTemplate")
	cd:SetHideCountdownNumbers(true)
	grid_meta.cooldown = cd
	return grid_meta
end

function Peachpies.GridConfig(t,grid_meta)
	local secure_frame = t.globalframe
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
	grid_meta.center_text:SetFont(LSM:HashTable("font")[tb.CenterTextFont], tb.CenterTextSize, "OUTLINE")
	grid_meta.bottom_text:SetFont(LSM:HashTable("font")[tb.BottomTextFont], tb.BottomTextSize, "OUTLINE")
	return tb
end
