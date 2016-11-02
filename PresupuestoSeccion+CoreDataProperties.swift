//
//  PresupuestoSeccion+CoreDataProperties.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 18/07/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PresupuestoSeccion {

    @NSManaged var descripcion: String?
    @NSManaged var totalEgresos: NSNumber?
    @NSManaged var totalIngresos: NSNumber?
    @NSManaged var presupuesto: Presupuesto?
    @NSManaged var recibos: NSSet?

}
