local composer = require "composer"
require "json"
-- Your code here

-- GLOBAL - Gather insets (function returns these in the order of top, left, bottom, right)
topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

--APP Colours
-- GREEN: 63, 179, 79
local _green = {63/255, 179/255, 79/255}
-- BLUE: 110, 159, 182
local _blue = {110/255,159/255,182/255}
-- RED/PINK: 233, 105, 162
local _red = {233/255, 105/255, 162/255}


-- main background
--

-- header background bar
local global_header_background_bar = display.newRect(display.contentCenterX, 0, display.contentWidth, 120+topInset);
global_header_background_bar:setFillColor(63/255, 179/255, 79/255);

-- header wording to be left in place all the time - scenes will display below this area.
local global_header = display.newText({
	text="Greylees Rock Hunt",
	x=display.contentCenterX,
	y=topInset+20,
	fontSize=28,
	font=native.systemFontBold 
	});
global_header:setFillColor(1,1,1);

local global_new_photo_button = display.newText({
	text="+",
	fontSize=30,
	y=topInset+20,
	x = display.safeActualContentWidth - 20
	})
global_new_photo_button:setFillColor(1,1,1)


local global_new_photo_button = display.newText({
	text="?",
	fontSize=30,
	y=topInset+20,
	x = 20
	})
global_new_photo_button:setFillColor(1,1,1)

composer.gotoScene("view_list")


function fileExists(myFile, directoryName)

        local filePath = system.pathForFile(myFile, directoryName)
        local results = false
        if filePath == nil then
                return false
        else
                local file = io.open(filePath, "r")
                --If the file exists, return true
                if file then
                        io.close(file)
                    results = true
                end
                return results
        end
end