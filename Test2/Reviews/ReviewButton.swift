//
//  ReviewButton.swift
//  Test2
//
//  Created by maciulek on 26/06/2022.
//

import UIKit

class FAB: UIButton {
    let buttonWidth = 100.0

    override init(frame: CGRect){
        super.init(frame: frame)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        layer.cornerRadius = buttonWidth/2
        layer.masksToBounds = true
        backgroundColor = .red
        widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    }
}

class ReviewFAB: FAB {
    override init(frame: CGRect){
        super.init(frame: frame)
        setTitle("Review", for: .normal)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setTitle("Review", for: .normal)
    }
}
