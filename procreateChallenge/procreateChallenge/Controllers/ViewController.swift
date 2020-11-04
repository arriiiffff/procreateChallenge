//
//  ViewController.swift
//  procreateChallenge
//
//  Created by ARIF on 02/11/20.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var toolsView: UIView!
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var saturationSlider: GradientSlider!
    @IBOutlet weak var brightnesSlider: GradientSlider!
    @IBOutlet weak var previewBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var undoBtn: UIButton!
    @IBOutlet weak var redoBtn: UIButton!
    
    var hueValue:CGFloat = 0.5
    var satValue:CGFloat = 0.5
    var brightnessValue:CGFloat = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Detect long gesture for preview button
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(long))  //Long function will call when user long press on button.
        previewBtn.addGestureRecognizer(longGesture)
        
        // Setup initial state
        self.setupInitialState()
        
        // Set Hue Color of the image
        self.hueSlider.actionBlock = { slider, value, finished in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.enableBtn(button: self.previewBtn)
            self.enableBtn(button: self.resetBtn)
            self.enableBtn(button: self.undoBtn)
            slider.thumbColor = UIColor(hue: value, saturation: self.satValue, brightness: self.brightnessValue, alpha: 1.0)
            self.backgroundImg.image = self.backgroundImg.image?.tint(UIColor(hue: value, saturation: self.satValue, brightness: self.brightnessValue, alpha: 1.0))
            self.hueValue = value
            self.undoManager?.registerUndo(withTarget: self, handler: { (selfTarget) in
                selfTarget.backgroundImg.image = self.backgroundImg.image?.tint(UIColor(hue: value, saturation: self.satValue, brightness: self.brightnessValue, alpha: 1.0))
                selfTarget.hueSlider.value = value
                selfTarget.satValue = self.satValue
                selfTarget.brightnessValue = self.brightnessValue
            })
            CATransaction.commit()
        }
        
        // Set Saturation Color of the image
        self.saturationSlider.actionBlock = { slider, value, finished in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.enableBtn(button: self.previewBtn)
            self.enableBtn(button: self.resetBtn)
            self.enableBtn(button: self.undoBtn)
            slider.thumbColor = UIColor(hue: self.hueValue, saturation: value, brightness: self.brightnessValue, alpha: 1.0)
            self.backgroundImg.image = self.backgroundImg.image?.tint(UIColor(hue: self.hueValue, saturation: value, brightness: self.brightnessValue, alpha: 1.0))
            self.satValue = value
            self.undoManager?.registerUndo(withTarget: self, handler: { (selfTarget) in
                selfTarget.backgroundImg.image = self.backgroundImg.image?.tint(UIColor(hue: self.hueValue, saturation: value, brightness: self.brightnessValue, alpha: 1.0))
                selfTarget.saturationSlider.value = value
            })
            CATransaction.commit()
        }
        
        // Set Brightness Color of the image
        self.brightnesSlider.actionBlock = { slider, value, finished in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.enableBtn(button: self.previewBtn)
            self.enableBtn(button: self.resetBtn)
            self.enableBtn(button: self.undoBtn)
            slider.thumbColor = UIColor(hue: self.hueValue, saturation: self.satValue, brightness: value, alpha: 1.0)
            self.backgroundImg.image = self.backgroundImg.image?.tint(UIColor(hue: self.hueValue, saturation: self.satValue, brightness: value, alpha: 1.0))
            self.brightnessValue = value
            self.undoManager?.registerUndo(withTarget: self, handler: { (selfTarget) in
                selfTarget.backgroundImg.image = self.backgroundImg.image?.tint(UIColor(hue: self.hueValue, saturation: self.satValue, brightness: value, alpha: 1.0))
                selfTarget.brightnesSlider.value = value
            })
            CATransaction.commit()
        }
        
        self.addBlurEffect(view: self.toolsView)
    }
    
    // method to call initial state of sliders
    func setupInitialState() {
        self.backgroundImg.image = UIImage(named: "ic-image")
        
        disableBtn(button: previewBtn)
        disableBtn(button: resetBtn)
        disableBtn(button: undoBtn)
        disableBtn(button: redoBtn)
        
        self.hueSlider.value = 0.5
        self.saturationSlider.value = 0.5
        self.brightnesSlider.value = 0.5
        
        self.hueSlider.thumbColor = .white
        self.saturationSlider.thumbColor = .white
        self.brightnesSlider.thumbColor = .white
    }
    
    // method to add blur effect to tools view
    func addBlurEffect(view: UIView) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
    
    // method to disable button
    func disableBtn(button: UIButton) {
        button.backgroundColor = .darkGray
        button.setTitleColor(.lightGray, for: .normal)
        button.isEnabled = false
    }
    
    // method to enable button
    func enableBtn(button: UIButton) {
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = true
    }
    
    // method to call long press
    @objc func long() {
        if self.previewBtn.state.rawValue == 1 {
            self.backgroundImg.isHidden = true
        } else {
            self.backgroundImg.isHidden = false
        }
    }

    // Reset Action to first state
    @IBAction func btnReset(_ sender: UIButton) {
        self.setupInitialState()
    }
    
    // Undo Action
    @IBAction func btnUndo(_ sender: UIButton) {
        enableBtn(button: redoBtn)
        if self.undoManager?.canUndo == true {
            self.undoManager?.undo()
        } else {
            self.setupInitialState()
        }
    }
    
    // Redo action only available once
    @IBAction func btnRedo(_ sender: UIButton) {
        if self.undoManager?.canRedo == true {
            self.undoManager?.redo()
            self.brightnesSlider.value = brightnessValue
            self.hueSlider.value = hueValue
            self.saturationSlider.value = satValue
            disableBtn(button: redoBtn)
        }
    }
}

extension UIImage {
    
    // colorize image with given tint color
    // this is similar to Photoshop's "Color" layer blend mode
    // this is perfect for non-greyscale source images, and images that have both highlights and shadows that should be preserved
    // white will stay white and black will stay black as the lightness of the image is preserved
    func tint(_ tintColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            // draw original image
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: rect)
            
            // tint image (loosing alpha) - the luminosity of the original image is preserved
            context.setBlendMode(.color)
            tintColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    // fills the alpha channel of the source image with the given color
    // any color information except to the alpha channel will be ignored
    func fillAlpha(_ fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    
    fileprivate func modifiedImage(_ draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height);
        context.scaleBy(x: 1.0, y: -1.0);
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
