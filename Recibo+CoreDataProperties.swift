//
//  Recibo+CoreDataProperties.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 26/07/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Recibo {

    @NSManaged var descripcion: String?
    @NSManaged var fecha: NSDate?
    @NSManaged var tipo: NSNumber?
    @NSManaged var valor: NSNumber?
    @NSManaged var seccion: PresupuestoSeccion?

}
