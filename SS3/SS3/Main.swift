//
//  Main.swift
//  SS3
//
//  Created by Leonid Lokhmatov on 12/24/18.
//  Copyright © 2018 Luxoft. All rights reserved
//

import ScreenSaver

class Main: ScreenSaverView {
    var startCount = Int(0)
    var stopCount = Int(0)
    
    @IBOutlet var settingsPanel: NSPanel?
    
//    @property (nonatomic, retain) IBOutlet NSPanel    *settingsPanel;

    override var hasConfigureSheet: Bool {
        get {
            return true
        }
    }
    
    override var configureSheet: NSWindow? {
        get {
            let bundle = Bundle(for: self.classForCoder)
            let success = bundle.loadNibNamed(NSNib.Name("OptionsWindow"), owner: self, topLevelObjects: nil)
            
            return self.settingsPanel!
            
            
//            const BOOL success = [[NSBundle bundleForClass:[self class]] loadNibNamed:@"OptionsWindow" owner:self topLevelObjects:nil];
//            if (success) {
//                return self.settingsPanel;
//            }
//            
//            const NSUInteger styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
//            NSWindow *configureSheet = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 320, 480) styleMask:styleMask backing:[ScreenSaverView backingStoreType] defer:NO];
//            configureSheet.backgroundColor = [NSColor blueColor];
//            return configureSheet;
        }
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1.0/30.0
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.animationTimeInterval = 1.0/30.0
    }
    
    /**
     animateOneFrame is called every time the screen saver frame is to be updated, and
     is used to re-draw the time/quote if required.
     */
    override func animateOneFrame() {
        setNeedsDisplay(self.bounds)
        return
        
        
        let time = getTime()
        clearStage()
        drawText(time + " hello there")
    }
    
    /**
     getTime returns the current time as a formatted string.
     
     - Returns: A new string showing the current time, formatted as HH:mm:ss
     */
    func getTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        return formatter.string(from: date)
    }
    
    /**
     drawText draws a provided string to the bottom-left of the stage.
     
     - Parameter text: The text to draw onto the stage.
     */
    func drawText(_ text: String) {
        NSColor.black.set()
        text.draw(at: NSPoint(x: 100.0, y: 200.0), withAttributes: nil)
    }
    
    /**
     clearStage clears the stage, by filling it with a solid colour.
     */
    func clearStage() {
        NSColor.red.setFill()
        self.bounds.fill()
//        NSRect.fill(from: self.bounds)
    }
    
    /**
     draw is called to initialise the stage of the screen saver.
     */
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        let text = getTime()
        
        clearStage()
        drawText(text + " >> draw-rect started: \(startCount); stopped: \(stopCount)")
    }
    
    
    override func startAnimation() {
        super.startAnimation()
        startCount += 1
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        stopCount += 1
    }
    
    @IBAction func actCloseSettings(_ sender: AnyObject) {
        
        self.settingsPanel?.parent?.endSheet(self.settingsPanel!)
        
//        NSApplication.shared.endSheet(self.settingsPanel!)
        self.settingsPanel = nil
//    //    [[self.settingsPanel parentWindow] endSheet:self.settingsPanel];//does not work
//    [[NSApplication sharedApplication] endSheet:self.settingsPanel];
//    self.settingsPanel = nil;
    }

}
