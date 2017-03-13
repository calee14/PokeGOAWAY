//
//  ViewController.swift
//  PokeGOAWAY
//
//  Created by Cappillen on 2/28/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var updateCount = 0
    
    var manager = CLLocationManager()
    
    var pokemons : [Pokemon] = []
    
    var caughtPokemons : [Pokemon] = []
    
    var firstPokemon = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        caughtPokemons = getAllCaughtPokemons()
        
        mapView.showsCompass = false;
        
        pokemons = getAllPokemon()
        
        for i in 0...13 {
            if self.pokemons[i].name == "Pikachu" {
                firstPokemon = i
            }
        }
        
        manager.delegate = self
        
        //gets location
        if CLLocationManager.authorizationStatus() ==  .authorizedWhenInUse {
            
            setUp()
            
        } else {
            manager.requestWhenInUseAuthorization()
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            setUp()
            caughtPokemons = getAllCaughtPokemons()
            
        }
    }
    
    func setUp() {
        if pokemons[firstPokemon].caught == false {
            getFirstPoke()
            caughtPokemons = getAllCaughtPokemons()
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        //set up mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        manager.startUpdatingLocation()
        
        Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { (timer) in
            // Spawn a random Pokemon
            if let coord = self.manager.location?.coordinate {
                let pokemon = self.pokemons[Int(arc4random_uniform(UInt32(self.pokemons.count)))]
                let anno = PokeAnnotation(coord: coord, pokemon: pokemon)
                let randlat = (Double(arc4random_uniform(200)) - 100.0) / 100000.0
                let randlon = (Double(arc4random_uniform(200)) - 100.0) / 100000.0
                anno.coordinate.latitude += randlat
                anno.coordinate.longitude += randlon
                self.mapView.addAnnotation(anno)
                Timer.scheduledTimer(withTimeInterval: 60, repeats: false, block: { (time) in
                    self.mapView.removeAnnotation(anno)
                })
            }
            
        })
    }
    
    func getFirstPoke() {
        //gets the first pokemon
        let alertVC = UIAlertController(title: "Sup", message: "You want your first Pokemon?", preferredStyle: .alert)
        let Nofirst = UIAlertAction(title: "No", style: .default, handler: nil)
        alertVC.addAction(Nofirst)
        let OKfirst = UIAlertAction(title: "Yes", style: .default, handler: {(action) in
            self.pokemons[self.firstPokemon].caught = true
            self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        })
        self.caughtPokemons = getAllCaughtPokemons()
        alertVC.addAction(OKfirst)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //if annotaions is the player give player img
        if annotation is MKUserLocation {
            let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            
            annoView.image = UIImage(named: "player")
            var frame = annoView.frame
            frame.size.height = 50
            frame.size.width = 50
            annoView.frame = frame
            
            return annoView
        }
        
        //gives the pokemon imgs to the annotations
        let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        let pokemon = (annotation as! PokeAnnotation).pokemon
        annoView.image = UIImage(named: pokemon.imageName!)
        
        var frame = annoView.frame
        frame.size.height = 50
        frame.size.width = 50
        annoView.frame = frame
        
        return annoView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //updates location at start of game
        if updateCount < 3 {
            let region = MKCoordinateRegionMakeWithDistance(manager.location!.coordinate, 200, 200)
            mapView.setRegion(region, animated: false)
            updateCount += 1
        } else {
            manager.stopUpdatingLocation()
        }
    }
    
    @IBAction func centerTapped(_ sender: Any) {
        //centers the player in the screen
        if let coord = manager.location?.coordinate {
            let region = MKCoordinateRegionMakeWithDistance(coord, 200, 200)
            mapView.setRegion(region, animated: true)
            updateCount += 1
        }
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation!, animated: true)
        
        if view.annotation is MKUserLocation {
            return
        }
        //zoom in pokemon
        let region = MKCoordinateRegionMakeWithDistance(view.annotation!.coordinate, 200, 200)
        mapView.setRegion(region, animated: true)
        
        //timer times the zoom in
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            if let coord = self.manager.location?.coordinate {
                //giving pokemon the pokemon annotation
                let pokemon = (view.annotation as! PokeAnnotation).pokemon
                self.caughtPokemons = getAllCaughtPokemons()
                //if the annotation we tapped is cloes enough to the player
                if MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate(coord)) {
                    //if we have pokemon then we can catch pokemon
                    if self.caughtPokemons.capacity > 1 {
                        let trainerStr = self.caughtPokemons.count * 2
                        let pokemonCatch = Int(arc4random_uniform(90)) + trainerStr
                        if pokemonCatch >= 60 {
                            //pokemon caught is now caught
                            pokemon.caught = true
                            (UIApplication.shared.delegate as! AppDelegate).saveContext()
                            //removes caught pokemon
                            mapView.removeAnnotation(view.annotation!)
                            //alerts that we caught pokemon
                            let alertVC = UIAlertController(title: "Congrats", message: "You caught a \(pokemon.name!). You are a Pokemon Master!", preferredStyle: .alert)
                            let OKaction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertVC.addAction(OKaction)
                            let PokedexAction = UIAlertAction(title: "Pokedex", style: .default, handler: {(action) in
                                self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
                            })
                            alertVC.addAction(PokedexAction)
                            self.present(alertVC, animated: true, completion: nil)
                        } else {
                            //if the pokemon runs away
                            mapView.removeAnnotation(view.annotation!)
                            let alertVC = UIAlertController(title: "It ran away", message: "You tried to catch a \(pokemon.name!) but you weren't strong enough. Keep on training!", preferredStyle: .alert)
                            let OKaction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertVC.addAction(OKaction)
                            self.present(alertVC, animated: true, completion: nil)
                        }
                    } else {
                        //else if you got no  pokemon which is unlikely goin to happen
                        let alertVC = UIAlertController(title: "Uh-Oh", message: "You have no pokemon to catch the \(pokemon.name!). You should've gotten your first pokemon.", preferredStyle: .alert)
                        let OKaction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertVC.addAction(OKaction)
                        self.present(alertVC, animated: true, completion: nil)
                    }
                    
                } else {
                    //else if too faraway alert too far away
                    let alertVC = UIAlertController(title: "Uh-Oh", message: "You are too far away to catch the \(pokemon.name!). Move closer to get it.", preferredStyle: .alert)
                    let OKaction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(OKaction)
                    self.present(alertVC, animated: true, completion: nil)
                }
            }
        }
        
    }
    
}

