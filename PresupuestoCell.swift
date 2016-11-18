//
//  PresupuestoCell.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 9/11/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import UIKit

class PresupuestoCell: UITableViewCell {
    
    @IBOutlet weak var titulo: UILabel!
    
    @IBOutlet weak var rangoFechas: UILabel!

    @IBOutlet weak var porcentaje: UILabel!
    
    @IBOutlet weak var valorPresupuesto: UILabel!
    
    @IBOutlet weak var valorIngresos: UILabel!
    
    @IBOutlet weak var valorEgresos: UILabel!
    
    @IBOutlet weak var ivSync: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //self.ivSync.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.ivSync.isUserInteractionEnabled = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
