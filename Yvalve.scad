use <threads.scad>

MainThread = 47.8; // Rosca de 1 1/2 polegada
StepThread = 2.3;
Gap = 0.25;
Thickness = 3;
ThreadLength = 12;
Fitting = 12;
HandleThickness = 7;
HandleLength = 80;

TheradHeight = StepThread * sqrt(3) * 5 / 8;
MinDiameter = MainThread - TheradHeight;
InternalDiameter = MinDiameter - 2 * Thickness;
ExternalDiameter = MainThread + 2 * Thickness;
PipeLigth = (InternalDiameter - 2 * Thickness) * sqrt(3) / 2;
BodyDiameter = MainThread;
ArmLegth = BodyDiameter / 2 + Thickness + Fitting;
GateDiameter = 2 * PipeLigth * sqrt(3) / 3 + 2 * Thickness;
GateHeight = PipeLigth + 2 * (Thickness - Gap);
HubDiameter = GateDiameter + 2 * Thickness;
CommandAxisDiamenter = GateDiameter / 2;

echo(PipeLigth);

$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : .2;

module InternalThread() // make me
{
  HexNutDiameter = 2 * sqrt(3) * ExternalDiameter / 3;
  FillamentD = 2;
  HoleDist = sqrt(3) * (FillamentD + 1) / 3;
  difference() {
    union() {
      cylinder(d=HexNutDiameter, h=ThreadLength, $fn=6);
      translate([0, 0, ThreadLength]) {
        cylinder(d=HexNutDiameter, h=Thickness, $fn=6);
        translate([0, 0, Thickness])
          cylinder(d=InternalDiameter - 2 * Gap, h=Fitting, $fn=6);
      }
    }
    translate([0, 0, -Gap]) {
      metric_thread(
        diameter=MainThread + 2 * Gap,
        pitch=StepThread,
        length=ThreadLength + Gap,
        leadin=3,
        test=$preview,
        internal=true
      );
      cylinder(d=PipeLigth, h=ThreadLength + Thickness + Fitting + 2);
    }
    #for(i=[0:5]) {
      rotate([0, 0, i * 60])
        translate([HexNutDiameter / 2 - HoleDist, 0, -.5])
          cylinder(d=FillamentD, h=ThreadLength + Thickness + 1);
    }
  }
}

module ExternalThread() // make me
{
  difference() {
    union() {
      metric_thread(
        diameter=MainThread - 2 * Gap,
        pitch=StepThread,
        length=ThreadLength,
        leadin=2,
        test=$preview,
        internal=false
      );
      translate([0, 0, ThreadLength])
        cylinder(d=InternalDiameter - 2 * Gap, h=Fitting, $fn=6);
    }
    translate([0, 0, -1])
      cylinder(d=PipeLigth, h=ThreadLength + Fitting + 2);
  }
}

module MainBody() // make me
{
  difference() {
    union() {
      //Braços do Y
      for (i = [0, 120, 240]) {
        rotate([0, 0, i])
          rotate([0, 90, 0])
            cylinder(d=BodyDiameter, h=ArmLegth);
      }
      //Central hub
      cylinder(d=HubDiameter, h=BodyDiameter, center=true);
    }
    for (i = [0, 120, 240]) {
      rotate([0, 0, i])
        rotate([0, 90, 0]) {
          cylinder(d=PipeLigth, h=ArmLegth + 1);
          translate([0, 0, ArmLegth - Fitting])
            cylinder(d=InternalDiameter + 2 * Gap, h=Fitting + 1, $fn=6);
        }
    }
    //Hole for the gate
    translate([0, 0, -(PipeLigth / 2 + Thickness)]) {
      cylinder(d=GateDiameter + Gap, h=BodyDiameter);
      //Apoio de rotação
      translate([0, 0, -(Thickness * 2 / 3)]) {
        cylinder(d=GateDiameter / 4 + Gap, h=Thickness * 2 / 3 + 2 * Gap);
        translate([0, 0, Thickness / 3])
          LimetMainBody();
      }
    }
    //Rosca de fechamento
    translate([0, 0, GateHeight / 2])
      metric_thread(
        diameter=GateDiameter + TheradHeight + 2 * Gap,
        pitch=StepThread,
        length=(BodyDiameter - GateHeight) / 2 + StepThread / 2,
        leadin=1,
        internal=true,
        test=$preview
      );
  }
}

module FlowChannel() {
  sphere(d=PipeLigth);
  for (i = [0, 120]) {
    rotate([0, 0, i])
      rotate([0, 90, 0])
        cylinder(d=PipeLigth, h=ArmLegth + 1);
  }
}

module Gate() // make me
{
  AxisLegth = GateHeight; //Confirmar depois
  difference() {
    union() {
      //Corpo do gate
      cylinder(d=GateDiameter - Gap, h=GateHeight, center=true);
      //Apoio de rotação
      translate([0, 0, GateHeight / 2]) {
        cylinder(d=GateDiameter / 4 - Gap, h=Thickness * 2 / 3);
        LimitGate();
      }
    }
    //Canal de escoamento
    FlowChannel();
    //Encaixe do eixo
    rotate([180, 0, 0])
      cylinder(d=CommandAxisDiamenter + Gap, h=AxisLegth, $fn=6);
  }
}

module LimitGate() {
  rotate([0, 0, 60])
    linear_extrude(height=Thickness / 3) {
      intersection() {
        circle(d=GateDiameter / 2 - Gap);
        translate([-GateDiameter / 2, 0, 0])
          circle(d=GateDiameter, $fn=3);
      }
    }
}

module LimetMainBody() {
  rotate([0, 0, 90])
    linear_extrude(height=Thickness / 3 + Gap) {
      intersection() {
        circle(d=GateDiameter / 2 + Gap);
        translate([-GateDiameter / 4, 0, 0])
          square([GateDiameter / 2, GateDiameter / 4]);
      }
    }
}

module CommandAxis() // make me
{
  CommandAxisLenght = BodyDiameter / 2 + Thickness + 2 + HandleThickness;
  difference() {
    cylinder(d=CommandAxisDiamenter, h=CommandAxisLenght, $fn=6);
    rotate([0, 0, -120]) FlowChannel();
    translate([0, 0, CommandAxisLenght - HandleThickness / 2])
      rotate([0, 90, -60])
        cylinder(d=2.8, h=CommandAxisDiamenter + 3 * Thickness);
  }
}

module CommandAxisRing(gap = 0) 
{
  RingHeight = (BodyDiameter - GateHeight) / 2 + Thickness + gap;
  difference() {
    union() {
      cylinder(d=CommandAxisDiamenter + 2 * Thickness + gap, h=RingHeight / 2);
      cylinder(d=CommandAxisDiamenter + Thickness + gap, h=RingHeight);
    }
    if (gap == 0) {
      translate([0, 0, -1])
        cylinder(d=CommandAxisDiamenter + Gap, h=RingHeight + 2, $fn=6);
    }
  }
}

module commandAxisRing() // make me
{
  CommandAxisRing();
}

module GateFixture() // make me
{
  TL = (BodyDiameter - GateHeight) / 2;
  difference() {
    union() {
      translate([0, 0, -Thickness])
        cylinder(d=HubDiameter * 2 * sqrt(3) / 3, h=Thickness, $fn=6);
      metric_thread(
        diameter=GateDiameter + TheradHeight - 2 * Gap,
        pitch=StepThread,
        length=TL - Gap,
        leadin=1,
        internal=false,
        test=$preview
      );
    }
    translate([0, 0, TL + Gap / 2])
      rotate([180, 0, 0])
        CommandAxisRing(gap=Gap);
  }
}

module Handle() // make me
{
  SmoothDiameter = 4;
  difference() {
    minkowski() {
      translate([0, 0, SmoothDiameter / 2])
        union() {
          cylinder(d=CommandAxisDiamenter + 3 * Thickness - SmoothDiameter, h=HandleThickness - SmoothDiameter);
          //Manipulador
          rotate([0, 0, 120])
            translate([CommandAxisDiamenter / 2, -CommandAxisDiamenter / 2, 0] + [.5, 1, 0] * SmoothDiameter / 2)
              cube([HandleLength, CommandAxisDiamenter, HandleThickness] - [.5, 1, 1] * SmoothDiameter);
          translate([0, 0, (HandleThickness - SmoothDiameter) / 2])
          //Seta de direção do fluxo
          for (i = [0, -120]) {
            rotate([0, 0, i]) {
              translate([CommandAxisDiamenter / 2 + Thickness, 0, 0]) {
                translate([CommandAxisDiamenter / 2, 0, 0])
                  cylinder(d=CommandAxisDiamenter, h=HandleThickness - SmoothDiameter, center=true, $fn=3);
                cube([CommandAxisDiamenter / 2, CommandAxisDiamenter / 2, HandleThickness - SmoothDiameter], center=true);
              }
            }
          }
        }
      sphere(d=SmoothDiameter);
      //cylinder(d=SmoothDiameter, h=SmoothDiameter, center=true);
    }
    //furo do eixo
    translate([0, 0, -1])
      cylinder(d=CommandAxisDiamenter + Gap, h=HandleThickness + 2, $fn=6);
    //furo do parafuso
    translate([0, 0, HandleThickness / 2])
      rotate([0, 90, -60])
        cylinder(d=2.8, h=CommandAxisDiamenter + 3 * Thickness);
    //*/
  }
}

//InternalThread();
//ExternalThread();
//MainBody();
//Gate();
//GateFixture();
//CommandAxis();
//CommandAxisRing();
//Handle();

/*
        MainBody();
        rotate([180,0,0]) color("blue") Gate();
        color("green") CommandAxis();
        translate([0,0,GateHeight / 2]) color("red") CommandAxisRing();
        translate([0,0,BodyDiameter / 2]) rotate([180,0,0]) color("purple") GateFixture();
//*/

/*intersection(){
    translate([0,0,25.25])
    cube([100,100,BodyDiameter+40],center = true);///
    union(){        
        MainBody();
        translate([ArmLegth+ThreadLength+Thickness+Gap,0,0]) rotate([0,-90,0]) color("green") InternalThread();
        rotate([0,0,120]) translate([ArmLegth+ThreadLength+Gap,0,0]) rotate([0,-90,0]) color("green") ExternalThread();
        rotate([0,0,-120]) translate([ArmLegth+ThreadLength+Gap,0,0]) rotate([0,-90,0]) color("green") ExternalThread();
        translate([0,0,BodyDiameter / 2]) rotate([180,0,0]) color("purple") GateFixture();
        rotate([0,0,acos( (abs($t-.5) * 4-1)*cos(30))-30]){
            rotate([180,0,0]) color("blue") Gate();
            color("green") CommandAxis();
            translate([0,0,GateHeight / 2]) color("red") CommandAxisRing();
            translate([0,0,BodyDiameter / 2 + Thickness + 2]) color("cyan") Handle();
        }
    }/*
}
//*/
