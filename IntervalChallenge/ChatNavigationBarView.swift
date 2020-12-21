//
//  ChatNavigationBarView.swift
//  IntervalChallenge
//
//  Created by Gershy Lev on 12/18/20.
//

import UIKit

class ChatNavigationBarView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var image: UIImage!
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    private var titleLabel: UILabel!
    
    init(im: UIImage?, title: String?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let imageView = UIImageView(image: im!)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        let label = UILabel()
        label.text = title
        label.font = label.font.withSize(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
