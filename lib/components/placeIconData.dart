import 'package:flutter/material.dart';

IconData getPlaceIconData(List<String> types, String placeName) {
  if (types.contains('accounting') || placeName.toLowerCase().contains('accounting')) {
    return Icons.account_balance_wallet;
  } else if (types.contains('airport') || placeName.toLowerCase().contains('airport')) {
    return Icons.local_airport;
  } else if (types.contains('amusement_park') || placeName.toLowerCase().contains('amusement_park')) {
    return Icons.attractions;
  } else if (types.contains('aquarium') || placeName.toLowerCase().contains('aquarium')) {
    return Icons.water;
  } else if (types.contains('art_gallery') || placeName.toLowerCase().contains('art_gallery')) {
    return Icons.art_track;
  } else if (types.contains('atm') || placeName.toLowerCase().contains('atm')) {
    return Icons.atm;
  } else if (types.contains('bakery') || placeName.toLowerCase().contains('bakery')) {
    return Icons.cake;
  } else if (types.contains('bank') || placeName.toLowerCase().contains('bank')) {
    return Icons.account_balance;
  } else if (types.contains('bar') || placeName.toLowerCase().contains('bar')) {
    return Icons.local_bar;
  } else if (types.contains('beauty_salon') || placeName.toLowerCase().contains('beauty_salon')) {
    return Icons.brush;
  } else if (types.contains('bicycle_store') || placeName.toLowerCase().contains('bicycle_store')) {
    return Icons.directions_bike;
  } else if (types.contains('book_store') || placeName.toLowerCase().contains('book_store')) {
    return Icons.book;
  } else if (types.contains('bowling_alley') || placeName.toLowerCase().contains('bowling_alley')) {
    return Icons.rice_bowl;
  } else if (types.contains('bus_station') || placeName.toLowerCase().contains('bus_station')) {
    return Icons.directions_bus;
  } else if (types.contains('cafe') || placeName.toLowerCase().contains('cafe')) {
    return Icons.local_cafe;
  } else if (types.contains('campground') || placeName.toLowerCase().contains('campground')) {
    return Icons.park;
  } else if (types.contains('car_dealer') ||
      placeName.toLowerCase().contains('car_dealer') ||
      placeName.toLowerCase().contains('station')) {
    return Icons.directions_car;
  } else if (types.contains('car_rental') || placeName.toLowerCase().contains('car_rental')) {
    return Icons.car_rental;
  } else if (types.contains('car_repair') || placeName.toLowerCase().contains('car_repair')) {
    return Icons.car_repair;
  } else if (types.contains('car_wash') || placeName.toLowerCase().contains('car_wash')) {
    return Icons.local_car_wash;
  } else if (types.contains('casino') || placeName.toLowerCase().contains('casino')) {
    return Icons.casino;
  } else if (types.contains('cemetery') || placeName.toLowerCase().contains('cemetery')) {
    return Icons.account_balance;
  } else if (types.contains('church') || placeName.toLowerCase().contains('church')) {
    return Icons.church;
  } else if (types.contains('city_hall') || placeName.toLowerCase().contains('city_hall')) {
    return Icons.location_city;
  } else if (types.contains('clothing_store') || placeName.toLowerCase().contains('clothing_store')) {
    return Icons.shopping_bag;
  } else if (types.contains('convenience_store') || placeName.toLowerCase().contains('convenience_store')) {
    return Icons.local_convenience_store;
  } else if (types.contains('courthouse') || placeName.toLowerCase().contains('courthouse')) {
    return Icons.account_balance;
  } else if (types.contains('dentist') || placeName.toLowerCase().contains('dentist')) {
    return Icons.medical_services;
  } else if (types.contains('department_store') || placeName.toLowerCase().contains('department_store')) {
    return Icons.store;
  } else if (types.contains('doctor') || placeName.toLowerCase().contains('doctor')) {
    return Icons.local_hospital;
  } else if (types.contains('electrician') || placeName.toLowerCase().contains('electrician')) {
    return Icons.electrical_services;
  } else if (types.contains('electronics_store') || placeName.toLowerCase().contains('electronics_store')) {
    return Icons.electrical_services;
  } else if (types.contains('embassy') || placeName.toLowerCase().contains('embassy')) {
    return Icons.account_balance;
  } else if (types.contains('fire_station') || placeName.toLowerCase().contains('fire_station')) {
    return Icons.local_fire_department;
  } else if (types.contains('florist') || placeName.toLowerCase().contains('florist')) {
    return Icons.local_florist;
  } else if (types.contains('funeral_home') || placeName.toLowerCase().contains('funeral_home')) {
    return Icons.account_balance;
  } else if (types.contains('furniture_store') || placeName.toLowerCase().contains('furniture_store')) {
    return Icons.chair;
  } else if (types.contains('gas_station') || placeName.toLowerCase().contains('gas_station')) {
    return Icons.local_gas_station;
  } else if (types.contains('gym') || placeName.toLowerCase().contains('gym')) {
    return Icons.fitness_center;
  } else if (types.contains('hair_care') || placeName.toLowerCase().contains('hair_care')) {
    return Icons.content_cut;
  } else if (types.contains('hardware_store') || placeName.toLowerCase().contains('hardware_store')) {
    return Icons.build;
  } else if (types.contains('hindu_temple') || placeName.toLowerCase().contains('hindu_temple')) {
    return Icons.temple_hindu;
  } else if (types.contains('home_goods_store') || placeName.toLowerCase().contains('home_goods_store')) {
    return Icons.home;
  } else if (types.contains('hospital') || placeName.toLowerCase().contains('hospital')) {
    return Icons.local_hospital;
  } else if (types.contains('insurance_agency') || placeName.toLowerCase().contains('insurance_agency')) {
    return Icons.policy;
  } else if (types.contains('jewelry_store') || placeName.toLowerCase().contains('jewelry_store')) {
    return Icons.diamond;
  } else if (types.contains('laundry') || placeName.toLowerCase().contains('laundry')) {
    return Icons.local_laundry_service;
  } else if (types.contains('lawyer') || placeName.toLowerCase().contains('lawyer')) {
    return Icons.gavel;
  } else if (types.contains('library') || placeName.toLowerCase().contains('library')) {
    return Icons.local_library;
  } else if (types.contains('light_rail_station') || placeName.toLowerCase().contains('light_rail_station')) {
    return Icons.tram;
  } else if (types.contains('liquor_store') || placeName.toLowerCase().contains('liquor_store')) {
    return Icons.local_bar;
  } else if (types.contains('local_government_office') || placeName.toLowerCase().contains('local_government_office')) {
    return Icons.account_balance;
  } else if (types.contains('locksmith') || placeName.toLowerCase().contains('locksmith')) {
    return Icons.lock;
  } else if (types.contains('lodging') || placeName.toLowerCase().contains('lodging')) {
    return Icons.hotel;
  } else if (types.contains('meal_delivery') || placeName.toLowerCase().contains('meal_delivery')) {
    return Icons.delivery_dining;
  } else if (types.contains('meal_takeaway') || placeName.toLowerCase().contains('meal_takeaway')) {
    return Icons.takeout_dining;
  } else if (types.contains('mosque') || placeName.toLowerCase().contains('mosque')) {
    return Icons.mosque;
  } else if (types.contains('movie_rental') || placeName.toLowerCase().contains('movie_rental')) {
    return Icons.movie;
  } else if (types.contains('movie_theater') || placeName.toLowerCase().contains('movie_theater')) {
    return Icons.movie;
  } else if (types.contains('moving_company') || placeName.toLowerCase().contains('moving_company')) {
    return Icons.local_shipping;
  } else if (types.contains('museum') || placeName.toLowerCase().contains('museum')) {
    return Icons.museum;
  } else if (types.contains('night_club') || placeName.toLowerCase().contains('night_club')) {
    return Icons.nightlife;
  } else if (types.contains('painter') || placeName.toLowerCase().contains('painter')) {
    return Icons.format_paint;
  } else if (types.contains('park') || placeName.toLowerCase().contains('park')) {
    return Icons.park;
  } else if (types.contains('parking') || placeName.toLowerCase().contains('parking')) {
    return Icons.local_parking;
  } else if (types.contains('pet_store') || placeName.toLowerCase().contains('pet_store')) {
    return Icons.pets;
  } else if (types.contains('pharmacy') || placeName.toLowerCase().contains('pharmacy')) {
    return Icons.local_pharmacy;
  } else if (types.contains('physiotherapist') || placeName.toLowerCase().contains('physiotherapist')) {
    return Icons.accessibility;
  } else if (types.contains('plumber') || placeName.toLowerCase().contains('plumber')) {
    return Icons.plumbing;
  } else if (types.contains('police') || placeName.toLowerCase().contains('police')) {
    return Icons.local_police;
  } else if (types.contains('post_office') || placeName.toLowerCase().contains('post_office')) {
    return Icons.local_post_office;
  } else if (types.contains('primary_school') || placeName.toLowerCase().contains('primary_school')) {
    return Icons.school;
  } else if (types.contains('real_estate_agency') || placeName.toLowerCase().contains('real_estate_agency')) {
    return Icons.real_estate_agent;
  } else if (types.contains('restaurant') || placeName.toLowerCase().contains('restaurant')) {
    return Icons.restaurant;
  } else if (types.contains('roofing_contractor') || placeName.toLowerCase().contains('roofing_contractor')) {
    return Icons.roofing;
  } else if (types.contains('rv_park') || placeName.toLowerCase().contains('rv_park')) {
    return Icons.rv_hookup;
  } else if (types.contains('school') || placeName.toLowerCase().contains('school')) {
    return Icons.school;
  } else if (types.contains('secondary_school') || placeName.toLowerCase().contains('secondary_school')) {
    return Icons.school;
  } else if (types.contains('shoe_store') || placeName.toLowerCase().contains('shoe_store')) {
    return Icons.shopping_bag;
  } else if (types.contains('shopping_mall') || placeName.toLowerCase().contains('shopping_mall')) {
    return Icons.shopping_bag;
  } else if (types.contains('spa') || placeName.toLowerCase().contains('spa')) {
    return Icons.spa;
  } else if (types.contains('stadium') || placeName.toLowerCase().contains('stadium')) {
    return Icons.sports_soccer;
  } else if (types.contains('storage') || placeName.toLowerCase().contains('storage')) {
    return Icons.storage;
  } else if (types.contains('store') || placeName.toLowerCase().contains('store')) {
    return Icons.store;
  } else if (types.contains('subway_station') || placeName.toLowerCase().contains('subway_station')) {
    return Icons.subway;
  } else if (types.contains('supermarket') || placeName.toLowerCase().contains('supermarket')) {
    return Icons.local_grocery_store;
  } else if (types.contains('synagogue') || placeName.toLowerCase().contains('synagogue')) {
    return Icons.synagogue;
  } else if (types.contains('taxi_stand') || placeName.toLowerCase().contains('taxi_stand')) {
    return Icons.local_taxi;
  } else if (types.contains('tourist_attraction') || placeName.toLowerCase().contains('tourist_attraction')) {
    return Icons.attractions;
  } else if (types.contains('train_station') || placeName.toLowerCase().contains('train_station')) {
    return Icons.train;
  } else if (types.contains('transit_station') || placeName.toLowerCase().contains('transit_station')) {
    return Icons.directions_transit;
  } else if (types.contains('travel_agency') || placeName.toLowerCase().contains('travel_agency')) {
    return Icons.card_travel;
  } else if (types.contains('university') || placeName.toLowerCase().contains('university')) {
    return Icons.account_balance_outlined;
  } else if (types.contains('veterinary_care') || placeName.toLowerCase().contains('veterinary_care')) {
    return Icons.local_hospital;
  } else if (types.contains('zoo') || placeName.toLowerCase().contains('zoo')) {
    return Icons.pets;
  } else {
    return Icons.place;
  }
}
