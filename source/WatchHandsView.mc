import Toybox.Graphics;
import Toybox.Math;

class WatchHandsView {
    // Define custom colors
    const COLOR_LIGHT_ORANGE = 0xFFA500;
    const COLOR_LIGHT_GREY = 0xD3D3D3;
    const COLOR_RED = 0xFF0000;
    const COLOR_GREY_METALLIC = 0xA9A9A9; // Grey metallic color
    
    // Special marker size constant - easy to adjust
    const SPECIAL_MARKER_SIZE = 26;  // 1.3x larger than before (was 20)

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
    }

    // Draw hour markers around the watch face
    function drawHourMarkers(dc as Dc, centerX, centerY, radius) as Void {
        // Draw regular dot markers for most positions
        for (var i = 0; i < 12; i++) {
            // Skip positions 3, 6, and 9
            if (i == 3 || i == 6 || i == 9) {
                // Draw special markers at these positions instead
                drawSpecialHourMarker(dc, centerX, centerY, radius, i);
                continue;
            }
            
            var angle = i * 30 * Math.PI / 180;
            // Move markers slightly closer to center 
            var markerX = centerX + (radius - 15) * Math.sin(angle);
            var markerY = centerY - (radius - 15) * Math.cos(angle);

            // Draw each marker with white on black
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.fillCircle(markerX, markerY, 3);
        }
    }

    // Draw special hour markers at 3, 6, and 9 with red borders
    function drawSpecialHourMarker(dc as Dc, centerX, centerY, radius, position) as Void {
        var angle = position * 30 * Math.PI / 180;
        // Move special markers more toward the center
        var markerX = centerX + (radius - 25) * Math.sin(angle);
        var markerY = centerY - (radius - 25) * Math.cos(angle);
        
        var markerRadius = SPECIAL_MARKER_SIZE; // Using our constant for size
        var borderWidth = 3;
        
        // Red border only - no gradient
        dc.setColor(COLOR_RED, Graphics.COLOR_BLACK);
        dc.drawCircle(markerX, markerY, markerRadius);
        dc.drawCircle(markerX, markerY, markerRadius-1);
        dc.drawCircle(markerX, markerY, markerRadius-2);
        
        // Clear center for future number placement
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillCircle(markerX, markerY, markerRadius - borderWidth);
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
}