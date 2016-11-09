//
//  PresupuestoDetalleCell.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 9/11/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import UIKit

class PresupuestoDetalleCell: UITableViewCell {
    
    @IBOutlet weak var descripcion: UILabel!
    
    @IBOutlet weak var fecha: UILabel!
    
    @IBOutlet weak var monto: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
