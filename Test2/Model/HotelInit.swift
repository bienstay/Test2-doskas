//
//  HotelInit.swift
//  Test2
//
//  Created by maciulek on 19/05/2021.
//

import Foundation

func initDestinationDining() {
    hotel.destinationDining.groups = [

    DestinationDiningGroup(title: "Early Risers", description: "Sunrise to 11am", image: "", items: [
        DestinationDiningItem(title: "Sunrise Champagne Breakfast", timeLocation: "Choice of venue: Anchorage Beach, Kakuni Beach, In-Villa Dining, Lagoon Dining or In-Pool Dining", description: "Set the tone to a great day with a curated breakfast experience in the privacy of your own plunge pool or whilst splashing around in the lagoon. Or perhaps a romantic breakfast on the beach is more your style. No matter your preference, we have you covered. Our team is here to ensure you have an unforgettable start to your day in paradise.\nPackage includes:\nChoice of American, Continental or Maldivian\nA bottle of premium champagne (375 ml)", price: "$210 per couple", image: "DestinationDiningChampagneBreakfast.jpg"),
        DestinationDiningItem(title: "HAMACLAND™ BREAKFAST CRUISE", timeLocation: "", description: "HamacLand™ is an innovative waterbased recreational concept for those who enjoy the unconventional. This private floating island offers you unparalleled views of the natural surroundings with an elevated level of comfort.\nPackage includes:\nChoice of American, Continental or Maldivian style\nA bottle of premium champagne (375 ml)\nA private host", price: "$250 per couple", image: "DestinationDiningLagoonLunch.jpg")
    ]),

    DestinationDiningGroup(title: "Sun Lovers", description: "Offered daily from noon to 4pm", image: "", items: [
        DestinationDiningItem(title: "Lagoon Lunch", timeLocation: "12:00 PM Midday to 4:00 PM", description: "LAGOON LUNCH\nThe ideal combination of sun & sea. Enjoy a hearty three-course lunch, barefoot in the calm, turquoise blue waters of the lagoon. Feel the water beneath your feet as you feast on sumptuous treats and soak in the scenic views of your natural surroundings.\nPackage includes:\nYour favorite welcome cocktail 3-course meal curated to your preference\nA bottle of selected red, white or sparkling wine\nPrivate host", price: "$320 per couple", image: "DestinationDiningLagoonLunch.jpg"),
        DestinationDiningItem(title: "HAMACLAND™ LUNCH CRUISE", timeLocation: "", description: "This innovative floating hammock pontoon is suited to those who enjoy the unconventional. This private craft offers you unparalleled views of the natural surroundings with an elevated level of comfort.\nPackage includes:\nYour favorite welcome cocktail\n3-course meal curated to your preference\nA bottle of red, white or sparkling wine\nPrivate host", price: "$385 per couple", image: "DestinationDiningLagoonLunch.jpg"),
        DestinationDiningItem(title: "Sandbank Picnic", timeLocation: "", description: "Quintessentially Maldivian, this iconic experience is by far one of the most popular dining excursions. Often featured on the covers of glossy editorials, this highly personalized trip is known to be the epitome of a true Maldivian vacation. Enjoy spectacular views as you indulge in a generous spread of your favorite dishes.\nPackage includes:\n\nWelcome champagne cocktail\nA tailored 5-course menu created by your very own personal chef\nA bottle of selected red, white or sparkling wine\nPrivate dolphin cruise with champagne & canapés\nPrivate speed boat transfers\nPrivate host", price: "$1,600 per couple", image: "DestinationDiningSandbankPicnic.jpg"),
        DestinationDiningItem(title: "FURANAFUSHI PICNIC", timeLocation: "", description: "Spend your afternoon with a long and relaxing picnic in a secluded location on the island, in your room or on one of the lagoon islets.\nPackage includes:\n\nA bottle of selected red, white or sparkling wine\nA picnic basket tailored your preference complete with cutlery, glassware & picnic blanket", price: "$140 per couple", image: "DestinationDiningLagoonLunch.jpg"),
        DestinationDiningItem(title: "COOKING CLASS", timeLocation: "", description: "Try your hand at cooking up a storm with this interactive cooking class. Choose from Thai, Maldivian or Indian cuisines under the guidance of our experienced culinary team.\nFit for any foodie, package includes:\n\nAn unforgettable ad interactive learning experience\nA bottle of selected red, white or sparkling wine\nAprons with logo and chef’s hat", price: "$295 per couple", image: "DestinationDiningLagoonLunch.jpg")
    ]),

    DestinationDiningGroup(title: "Romantics", description: "Available every day from 4pm to 11pm", image: "", items: [
        DestinationDiningItem(title: "BUBBLY SUNSET ROMANCE", timeLocation: "", description: "This innovative floating hammock pontoon is suited to those who enjoy the unconventional. This private craft offers you unparalleled views of the natural surroundings with an elevated level of comfort.\n\nPackage includes:\n\nCruising the lagoon over sunset\nChoice of selected hot and cold canapés\nA bottle of selected red, white or sparkling wine\nFruit platter\nPrivate host", price: "#310 per couple", image: "DestinationDiningLagoonLunch.jpg"),
        DestinationDiningItem(title: "COCKTAIL MASTERCLASS", timeLocation: "", description: "In this invigorating masterclass, our experienced bartenders will share tips & tricks to creating sumptuous cocktails. A party hit for any occasion.\n\nPackage includes:\n\nSignature Sheraton cocktail recipes\nFun and interactive learnings\nExperienced mixologist", price: "$60 per person", image: "DestinationDiningLagoonLunch.jpg"),
        DestinationDiningItem(title: "DEGUSTATION DINNER", timeLocation: "", description: "A sumptuous 5-course dinner, tailored to your preferences and served in the Sea Salt pavilion, overlooking the lagoon.\n\nPackage includes:\nA curated 5-course meal\nPaired premium wines with each course", price: "$400 per couple", image: "DestinationDiningLagoonLunch.jpg"),
        DestinationDiningItem(title: "DINNER OF DREAMS", timeLocation: "", description: "The ultimate setting for an unforgettable evening. On the beach, surrounded by the scenic beauty of the Maldives, this setting sets the tone for a truly special occasion. Complete with a private serenade by a dedicated musician and a professional photographer to capture every moment.\n\nPackage includes:\n\nA bottle of premium champagne\nSelected hot and cold canapés\nA personalized 5-course dinner\nA bottle of selected red, white or sparkling wine\nPrivate musician to serenade you throughout dinner\nProfessional photographer to capture the evening’s special moments\nIn-Villa or beachside breakfast the following day\nRomantic bed decoration, complete with fruit platter and Baileys\nPrivate host", price: "$1,250 per couple", image: "DestinationDiningLagoonLunch.jpg"),
        DestinationDiningItem(title: "ORIENTAL NIGHT", timeLocation: "", description: "A magical evening under the stars! Set on the beach, in true Ottoman fashion, this evening blends an Arabian themed setting with an Asian inspired menu.\n\nPackage includes:\n\nAsian inspired canapés & entrees\nPersonalized 5-course menu\nA bottle of selected red, white or sparkling wine\nShisha with your choice of tobacco flavor", price: "$550 per couple", image: "DestinationDiningLagoonLunch.jpg"),
        DestinationDiningItem(title: "Bubbles Under The Stars", timeLocation: "", description: "As romantic as it gets! A spectacular beach setting with a fabulous champagne dinner, culminating with a champagne breakfast in the comfort of your room or beachside for those early risers.\n\nPackage includes:\n\nA bottle of premium champagne\nSelected hot and cold canapés\nYour selection of a Thai, Mediterranean,\nMaldivian, Vegetarian or Asian\n5-course menu\nRomantic beach setting\nIn-villa or beachside champagne breakfast the following day\nBed decorations, complete with fruit platter and Baileys\nPrivate host ", price: "$580 per couple", image: "DestinationDiningBubblesUnderTheStars.jpg")
    ]),

    DestinationDiningGroup(title: "Other", description: "", image: "", items: [
        DestinationDiningItem(title: "Private Events", timeLocation: "", description: "Want to host your own private event? Check out our multi-purpose venue Jalsaa, equipped with a private pool and garden", price: "", image: "DestinationDiningPrivateEvents.jpg"),
        DestinationDiningItem(title: "Curated Experiences", timeLocation: "", description: "Have your own vision on what the perfect setting should look like? Let us know. We are here to help create unforgettable moments", price: "", image: "DestinationDiningCuratedExperiences.jpg")
    ])
    ]

    hotel.destinationDining.headline.0 = "Destination Dining"
    hotel.destinationDining.headline.1 = "With its turquoise blue waters, tropical islands and dreamy sunsets, the Maldives have long been an inspiration to many romantics. This overview is a short guide to a curated selection of some of our most popular private culinary journeys on offer."
    hotel.destinationDining.headline.2 = "All packages, unless otherwise stated, are quoted per couple (2 adults) and are inclusive of Service Charge and GST."
}

func initFacilities() {
    
}

//func initRestaurantsFromBundleFiles() {
//    let restaurants: [Restaurant] = loadFromJSON(fileNameNoExt: "sheratonRestaurants")
//    hotel.restaurants = restaurants
//    Log.log(level: .INFO, hotel)
//}
