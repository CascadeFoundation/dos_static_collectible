module dos_static_collectible::static_collectible;

use std::string::String;
use std::type_name::{Self, TypeName};
use sui::event::emit;
use sui::vec_map::{Self, VecMap};

//=== Structs ===

public struct StaticCollectible<phantom T> has store {
    number: u64,
    name: String,
    description: String,
    attributes: VecMap<String, String>,
    image: String,
    animation_url: String,
    external_url: String,
}

//=== Events ===

public struct StaticCollectibleCreatedEvent has copy, drop {
    collectible_type: TypeName,
    collectible_number: u64,
}

public struct StaticCollectibleDestroyedEvent has copy, drop {
    collectible_type: TypeName,
    collectible_number: u64,
}

public struct StaticCollectibleRevealedEvent has copy, drop {
    collectible_type: TypeName,
    collectible_number: u64,
    attribute_keys: vector<String>,
    attribute_values: vector<String>,
}

//=== Constants ===

const EAttributesLengthMismatch: u64 = 10000;

//=== Public Functions ===

// Create a new static StaticCollectible<T>.
//
// The `image` is specified upfront because it can be calculated ahead of time
// without revealing the image. For example, if you're using Walrus for image storage,
// you can use the Walrus CLI to pre-calculate blob IDs to use as image URIs.
// The actual image can be uploaded to Walrus at a later time.
public fun new<T>(
    name: String,
    number: u64,
    description: String,
    image: String,
    animation_url: String,
    external_url: String,
): StaticCollectible<T> {
    let collectible = StaticCollectible<T> {
        number: number,
        name: name,
        description: description,
        image: image,
        animation_url: animation_url,
        external_url: external_url,
        attributes: vec_map::empty(),
    };

    emit(StaticCollectibleCreatedEvent {
        collectible_type: type_name::get<T>(),
        collectible_number: collectible.number,
    });

    collectible
}

public fun destroy<T>(self: StaticCollectible<T>) {
    let StaticCollectible<T> {
        number,
        ..,
    } = self;

    emit(StaticCollectibleDestroyedEvent {
        collectible_type: type_name::get<T>(),
        collectible_number: number,
    });
}

public fun reveal<T>(
    self: &mut StaticCollectible<T>,
    attribute_keys: vector<String>,
    attribute_values: vector<String>,
) {
    assert!(attribute_keys.length() == attribute_values.length(), EAttributesLengthMismatch);

    emit(StaticCollectibleRevealedEvent {
        collectible_type: type_name::get<T>(),
        collectible_number: self.number,
        attribute_keys: attribute_keys,
        attribute_values: attribute_values,
    });

    self.attributes = vec_map::from_keys_values(attribute_keys, attribute_values);
}

public fun name<T>(self: &StaticCollectible<T>): String {
    self.name
}

public fun number<T>(self: &StaticCollectible<T>): u64 {
    self.number
}

public fun description<T>(self: &StaticCollectible<T>): String {
    self.description
}

public fun image<T>(self: &StaticCollectible<T>): String {
    self.image
}

public fun animation_url<T>(self: &StaticCollectible<T>): String {
    self.animation_url
}

public fun external_url<T>(self: &StaticCollectible<T>): String {
    self.external_url
}

public fun attributes<T>(self: &StaticCollectible<T>): VecMap<String, String> {
    self.attributes
}
