//
//  UIViewExtensions.swift
//  Test2
//
//  Created by maciulek on 07/07/2021.
//

import UIKit

extension UIView {
    @objc var glossy_radius: CGFloat { frame.width/40.0 }

    @objc func glossy_bgColor() -> CGColor { return UIColor.BBcellColor.cgColor }
    @objc func glossy_shadowColor() -> CGColor { return UIColor.black.cgColor }
    @objc func glossy_offset() -> CGSize { return CGSize(width: 5, height: 5) }

    private var glossy_shadowRadius: CGFloat { 5 }

    @objc func glossy_isDown() -> Bool { return false }

    func glossy_initialSetup() {
        layer.backgroundColor = glossy_bgColor()
        layer.cornerRadius = glossy_radius
        layer.masksToBounds = false
        //clipsToBounds = true
        layer.frame = layer.bounds

        //[CAShapeLayer(), CAShapeLayer()].forEach {
        [CAShapeLayer()].forEach {
            $0.backgroundColor = glossy_bgColor()
            $0.cornerRadius = glossy_radius
            $0.shadowRadius = glossy_shadowRadius
            $0.masksToBounds = false
            $0.frame = layer.bounds
            layer.insertSublayer($0, at: 0)
        }

        setNeedsLayout()
    }

    func glossy_setupShadows() {
        layer.backgroundColor = glossy_bgColor()
        let glossy_bottomShadowLayer = layer.sublayers![0]
//        let glossy_topShadowLayer = layer.sublayers![1]

        glossy_bottomShadowLayer.shadowColor = glossy_shadowColor()
        glossy_bottomShadowLayer.shadowOpacity = 0.5
        glossy_bottomShadowLayer.shadowPath = UIBezierPath(rect: bounds).cgPath
        glossy_bottomShadowLayer.frame = layer.bounds

//        glossy_topShadowLayer.shadowColor = glossy_shadowColor()
//        glossy_topShadowLayer.shadowOpacity = 0.2
//        glossy_topShadowLayer.shadowPath = UIBezierPath(rect: bounds).cgPath
//        glossy_topShadowLayer.frame = layer.bounds

        glossy_bottomShadowLayer.shadowRadius = glossy_shadowRadius
//        glossy_topShadowLayer.shadowRadius = glossy_shadowRadius

        if glossy_isDown() {
            glossy_bottomShadowLayer.shadowOffset = CGSize(width: 0, height: 0)
//            glossy_topShadowLayer.shadowOffset = CGSize(width: 0, height: 0)
            glossy_bottomShadowLayer.shadowRadius = 1
//            glossy_topShadowLayer.shadowRadius = 3
        } else {
            glossy_bottomShadowLayer.shadowOffset = glossy_offset()
        }
    }
}

class GlossyView: UIView {

    override init(frame: CGRect){
        super.init(frame: frame)
        glossy_initialSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        glossy_initialSetup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        glossy_setupShadows()
    }
}

class GlossyButton: UIButton {
    override init(frame: CGRect){
        super.init(frame: frame)
        glossy_initialSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        glossy_initialSetup()
    }

    @objc override func glossy_isDown() -> Bool { return isTouchInside }
    @objc override func glossy_offset() -> CGSize { return CGSize(width: 3, height: 3) }
    @objc override var glossy_radius: CGFloat { frame.height/5.0 }

    override func layoutSubviews() {
        super.layoutSubviews()
        glossy_setupShadows()
    }
    
    private func glossy_initialButtonSetup() {
        addTarget(self, action: #selector(buttonActioned), for: .touchDown)
        addTarget(self, action: #selector(buttonActioned), for: .touchUpInside)
        addTarget(self, action: #selector(buttonActioned), for: .touchUpOutside)
    }

    @objc func buttonActioned() {
        setNeedsLayout()
    }
}

// for tableView do this in viewDidLoad:
//  let backgroundView = UIView(frame: tableView.bounds)
//  backgroundView.setGradientBackground()
//  tableView.backgroundView = backgroundView
// ... and
//  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,                   forRowAtIndexPath indexPath: NSIndexPath) {
//      cell.backgroundColor = .clear
//  }

extension UIView {
    func setGradientBackground() {
//        let colorTop =  UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
//        let colorBottom = UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor

        let colorTop = UIColor.white.cgColor
        let colorBottom = UIColor.offWhite.cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = bounds

        layer.insertSublayer(gradientLayer, at:0)
    }
}


extension UIView {
    func dropShadow() {
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 2, height: 4)
        self.layer.shadowRadius = 5
    }
}


extension UIView {
    func blur(withStyle style: UIBlurEffect.Style) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        addSubview(blurEffectView)
    }
}

/*
extension UIView {
    func addInnerShadow() {
        let innerShadow = CALayer()
        innerShadow.frame = bounds
        
        // Shadow path (1pt ring around bounds)
        let radius = self.frame.size.height/2
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: -1, dy:-1), cornerRadius:radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius:radius).reversing()
        
        
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        // Shadow properties
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 3)
        innerShadow.shadowOpacity = 0.15
        innerShadow.shadowRadius = 3
        innerShadow.cornerRadius = self.frame.size.height/2
        layer.addSublayer(innerShadow)
    }
}

extension UITableViewCell {
    func addShadows(backgroundColor: UIColor = .white, cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 5, shadowOpacity: Float = 0.1, shadowPathInset: (dx: CGFloat, dy: CGFloat) = (16, 6), shadowPathOffset: (dx: CGFloat, dy: CGFloat) = (0, 2)) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = UIBezierPath(roundedRect: bounds.insetBy(dx: shadowPathInset.dx, dy: shadowPathInset.dy).offsetBy(dx: shadowPathOffset.dx, dy: shadowPathOffset.dy), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        let whiteBackgroundView = UIView()
        whiteBackgroundView.backgroundColor = backgroundColor
        whiteBackgroundView.layer.cornerRadius = cornerRadius
        whiteBackgroundView.layer.masksToBounds = true
        whiteBackgroundView.clipsToBounds = false
        
        whiteBackgroundView.frame = bounds.insetBy(dx: shadowPathInset.dx, dy: shadowPathInset.dy)
        insertSubview(whiteBackgroundView, at: 0)
    }
}
*/


extension UIView {
    func addInnerShadow() {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 6
        layer.masksToBounds = true
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = 15
    }
}


protocol ShadowableRoundableView where Self: UIView {

    var cornerRadius: CGFloat { get }
    var shadowColor: UIColor { get  }
    var shadowOffsetWidth: CGFloat { get  }
    var shadowOffsetHeight: CGFloat { get  }
    var shadowOpacity: Float { get  }
    var shadowRadius: CGFloat { get  }

    var shadowLayer: CAShapeLayer { get }

    func setCornerRadiusAndShadow()
}

extension ShadowableRoundableView {
    //var cornerRadius: CGFloat { 12.0 }
    var shadowColor: UIColor { .black }
    var shadowOffsetWidth: CGFloat { 3.0 }
    var shadowOffsetHeight: CGFloat { 3.0 }
    var shadowOpacity: Float { 0.4 }
    var shadowRadius: CGFloat { 4.0 }
}

extension ShadowableRoundableView {
    func setCornerRadiusAndShadow() {
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shadowLayer.fillColor = backgroundColor?.cgColor
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        shadowLayer.shadowOpacity = shadowOpacity
        shadowLayer.shadowRadius = shadowRadius

        shadowLayer.cornerRadius = cornerRadius
        shadowLayer.masksToBounds = false

        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
    }
}


class ShadedView: UIView, ShadowableRoundableView {
    var cornerRadius: CGFloat { 12.0 }
    private(set) lazy var shadowLayer: CAShapeLayer = {
        let shlayer = CAShapeLayer()
        self.layer.insertSublayer(shlayer, at: 0)
        self.setNeedsLayout()
        return shlayer
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setCornerRadiusAndShadow()
    }
}




/*
class RoundShadedView: ShadedView {
    override var cornerRadius: CGFloat { frame.width/2 }
}
*/
class RoundShadedView: UIView, ShadowableRoundableView {
    var cornerRadius: CGFloat { frame.width/2 }
    private(set) lazy var shadowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        self.layer.insertSublayer(layer, at: 0)
        self.setNeedsLayout()
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setCornerRadiusAndShadow()
    }
}



class ShadedTableViewCell: UITableViewCell {
    let cornerRadius = 12.0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = false

        // Apply rounded corners to contentView
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
        
        // Set masks to bounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        
        // Apply a shadow
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.40
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}


class ShadedCollectionViewCell: UICollectionViewCell {
    let cornerRadius = 12.0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = false

        // Apply rounded corners to contentView
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
        
        // Set masks to bounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        
        // Apply a shadow
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.40
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}


class ActionButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        customize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customize()
    }
/*
    override func layoutSubviews() {
        super.layoutSubviews()
        customize()
    }
*/
    func customize() {
        layer.cornerRadius = self.frame.size.height / 4
        //layer.cornerRadius = 16
        layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            backgroundColor = .label
            tintColor = .systemBackground
            setTitleColor(.systemBackground, for: .normal)
        }
        //titleLabel?.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    }
}

