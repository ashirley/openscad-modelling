use <MCAD/fasteners/threads.scad>

/*

| ========== |
|----------  |
|  ----------|
| ========== |

*/


gap = 0.2;
m3ClearanceHole = 3.5;

//leg adjustment
threadGap = 0.75;
nutLength = 35;
capLength = 2;
adjusterThread = 12;
connectorDepth = 2;

//leg
legTopThickness = 13; //Height of leg tops. Cannot be too small or the bolt won't fit.
legTopHubClearance = 24; //The length (from the center) of the cutout in the leg top to clear the hub
legTopLength = 60; //The length (from the center) to the end of the leg top.
legWidth = m3ClearanceHole+4;
legToAdjusterDistance = min(legTopLength-legTopHubClearance, legWidth);
legAngle = 20;
bottleRadius = 54;

legBottomLength = 60; //The length (from the joint) to the end of the leg bottom.
footLength=14;

//hub
hubThickness = 3;
hubSize = 10  ; // half distance between holes.
hubHeight = hubSize * sqrt(3);

module legAdjustment(toPrint = false, bottomTaper = false) {
    module inner(withTaper = false) {
        if (withTaper) {
            //cap with taper
            hull() {
                //this has to be 3d thing for hull to work but logically it is 2d.
                translate([0,0,-(capLength+legToAdjusterDistance)]) rotate([-legAngle,0,0]) linear_extrude(height=.1) polygon([[-legWidth/2,-legTopThickness/2],[legWidth/2,-legTopThickness/2],[legWidth/2, legTopThickness/2],[-legWidth/2,legTopThickness/2]]);
                translate([0,0,-capLength]) cylinder(r=7 + threadGap, h=capLength);
            }
        } else {
            //cap
            translate([0, 0, -capLength]) cylinder(r = 7 + threadGap, h = capLength);
        }
        //thread
        difference() {
            //fairly random rotation but aligns the inner and outer thread.
            rotate ([0, 0, -120]) metric_thread(adjusterThread, 1.5, nutLength / 2);
            cylinder(r = 4.5, h = nutLength / 2);
        }

        module groove() {
            translate([-gap - 1, -1, nutLength / 2]) rotate([90, 90, 0])
                linear_extrude(height = 2.5, convexity = 10, twist = 0)
                    polygon([[nutLength,1],[nutLength,0],[4,0],[3,1]]);
        }

        //alignment semi-cylinder (bottom half)
        color("red") difference() {
            cylinder(r = 4.5, h = nutLength/ 2);
            translate([-gap, -5, 0])
                cube([5, 10, nutLength]);
            translate([0, 0, nutLength / 2]) groove();
        }

        //alignment semi-cylinder (top half)
        color("blue") translate([0, 0, nutLength / 2]) difference() {
            cylinder(r = 4.5 - gap, h = nutLength / 2);
            translate([-gap, -5, 0])
                cube([5, 10, nutLength]);
            groove();
        }

        translate([-gap, 3.5, nutLength]) rotate([90, 90, 0])
            linear_extrude(height = 2.5, convexity = 10, twist = 0)
                polygon([[0,0],[4,0],[3,1]]);
    }

    module nutHalf() {
        //nut / outer
        difference() {
            cylinder(r = 7 + threadGap, h = nutLength / 2, $fn = 12);
            //translate and add length to ensure a 2-manifold result
            translate([0, 0, -1]) metric_thread(adjusterThread + threadGap, 1.5, (nutLength / 2) + 2, internal=true);
        }
    }

    if (toPrint) {
        $fa = $preview ? $fa : 5;
        $fs = $preview ? $fs : 0.1;

        if (bottomTaper) {
            difference() {
                rotate([legAngle,0,0]) translate([20, 0, capLength+legToAdjusterDistance]) inner(withTaper=true);
                translate([20,0,0]) minkowski() {
                    legTopBottomConnector();
                    sphere(d=gap);
                }
            }
        } else {
            translate([20, 0, capLength]) translate([0, 0, capLength]) inner(withTaper=false);
        }
        nutHalf();
        translate([0, 0, nutLength + 0]) rotate([0, 180, 0]) mirror([0, 1, 0]) nutHalf();
        translate([40, 0, 0]) mirror([0, 1, 0]) difference() {
            translate([0, 0, capLength]) inner();
            translate([0,0,-gap]) minkowski() {
                legBottomProfile(height=connectorDepth);
                sphere(d=gap);
            }
        }
    } else {
        translate([0, 0, capLength]) {
            inner(withTaper=bottomTaper);
            nutHalf();
            translate([0, 0, nutLength + 0]) rotate([0, 180, 0]) mirror([0, 1, 0]) inner(withTaper=false);
            translate([0, 0, nutLength + 0]) rotate([0, 180, 0]) mirror([0, 1, 0]) nutHalf();
        }
    }
}


module hub() {
    linear_extrude(height = hubThickness) difference() {
        hull() {
            translate([hubSize, - hubHeight / 3, 0]) circle(d=5, $fn=16);
            translate([-hubSize, - hubHeight / 3, 0]) circle(d=5, $fn=16);
            translate([0, 2 * hubHeight / 3, 0]) circle(d=5, $fn=16);
        }
        translate([hubSize, - hubHeight / 3, 0]) circle(d=m3ClearanceHole, $fn=16);
        translate([-hubSize, - hubHeight / 3, 0]) circle(d=m3ClearanceHole, $fn=16);
        translate([0, 2 * hubHeight / 3, 0]) circle(d=m3ClearanceHole, $fn=16);
    }
}

module legTop(rotate=0) {
    /*
    
    ----    legTopThickness
        |
    ----    y = (legTopThickness + (hubThickness + 2*gap)) / 2;
    |
    ----    x = (legTopThickness - (hubThickness + 2*gap)) / 2;
        |
    ----    0
    
    */
    x = (legTopThickness - (hubThickness + 2*gap)) / 2;
    y = (legTopThickness + (hubThickness + 2*gap)) / 2;

    module centralEndMask() {
        translate([0, 2 * hubHeight / 3, 0])
            union() {
                circle(r=hubSize-gap);
                translate([0, (legTopLength) / 2, 0]) square(size=[legWidth + 2, legTopLength], center=true);
            }
    }

    translate([0, 2*hubHeight/3,0]) rotate([0,0,rotate]) translate([0, -2*hubHeight/3,0]) union() {
        difference() {
            intersection() {
                rotate([90,0,90]) translate([0, ((hubThickness - legTopThickness)/2), -legWidth/2])
                    linear_extrude(height = legWidth, convexity=3)
                        polygon([[0,0], [0,x], [legTopHubClearance,x],[legTopHubClearance,y],[0,y],[0,legTopThickness],[bottleRadius-6,legTopThickness],[bottleRadius-6,legTopThickness-5],[bottleRadius+3,legTopThickness-5],[bottleRadius,legTopThickness-2],[bottleRadius,legTopThickness],[legTopLength,legTopThickness],[legTopLength,0]]);
                linear_extrude(height = legTopThickness * 2, center=true) centralEndMask();
            }
            //screw head
            translate([0,2 * hubHeight / 3,(legTopThickness+hubThickness)/2-3.5]) cylinder(d=6, h=3.5+gap, $fn=16);
            //clearance hole
            translate([0,2 * hubHeight / 3,-legTopThickness/2]) cylinder(d=m3ClearanceHole, h=legTopThickness, $fn=16);
            //nut recess
            translate([0,2 * hubHeight / 3,-(legTopThickness-hubThickness)/2-gap]) cylinder(d=6.5, h=2.5+gap, $fn=6);
        }
        translate([0, legTopLength, hubThickness/2]) rotate([-90,0,0]) legTopBottomConnector();
    }
}

module legBottomProfile(height=0.1) {
    linear_extrude(height = height)  {
        translate([0,0,0]) square(size=[10,2], center=true);
        translate([3,-legWidth/2,0]) square(size=[2,legWidth]);
    }
}

module legBottom(rotate=0, topGap=0, length=legBottomLength, withTaper=true, toPrint=false) {

    module profile(height=0.1, topGap=0) {
        translate ([0, legTopLength + legToAdjusterDistance, 0]) rotate([0, 90 + legAngle, 90]) translate([0,0,topGap]) legBottomProfile(height=height);
    }
    module body() {
        profile(height=length, topGap=topGap);

        if (withTaper) {
            //cap with taper
            //TODO: I want to just use skin or loft to do this but there isn't an obvious function to just achieve this.
            difference() {
                hull() {
                    //this has to be a 3d thing for hull to work but logically it is 2d.
                    translate([0,legTopLength+0.1,0]) rotate([90,0,0]) linear_extrude(height=.1)
                        polygon([[-legWidth/2, 0],[-legWidth/2,-legTopThickness/2],[0,-legTopThickness/2],[legWidth/2,-legTopThickness/2],[legWidth/2, 0],[legWidth/2, legTopThickness/2],[0,legTopThickness/2],[-legWidth/2,legTopThickness/2]]);
                    profile(topGap=topGap);
                }
                translate([0,legTopLength-gap,0]) rotate([-90, 0, 0]) minkowski() {
                    legTopBottomConnector();
                    sphere(d=gap);
                }
            }
        }

        translate ([0, legTopLength + legToAdjusterDistance, 0]) rotate([0, 90 + legAngle, 90]) translate([5,0,length+topGap]) {
            rotate([0, - (90 + legAngle), 0]) linear_extrude(height=2) translate([footLength/2,0,0]) square(size=[footLength,legWidth], center=true);
            hull() {
               rotate([0, - (90 + legAngle), 0]) translate([0,0,1.9]) linear_extrude(height=.1) translate([footLength/2,0,0]) square(size=[footLength,2], center=true);
               rotate([0, 180, 0]) linear_extrude(height=.1) translate([5,0,0]) square(size=[10,2], center=true);
            }
        }
    }

    if (toPrint) {
        if (withTaper) {
            //rotate so taper is on the ground
            translate([0,0,-legTopLength-topGap]) rotate([90,0,0]) body();
        } else {
            //rotate so profile is on the ground
            rotate([0,0,90]) translate([0,0,-topGap]) rotate([0, -(90 + legAngle), 0]) rotate([0,0,-90]) translate ([0, -(legTopLength + legToAdjusterDistance), 0]) body();
        }
    } else {
        translate([0, 2*hubHeight/3, hubThickness/2]) rotate([0,0,rotate]) translate([0, -2*hubHeight/3,0]) {
            body();
        }
    }
}

//The connecting piece to align the top and bottom leg when glueing them together.
module legTopBottomConnector() {
    linear_extrude(height=connectorDepth, scale=0.1) union() {
        square(size=[legWidth-2,2], center=true);
        square(size=[2,legTopThickness-2], center=true);
    }
}

module stand(toPrint=false, collapsed=false) {
    if (toPrint) {
        hub();

        //adjustable leg
        translate([0, hubHeight,legWidth/2]) rotate([0,90,0]) legTop();
        //TODO taper won't print like this.
        translate([-(hubHeight + adjusterThread / 2), 0, 0]) rotate([0,0,90]) legAdjustment(bottomTaper=true, toPrint=true);
        translate([hubHeight + (legWidth + 2) * 2, 0, 0]) legBottom(topGap=nutLength+2*capLength, length=legBottomLength-nutLength-2*capLength-(2.5/cos(90-legAngle))+connectorDepth, withTaper=false, toPrint=true);
        //Fixed legs
        translate([legTopThickness + 2, hubHeight,legWidth/2]) rotate([0,90,0]) legTop();
        translate([hubHeight, 0, 0]) legBottom(toPrint=true);
        translate([2*(legTopThickness + 2), hubHeight,legWidth/2]) rotate([0,90,0]) legTop();
        translate([hubHeight + legWidth + 2, 0, 0]) legBottom(toPrint=true);
        //TODO Add joints between topLeg and bottomLeg and between adjuster and things

    } else {
        hub();

        //adjustable leg
        rotate([0,0,120]) legTop();
        //TODO: move this transformation into the adjuster itself.
        translate([0,0,hubThickness / 2]) rotate([90,0,-60]) translate([0,0,legTopLength]) rotate([legAngle,0,0]) translate([0,0,legToAdjusterDistance]) legAdjustment(bottomTaper=true);
        rotate([0,0,120]) legBottom(topGap=nutLength+2*capLength, length=legBottomLength-nutLength-2*capLength-(2.5/cos(90-legAngle))+connectorDepth, withTaper=false);

        //Fixed legs
        if (collapsed) {
            legTop(rotate=120);
            legBottom(rotate=120);
            rotate([0,0,-120]) legTop(rotate=-120);
            rotate([0,0,-120]) legBottom(rotate=-120);
        } else {
            legTop();
            legBottom();
            rotate([0,0,-120]) legTop();
            rotate([0,0,-120]) legBottom();
        }

    }
}

stand(toPrint=true);