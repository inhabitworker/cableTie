/* [Main] */
// Length of the link band, or total length excluding extra length at tip and female tab end.
FunctionalLength = 150;
// Thickness/depth of the tie. Smaller value = more flexibility.
Thickness = 0.8;
// Gap between links. Lower means more "resolution" steps to possible circumference of tie in use. Should ideally be greater than thickness.
LinkGap = 1;
// The width of the band. This will provides more surface area about axis for grip or direction.
BandWidth = 8;
// Socket types to include on the female end tab.
HoleType = "Both"; // ["Both", "Taper", "Double"]


/* [Hidden] */
LinkRadius = 1.5;
LinkLength = 2*LinkRadius + LinkGap;
LockHoleLength = 1.8;
LockHoleWidth = BandWidth * 1.05;
SpaceHoleLength = LinkRadius*2;
SpaceHoleWidth = BandWidth*1.2 + LinkRadius*2;
TaperHoleLength = LinkRadius*2 + BandWidth;
LipProjection = 1;
LipLength = 1;
SocketSpacing = 3;
LockLength = LockHoleLength + LipLength;

TaperTotalLength = TaperHoleLength + LockLength + SpaceHoleLength;
DoubleTotalLength = LockLength * 2 + SpaceHoleLength;

// Extension at start and end of main band
GuideLength = 10;
PreSocketsLength = 20;
PreSocketsWidth = BandWidth*2;
TabWidth = SpaceHoleWidth * 1.5;

// meta
$fn = 20;
Overlap = 0.1;


module Link() {   
    LinkLength = LinkLength + Overlap;
    //linear_extrude(Thickness)
    union() {
        translate([LinkRadius*3,BandWidth/2,0])
        circle(LinkRadius);

        translate([LinkRadius*3,-BandWidth/2,0])
        circle(LinkRadius);

        polygon([[-Overlap,BandWidth/2], [-Overlap, -BandWidth/2], [LinkLength, -BandWidth/2], [LinkLength, BandWidth/2]]);
    };
}

module LockHoleMask() {
    module Half() {
        polygon([
            [0, -Overlap],
            [0, LockHoleWidth/2 - LipProjection],
            [LipLength*0.8, LockHoleWidth/2 - LipProjection],
            [LipLength, LockHoleWidth/2],
            [LockLength, LockHoleWidth/2],
            [LockLength, -Overlap]
        ]);
    }
    
    Half();
    mirror([0,1,0])
    Half();
}

module TaperMask() {
    L1 = SpaceHoleLength;
    L2 = L1 + TaperHoleLength;
    
    module Half() {       
        polygon([
            [0, -Overlap],
            [0, SpaceHoleWidth/2],
            [L1, SpaceHoleWidth/2],
            [L2, LockHoleWidth/2],
            [L2, -Overlap]
        ]);
    }
    
    union() {
        Half();
        mirror([0,1,0])
        Half();
        translate([L2,0,0])
        LockHoleMask();
    };
}

module DoubleMask() {
    translate([LockHoleLength + LipLength,0,0])
    union() {
        mirror([1,0,0])
        LockHoleMask();

        translate([-Overlap,-SpaceHoleWidth/2,0])
        square([SpaceHoleLength+2*Overlap, SpaceHoleWidth]);
    }
    
    
    translate([LockHoleLength+LipLength+SpaceHoleLength,0,0])
    LockHoleMask();
}

module Tab() {
    L1 = PreSocketsLength * 5/8; 
    L2 = PreSocketsLength;
    
    Both = (HoleType == "Both");
    Taper = (HoleType == "Both" || HoleType == "Taper");
    Double = (HoleType == "Both" || HoleType == "Double");
    
    SocketLength = 0 + (Taper ? TaperTotalLength : 0) + (Double ? DoubleTotalLength : 0);
    TotalLength = SocketSpacing*(Both ? 2 : 1) + SocketLength;
    
    L3 = L2 + TotalLength;
    
    module Half() {
        polygon([
            [-Overlap, -Overlap],
            [-Overlap, PreSocketsWidth/2],
            [L1, PreSocketsWidth/2],
            [L2, TabWidth/2],
            [L3, TabWidth/2],
            [L3, -Overlap]
        ]);
    }
    
    mirror([1,0,0])
    difference() {
        union() {
            Half();
            mirror([0,1,0])
            Half();
        }
        
        if(Double) {     
            translate([L2 + (HoleType == "Both" ? SocketSpacing + TaperTotalLength : 0),0,0])
            DoubleMask();
        }
        
        if(Taper) {
            translate([L2,0,0])
            TaperMask();
        }
    }
}

module Band() {
    n = FunctionalLength / LinkLength;
    
    union() {
        // Links
        for(i = [0 : 1 : n]) {
            translate([i*LinkLength,0,0])
            Link();
        }
            
        // Tip/Guide
        GuideTaperLength = GuideLength + 1;
        GuideTaperWidth = BandWidth - 1;
        // linear_extrude(Thickness)         
        translate([n*LinkLength,0,0])
        polygon([
            [-Overlap, BandWidth/2],
            [-Overlap, -BandWidth/2],
            [GuideLength, -BandWidth/2],
            [GuideTaperLength, -GuideTaperWidth/2],
            [GuideTaperLength, GuideTaperWidth/2],
            [GuideLength, BandWidth/2]          
        ]);          
    }
}

module Full() {
    linear_extrude(Thickness)
    union() {
        Band();
        Tab();
    };
}

Full();


    