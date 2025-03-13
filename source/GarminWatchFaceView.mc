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

class GarminWatchFaceView extends WatchUi.WatchFace {
    private var _watchHandsView;

    const COLOR_LIGHT_ORANGE = 0xFFA500;  // Orange for battery
    const COLOR_METALLIC_GREY = 0xA9A9A9; // Metallic grey for steps

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

        // Steps ASCII indicator in metallic grey
        drawStepsIcon(dc, centerX, centerY, radius);

        // Heart rate in metallic grey, below center dot
        drawHeartRate(dc, centerX, centerY, radius);
    }


    // Heart rate (ASCII label + BPM) - simplified version
    function drawHeartRate(dc as Dc, centerX as Number, centerY as Number, radius as Number) as Void {
        // Initialize with a default value
        var heartRateStr = "--"; // Hard-coded value that will always display
        
        // Try to get actual heart rate (simple, minimal approach)
        try {
            var info = ActivityMonitor.getInfo();
            if (info != null && info has :heartRate && info.heartRate != null && info.heartRate > 0) {
                heartRateStr = info.heartRate.format("%d");
            }
        } catch(ex) {
            // Silently handle any errors
        }
        
        // Position below center
        var yPosition = centerY + 20;
        
        // Draw heart rate - combined heart symbol and number
        dc.setColor(COLOR_METALLIC_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            yPosition,
            Graphics.FONT_TINY,
            "♥ " + heartRateStr, // Combine heart and number
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
    
    // Battery (ASCII label + percentage)
    function drawBatteryIcon(dc as Dc, centerX as Number, centerY as Number, radius as Number) as Void {
        var stats = System.getSystemStats();
        var batteryPct = stats.battery.format("%d") + "%";
        var batteryText = batteryPct; // ASCII label

        dc.setColor(COLOR_LIGHT_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            centerY - radius + 20,
            Graphics.FONT_TINY,   // Extra-small font
            batteryText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    // Steps (ASCII label + step count)
    function drawStepsIcon(dc as Dc, centerX as Number, centerY as Number, radius as Number) as Void {
        var info = ActivityMonitor.getInfo();
        var stepCount = info != null ? info.steps : 0;
        var stepsText = stepCount.toString(); // ASCII label

        dc.setColor(COLOR_METALLIC_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            centerY - radius + 60,
            Graphics.FONT_TINY,
            stepsText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    // Required stubs
    function onLayout(dc as Dc) as Void {}
    function onShow() as Void {}
    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}