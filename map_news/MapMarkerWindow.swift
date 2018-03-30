//
//  MapMarkerWindow.swift
//  map_news
//
//  Created by Carolyn Hampe on 3/28/18.
//  Copyright © 2018 Carolyn Hampe. All rights reserved.
//

import UIKit

class MapMarkerWindow: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var viewLinkLabel: UILabel!
    @IBOutlet weak var storyImg: UIImageView!
    
    weak var delegate: MapMarkerDelegate?
    var spotData: NSDictionary?
    
    var imgUrl: String?
    var storyUrl: String?

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
}
