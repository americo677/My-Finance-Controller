//
//  File.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 10/11/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import UIKit
import Foundation

@objc protocol DataBudgetDelegate: class {
    @objc optional func sendDataBudgetBack(_ budget: Presupuesto?)
    @objc optional func sendDataImageReceipt(_ image: UIImage?)
}
