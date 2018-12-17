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
nutLength = 20;
capLength = 2;

//leg
legThickness = 13;

//hub
hubThickness = 3;
l1 = 21;
l2 = 68;
legWidth = m3ClearanceHole+4;

module legAdjustment(toPrint = false, bottomTaper = false) {
    module inner() {
        if (withTaper) {
            //cap with taper
            hull() {
                //this has to be a cylindar for hull to work but logically it is a circle.
                translate([0,0,-(capLength+min(l2-l1, legWidth))+gap]) cylinder(d=legWidth, h=.1);
                translate([0,0,-capLength]) cylinder(r=7 + threadGap, h=capLength);
            }
        } else {
            //cap
            translate([0, 0, -capLength]) cylinder(r = 7 + threadGap, h = capLength);
        }
        //thread
        difference() {
            //fairly random rotation but aligns the inner and outer thread.
            rotate ([0, 0, -120]) metric_thread(12, 1.5, nutLength / 2);
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
            translate([0, 0, -1]) metric_thread(12 + threadGap, 1.5, (nutLength / 2) + 2, internal=true);
        }
    }

    if (toPrint) {
        $fa = $preview ? $fa : 5;
        $fs = $preview ? $fs : 0.1;

        translate([20, 0, capLength]) inner();
        nutHalf();
        translate([0, 0, nutLength + 0]) rotate([0, 180, 0]) mirror([0, 1, 0]) nutHalf();        
        translate([40, 0, capLength]) mirror([0, 1, 0]) inner();
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
    a = 8; // half distance between holes.
    height = a * sqrt(3);

    linear_extrude(height = hubThickness) difference() {
        hull() {
            translate([a, - height / 3, 0]) circle(d=5, $fn=16);
            translate([-a, - height / 3, 0]) circle(d=5, $fn=16);
            translate([0, 2 * height / 3, 0]) circle(d=5, $fn=16);
        }
        translate([a, - height / 3, 0]) circle(d=m3ClearanceHole, $fn=16);
        translate([-a, - height / 3, 0]) circle(d=m3ClearanceHole, $fn=16);
        translate([0, 2 * height / 3, 0]) circle(d=m3ClearanceHole, $fn=16);
    }
}

module legAttachment(rotate=0) {
    a = 8; // half distance between holes.
    height = a * sqrt(3);
    
    /*
    
    ----    legThickness
        |
    ----    y = (legThickness + (hubThickness + 2*gap)) / 2;
    |
    ----    x = (legThickness - (hubThickness + 2*gap)) / 2;
        |
    ----    0
    
    */
    x = (legThickness - (hubThickness + 2*gap)) / 2;
    y = (legThickness + (hubThickness + 2*gap)) / 2;

    module centralEndMask() {
        translate([0, 2 * height / 3, 0])
            union() {
                circle(r=a-gap, center=true);
                translate([0, (l2) / 2, 0]) square(size=[legWidth + 2, l2], center=true);
            }
    }

    translate([0, 2*height/3,0]) rotate([0,0,rotate]) translate([0, -2*height/3,0])
        difference() {
            intersection() {
                rotate([90,0,90]) translate([0, ((hubThickness - legThickness)/2), -legWidth/2])
                    linear_extrude(height = legWidth, convexity=3)
                        polygon([[0,0], [0,x], [l1,x],[l1,y],[0,y],[0,legThickness],[l2,legThickness],[l2,0]]);
                linear_extrude(height = legThickness * 2, center=true) centralEndMask();
            }
            //screw head
            translate([0,2 * height / 3,(legThickness+hubThickness)/2-3.5]) cylinder(d=6, h=3.5+gap, $fn=16);
            //clearance hole
            translate([0,2 * height / 3,-legThickness/2]) cylinder(d=m3ClearanceHole, h=legThickness, $fn=16);
            //nut recess
            translate([0,2 * height / 3,-(legThickness-hubThickness)/2-gap]) cylinder(d=6.5, h=2.5+gap, $fn=6);
        }
}

//leg(toPrint = true);

hub();
legAttachment(rotate=120);
translate([0,0,hubThickness / 2]) rotate([90,0,-60]) translate([0,0,l2]) legAdjustment(bottomTaper=true);
rotate([0,0,120]) legAttachment();
rotate([0,0,-120]) legAttachment(rotate=-120);
circle(d=110);

//hub();
//translate([20,0,0]) rotate([0,90,0]) legAttachment(rotate=false);
//translate([40,0,0]) rotate([0,90,0]) legAttachment();

/* assembled with a cut away
difference() {
    legAdjustment(toPrint = false);
    cube([10, 10, nutLength]);    
}

*/