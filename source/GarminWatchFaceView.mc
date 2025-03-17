import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Sensor;
import Toybox.SensorHistory;

class GarminWatchFaceView extends WatchUi.WatchFace {
    private var _watchHandsView;

    const COLOR_LIGHT_ORANGE = 0xFFA500;  // Orange for battery
    const COLOR_METALLIC_GREY = 0xA9A9A9; // Metallic grey for steps
    const COLOR_BACKGROUND = Graphics.COLOR_BLACK;

    function initialize() {
        WatchFace.initialize();
        _watchHandsView = new WatchHandsView();
    }

    function onUpdate(dc as Dc) as Void {
        // Clear background to black
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var radius = centerX - 15;

        // Get current time
        var clockInfo = System.getClockTime();
        var hours = clockInfo.hour;
        var minutes = clockInfo.min;
        var seconds = clockInfo.sec;

        // Draw watch hands
        _watchHandsView.drawHands(dc, centerX, centerY, radius, hours, minutes, seconds);

        // Battery ASCII indicator in orange
        drawBatteryIcon(dc, centerX, centerY, radius);
        
        // Draw elevation below battery
        drawElevation(dc, centerX, centerY, radius);

        // Steps indicator next to 9 o'clock
        drawStepsIcon(dc, centerX, centerY, radius);
        
        // Date display in box next to 3 o'clock
        drawDate(dc, centerX, centerY, radius);
        
        // // drawWeatherTemperature(dc, centerX, centerY, radius);
        // // drawHeartRate(dc, centerX, centerY, radius);
        // // drawSolarIntensity(dc, centerX, centerY, radius);
        
        // drawSolarIntensity(dc, centerX, centerY, radius);
        // drawWeatherTemperature(dc, centerX, centerY, radius);
        // drawHeartRate(dc, centerX, centerY, radius);
    }

    // Battery (ASCII label + percentage)
    function drawBatteryIcon(dc as Dc, centerX as Number, centerY as Number, radius as Number) as Void {
        var stats = System.getSystemStats();
        var batteryPct = stats.battery.format("%d") + "%";
        // Move down further (from 30 to 50)
        var yPosition = centerY - radius + 50;
        
        dc.setColor(COLOR_LIGHT_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            yPosition,
            Graphics.FONT_XTINY,
            batteryPct,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    // Elevation display with tiny grey icon
    function drawElevation(dc as Dc, centerX as Number, centerY as Number, radius as Number) as Void {
        // Position twice as far down (from 50 to 80)
        var yPosition = centerY - radius + 80;
        
        // Try to get current elevation if available
        var elevationText = "---";
        try {
            var info = Activity.getActivityInfo();
            if (info != null && info has :altitude && info.altitude != null) {
                // Convert to meters and format
                var elevation = info.altitude;
                elevationText = elevation.format("%d") + "m";
            } 
        } catch(ex) {
            // Silently handle errors
        }
        
        // Remove the elevation triangle icon
        
        // Draw elevation text
        var xPosition = 35; // Move further right so it's not on “10”
        dc.setColor(COLOR_METALLIC_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            xPosition,
            yPosition,
            Graphics.FONT_XTINY,
            elevationText,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    // Steps display - positioned near 9 o'clock
    function drawStepsIcon(dc as Dc, centerX as Number, centerY as Number, radius as Number) as Void {
        // Position at 9 o'clock with slight adjustment
        var angle = 270 * Math.PI / 180; // Center on 9 o'clock
        var distance = radius * 0.75;
        var posX = centerX + distance * Math.sin(angle);
        var posY = centerY - distance * Math.cos(angle);
        var posYUp = posY - 2; // Move steps icon slightly up
        
        var info = ActivityMonitor.getInfo();
        var currentSteps = info != null ? info.steps : 0;
        var goalSteps = info != null ? info.stepGoal : 0;
        
        // Format text
        var currentStepsText = currentSteps.toString();
        var goalStepsText = goalSteps.toString();
        
        // Draw current/goal steps with smaller text and spacing
        dc.setColor(COLOR_METALLIC_GREY, Graphics.COLOR_TRANSPARENT);
        
        // Use smallest font and reduce spacing for 2x smaller display
        var posXFinal = posX + 5; // Shift to the right
        dc.drawText(
            posXFinal,
            posYUp - 10,
            Graphics.FONT_XTINY, // Smaller font
            currentStepsText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        // Smaller line
        dc.setPenWidth(1);
        dc.drawLine(posXFinal - 12, posYUp - 4, posXFinal + 12, posYUp - 4);
        
        // Goal steps
        dc.drawText(
            posXFinal,
            posYUp + 2,
            Graphics.FONT_XTINY, // Smaller font
            goalStepsText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
    
    // Date display - simplified format
    function drawDate(dc as Dc, centerX as Number, centerY as Number, radius as Number) as Void {
        // Position at 3 o'clock
        var angle = 90 * Math.PI / 180;
        var distance = radius * 0.75;
        var posX = centerX + distance * Math.sin(angle);
        var posY = centerY - distance * Math.cos(angle);
        var posXLeft = posX - 3; // Move date a bit to the left
        var posYUp = posY - 8;   // Move date a bit up
        
        // Get date information
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var day = info.day;
        
        // Very short day name (2 letters) for smaller display
        var dayOfWeek = info.day_of_week;
        var tinyDayNames = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]; // 2-letter abbreviations
        var dayName = tinyDayNames[dayOfWeek - 1];
        
        // Format as compact date
        var dateText = day.format("%d") + dayName;
        
        // Draw date with minimum font size
        dc.setColor(COLOR_METALLIC_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            posXLeft,
            posYUp,
            Graphics.FONT_XTINY,
            dateText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    // // Heart rate (ASCII label + BPM) - simplified version
    // function drawHeartRate(dc as Dc, centerX, centerY, radius) as Void {
    //     // Initialize with a default value
    //     var heartRateStr = "--"; // Hard-coded value that will always display
        
    //     // Try to get actual heart rate (simple, minimal approach)
    //     try {
    //         var info = ActivityMonitor.getInfo();
    //         if (info != null && info has :heartRate && info.heartRate != null && info.heartRate > 0) {
    //             heartRateStr = info.heartRate.format("%d");
    //         }
    //     } catch(ex) {
    //         // Silently handle any errors
    //     }
        
    //     // Position below center
    //     var yPosition = centerY + 20;
        
    //     // Draw heart rate - combined heart symbol and number
    //     dc.setColor(COLOR_METALLIC_GREY, Graphics.COLOR_TRANSPARENT);
    //     dc.drawText(
    //         centerX,
    //         yPosition,
    //         Graphics.FONT_XTINY, // Smaller font
    //         "♥ " + heartRateStr, // Combine heart and number
    //         Graphics.TEXT_JUSTIFY_CENTER
    //     );
    // }

    // // Solar intensity display
    // function drawSolarIntensity(dc as Dc, centerX, centerY, radius) as Void {
    //     // Position below heart rate (moved down from 40 to 45)
    //     var yPosition = centerY + 45;
        
    //     // Default placeholder for solar intensity
    //     var solarIntensity = "-- %";
        
    //     try {
    //         // Fetch overall solar intensity from SensorHistory
    //         var dailyTotals = SensorHistory.getDailyTotals(SensorHistory.SENSOR_SOLAR_INTENSITY);
    //         if (dailyTotals != null && dailyTotals.size() > 0 && dailyTotals[0] has :avg && dailyTotals[0].avg != null) {
    //             var avg = dailyTotals[0].avg;
    //             solarIntensity = avg.format("%d") + " %";
    //         }
    //     } catch(ex) {
    //         // Silently handle errors - not all watches have solar
    //     }
        
    //     // Draw sun icon and text
    //     dc.setColor(COLOR_LIGHT_ORANGE, Graphics.COLOR_TRANSPARENT);
        
    //     // Draw simple sun icon (circle with rays)
    //     var iconX = centerX - 15;
    //     var iconY = yPosition + 4;
    //     var rayLength = 3;
        
    //     // Sun circle
    //     dc.fillCircle(iconX, iconY, 3);
        
    //     // Rays (8 directions)
    //     for (var i = 0; i < 8; i++) {
    //         var rayAngle = i * 45 * Math.PI / 180;
    //         dc.drawLine(
    //             iconX + 3 * Math.sin(rayAngle), 
    //             iconY - 3 * Math.cos(rayAngle),
    //             iconX + (3 + rayLength) * Math.sin(rayAngle), 
    //             iconY - (3 + rayLength) * Math.cos(rayAngle)
    //         );
    //     }
        
    //     // Draw solar intensity text
    //     dc.drawText(
    //         centerX + 5,
    //         yPosition,
    //         Graphics.FONT_XTINY,
    //         solarIntensity,
    //         Graphics.TEXT_JUSTIFY_LEFT
    //     );
    // }
    
    // // Weather temperature display
    // function drawWeatherTemperature(dc as Dc, centerX, centerY, radius) as Void {
    //     // Position at 8 o'clock
    //     var angle = 240 * Math.PI / 180; // 8 o'clock position
    //     var distance = radius * 0.75;
    //     var posX = centerX + distance * Math.sin(angle);
    //     var posY = centerY - distance * Math.cos(angle);
        
    //     // Placeholder temperature (in real app, would come from Weather API)
    //     var temperature = "18°";
        
    //     try {
    //         // Fetch temperature from the latest Weather API
    //         var currentCond = Weather.getCurrentConditions();
    //         if (currentCond != null && currentCond has :temperature && currentCond.temperature != null) {
    //             temperature = currentCond.temperature.format("%d°");
    //         } else {
    //             temperature = "--°";
    //         }
    //     } catch(ex) {
    //         temperature = "--°";
    //     }
        
    //     // Draw thermometer icon
    //     dc.setColor(COLOR_METALLIC_GREY, Graphics.COLOR_TRANSPARENT);
        
    //     // Simple thermometer icon
    //     var iconX = posX - 10;
    //     var iconY = posY + 3;
        
    //     // Draw thermometer bulb
    //     dc.fillCircle(iconX, iconY, 2);
        
    //     // Draw thermometer stem
    //     dc.fillRectangle(iconX - 1, iconY - 5, 2, 5);
        
    //     // Draw temperature text
    //     dc.drawText(
    //         posX + 5,
    //         posY - 4,
    //         Graphics.FONT_XTINY,
    //         temperature,
    //         Graphics.TEXT_JUSTIFY_LEFT
    //     );
    // }

    // Required stubs
    function onLayout(dc as Dc) as Void {}
    function onShow() as Void {}
    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}