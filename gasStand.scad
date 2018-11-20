use <MCAD/fasteners/threads.scad>

/*

  |-100mm--|


| ========== |
|----------  |
|  ----------|
| ========== |

TODO:

* Add texture to nut outside
* Add a catch to keep from unwinding completely

*/


gap = 0.2;
threadGap = 0.75;
nutLength = 100;
capLength = 2;



module leg(toPrint = false) {
    module inner() {
        //cap
        translate([0, 0, -capLength]) cylinder(r = 7 + threadGap, h = capLength);
        //thread
        difference() {
            //fairly random rotation but aligns the inner and outer thread.
            rotate ([0, 0, -120]) metric_thread(12, 1.5, nutLength / 2);
            cylinder(r = 4.5, h = nutLength / 2);
        }
        //alignment semi-cylinder (bottom half)
        color("red") difference() {
            cylinder(r = 4.5, h = nutLength/ 2);
            translate([-gap, -5, 0])
                cube([5, 10, nutLength]);
        }
        //alignment semi-cylinder (top half)
        color("blue") translate([0, 0, nutLength / 2]) difference() {
            cylinder(r = 4.5 - gap, h = nutLength / 2);
            translate([-gap, -5, 0])
                cube([5, 10, nutLength]);
        }
    }

    module nutHalf() {
        //nut / outer
        difference() {
            cylinder(r = 7 + threadGap, h = nutLength / 2);
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
        inner();
        translate([0, 0, 0]) nutHalf();
        translate([0, 0, nutLength + 0]) rotate([0, 180, 0]) mirror([0, 1, 0]) inner();
        translate([0, 0, nutLength + 0]) rotate([0, 180, 0]) mirror([0, 1, 0]) nutHalf();
    }
}

leg(toPrint = true);

/* assembled with a cut away
difference() {
    leg(toPrint = false);
    cube([10, 10, nutLength]);    
}

*/