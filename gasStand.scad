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
nutLength = 100;
capLength = 2;



module leg(toPrint = false) {
    module inner() {
        //cap
        cylinder(r = 7, h = capLength);
        //thread
        difference() {
            metric_thread(12, 1.5, nutLength / 2);
            cylinder(r = 5, h = nutLength / 2);
        }
        //alignment semi-cylinder (bottom half)
        color("red") difference() {
            cylinder(r = 5, h = nutLength/ 2);
            translate([0, -5, 0])
                cube([5, 10, nutLength]);
        }
        //alignment semi-cylinder (bottom half)
        color("blue") translate([0, 0, nutLength / 2]) difference() {
            cylinder(r = 5 - gap, h = nutLength / 2);
            translate([-gap, -5, 0])
                cube([5, 10, nutLength]);
        }
    }

    module nutHalf() {
        //nut / outer
        difference() {
            cylinder(r = 7, h = nutLength / 2);
            //translate and add length to ensure a 2-manifold result
            translate([0, 0, -1]) metric_thread(12.2, 1.5, (nutLength / 2) + 2, internal=true);
        }
    }
    
    if (toPrint) {
        $fa = $preview ? $fa : 5;
        $fs = $preview ? $fs : 0.1;

        translate([20, 0, 0]) inner();
        nutHalf();
        translate([0, 0, nutLength + 0]) rotate([0, 180, 0]) mirror([0, 1, 0]) nutHalf();        
        translate([40, 0, 0]) mirror([0, 1, 0]) inner();
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