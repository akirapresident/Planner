//
//  EventosTableViewCell.swift
//  2019 - Planner
//
//  Created by akira tsukamoto on 13/06/19.
//  Copyright © 2019 akira tsukamoto. All rights reserved.
//

import UIKit

class EventosTableViewCell: UITableViewCell {
    @IBOutlet weak var progress: UILabel!
    var evento: Evento!
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var progressView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    @IBOutlet weak var pontaquadrada: UIView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
