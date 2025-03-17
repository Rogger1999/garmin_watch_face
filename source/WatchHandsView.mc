import Toybox.Graphics;
import Toybox.Math;

class WatchHandsView {
    // Define custom colors
    const COLOR_LIGHT_ORANGE = 0xFFA500;
    const COLOR_LIGHT_GREY = 0xD3D3D3;
    const COLOR_RED = 0xFF0000;
    const COLOR_GREY_METALLIC = 0xA9A9A9; // Grey metallic color
    const COLOR_DIM_ORANGE = 0xBB7A00;    // A dimmer version of the orange color
    
    // Special marker size constant - easy to adjust
    const SPECIAL_MARKER_SIZE = 29;  // 10% larger than before (was 26)

    // Draw the analog hands and markers
    function drawHands(dc as Dc, centerX, centerY, radius, hours, minutes, seconds) as Void {
        var hourAngle   = ((hours % 12) * 30 + minutes / 2) * Math.PI / 180;
        var minuteAngle = minutes * 6 * Math.PI / 180;
        var secondAngle = seconds * 6 * Math.PI / 180;

        // Enable anti-aliasing for smoother drawing if available
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        drawHourMarkers(dc, centerX, centerY, radius);

        // Hour hand: tapered polygon for smooth appearance
        drawSmoothHourHand(dc, centerX, centerY, radius, hourAngle);

        // Minute hand: tapered polygon for smooth appearance
        drawSmoothMinuteHand(dc, centerX, centerY, radius, minuteAngle);

        // Second hand: smoother implementation
        drawSmoothSecondHand(dc, centerX, centerY, radius, secondAngle);

        // Center dot
        drawCenterDot(dc, centerX, centerY);
        
        // Disable anti-aliasing when done
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(false);
        }

        drawBatteryElevationIndicators(dc, centerX, centerY);
    }

    // Draw hour markers around the watch face
    function drawHourMarkers(dc as Dc, centerX, centerY, radius) as Void {
        // Draw hour markers (larger dots) at the very edge
        for (var i = 0; i < 12; i++) {
            var angle = i * 30 * Math.PI / 180;
            // Move dots to the very edge (just 5px from edge)
            var markerX = centerX + (radius - 5) * Math.sin(angle);
            var markerY = centerY - (radius - 5) * Math.cos(angle);
            
            // Draw alternating dot styles: GREY for even, GREY with Black center for odd
            dc.setColor(COLOR_GREY_METALLIC, Graphics.COLOR_BLACK);
            dc.fillCircle(markerX, markerY, 4);
            
            if (i % 2 == 1) {  // Odd positions (1, 3, 5, 7, 9, 11)
                // Add black center to create transparent/hollow look
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.fillCircle(markerX, markerY, 2);
            }
            
            // Draw the 3 smaller dots between each hour position
            drawMinuteDots(dc, centerX, centerY, radius, i);
        }
        
        // Draw hour numbers in a separate loop to ensure consistent positioning
        // and separation from the dots
        drawHourNumbers(dc, centerX, centerY, radius);
    }
    
    // Draw hour numbers in a separate function for better organization
    function drawHourNumbers(dc as Dc, centerX, centerY, radius) as Void {
        // Apply a global vertical shift to move all numbers up
        var verticalShift = 14;
        
        for (var i = 0; i < 12; i++) {
            // Skip positions 3 and 9 (where date and steps will be)
            if (i == 3 || i == 9) {
                continue;
            }
            
            var angle = i * 30 * Math.PI / 180;
            
            // Position numbers closer to the edge dots (but not too close)
            var numberDistance = radius * 0.78; 
            var numX = centerX + numberDistance * Math.sin(angle);
            var numY = centerY - numberDistance * Math.cos(angle) - verticalShift;
            
            // Convert to 12-hour format
            var hourNum = (i == 0) ? 12 : i;
            
            // Use dimmer orange color
            dc.setColor(COLOR_DIM_ORANGE, Graphics.COLOR_TRANSPARENT);
            
            // Draw the hour number
            dc.drawText(
                numX,
                numY - 3,
                Graphics.FONT_TINY, // Use FONT_TINY to ensure compatibility
                hourNum.toString(),
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }
    
    // Draw minute dots (3 small dots between each hour marker)
    function drawMinuteDots(dc as Dc, centerX, centerY, radius, hourPosition) as Void {
        var startAngle = hourPosition * 30;
        
        for (var i = 1; i <= 3; i++) {
            var angle = (startAngle + i * 7.5) * Math.PI / 180; // 7.5 degrees = 30/4
            // Move minute dots to the edge as well
            var dotX = centerX + (radius - 5) * Math.sin(angle);
            var dotY = centerY - (radius - 5) * Math.cos(angle);
            
            // Draw a small grey dot
            dc.setColor(COLOR_GREY_METALLIC, Graphics.COLOR_BLACK);
            dc.fillCircle(dotX, dotY, 1);
        }
    }

    // Draw a smooth hour hand using a polygon
    function drawSmoothHourHand(dc as Dc, centerX, centerY, radius, angle) as Void {
        var fillLength = radius * 0.63; // 30% shorter than 0.9
        var baseWidth = 14;             // 10% thinner (was 15)
        var tipWidth = 5;               // 10% thinner (was 6)
        
        // Calculate points for a tapered polygon
        var points = new [4];
        
        // Calculate perpendicular angle for width
        var perpAngle = angle + Math.PI/2;
        
        // Base left point
        points[0] = [centerX - (baseWidth/2) * Math.sin(perpAngle),
                     centerY + (baseWidth/2) * Math.cos(perpAngle)];
        
        // Base right point
        points[1] = [centerX + (baseWidth/2) * Math.sin(perpAngle),
                     centerY - (baseWidth/2) * Math.cos(perpAngle)];
        
        // Tip right point
        points[2] = [centerX + fillLength * Math.sin(angle) + (tipWidth/2) * Math.sin(perpAngle),
                     centerY - fillLength * Math.cos(angle) - (tipWidth/2) * Math.cos(perpAngle)];
        
        // Tip left point
        points[3] = [centerX + fillLength * Math.sin(angle) - (tipWidth/2) * Math.sin(perpAngle),
                     centerY - fillLength * Math.cos(angle) + (tipWidth/2) * Math.cos(perpAngle)];
        
        // Fill the polygon using triangles since fillPolygon isn't available
        dc.setColor(COLOR_GREY_METALLIC, Graphics.COLOR_BLACK);
        
        // Create triangles from the polygon points
        // Triangle 1: points 0, 1, 2
        dc.fillPolygon([[points[0][0], points[0][1]], 
                         [points[1][0], points[1][1]], 
                         [points[2][0], points[2][1]]]);
        
        // Triangle 2: points 0, 2, 3
        dc.fillPolygon([[points[0][0], points[0][1]], 
                         [points[2][0], points[2][1]], 
                         [points[3][0], points[3][1]]]);
        
        // Draw the outline
        dc.setColor(COLOR_LIGHT_GREY, Graphics.COLOR_BLACK);
        dc.setPenWidth(1);
        
        // Draw lines between all points to form the polygon outline
        for (var i = 0; i < 4; i++) {
            var nextIndex = (i + 1) % 4; // Wrap around to first point
            dc.drawLine(
                points[i][0], points[i][1],
                points[nextIndex][0], points[nextIndex][1]
            );
        }
    }

    // Draw a smooth minute hand using a polygon
    function drawSmoothMinuteHand(dc as Dc, centerX, centerY, radius, angle) as Void {
        var fillLength = radius * 0.86;  // 10% shorter (from 0.95)
        var baseWidth = 9;               // 30% thicker (was 7)
        var tipWidth = 4;                // 30% thicker (was 3)
        
        // Calculate points for a tapered polygon
        var points = new [4];
        
        // Calculate perpendicular angle for width
        var perpAngle = angle + Math.PI/2;
        
        // Base left point
        points[0] = [centerX - (baseWidth/2) * Math.sin(perpAngle),
                     centerY + (baseWidth/2) * Math.cos(perpAngle)];
        
        // Base right point
        points[1] = [centerX + (baseWidth/2) * Math.sin(perpAngle),
                     centerY - (baseWidth/2) * Math.cos(perpAngle)];
        
        // Tip right point
        points[2] = [centerX + fillLength * Math.sin(angle) + (tipWidth/2) * Math.sin(perpAngle),
                     centerY - fillLength * Math.cos(angle) - (tipWidth/2) * Math.cos(perpAngle)];
        
        // Tip left point
        points[3] = [centerX + fillLength * Math.sin(angle) - (tipWidth/2) * Math.sin(perpAngle),
                     centerY - fillLength * Math.cos(angle) + (tipWidth/2) * Math.cos(perpAngle)];
        
        // Fill the polygon using triangles since fillPolygon isn't available
        dc.setColor(COLOR_LIGHT_ORANGE, Graphics.COLOR_BLACK);
        
        // Create triangles from the polygon points
        // Triangle 1: points 0, 1, 2
        dc.fillPolygon([[points[0][0], points[0][1]], 
                         [points[1][0], points[1][1]], 
                         [points[2][0], points[2][1]]]);
        
        // Triangle 2: points 0, 2, 3
        dc.fillPolygon([[points[0][0], points[0][1]], 
                         [points[2][0], points[2][1]], 
                         [points[3][0], points[3][1]]]);
        
        // Draw the outline
        dc.setColor(COLOR_LIGHT_GREY, Graphics.COLOR_BLACK);
        dc.setPenWidth(1);
        
        // Draw lines between all points to form the polygon outline
        for (var i = 0; i < 4; i++) {
            var nextIndex = (i + 1) % 4; // Wrap around to first point
            dc.drawLine(
                points[i][0], points[i][1],
                points[nextIndex][0], points[nextIndex][1]
            );
        }
    }
    
    // Draw a smoother second hand
    function drawSmoothSecondHand(dc as Dc, centerX, centerY, radius, angle) as Void {
        var secondHandLength = radius * 0.9;
        var secondHandTailLength = radius * 0.2;
        var handWidth = 1;  // Thinner for elegance
        var tailWidth = 2;  // Thinner tail for better balance
        
        // Set clip region to improve performance
        dc.setClip(
            centerX - radius, 
            centerY - radius, 
            radius * 2, 
            radius * 2
        );

        // Main hand - a thin red line
        dc.setColor(COLOR_RED, Graphics.COLOR_BLACK);
        dc.setPenWidth(handWidth);
        dc.drawLine(
            centerX,
            centerY,
            centerX + secondHandLength * Math.sin(angle),
            centerY - secondHandLength * Math.cos(angle)
        );

        // Counterbalance tail
        dc.setPenWidth(tailWidth);
        dc.drawLine(
            centerX,
            centerY,
            centerX - secondHandTailLength * Math.sin(angle),
            centerY + secondHandTailLength * Math.cos(angle)
        );

        // Circle at tip
        dc.fillCircle(
            centerX + secondHandLength * Math.sin(angle),
            centerY - secondHandLength * Math.cos(angle),
            3
        );
        
        // Clear clipping region
        dc.clearClip();
    }

    // Draw a refined center dot
    function drawCenterDot(dc as Dc, centerX, centerY) as Void {
        // Metallic grey outer circle
        dc.setColor(COLOR_GREY_METALLIC, Graphics.COLOR_BLACK);
        dc.fillCircle(centerX, centerY, 9);

        // Middle circle
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillCircle(centerX, centerY, 7);

        // Inner circle
        dc.setColor(COLOR_LIGHT_ORANGE, Graphics.COLOR_BLACK);
        dc.fillCircle(centerX, centerY, 5);

        // Innermost dot
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillCircle(centerX, centerY, 2);
    }

    // Add a new function to draw simple shape-based battery/elevation indicators
    function drawBatteryElevationIndicators(dc as Dc, centerX, centerY) as Void {
        // Battery indicator: move it a tiny bit down
        var batteryOffsetY = 5;
        dc.setColor(COLOR_GREY_METALLIC, Graphics.COLOR_BLACK);
        dc.fillCircle(centerX, centerY + batteryOffsetY, 3);

        // Elevation indicator: move it a tiny bit up
        var elevationOffsetY = -5;
        dc.setColor(COLOR_DIM_ORANGE, Graphics.COLOR_BLACK);
        dc.fillCircle(centerX, centerY + elevationOffsetY, 3);
    }
}