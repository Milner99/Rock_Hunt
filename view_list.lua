local composer = require( "composer" )
local widget = require("widget")
local json = require("json")

local pullToRelease = {}
local reload_notice = {} 
local scene = composer.newScene()
local feed_data = {}
local rocks_table_view = {}
local feed_listener = {}
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
 
 
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        local background = display.newRect(sceneGroup, 0, 0, display.contentWidth, display.contentHeight)
        background:setFillColor(1,1,1)
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
    
        -- load in and display a loading message
        local loadMessage = display.newText({
            parent=sceneGroup,
            text="Loading Rock Library",
            fontSize=20,
            x=display.contentCenterX,
            y=display.contentHeight - 100
            })
        loadMessage.anchorX=0.5
        loadMessage:setFillColor(0,0,0)



        -- load in and display a loading message
        pullToRelease = display.newText({
            parent=sceneGroup,
            text="Keep pulling...",
            fontSize=20,
            x=display.contentCenterX,
            y=topInset+60
            })
        pullToRelease.anchorX=0.5
        pullToRelease:setFillColor(0,0,0)

        -- show the device activity monitor 
        --native.setActivityIndicator(true)


        -- row render method for the table view
        local function onRowRender(e)
            local rowGroup=e.row
            local rowTitle = display.newText({
                parent=rowGroup,
                text=feed_data[e.row.index].title.rendered,
                fontSize=20,
                x=0,
                y=10,
                width=display.contentWidth-110
                })
            rowTitle.anchorX=0
            rowTitle.anchorY=0
            rowTitle.y=5
            rowTitle.x=100
            rowTitle:setFillColor(0,0,0)


            local function featured_image_listener(e2)
                if ( event.isError ) then
                    print( "Network error: ", e2.response )
                else

                    local img = json.decode(e2.response);

                    if img.id == nil then
                        return false;
                    end
                        
                    -- check for loacl cache
                    if fileExists("image"..img.id..".png", system.TemporaryDirectory) then
                        local image_from_cache = display.newImage(rowGroup, "image"..img.id..".png", system.TemporaryDirectory)
                        image_from_cache.width=90
                        image_from_cache.height=90
                        image_from_cache.x=0
                        image_from_cache.y=0
                        image_from_cache.alpha=0
                        transition.to(image_from_cache,{time=200, alpha=1, transition=easing.outQuart});
                    else
                        local function remoteImageLoadingListener(e3)
                            e3.target.width=90
                            e3.target.height=90
                            e3.target.x=0
                            e3.target.y=0
                            e3.target.alpha=0
                            transition.to(e3.target,{time=200, alpha=1, transition=easing.outQuart});
                            rowGroup:insert(e3.target)
                        end
                        if img ~= nil then
                            local new_row_thumb = display.loadRemoteImage(img.media_details.sizes.thumbnail.source_url, "GET", remoteImageLoadingListener, "image"..img.id..".png", system.TemporaryDirectory)
                        end
                    end
                end
            end
            network.request("https://slistapp.com/wp-json/wp/v2/media/" .. feed_data[e.row.index].featured_media, "GET", featured_image_listener)
        end

        local function onRowTouch(event)
            if (event.phase == "release") then
                local options =
                {
                    isModal = true,
                    effect = "fromBottom",
                    time = 400,
                    params = {
                        link = feed_data[event.row.index]._links.self[1].href,
                        sampleVar2 = "another sample variable"
                    }
                }
               --composer.showOverlay("modal_details", options)
            end
        end

        -- scroll listener 
        local function onScrollEvent(event) 
            if (rocks_table_view:getContentPosition() > 100) then
                pullToRelease.text = "Release to reload!"
            else
                pullToRelease.text = "Keep pulling..."
            end
            if (event.direction=="down" and event.limitReached==true and rocks_table_view:getContentPosition() > 100) then
                native.setActivityIndicator(true)
                loadMessage.alpha=1
                rocks_table_view:deleteAllRows()
                network.request("https://slistapp.com/wp-json/wp/v2/greylees_rocks", "GET", feed_listener)
            end
        end

        -- setup a table view - with event listeners for touch to show the details screen
        rocks_table_view = widget.newTableView(
            {
                left = 0,
                top = topInset+40,
                height = display.safeActualContentHeight - 30,
                width = display.safeActualContentWidth,
                onRowRender = onRowRender,
                onRowTouch = onRowTouch,
                listener = onScrollEvent, -- disabled pull down to refresh
                hideBackground=true,
                bottomPadding=50,
                maxVelocity=1
            }
        )
        rocks_table_view.anchorX=0.5
        rocks_table_view.x = display.contentCenterX
        sceneGroup:insert(rocks_table_view)

        -- iterate over into a tableview

        -- retrieve the feed from the web server
        -- parse it as JSON
        feed_listener = function(event)
            print(event.phase)
            if ( event.isError ) then
                print( "Network error: ", event.response )
            elseif event.phase == "ended" then

                print ( "RESPONSE: " .. json.prettify(event.response) )
                feed_data = json.decode(event.response)
                for k,v in ipairs(feed_data) do
                        rocks_table_view:insertRow({
                            isCategory = false,
                            rowHeight = 90,
                            rowColor = {default={1,1,1}, over={110/255,159/255,182/255,0.2}},
                            lineColor = {0.3,0.3,0.3}
                        })
                end
            end
            reload_notice.alpha=1
            native.setActivityIndicator(false)
            loadMessage.alpha=0
        end
        native.setActivityIndicator(true)
        network.request("https://slistapp.com/wp-json/wp/v2/greylees_rocks", "GET", feed_listener)

    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene